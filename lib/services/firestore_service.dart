import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_model.dart';
import '../models/market_price_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── PICKUPS ───────────────────────────────────────────────────────────────

  /// Create a new pickup booking
  Future<String> createPickup(PickupModel pickup) async {
    final docRef = _db.collection(AppConstants.colPickups).doc();
    final newPickup = PickupModel(
      id: docRef.id,
      sellerId: pickup.sellerId,
      buyerId: pickup.buyerId,
      sellerName: pickup.sellerName,
      buyerName: pickup.buyerName,
      scrapType: pickup.scrapType,
      scrapTypeIcon: pickup.scrapTypeIcon,
      estimatedWeightKg: pickup.estimatedWeightKg,
      estimatedValue: pickup.estimatedValue,
      address: pickup.address,
      scheduledAt: pickup.scheduledAt,
      timeSlot: pickup.timeSlot,
      status: PickupStatus.pending,
      notes: pickup.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(newPickup.toFirestore());
    return docRef.id;
  }

  /// Get seller's pickups stream
  Stream<List<PickupModel>> getSellerPickups(String sellerId) {
    return _db
        .collection(AppConstants.colPickups)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PickupModel.fromFirestore).toList());
  }

  /// Get seller's recent pickups (last 10)
  Stream<List<PickupModel>> getSellerRecentPickups(String sellerId) {
    return _db
        .collection(AppConstants.colPickups)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map(PickupModel.fromFirestore).toList());
  }

  /// Get completed seller pickups for history
  Stream<List<PickupModel>> getSellerPickupHistory(String sellerId) {
    return _db
        .collection(AppConstants.colPickups)
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'completed')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PickupModel.fromFirestore).toList());
  }

  /// Get buyer's completed pickups for earnings history
  Stream<List<PickupModel>> getBuyerEarningsHistory(String buyerId) {
    return _db
        .collection(AppConstants.colPickups)
        .where('buyerId', isEqualTo: buyerId)
        .where('status', isEqualTo: 'completed')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PickupModel.fromFirestore).toList());
  }

  /// Get available pending pickups for buyers (nearby)
  Stream<List<PickupModel>> getAvailablePickups() {
    return _db
        .collection(AppConstants.colPickups)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map(PickupModel.fromFirestore).toList());
  }

  /// Update pickup status
  Future<void> updatePickupStatus(String pickupId, PickupStatus status, {String? buyerId, String? buyerName}) async {
    final Map<String, dynamic> data = {
      'status': _statusToString(status),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (buyerId != null) data['buyerId'] = buyerId;
    if (buyerName != null) data['buyerName'] = buyerName;

    await _db.collection(AppConstants.colPickups).doc(pickupId).update(data);
  }

  /// Rate a completed pickup
  Future<void> ratePickup(String pickupId, int rating) async {
    await _db.collection(AppConstants.colPickups).doc(pickupId).update({
      'rating': rating,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ─── MARKET PRICES ─────────────────────────────────────────────────────────

  /// Get real-time market prices stream
  Stream<List<MarketPriceModel>> getMarketPrices() {
    return _db
        .collection(AppConstants.colMarketPrices)
        .snapshots()
        .map((snap) => snap.docs.map(MarketPriceModel.fromFirestore).toList());
  }

  /// Seed default market prices (call once during setup)
  Future<void> seedMarketPrices() async {
    final batch = _db.batch();
    for (final price in MarketPriceModel.defaults) {
      final ref = _db.collection(AppConstants.colMarketPrices).doc(price.scrapTypeId);
      batch.set(ref, price.toFirestore());
    }
    await batch.commit();
  }

  // ─── USERS ────────────────────────────────────────────────────────────────

  /// Get user profile stream (real-time updates)
  Stream<UserModel?> getUserStream(String uid) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Add vehicle to buyer profile
  Future<void> addVehicle(String uid, VehicleInfo vehicle) async {
    await _db.collection(AppConstants.colUsers).doc(uid).update({
      'vehicles': FieldValue.arrayUnion([vehicle.toMap()]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Remove vehicle from buyer profile
  Future<void> removeVehicle(String uid, VehicleInfo vehicle) async {
    await _db.collection(AppConstants.colUsers).doc(uid).update({
      'vehicles': FieldValue.arrayRemove([vehicle.toMap()]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ─── BUYER EARNINGS ────────────────────────────────────────────────────────

  /// Calculate total earnings for a buyer today
  Future<double> getBuyerTodayEarnings(String buyerId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _db
        .collection(AppConstants.colPickups)
        .where('buyerId', isEqualTo: buyerId)
        .where('status', isEqualTo: 'completed')
        .where('updatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('updatedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snap.docs
        .map(PickupModel.fromFirestore)
        .fold<double>(0.0, (total, p) => total + (p.actualValue ?? p.estimatedValue));
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  String _statusToString(PickupStatus status) {
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
}
