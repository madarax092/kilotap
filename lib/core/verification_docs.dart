// The verification documents a collector provides (Table 9,
// Verification_Docs entries), the same set for every vehicle type — a
// pushcart has no LTO papers, so vehicle registration documents are not
// required. Order is the display order.
const List<String> requiredVerificationDocTypes = [
  'Valid ID',
  'Vehicle Photo',
];

// Optional: an admin can verify a collector without it. When uploaded and
// approved, the collector earns the "Barangay Cleared" badge households see.
const String barangayClearanceDocType = 'Barangay Clearance';
const List<String> optionalVerificationDocTypes = [barangayClearanceDocType];

const List<String> allVerificationDocTypes = [
  ...requiredVerificationDocTypes,
  ...optionalVerificationDocTypes,
];

bool isOptionalVerificationDoc(String type) =>
    optionalVerificationDocTypes.contains(type);

// Document types that were required before and have since been replaced.
// An old upload is not a valid substitute for a different document, so
// these are dropped rather than renamed.
const List<String> _retiredVerificationDocTypes = [
  'Profile Photo Match',
  'Car Registration',
  'Official Receipt',
];

List<Map<String, dynamic>> emptyVerificationDocs() => [
      for (final t in allVerificationDocTypes)
        {'type': t, 'url': '', 'status': 'pending'},
    ];

// Brings a collector's stored docs array up to the current set: removes
// retired types and adds any type they don't have yet, so accounts
// registered before a change still get the new upload slots.
List<Map<String, dynamic>> normalizeVerificationDocs(
    List<Map<String, dynamic>> docs) {
  final kept = docs
      .where((d) => !_retiredVerificationDocTypes.contains(d['type']))
      .toList();
  for (final t in allVerificationDocTypes) {
    if (!kept.any((d) => d['type'] == t)) {
      kept.add({'type': t, 'url': '', 'status': 'pending'});
    }
  }
  return kept;
}

Map<String, dynamic>? verificationDocOf(
    List<Map<String, dynamic>> docs, String type) {
  for (final d in docs) {
    if (d['type'] == type) return d;
  }
  return null;
}

bool isDocUploaded(Map<String, dynamic>? doc) =>
    ((doc?['url'] as String?) ?? '').isNotEmpty;

/// Required document types the collector has not uploaded yet.
List<String> missingRequiredDocs(List<Map<String, dynamic>> docs) => [
      for (final t in requiredVerificationDocTypes)
        if (!isDocUploaded(verificationDocOf(docs, t))) t,
    ];

/// True when an admin approved the optional Barangay Clearance. Read from
/// ScrapCollector.Barangay_Cleared (not in Table 9), which only an admin can
/// set (firestore.rules) — the collector writes their own Verification_Docs
/// array, so a status there could be self-awarded.
bool hasBarangayClearance(Map<String, dynamic>? collectorProfile) =>
    collectorProfile?['Barangay_Cleared'] == true;

/// An uploaded Barangay Clearance still waiting for an admin decision.
bool barangayClearanceAwaitingReview(List<Map<String, dynamic>> docs) {
  final d = verificationDocOf(docs, barangayClearanceDocType);
  return isDocUploaded(d) &&
      ((d?['status'] as String?) ?? 'pending').toLowerCase() == 'pending';
}

List<Map<String, dynamic>> verificationDocsFrom(Map<String, dynamic>? profile) =>
    (profile?['Verification_Docs'] as List<dynamic>? ?? const [])
        .map((d) => Map<String, dynamic>.from(d as Map))
        .toList();
