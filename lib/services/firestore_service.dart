import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/collector_model.dart';
import '../models/booking_model.dart';
import '../models/booking_item_model.dart';
import '../models/rating_model.dart';
import '../models/subdivision_access_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // USERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get user profile stream
  Stream<UserModel?> getUserStream(String uid) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Create or update user profile
  Future<void> upsertUser(UserModel user) async {
    await _db.collection(AppConstants.colUsers).doc(user.uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COLLECTORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get collector profile stream
  Stream<CollectorModel?> getCollectorStream(String userId) {
    return _db
        .collection(AppConstants.colCollectors)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? CollectorModel.fromFirestore(doc) : null);
  }

  /// Create or update collector profile
  Future<void> upsertCollector(CollectorModel collector) async {
    await _db.collection(AppConstants.colCollectors).doc(collector.userId).set(
          collector.toFirestore(),
          SetOptions(merge: true),
        );
  }

  /// Toggle online status
  Future<void> setCollectorOnline(String userId, bool online) async {
    await _db.collection(AppConstants.colCollectors).doc(userId).update({
      'onlineStatus': online,
      'currentGPS': online ? null : null, // updated separately via geolocation
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Update collector GPS location
  Future<void> updateCollectorGPS(String userId, GeoPoint gps) async {
    await _db.collection(AppConstants.colCollectors).doc(userId).update({
      'currentGPS': gps,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOOKINGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a new booking
  Future<String> createBooking(BookingModel booking) async {
    final docRef = _db.collection(AppConstants.colBookings).doc();
    final newBooking = BookingModel(
      id: docRef.id,
      userId: booking.userId,
      sellerName: booking.sellerName,
      address: booking.address,
      latitude: booking.latitude,
      longitude: booking.longitude,
      spatialAreaRatio: booking.spatialAreaRatio,
      vehicleRequirement: booking.vehicleRequirement,
      snapshotImageURL: booking.snapshotImageURL,
      haversineDistanceKm: booking.haversineDistanceKm,
      scheduledAt: booking.scheduledAt,
      timeSlot: booking.timeSlot,
      status: BookingStatus.pending,
      notes: booking.notes,
      estimatedTotalWeightKg: booking.estimatedTotalWeightKg,
      estimatedTotalValue: booking.estimatedTotalValue,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(newBooking.toFirestore());
    return docRef.id;
  }

  /// Get seller's bookings stream
  Stream<List<BookingModel>> getSellerBookings(String sellerId) {
    return _db
        .collection(AppConstants.colBookings)
        .where('userId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Get available pending bookings for buyers
  Stream<List<BookingModel>> getAvailableBookings() {
    return _db
        .collection(AppConstants.colBookings)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Get buyer's accepted bookings
  Stream<List<BookingModel>> getBuyerBookings(String collectorId) {
    return _db
        .collection(AppConstants.colBookings)
        .where('collectorId', isEqualTo: collectorId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    String? collectorId,
    String? collectorName,
  }) async {
    final Map<String, dynamic> data = {
      'status': _bookingStatusToString(status),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (collectorId != null) data['collectorId'] = collectorId;
    if (collectorName != null) data['collectorName'] = collectorName;

    await _db.collection(AppConstants.colBookings).doc(bookingId).update(data);
  }

  /// Calculate buyer's today earnings from completed bookings
  Future<double> getBuyerTodayEarnings(String collectorId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _db
        .collection(AppConstants.colBookings)
        .where('collectorId', isEqualTo: collectorId)
        .where('status', isEqualTo: 'completed')
        .where('updatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('updatedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snap.docs
        .map(BookingModel.fromFirestore)
        .fold<double>(0.0, (total, b) => total + (b.actualTotalValue ?? b.estimatedTotalValue));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOOKING ITEMS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get items for a booking
  Stream<List<BookingItemModel>> getBookingItems(String bookingId) {
    return _db
        .collection(AppConstants.colBookingItems)
        .where('bookingId', isEqualTo: bookingId)
        .snapshots()
        .map((snap) => snap.docs.map(BookingItemModel.fromFirestore).toList());
  }

  /// Add an item to a booking (batch: add all items at once)
  Future<void> addBookingItems(List<BookingItemModel> items) async {
    final batch = _db.batch();
    for (final item in items) {
      final ref = _db.collection(AppConstants.colBookingItems).doc();
      batch.set(ref, item.toFirestore());
    }
    await batch.commit();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RATINGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Submit a rating for a completed booking
  Future<String> submitRating(RatingModel rating) async {
    final docRef = _db.collection(AppConstants.colRatings).doc();
    final newRating = RatingModel(
      id: docRef.id,
      bookingId: rating.bookingId,
      userId: rating.userId,
      collectorId: rating.collectorId,
      score: rating.score,
      categories: rating.categories,
      createdAt: DateTime.now(),
    );
    await docRef.set(newRating.toFirestore());

    // Also update collector's average rating
    await _updateCollectorAvgRating(rating.collectorId);

    return docRef.id;
  }

  /// Get ratings for a collector
  Stream<List<RatingModel>> getCollectorRatings(String collectorId) {
    return _db
        .collection(AppConstants.colRatings)
        .where('collectorId', isEqualTo: collectorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RatingModel.fromFirestore).toList());
  }

  /// Recalculate collector's average rating
  Future<void> _updateCollectorAvgRating(String collectorId) async {
    final snap = await _db
        .collection(AppConstants.colRatings)
        .where('collectorId', isEqualTo: collectorId)
        .get();

    if (snap.docs.isEmpty) return;

    final total = snap.docs.fold<int>(0, (sum, doc) {
      final data = doc.data();
      return sum + (data['score'] as int? ?? 0);
    });
    final avg = total / snap.docs.length;

    await _db.collection(AppConstants.colCollectors).doc(collectorId).update({
      'avgRating': double.parse(avg.toStringAsFixed(1)),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBDIVISION ACCESS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get subdivision access for a collector
  Stream<List<SubdivisionAccessModel>> getCollectorSubdivisionAccess(String collectorId) {
    return _db
        .collection(AppConstants.colSubdivisionAccess)
        .where('collectorId', isEqualTo: collectorId)
        .snapshots()
        .map((snap) => snap.docs.map(SubdivisionAccessModel.fromFirestore).toList());
  }

  /// Request access to a subdivision
  Future<String> requestSubdivisionAccess(SubdivisionAccessModel access) async {
    final docRef = _db.collection(AppConstants.colSubdivisionAccess).doc();
    final request = SubdivisionAccessModel(
      id: docRef.id,
      collectorId: access.collectorId,
      subdivisionName: access.subdivisionName,
      accessStatus: AccessStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(request.toFirestore());
    return docRef.id;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String _bookingStatusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted: return 'accepted';
      case BookingStatus.enRoute: return 'en_route';
      case BookingStatus.completed: return 'completed';
      case BookingStatus.cancelled: return 'cancelled';
      case BookingStatus.disputed: return 'disputed';
      default: return 'pending';
    }
  }
}
