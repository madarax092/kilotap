/// Table 8: Scrap Seller (subcollection of UserAccount)
class ScrapSeller {
  final String sellerId;
  final String accountId;
  final String fullName;
  final String address;
  final String housingType;
  final String preferredSchedule;
  final DateTime? createdAt;

  const ScrapSeller({
    required this.sellerId,
    required this.accountId,
    required this.fullName,
    required this.address,
    this.housingType = '',
    this.preferredSchedule = 'ASAP',
    this.createdAt,
  });

  factory ScrapSeller.fromMap(Map<String, dynamic> m) => ScrapSeller(
    sellerId: m['Seller_Id'] ?? '',
    accountId: m['Account_Id'] ?? '',
    fullName: m['Full_Name'] ?? '',
    address: m['Address'] ?? '',
    housingType: m['Housing_Type'] ?? '',
    preferredSchedule: m['Preferred_Schedule'] ?? 'ASAP',
    createdAt: (m['Created_At'] as dynamic)?.toDate(),
  );
}
