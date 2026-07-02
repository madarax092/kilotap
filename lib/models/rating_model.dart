import 'package:cloud_firestore/cloud_firestore.dart';

/// tblRating — Post-booking collector rating
/// Firestore: 'ratings' collection
class RatingModel {
  final String ratingId;
  final String bookingId; // FK → tblBooking
  final int score;        // 1–5 stars
  final String? feedbackText;
  final DateTime createdAt;

  const RatingModel({
    required this.ratingId,
    required this.bookingId,
    required this.score,
    this.feedbackText,
    required this.createdAt,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      ratingId: doc.id,
      bookingId: data['Booking_ID'] ?? '',
      score: data['Score'] ?? 0,
      feedbackText: data['FeedbackText'],
      createdAt: (data['Created_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'Booking_ID': bookingId,
    'Score': score,
    'FeedbackText': feedbackText,
    'Created_At': Timestamp.fromDate(createdAt),
  };
}
