/// Table 10: BookingItem
class BookingItem {
  final String itemId;
  final String bookingId;
  final String materialType;
  final double confidenceScore;
  final String bbox;
  final double estimatedWeightKg;
  final double actualWeightKg;

  const BookingItem({required this.itemId, required this.bookingId,
      required this.materialType, this.confidenceScore = 0.0,
      this.bbox = '', this.estimatedWeightKg = 0.0, this.actualWeightKg = 0.0});

  factory BookingItem.fromMap(String id, Map<String, dynamic> m) => BookingItem(
    itemId: m['Item_ID'] ?? id,
    bookingId: m['Booking_ID'] ?? '',
    materialType: m['MaterialType'] ?? '',
    confidenceScore: (m['ConfidenceScore'] ?? 0).toDouble(),
    bbox: m['BBox'] ?? '',
    estimatedWeightKg: (m['EstimatedWeightKg'] ?? 0).toDouble(),
    actualWeightKg: (m['ActualWeightKg'] ?? 0).toDouble(),
  );
}
