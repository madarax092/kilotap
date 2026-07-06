import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/booking.dart';
import '../models/booking_item.dart';
import '../models/rating.dart';
import '../models/notification.dart';
import '../models/audit_log.dart';

/// Firestore CRUD — Tables 9–13 (Paper Data Dictionary)
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Bookings (Table 9) ────────────────────────────────────────

  Future<String> createBooking(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colBookings).doc();
    data['Booking_ID'] = ref.id;
    data['Created_At'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return ref.id;
  }

  Future<Booking?> getBooking(String id) async {
    final doc = await _db.collection(AppConstants.colBookings).doc(id).get();
    return doc.exists ? Booking.fromMap(id, doc.data()!) : null;
  }

  Stream<List<Booking>> sellerBookings(String sellerId) => _db
      .collection(AppConstants.colBookings)
      .where('Seller_ID', isEqualTo: sellerId)
      .orderBy('Created_At', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());

  Stream<List<Booking>> collectorBookings(String collectorId) => _db
      .collection(AppConstants.colBookings)
      .where('Collector_ID', isEqualTo: collectorId)
      .orderBy('Created_At', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());

  Stream<List<Booking>> availableBookings() => _db
      .collection(AppConstants.colBookings)
      .where('Status', isEqualTo: 'Pending')
      .orderBy('Created_At', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());

  Future<void> updateBookingStatus(String id, String status, {String? collectorId}) async {
    final data = <String, dynamic>{'Status': status};
    if (collectorId != null) data['Collector_ID'] = collectorId;
    if (status == 'Completed') data['Completed_At'] = FieldValue.serverTimestamp();
    await _db.collection(AppConstants.colBookings).doc(id).update(data);
  }

  // ─── BookingItems (Table 10) ───────────────────────────────────

  Future<void> createBookingItem(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colBookingItems).doc();
    data['Item_ID'] = ref.id;
    await ref.set(data);
  }

  Stream<List<BookingItem>> bookingItems(String bookingId) => _db
      .collection(AppConstants.colBookingItems)
      .where('Booking_ID', isEqualTo: bookingId)
      .snapshots()
      .map((s) => s.docs.map((d) => BookingItem.fromMap(d.id, d.data())).toList());

  // ─── Ratings (Table 11) ────────────────────────────────────────

  Future<void> createRating(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colRatings).doc();
    data['Rating_ID'] = ref.id;
    await ref.set(data);
  }

  Future<List<Rating>> getRatings(String bookingId) async {
    final s = await _db.collection(AppConstants.colRatings)
        .where('Booking_ID', isEqualTo: bookingId).get();
    return s.docs.map((d) => Rating.fromMap(d.id, d.data())).toList();
  }

  // ─── Notifications (Table 13) ──────────────────────────────────

  Future<void> sendNotification(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colNotifications).doc();
    data['Notification_ID'] = ref.id;
    data['Timestamp'] = FieldValue.serverTimestamp();
    await ref.set(data);
  }

  Stream<List<AppNotification>> userNotifications(String recipientId) => _db
      .collection(AppConstants.colNotifications)
      .where('Recipient_ID', isEqualTo: recipientId)
      .orderBy('Timestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList());

  // ─── AuditLogs (Table 12) ──────────────────────────────────────

  Future<void> logAction(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colAuditLogs).doc();
    data['Log_ID'] = ref.id;
    data['Timestamp'] = FieldValue.serverTimestamp();
    await ref.set(data);
  }

  Stream<List<AuditLog>> recentLogs({int limit = 20}) => _db
      .collection(AppConstants.colAuditLogs)
      .orderBy('Timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => AuditLog.fromMap(d.id, d.data())).toList());
}
