import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Table 10: Booking ───

class Booking {
  final String bookingId;
  final String sellerId;
  final String collectorId;
  final String status;
  final String vehicleRequirement;
  final double spatialAreaRatio;
  final GeoPoint pickupGps;
  final String pickupAddress;
  final String notes;
  final String photoUrl;
  // Pickup timing, field names per the paper's Figure 12: 'ASAP' or
  // 'Scheduled'; scheduledDate holds the chosen date and time when Scheduled.
  final String pickupType;
  final DateTime? scheduledDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Booking({
    required this.bookingId,
    required this.sellerId,
    this.collectorId = '',
    this.status = 'Pending',
    this.vehicleRequirement = '',
    this.spatialAreaRatio = 0.0,
    required this.pickupGps,
    this.pickupAddress = '',
    this.notes = '',
    this.photoUrl = '',
    this.pickupType = 'ASAP',
    this.scheduledDate,
    required this.createdAt,
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
        notes: m['Notes'] ?? '',
        photoUrl: m['PhotoURL'] ?? '',
        pickupType: m['PickupType'] ?? 'ASAP',
        scheduledDate: (m['ScheduledDate'] as Timestamp?)?.toDate(),
        createdAt: (m['Created_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
        completedAt: (m['Completed_At'] as Timestamp?)?.toDate(),
      );
}
