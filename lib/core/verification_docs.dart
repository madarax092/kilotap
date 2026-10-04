// The verification documents every collector must provide (Table 9,
// Verification_Docs entries), the same set for every vehicle type — a
// pushcart has no LTO papers, so vehicle registration documents are not
// required. Order is the display order.
const List<String> requiredVerificationDocTypes = [
  'Valid ID',
  'Vehicle Photo',
  'Barangay Clearance',
];

// Document types that were required before and have since been replaced.
// An old upload is not a valid substitute for a different document, so
// these are dropped rather than renamed.
const List<String> _retiredVerificationDocTypes = [
  'Profile Photo Match',
  'Car Registration',
  'Official Receipt',
];

List<Map<String, dynamic>> emptyVerificationDocs() => [
      for (final t in requiredVerificationDocTypes)
        {'type': t, 'url': '', 'status': 'pending'},
    ];

// Brings a collector's stored docs array up to the current required set:
// removes retired types and adds any required type they don't have yet, so
// accounts registered before a change still get the new upload slots.
List<Map<String, dynamic>> normalizeVerificationDocs(
    List<Map<String, dynamic>> docs) {
  final kept = docs
      .where((d) => !_retiredVerificationDocTypes.contains(d['type']))
      .toList();
  for (final t in requiredVerificationDocTypes) {
    if (!kept.any((d) => d['type'] == t)) {
      kept.add({'type': t, 'url': '', 'status': 'pending'});
    }
  }
  return kept;
}
