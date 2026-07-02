import 'package:cloud_firestore/cloud_firestore.dart';

/// Individual scrap item within a booking — one per YOLO-detected object
/// Stored in 'bookingItems' collection or as subcollection under bookings/{id}/items
class BookingItemModel {
  final String id;
  final String bookingId;
  final String materialType;
  final double confidenceScore;
  final Map<String, double>? bbox; // {x, y, width, height}
  final double estimatedWeightKg;
  final double? actualWeightKg;
  final DateTime createdAt;

  const BookingItemModel({
    required this.id,
    required this.bookingId,
    required this.materialType,
    required this.confidenceScore,
    this.bbox,
    required this.estimatedWeightKg,
    this.actualWeightKg,
    required this.createdAt,
  });

  String get weightDisplay {
    final w = actualWeightKg ?? estimatedWeightKg;
    return '${w.toStringAsFixed(1)} kg';
  }

  String get confidenceDisplay => '${(confidenceScore * 100).toStringAsFixed(0)}%';

  factory BookingItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingItemModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      materialType: data['materialType'] ?? '',
      confidenceScore: (data['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      bbox: data['bbox'] != null
          ? Map<String, double>.from(
              (data['bbox'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())))
          : null,
      estimatedWeightKg: (data['estimatedWeightKg'] as num?)?.toDouble() ?? 0.0,
      actualWeightKg: (data['actualWeightKg'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'materialType': materialType,
      'confidenceScore': confidenceScore,
      'bbox': bbox,
      'estimatedWeightKg': estimatedWeightKg,
      'actualWeightKg': actualWeightKg,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
