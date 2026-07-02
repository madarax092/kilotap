import 'package:cloud_firestore/cloud_firestore.dart';

/// Subdivision/gated community access clearance for verified collectors
/// Stored in 'subdivisionAccess' collection
enum AccessStatus { granted, pending, denied, revoked }

class SubdivisionAccessModel {
  final String id;
  final String collectorId;
  final String subdivisionName;
  final AccessStatus accessStatus;
  final String? digitalIDToken;
  final String? qrCodeURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubdivisionAccessModel({
    required this.id,
    required this.collectorId,
    required this.subdivisionName,
    this.accessStatus = AccessStatus.pending,
    this.digitalIDToken,
    this.qrCodeURL,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isGranted => accessStatus == AccessStatus.granted;

  String get accessStatusLabel {
    switch (accessStatus) {
      case AccessStatus.granted:
        return 'Granted';
      case AccessStatus.denied:
        return 'Denied';
      case AccessStatus.revoked:
        return 'Revoked';
      default:
        return 'Pending';
    }
  }

  factory SubdivisionAccessModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubdivisionAccessModel(
      id: doc.id,
      collectorId: data['collectorId'] ?? '',
      subdivisionName: data['subdivisionName'] ?? '',
      accessStatus: _parseStatus(data['accessStatus']),
      digitalIDToken: data['digitalIDToken'],
      qrCodeURL: data['qrCodeURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'collectorId': collectorId,
      'subdivisionName': subdivisionName,
      'accessStatus': accessStatus.name,
      'digitalIDToken': digitalIDToken,
      'qrCodeURL': qrCodeURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static AccessStatus _parseStatus(String? status) {
    switch (status) {
      case 'granted':
        return AccessStatus.granted;
      case 'denied':
        return AccessStatus.denied;
      case 'revoked':
        return AccessStatus.revoked;
      default:
        return AccessStatus.pending;
    }
  }
}
