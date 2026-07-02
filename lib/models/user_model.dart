import 'package:cloud_firestore/cloud_firestore.dart';

/// User roles in KiloTap
enum UserRole { seller, buyer, admin }

/// KiloTap User model — core account only
/// Collector-specific fields moved to CollectorModel
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String address;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSeller => role == UserRole.seller;
  bool get isBuyer => role == UserRole.buyer;
  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      role: _parseRole(data['role']),
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role.name,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'buyer': return UserRole.buyer;
      case 'admin': return UserRole.admin;
      default: return UserRole.seller;
    }
  }
}
