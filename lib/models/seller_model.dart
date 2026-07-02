import 'package:cloud_firestore/cloud_firestore.dart';

/// tblScrapSeller — Unified user account for all roles (Household, Collector, Admin)
/// Firestore: 'sellers' collection, doc ID = Seller_ID
class SellerModel {
  final String sellerId;
  final String authUid;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'Household', 'Collector', 'Admin'
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerModel({
    required this.sellerId,
    required this.authUid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isHousehold => role == 'Household';
  bool get isCollector => role == 'Collector';
  bool get isAdmin => role == 'Admin';

  factory SellerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SellerModel(
      sellerId: doc.id,
      authUid: data['Auth_UID'] ?? '',
      fullName: data['FullName'] ?? '',
      email: data['Email'] ?? '',
      phone: data['Phone'] ?? '',
      role: data['Role'] ?? 'Household',
      createdAt: (data['Created_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['Updated_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Auth_UID': authUid,
      'FullName': fullName,
      'Email': email,
      'Phone': phone,
      'Role': role,
      'Created_At': Timestamp.fromDate(createdAt),
      'Updated_At': Timestamp.fromDate(updatedAt),
    };
  }
}
