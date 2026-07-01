import 'package:cloud_firestore/cloud_firestore.dart';

/// User roles in KiloTap
enum UserRole { seller, buyer }

/// Seller account types
enum SellerAccountType { individual, business }

/// KiloTap User model — covers both Seller and Buyer
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String address;
  final UserRole role;
  final SellerAccountType? accountType; // Seller only
  final bool isVerified; // Buyer only
  final String? areaOfOperation; // Buyer only
  final List<VehicleInfo> vehicles; // Buyer only
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
    this.accountType,
    this.isVerified = false,
    this.areaOfOperation,
    this.vehicles = const [],
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSeller => role == UserRole.seller;
  bool get isBuyer => role == UserRole.buyer;

  String get accountTypeLabel {
    switch (accountType) {
      case SellerAccountType.individual:
        return 'Individual / Household';
      case SellerAccountType.business:
        return 'Business / Organization';
      default:
        return '';
    }
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      role: data['role'] == 'seller' ? UserRole.seller : UserRole.buyer,
      accountType: data['accountType'] == 'individual'
          ? SellerAccountType.individual
          : data['accountType'] == 'business'
              ? SellerAccountType.business
              : null,
      isVerified: data['isVerified'] ?? false,
      areaOfOperation: data['areaOfOperation'],
      vehicles: (data['vehicles'] as List<dynamic>? ?? [])
          .map((v) => VehicleInfo.fromMap(v as Map<String, dynamic>))
          .toList(),
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
      'role': role == UserRole.seller ? 'seller' : 'buyer',
      'accountType': accountType == SellerAccountType.individual
          ? 'individual'
          : accountType == SellerAccountType.business
              ? 'business'
              : null,
      'isVerified': isVerified,
      'areaOfOperation': areaOfOperation,
      'vehicles': vehicles.map((v) => v.toMap()).toList(),
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? address,
    SellerAccountType? accountType,
    bool? isVerified,
    String? areaOfOperation,
    List<VehicleInfo>? vehicles,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role,
      accountType: accountType ?? this.accountType,
      isVerified: isVerified ?? this.isVerified,
      areaOfOperation: areaOfOperation ?? this.areaOfOperation,
      vehicles: vehicles ?? this.vehicles,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Buyer vehicle information
class VehicleInfo {
  final String type;
  final String model;
  final String plateNumber;

  const VehicleInfo({
    required this.type,
    required this.model,
    required this.plateNumber,
  });

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      type: map['type'] ?? '',
      model: map['model'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'model': model,
      'plateNumber': plateNumber,
    };
  }

  String get displayLabel => '$type · $plateNumber';
}
