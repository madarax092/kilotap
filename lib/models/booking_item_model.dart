import 'package:cloud_firestore/cloud_firestore.dart';

/// tblBookingItem — Individual detected scrap items within a booking
/// Firestore: 'bookingItems' collection
class BookingItemModel {
  final String itemId;
  final String bookingId; // FK → tblBooking
  final String materialType;
  final double confidenceScore;
  final String? bbox; // String coordinates of bounding box
  final double estimatedWeightKg;
  final double? actualWeightKg;

  const BookingItemModel({
    required this.itemId,
    required this.bookingId,
    required this.materialType,
    required this.confidenceScore,
    this.bbox,
    required this.estimatedWeightKg,
    this.actualWeightKg,
  });

  String get confidencePercent => '${(confidenceScore * 100).toStringAsFixed(0)}%';

  factory BookingItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingItemModel(
      itemId: doc.id,
      bookingId: data['Booking_ID'] ?? '',
      materialType: data['MaterialType'] ?? '',
      confidenceScore: (data['ConfidenceScore'] as num?)?.toDouble() ?? 0.0,
      bbox: data['BBox'],
      estimatedWeightKg: (data['EstimatedWeightKg'] as num?)?.toDouble() ?? 0.0,
      actualWeightKg: (data['ActualWeightKg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'Booking_ID': bookingId,
    'MaterialType': materialType,
    'ConfidenceScore': confidenceScore,
    'BBox': bbox,
    'EstimatedWeightKg': estimatedWeightKg,
    'ActualWeightKg': actualWeightKg,
  };
}
