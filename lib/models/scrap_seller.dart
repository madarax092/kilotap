class ScrapSeller {
  final String sellerId;
  final String accountId;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String preferredSchedule;
  final DateTime? createdAt;

  const ScrapSeller({
    required this.sellerId,
    required this.accountId,
    required this.fullName,
    this.phone = '',
    this.email = '',
    required this.address,
    this.preferredSchedule = 'ASAP',
    this.createdAt,
  });

  factory ScrapSeller.fromMap(Map<String, dynamic> m) => ScrapSeller(
    sellerId: m['Seller_Id'] ?? '',
    accountId: m['Account_Id'] ?? '',
    fullName: m['Full_Name'] ?? '',
    phone: m['Phone'] ?? '',
    email: m['Email'] ?? '',
    address: m['Address'] ?? '',
    preferredSchedule: m['Preferred_Schedule'] ?? 'ASAP',
    createdAt: (m['Created_At'] as dynamic)?.toDate(),
  );

  Map<String, dynamic> toMap() => {
    'Seller_Id': sellerId,
    'Account_Id': accountId,
    'Full_Name': fullName,
    'Phone': phone,
    'Email': email,
    'Address': address,
    'Preferred_Schedule': preferredSchedule,
    'Created_At': createdAt,
  };
}
