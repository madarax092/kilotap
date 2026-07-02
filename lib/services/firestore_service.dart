import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_model.dart';
import '../models/collector_model.dart';
import '../models/booking_model.dart';
import '../models/booking_item_model.dart';
import '../models/rating_model.dart';
import '../models/notification_model.dart';
import '../models/audit_log_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // tblScrapSeller
  // ═══════════════════════════════════════════════════════════════════════════

  Future<SellerModel?> getSeller(String sellerId) async {
    final doc = await _db.collection(AppConstants.colSellers).doc(sellerId).get();
    return doc.exists ? SellerModel.fromFirestore(doc) : null;
  }

  Stream<SellerModel?> sellerStream(String sellerId) {
    return _db.collection(AppConstants.colSellers).doc(sellerId)
        .snapshots().map((d) => d.exists ? SellerModel.fromFirestore(d) : null);
  }

  Future<void> upsertSeller(SellerModel seller) async {
    await _db.collection(AppConstants.colSellers).doc(seller.sellerId)
        .set(seller.toFirestore(), SetOptions(merge: true));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // tblScrapCollector
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<CollectorModel?> collectorStream(String collectorId) {
    return _db.collection(AppConstants.colCollectors).doc(collectorId)
        .snapshots().map((d) => d.exists ? CollectorModel.fromFirestore(d) : null);
  }

  Future<void> upsertCollector(CollectorModel c) async {
    await _db.collection(AppConstants.colCollectors).doc(c.collectorId)
        .set(c.toFirestore(), SetOptions(merge: true));
  }

  Future<List<CollectorModel>> getVerifiedCollectors() async {
    final snap = await _db.collection(AppConstants.colCollectors)
        .where('VerificationStatus', isEqualTo: 'Verified').get();
    return snap.docs.map(CollectorModel.fromFirestore).toList();
  }

  Future<List<CollectorModel>> getPendingCollectors() async {
    final snap = await _db.collection(AppConstants.colCollectors)
        .where('VerificationStatus', isEqualTo: 'Pending').get();
    return snap.docs.map(CollectorModel.fromFirestore).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // tblBooking
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String> createBooking(BookingModel booking) async {
    final ref = _db.collection(AppConstants.colBookings).doc();
    final b = BookingModel(
      bookingId: ref.id, sellerId: booking.sellerId,
      status: 'Pending', vehicleRequirement: booking.vehicleRequirement,
      spatialAreaRatio: booking.spatialAreaRatio,
      snapshotImageURL: booking.snapshotImageURL,
      pickupGPS: booking.pickupGPS, pickupAddress: booking.pickupAddress,
      haversineDistanceKm: booking.haversineDistanceKm,
      createdAt: DateTime.now(),
    );
    await ref.set(b.toFirestore());
    return ref.id;
  }

  Stream<List<BookingModel>> householdBookings(String sellerId) {
    return _db.collection(AppConstants.colBookings)
        .where('Seller_ID', isEqualTo: sellerId)
        .orderBy('Created_At', descending: true)
        .snapshots().map((s) => s.docs.map(BookingModel.fromFirestore).toList());
  }

  Stream<List<BookingModel>> collectorBookings(String collectorId) {
    return _db.collection(AppConstants.colBookings)
        .where('Collector_ID', isEqualTo: collectorId)
        .orderBy('Created_At', descending: true)
        .snapshots().map((s) => s.docs.map(BookingModel.fromFirestore).toList());
  }

  Stream<List<BookingModel>> get pendingBookings {
    return _db.collection(AppConstants.colBookings)
        .where('Status', isEqualTo: 'Pending')
        .orderBy('Created_At', descending: true)
        .snapshots().map((s) => s.docs.map(BookingModel.fromFirestore).toList());
  }

  Future<void> acceptBooking(String bookingId, String collectorId) async {
    await _db.collection(AppConstants.colBookings).doc(bookingId).update({
      'Collector_ID': collectorId, 'Status': 'Accepted',
    });
  }

  Future<void> completeBooking(String bookingId) async {
    await _db.collection(AppConstants.colBookings).doc(bookingId).update({
      'Status': 'Completed', 'Completed_At': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // tblBookingItem
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<BookingItemModel>> bookingItems(String bookingId) {
    return _db.collection(AppConstants.colBookingItems)
        .where('Booking_ID', isEqualTo: bookingId)
        .snapshots().map((s) => s.docs.map(BookingItemModel.fromFirestore).toList());
  }

  Future<void> addBookingItems(List<BookingItemModel> items) async {
    final batch = _db.batch();
    for (final item in items) {
      batch.set(_db.collection(AppConstants.colBookingItems).doc(), item.toFirestore());
    }
    await batch.commit();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // tblRating
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> submitRating(RatingModel rating) async {
    final ref = _db.collection(AppConstants.colRatings).doc();
    await ref.set(rating.toFirestore());
    // Recalculate collector avg
    final snap = await _db.collection(AppConstants.colRatings)
        .where('Booking_ID', isEqualTo: rating.bookingId).get();
    if (snap.docs.isNotEmpty) {
      final b = await _db.collection(AppConstants.colBookings).doc(rating.bookingId).get();
      final cid = b.data()?['Collector_ID'];
      if (cid != null) await _recalcAvgRating(cid);
    }
  }

  Future<void> _recalcAvgRating(String collectorId) async {
    final snap = await _db.collection(AppConstants.colBookings)
        .where('Collector_ID', isEqualTo: collectorId)
        .where('Status', isEqualTo: 'Completed').get();
    if (snap.docs.isEmpty) return;
    double total = 0; int count = 0;
    for (final bDoc in snap.docs) {
      final rSnap = await _db.collection(AppConstants.colRatings)
          .where('Booking_ID', isEqualTo: bDoc.id).get();
      for (final r in rSnap.docs) {
        total += (r.data()['Score'] as num?)?.toDouble() ?? 0;
        count++;
      }
    }
    if (count > 0) {
      await _db.collection(AppConstants.colCollectors).doc(collectorId).update({
        'AvgRating': double.parse((total / count).toStringAsFixed(1)),
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // tblNotification
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<NotificationModel>> notifications(String recipientId) {
    return _db.collection(AppConstants.colNotifications)
        .where('Recipient_ID', isEqualTo: recipientId)
        .orderBy('Timestamp', descending: true)
        .snapshots().map((s) => s.docs.map(NotificationModel.fromFirestore).toList());
  }

  Future<void> sendNotification(NotificationModel n) async {
    await _db.collection(AppConstants.colNotifications).doc().set(n.toFirestore());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // tblAuditLog
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> logAudit(AuditLogModel log) async {
    await _db.collection(AppConstants.colAuditLogs).doc().set(log.toFirestore());
  }

  Stream<List<AuditLogModel>> auditLogs() {
    return _db.collection(AppConstants.colAuditLogs)
        .orderBy('Timestamp', descending: true)
        .snapshots().map((s) => s.docs.map(AuditLogModel.fromFirestore).toList());
  }
}
