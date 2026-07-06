/// Table 11: Rating
class Rating {
  final String ratingId;
  final String bookingId;
  final int score;
  final String feedbackText;

  const Rating({required this.ratingId, required this.bookingId,
      this.score = 0, this.feedbackText = ''});

  factory Rating.fromMap(String id, Map<String, dynamic> m) => Rating(
    ratingId: m['Rating_ID'] ?? id,
    bookingId: m['Booking_ID'] ?? '',
    score: m['Score'] ?? 0,
    feedbackText: m['FeedbackText'] ?? '',
  );
}
