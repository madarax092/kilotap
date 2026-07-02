import 'package:cloud_firestore/cloud_firestore.dart';

/// Booking status lifecycle
enum BookingStatus { pending, accepted, enRoute, completed, cancelled, disputed }

/// A scrap pickup booking — maps to 'bookings' collection
/// Replaces the old 'pickups' collection
class BookingModel {
  final String id;
  final String userId; // household who requested
  final String? collectorId; // assigned collector (null until accepted)
  final String sellerName;
  final String? collectorName;
  final String address;
  final double? latitude;
  final double? longitude;
  final double spatialAreaRatio; // Omega (Ω)
  final String vehicleRequirement;
  final String? snapshotImageURL;
  final double? haversineDistanceKm;
  final DateTime scheduledAt;
  final String timeSlot;
  final BookingStatus status;
  final String? notes;
  final double estimatedTotalWeightKg;
  final double estimatedTotalValue;
  final double? actualTotalWeightKg;
  final double? actualTotalValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    this.collectorId,
    required this.sellerName,
    this.collectorName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.spatialAreaRatio,
    required this.vehicleRequirement,
    this.snapshotImageURL,
    this.haversineDistanceKm,
    required this.scheduledAt,
    required this.timeSlot,
    required this.status,
    this.notes,
    required this.estimatedTotalWeightKg,
    required this.estimatedTotalValue,
    this.actualTotalWeightKg,
    this.actualTotalValue,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case BookingStatus.accepted: return 'Accepted';
      case BookingStatus.enRoute: return 'En Route';
      case BookingStatus.completed: return 'Completed';
      case BookingStatus.cancelled: return 'Cancelled';
      case BookingStatus.disputed: return 'Disputed';
      default: return 'Pending';
    }
  }

  String get weightDisplay {
    final w = actualTotalWeightKg ?? estimatedTotalWeightKg;
    return '${w.toStringAsFixed(1)} kg';
  }

  String get valueDisplay {
    final v = actualTotalValue ?? estimatedTotalValue;
    return '₱${v.toStringAsFixed(2)}';
  }

  static BookingStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted': return BookingStatus.accepted;
      case 'en_route': return BookingStatus.enRoute;
      case 'completed': return BookingStatus.completed;
      case 'cancelled': return BookingStatus.cancelled;
      case 'disputed': return BookingStatus.disputed;
      default: return BookingStatus.pending;
    }
  }

  static String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted: return 'accepted';
      case BookingStatus.enRoute: return 'en_route';
      case BookingStatus.completed: return 'completed';
      case BookingStatus.cancelled: return 'cancelled';
      case BookingStatus.disputed: return 'disputed';
      default: return 'pending';
    }
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      collectorId: data['collectorId'],
      sellerName: data['sellerName'] ?? '',
      collectorName: data['collectorName'],
      address: data['address'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      spatialAreaRatio: (data['spatialAreaRatio'] as num?)?.toDouble() ?? 0.0,
      vehicleRequirement: data['vehicleRequirement'] ?? '',
      snapshotImageURL: data['snapshotImageURL'],
      haversineDistanceKm: (data['haversineDistanceKm'] as num?)?.toDouble(),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      status: _parseStatus(data['status']),
      notes: data['notes'],
      estimatedTotalWeightKg: (data['estimatedTotalWeightKg'] as num?)?.toDouble() ?? 0.0,
      estimatedTotalValue: (data['estimatedTotalValue'] as num?)?.toDouble() ?? 0.0,
      actualTotalWeightKg: (data['actualTotalWeightKg'] as num?)?.toDouble(),
      actualTotalValue: (data['actualTotalValue'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'collectorId': collectorId,
      'sellerName': sellerName,
      'collectorName': collectorName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'spatialAreaRatio': spatialAreaRatio,
      'vehicleRequirement': vehicleRequirement,
      'snapshotImageURL': snapshotImageURL,
      'haversineDistanceKm': haversineDistanceKm,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'timeSlot': timeSlot,
      'status': _statusToString(status),
      'notes': notes,
      'estimatedTotalWeightKg': estimatedTotalWeightKg,
      'estimatedTotalValue': estimatedTotalValue,
      'actualTotalWeightKg': actualTotalWeightKg,
      'actualTotalValue': actualTotalValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BookingModel copyWith({
    String? collectorId,
    String? collectorName,
    BookingStatus? status,
    double? actualTotalWeightKg,
    double? actualTotalValue,
  }) {
    return BookingModel(
      id: id,
      userId: userId,
      collectorId: collectorId ?? this.collectorId,
      sellerName: sellerName,
      collectorName: collectorName ?? this.collectorName,
      address: address, latitude: latitude, longitude: longitude,
      spatialAreaRatio: spatialAreaRatio,
      vehicleRequirement: vehicleRequirement,
      snapshotImageURL: snapshotImageURL,
      haversineDistanceKm: haversineDistanceKm,
      scheduledAt: scheduledAt, timeSlot: timeSlot,
      status: status ?? this.status,
      notes: notes,
      estimatedTotalWeightKg: estimatedTotalWeightKg,
      estimatedTotalValue: estimatedTotalValue,
      actualTotalWeightKg: actualTotalWeightKg ?? this.actualTotalWeightKg,
      actualTotalValue: actualTotalValue ?? this.actualTotalValue,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
