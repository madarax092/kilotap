/// Table 7: ScrapSeller (subcollection of UserAccount)
class ScrapSeller {
  final String sellerId;
  final String accountId;
  final String fullName;
  final String address;

  const ScrapSeller({required this.sellerId, required this.accountId,
      required this.fullName, required this.address});

  factory ScrapSeller.fromMap(Map<String, dynamic> m) => ScrapSeller(
    sellerId: m['Seller_Id'] ?? '',
    accountId: m['Account_Id'] ?? '',
    fullName: m['FullName'] ?? '',
    address: m['Address'] ?? '',
  );
}
