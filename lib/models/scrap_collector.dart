import 'package:cloud_firestore/cloud_firestore.dart';

/// Table 8: ScrapCollector (subcollection of UserAccount)
class VerificationDoc {
  final String type;
  final String url;
  final String status;
  const VerificationDoc({required this.type, this.url = '', this.status = 'pending'});
  factory VerificationDoc.fromMap(Map<String, dynamic> m) => VerificationDoc(
    type: m['type'] ?? '', url: m['url'] ?? '', status: m['status'] ?? 'pending');
  Map<String, dynamic> toMap() => {'type': type, 'url': url, 'status': status};
}

class ScrapCollector {
  final String collectorId;
  final String accountId;
  final String fullName;
  final String vehicleType;
  final double vehicleCapacityKg;
  final String verificationStatus;
  final List<VerificationDoc> verificationDocs;
  final String digitalBadgeUrl;
  final bool onlineStatus;
  final List<String> preferredMaterials;
  final GeoPoint? currentGps;
  final double avgRating;

  const ScrapCollector({
    required this.collectorId, required this.accountId, required this.fullName,
    required this.vehicleType, required this.vehicleCapacityKg,
    this.verificationStatus = 'Pending', this.verificationDocs = const [],
    this.digitalBadgeUrl = '', this.onlineStatus = false,
    this.preferredMaterials = const [],
    this.currentGps, this.avgRating = 0.0,
  });

  factory ScrapCollector.fromMap(Map<String, dynamic> m) => ScrapCollector(
    collectorId: m['Collector_ID'] ?? '',
    accountId: m['Account_Id'] ?? '',
    fullName: m['FullName'] ?? '',
    vehicleType: m['VehicleType'] ?? '',
    vehicleCapacityKg: (m['VehicleCapacityKg'] ?? 0).toDouble(),
    verificationStatus: m['VerificationStatus'] ?? 'Pending',
    verificationDocs: (m['VerificationDocs'] as List<dynamic>? ?? [])
        .map((v) => VerificationDoc.fromMap(v as Map<String, dynamic>)).toList(),
    digitalBadgeUrl: m['DigitalBadgeURL'] ?? '',
    onlineStatus: m['OnlineStatus'] ?? false,
    preferredMaterials: List<String>.from(m['PreferredMaterials'] ?? []),
    currentGps: m['CurrentGPS'] as GeoPoint?,
    avgRating: (m['AvgRating'] ?? 0).toDouble(),
  );
}
