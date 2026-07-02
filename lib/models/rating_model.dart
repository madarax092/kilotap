import 'package:cloud_firestore/cloud_firestore.dart';

/// Post-booking rating submitted by household for a collector
/// Stored in 'ratings' collection
class RatingModel {
  final String id;
  final String bookingId;
  final String userId; // household who rated
  final String collectorId; // collector being rated
  final int score; // 1-5
  final List<String> categories; // ['On_Time', 'Professional', etc.]
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.collectorId,
    required this.score,
    this.categories = const [],
    required this.createdAt,
  });

  static const List<String> availableCategories = [
    'On_Time',
    'Professional',
    'Careful_Handling',
    'Good_Communication',
  ];

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      collectorId: data['collectorId'] ?? '',
      score: data['score'] ?? 0,
      categories: List<String>.from(data['categories'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'collectorId': collectorId,
      'score': score,
      'categories': categories,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
