/// Table 9: Scrap Collector (subcollection of UserAccount)
class VerificationDoc {
  final String type;
  final String url;
  final String status;

  const VerificationDoc({required this.type, this.url = '', this.status = 'pending'});

  factory VerificationDoc.fromMap(Map<String, dynamic> m) => VerificationDoc(
    type: m['type'] ?? '',
    url: m['url'] ?? '',
    status: m['status'] ?? 'pending',
  );

  Map<String, dynamic> toMap() => {'type': type, 'url': url, 'status': status};
}

class ScrapCollector {
  final String collectorId;
  final String accountId;
  final String fullName;
  final String vehicleType;
  final double vehicleCapacityKg;
  final List<String> preferredMaterials;
  final String verificationStatus;
  final List<VerificationDoc> verificationDocs;
  final String digitalBadgeUrl;
  final double avgRating;
  final double currentLatitude;
  final double currentLongitude;
  final bool onlineStatus;

  const ScrapCollector({
    required this.collectorId,
    required this.accountId,
    required this.fullName,
    required this.vehicleType,
    required this.vehicleCapacityKg,
    this.preferredMaterials = const [],
    this.verificationStatus = 'Pending',
    this.verificationDocs = const [],
    this.digitalBadgeUrl = '',
    this.avgRating = 0.0,
    this.currentLatitude = 0.0,
    this.currentLongitude = 0.0,
    this.onlineStatus = false,
  });

  factory ScrapCollector.fromMap(Map<String, dynamic> m) => ScrapCollector(
    collectorId: m['Collector_ID'] ?? '',
    accountId: m['Account_Id'] ?? '',
    fullName: m['Full_Name'] ?? '',
    vehicleType: m['Vehicle_Type'] ?? '',
    vehicleCapacityKg: (m['Vehicle_Capacity_Kg'] ?? 0).toDouble(),
    preferredMaterials: List<String>.from(m['Preferred_Materials'] ?? []),
    verificationStatus: m['Verification_Status'] ?? 'Pending',
    verificationDocs: (m['Verification_Docs'] as List<dynamic>? ?? [])
        .map((v) => VerificationDoc.fromMap(v as Map<String, dynamic>))
        .toList(),
    digitalBadgeUrl: m['Digital_Badge_URL'] ?? '',
    avgRating: (m['Avg_Rating'] ?? 0).toDouble(),
    currentLatitude: (m['Current_Latitude'] ?? 0).toDouble(),
    currentLongitude: (m['Current_Longitude'] ?? 0).toDouble(),
    onlineStatus: m['Online_Status'] ?? false,
  );
}
