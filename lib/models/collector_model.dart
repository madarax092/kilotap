import 'package:cloud_firestore/cloud_firestore.dart';

/// Verification status for collector profiles
enum VerificationStatus { pending, verified, rejected, revoked }

/// Collector model — extended profile for buyer users
/// Stored in 'collectors' collection, doc ID = userId
class CollectorModel {
  final String userId;
  final String vehicleType;
  final double vehicleCapacityKg;
  final VerificationStatus verificationStatus;
  final Map<String, String>? verificationDocs; // {barangayClearance, validID, vehiclePhoto, profilePhoto}
  final String? digitalBadgeURL;
  final bool onlineStatus;
  final GeoPoint? currentGPS;
  final double avgRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollectorModel({
    required this.userId,
    required this.vehicleType,
    required this.vehicleCapacityKg,
    this.verificationStatus = VerificationStatus.pending,
    this.verificationDocs,
    this.digitalBadgeURL,
    this.onlineStatus = false,
    this.currentGPS,
    this.avgRating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  String get verificationStatusLabel {
    switch (verificationStatus) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.revoked:
        return 'Revoked';
      default:
        return 'Pending';
    }
  }

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  factory CollectorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectorModel(
      userId: doc.id,
      vehicleType: data['vehicleType'] ?? '',
      vehicleCapacityKg: (data['vehicleCapacityKg'] as num?)?.toDouble() ?? 0.0,
      verificationStatus: _parseStatus(data['verificationStatus']),
      verificationDocs: data['verificationDocs'] != null
          ? Map<String, String>.from(data['verificationDocs'])
          : null,
      digitalBadgeURL: data['digitalBadgeURL'],
      onlineStatus: data['onlineStatus'] ?? false,
      currentGPS: data['currentGPS'] as GeoPoint?,
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vehicleType': vehicleType,
      'vehicleCapacityKg': vehicleCapacityKg,
      'verificationStatus': verificationStatus.name,
      'verificationDocs': verificationDocs,
      'digitalBadgeURL': digitalBadgeURL,
      'onlineStatus': onlineStatus,
      'currentGPS': currentGPS,
      'avgRating': avgRating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static VerificationStatus _parseStatus(String? status) {
    switch (status) {
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'revoked':
        return VerificationStatus.revoked;
      default:
        return VerificationStatus.pending;
    }
  }
}
