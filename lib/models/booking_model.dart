import 'package:cloud_firestore/cloud_firestore.dart';

/// tblBooking — Pickup request lifecycle
/// Firestore: 'bookings' collection
class BookingModel {
  final String bookingId;
  final String sellerId;    // FK → tblScrapSeller
  final String? collectorId; // FK → tblScrapCollector (null until accepted)
  final String status;       // Pending, Accepted, Completed, Cancelled
  final String vehicleRequirement;
  final double spatialAreaRatio; // Omega
  final String? snapshotImageURL;
  final GeoPoint? pickupGPS;
  final String pickupAddress;
  final double? haversineDistanceKm;
  final DateTime createdAt;
  final DateTime? completedAt;

  const BookingModel({
    required this.bookingId,
    required this.sellerId,
    this.collectorId,
    required this.status,
    required this.vehicleRequirement,
    required this.spatialAreaRatio,
    this.snapshotImageURL,
    this.pickupGPS,
    required this.pickupAddress,
    this.haversineDistanceKm,
    required this.createdAt,
    this.completedAt,
  });

  bool get isPending => status == 'Pending';
  bool get isCompleted => status == 'Completed';

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: doc.id,
      sellerId: data['Seller_ID'] ?? '',
      collectorId: data['Collector_ID'],
      status: data['Status'] ?? 'Pending',
      vehicleRequirement: data['VehicleRequirement'] ?? '',
      spatialAreaRatio: (data['SpatialAreaRatio'] as num?)?.toDouble() ?? 0.0,
      snapshotImageURL: data['SnapshotImageURL'],
      pickupGPS: data['PickupGPS'] as GeoPoint?,
      pickupAddress: data['PickupAddress'] ?? '',
      haversineDistanceKm: (data['HaversineDistanceKm'] as num?)?.toDouble(),
      createdAt: (data['Created_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['Completed_At'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'Seller_ID': sellerId,
    'Collector_ID': collectorId,
    'Status': status,
    'VehicleRequirement': vehicleRequirement,
    'SpatialAreaRatio': spatialAreaRatio,
    'SnapshotImageURL': snapshotImageURL,
    'PickupGPS': pickupGPS,
    'PickupAddress': pickupAddress,
    'HaversineDistanceKm': haversineDistanceKm,
    'Created_At': Timestamp.fromDate(createdAt),
    'Completed_At': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
  };
}
