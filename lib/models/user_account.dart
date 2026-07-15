import 'package:cloud_firestore/cloud_firestore.dart';

/// Table 7: UserAccount
class UserAccount {
  final String accountId;
  final String authUid;
  final String displayName;
  final String email;
  final String phone;
  final String role;
  final DateTime createdAt;

  const UserAccount({
    required this.accountId,
    required this.authUid,
    this.displayName = '',
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory UserAccount.fromMap(String id, Map<String, dynamic> m) => UserAccount(
    accountId: m['Account_Id'] ?? id,
    authUid: m['Auth_UID'] ?? '',
    displayName: m['Display_Name'] ?? '',
    email: m['Email'] ?? '',
    phone: m['Phone'] ?? '',
    role: m['Role'] ?? 'Household',
    createdAt: (m['Created_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  bool get isHousehold => role == 'Household';
  bool get isCollector => role == 'Collector';
  bool get isAdmin => role == 'Admin';
}
