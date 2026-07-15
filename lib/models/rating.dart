/// Table 13: Rating
class Rating {
  final String ratingId;
  final String bookingId;
  final String sellerId;
  final String collectorId;
  final int score;
  final String feedbackText;
  final List<String> tags;
  final DateTime? createdAt;

  const Rating({
    required this.ratingId,
    required this.bookingId,
    this.sellerId = '',
    this.collectorId = '',
    this.score = 0,
    this.feedbackText = '',
    this.tags = const [],
    this.createdAt,
  });

  factory Rating.fromMap(String id, Map<String, dynamic> m) => Rating(
    ratingId: m['Rating_ID'] ?? id,
    bookingId: m['Booking_ID'] ?? '',
    sellerId: m['Seller_ID'] ?? '',
    collectorId: m['Collector_ID'] ?? '',
    score: m['Score'] ?? 0,
    feedbackText: m['Feedback_Text'] ?? '',
    tags: List<String>.from(m['Tags'] ?? []),
    createdAt: (m['Created_At'] as dynamic)?.toDate(),
  );
}
