import 'package:cloud_firestore/cloud_firestore.dart';

/// Pickup booking status
enum PickupStatus { pending, assigned, inProgress, completed, cancelled }

/// A scrap pickup booking in KiloTap
class PickupModel {
  final String id;
  final String sellerId;
  final String? buyerId;
  final String sellerName;
  final String? buyerName;
  final String scrapType;
  final String scrapTypeIcon;
  final double estimatedWeightKg;
  final double? actualWeightKg;
  final double estimatedValue;
  final double? actualValue;
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime scheduledAt;
  final String timeSlot;
  final PickupStatus status;
  final int? rating; // 1-5 stars
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PickupModel({
    required this.id,
    required this.sellerId,
    this.buyerId,
    required this.sellerName,
    this.buyerName,
    required this.scrapType,
    required this.scrapTypeIcon,
    required this.estimatedWeightKg,
    this.actualWeightKg,
    required this.estimatedValue,
    this.actualValue,
    required this.address,
    this.latitude,
    this.longitude,
    required this.scheduledAt,
    required this.timeSlot,
    required this.status,
    this.rating,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case PickupStatus.pending:
        return 'Pending';
      case PickupStatus.assigned:
        return 'Assigned';
      case PickupStatus.inProgress:
        return 'In Progress';
      case PickupStatus.completed:
        return 'Completed';
      case PickupStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get weightDisplay {
    final weight = actualWeightKg ?? estimatedWeightKg;
    return '${weight.toStringAsFixed(1)} kg';
  }

  String get valueDisplay {
    final value = actualValue ?? estimatedValue;
    return '₱${value.toStringAsFixed(2)}';
  }

  static PickupStatus _parseStatus(String? status) {
    switch (status) {
      case 'assigned':
        return PickupStatus.assigned;
      case 'in_progress':
        return PickupStatus.inProgress;
      case 'completed':
        return PickupStatus.completed;
      case 'cancelled':
        return PickupStatus.cancelled;
      default:
        return PickupStatus.pending;
    }
  }

  static String _statusToString(PickupStatus status) {
    switch (status) {
      case PickupStatus.assigned:
        return 'assigned';
      case PickupStatus.inProgress:
        return 'in_progress';
      case PickupStatus.completed:
        return 'completed';
      case PickupStatus.cancelled:
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  factory PickupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PickupModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      buyerId: data['buyerId'],
      sellerName: data['sellerName'] ?? '',
      buyerName: data['buyerName'],
      scrapType: data['scrapType'] ?? '',
      scrapTypeIcon: data['scrapTypeIcon'] ?? '📦',
      estimatedWeightKg: (data['estimatedWeightKg'] as num?)?.toDouble() ?? 0.0,
      actualWeightKg: (data['actualWeightKg'] as num?)?.toDouble(),
      estimatedValue: (data['estimatedValue'] as num?)?.toDouble() ?? 0.0,
      actualValue: (data['actualValue'] as num?)?.toDouble(),
      address: data['address'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      status: _parseStatus(data['status']),
      rating: data['rating'] as int?,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'buyerId': buyerId,
      'sellerName': sellerName,
      'buyerName': buyerName,
      'scrapType': scrapType,
      'scrapTypeIcon': scrapTypeIcon,
      'estimatedWeightKg': estimatedWeightKg,
      'actualWeightKg': actualWeightKg,
      'estimatedValue': estimatedValue,
      'actualValue': actualValue,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'timeSlot': timeSlot,
      'status': _statusToString(status),
      'rating': rating,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PickupModel copyWith({
    String? buyerId,
    String? buyerName,
    double? actualWeightKg,
    double? actualValue,
    PickupStatus? status,
    int? rating,
  }) {
    return PickupModel(
      id: id,
      sellerId: sellerId,
      buyerId: buyerId ?? this.buyerId,
      sellerName: sellerName,
      buyerName: buyerName ?? this.buyerName,
      scrapType: scrapType,
      scrapTypeIcon: scrapTypeIcon,
      estimatedWeightKg: estimatedWeightKg,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      estimatedValue: estimatedValue,
      actualValue: actualValue ?? this.actualValue,
      address: address,
      latitude: latitude,
      longitude: longitude,
      scheduledAt: scheduledAt,
      timeSlot: timeSlot,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      notes: notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
