import 'package:cloud_firestore/cloud_firestore.dart';

/// tblScrapCollector — Extended profile for collectors
/// Firestore: 'collectors' collection, doc ID = Collector_ID
class CollectorModel {
  final String collectorId;
  final String sellerId; // FK → tblScrapSeller.Seller_ID
  final String vehicleType;
  final double vehicleCapacityKg;
  final String verificationStatus; // Pending, Verified, Rejected
  final String? verificationDocs; // Cloud storage URL
  final String? digitalBadgeURL;
  final bool onlineStatus;
  final GeoPoint? currentGPS;
  final double avgRating; // defaults 5.00
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollectorModel({
    required this.collectorId,
    required this.sellerId,
    required this.vehicleType,
    required this.vehicleCapacityKg,
    this.verificationStatus = 'Pending',
    this.verificationDocs,
    this.digitalBadgeURL,
    this.onlineStatus = false,
    this.currentGPS,
    this.avgRating = 5.0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isVerified => verificationStatus == 'Verified';

  factory CollectorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectorModel(
      collectorId: doc.id,
      sellerId: data['Seller_ID'] ?? '',
      vehicleType: data['VehicleType'] ?? '',
      vehicleCapacityKg: (data['VehicleCapacityKg'] as num?)?.toDouble() ?? 0.0,
      verificationStatus: data['VerificationStatus'] ?? 'Pending',
      verificationDocs: data['VerificationDocs'],
      digitalBadgeURL: data['DigitalBadgeURL'],
      onlineStatus: data['OnlineStatus'] ?? false,
      currentGPS: data['CurrentGPS'] as GeoPoint?,
      avgRating: (data['AvgRating'] as num?)?.toDouble() ?? 5.0,
      createdAt: (data['Created_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['Updated_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Seller_ID': sellerId,
      'VehicleType': vehicleType,
      'VehicleCapacityKg': vehicleCapacityKg,
      'VerificationStatus': verificationStatus,
      'VerificationDocs': verificationDocs,
      'DigitalBadgeURL': digitalBadgeURL,
      'OnlineStatus': onlineStatus,
      'CurrentGPS': currentGPS,
      'AvgRating': avgRating,
      'Created_At': Timestamp.fromDate(createdAt),
      'Updated_At': Timestamp.fromDate(updatedAt),
    };
  }
}
