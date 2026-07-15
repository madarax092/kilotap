/// Table 11: BookingItem (subcollection of Booking)
class BookingItem {
  final String itemId;
  final String bookingId;
  final String itemName;
  final int quantity;
  final String sizeClass;
  final double estimatedWeightKg;
  final String scrapClass;

  const BookingItem({
    required this.itemId,
    required this.bookingId,
    required this.itemName,
    this.quantity = 1,
    this.sizeClass = 'Small',
    this.estimatedWeightKg = 0.0,
    this.scrapClass = '',
  });

  factory BookingItem.fromMap(String id, Map<String, dynamic> m) => BookingItem(
    itemId: m['Item_ID'] ?? id,
    bookingId: m['Booking_ID'] ?? '',
    itemName: m['ItemName'] ?? '',
    quantity: m['Quantity'] ?? 1,
    sizeClass: m['SizeClass'] ?? 'Small',
    estimatedWeightKg: (m['EstimatedWeightKg'] ?? 0).toDouble(),
    scrapClass: m['ScrapClass'] ?? '',
  );
}
