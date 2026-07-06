import 'package:cloud_firestore/cloud_firestore.dart';

/// Table 9: Booking
class Booking {
  final String bookingId;
  final String sellerId;
  final String collectorId;
  final String status;
  final String vehicleRequirement;
  final double spatialAreaRatio;
  final GeoPoint pickupGps;
  final String pickupAddress;
  final double haversineDistanceKm;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Booking({
    required this.bookingId, required this.sellerId,
    this.collectorId = '', this.status = 'Pending',
    this.vehicleRequirement = '', this.spatialAreaRatio = 0.0,
    required this.pickupGps, this.pickupAddress = '',
    this.haversineDistanceKm = 0.0, required this.createdAt,
    this.completedAt,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> m) => Booking(
    bookingId: m['Booking_ID'] ?? id,
    sellerId: m['Seller_ID'] ?? '',
    collectorId: m['Collector_ID'] ?? '',
    status: m['Status'] ?? 'Pending',
    vehicleRequirement: m['VehicleRequirement'] ?? '',
    spatialAreaRatio: (m['SpatialAreaRatio'] ?? 0).toDouble(),
    pickupGps: m['PickupGPS'] ?? const GeoPoint(0, 0),
    pickupAddress: m['PickupAddress'] ?? '',
    haversineDistanceKm: (m['HaversineDistanceKm'] ?? 0).toDouble(),
    createdAt: (m['Created_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
    completedAt: (m['Completed_At'] as Timestamp?)?.toDate(),
  );
}
