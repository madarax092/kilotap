import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/booking.dart';
import '../models/booking_item.dart';
import '../models/rating.dart';
import '../models/notification.dart';
import '../models/audit_log.dart';
import '../models/message.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Bookings (Table 10) ───────────────────────────────────────

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

  // Admin-wide view — every booking, not scoped to one user.
  Stream<List<Booking>> allBookings() => _db
      .collection(AppConstants.colBookings)
      .orderBy('Created_At', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());

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

  Future<void> updateBookingStatus(String id, String status,
      {String? collectorId}) async {
    final data = <String, dynamic>{'Status': status};
    if (collectorId != null) data['Collector_ID'] = collectorId;
    if (status == 'Completed') {
      data['Completed_At'] = FieldValue.serverTimestamp();
    }
    await _db.collection(AppConstants.colBookings).doc(id).update(data);
  }

  // ─── BookingItems (Table 11) ───────────────────────────────────

  Future<void> createBookingItem(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colBookingItems).doc();
    data['Item_ID'] = ref.id;
    await ref.set(data);
  }

  Stream<List<BookingItem>> bookingItems(String bookingId) => _db
      .collection(AppConstants.colBookingItems)
      .where('Booking_ID', isEqualTo: bookingId)
      .snapshots()
      .map((s) => s.docs.map((d) => BookingItem.fromMap(d.data())).toList());

  // ─── Ratings (Table 13) ────────────────────────────────────────

  Future<void> createRating(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colRatings).doc();
    data['Rating_ID'] = ref.id;
    await ref.set(data);
  }

  Future<List<Rating>> getRatings(String bookingId) async {
    final s = await _db
        .collection(AppConstants.colRatings)
        .where('Booking_ID', isEqualTo: bookingId)
        .get();
    return s.docs.map((d) => Rating.fromMap(d.id, d.data())).toList();
  }

  // ─── Notifications (Table 15) ──────────────────────────────────

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
      .map((s) =>
          s.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList());

  Future<void> markNotificationRead(String notificationId) async {
    await _db
        .collection(AppConstants.colNotifications)
        .doc(notificationId)
        .update({'IsRead': true});
  }

  // ─── AuditLogs (Table 14) ──────────────────────────────────────

  Future<void> logAction(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colAuditLogs).doc();
    data['Log_ID'] = ref.id;
    data['Create_At'] = FieldValue.serverTimestamp();
    await ref.set(data);
  }

  Stream<List<AuditLog>> recentLogs({int limit = 20}) => _db
      .collection(AppConstants.colAuditLogs)
      .orderBy('Create_At', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => AuditLog.fromMap(d.id, d.data())).toList());

  // ─── Messages (not a numbered paper table — added for chat) ────

  Future<void> sendMessage(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colMessages).doc();
    data['Message_ID'] = ref.id;
    data['Timestamp'] = FieldValue.serverTimestamp();
    data['Participants'] = [data['Sender_ID'], data['Recipient_ID']];
    await ref.set(data);
  }

  Future<String> uploadChatImage(
      File file, String senderId, String recipientId) async {
    if (AppConstants.cloudinaryCloudName == 'YOUR_CLOUDINARY_CLOUD_NAME') {
      throw Exception(
          'Cloudinary is not configured — set cloudinaryCloudName and cloudinaryUploadPreset in app_constants.dart');
    }
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: $body');
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }

  // Sorted in Dart, not via .orderBy() — combining array-contains with
  // orderBy on a different field would force a composite index.
  Stream<List<ChatMessage>> messagesBetween(String uidA, String uidB) => _db
      .collection(AppConstants.colMessages)
      .where('Participants', arrayContains: uidA)
      .snapshots()
      .map((s) => s.docs
          .map((d) => ChatMessage.fromMap(d.id, d.data()))
          .where((m) => m.participants.contains(uidB))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));

  static const _activeBookingStatuses = {'Pending', 'Accepted'};

  Future<bool> hasActiveBookingBetween(String uidA, String uidB) async {
    final asSeller = await _db
        .collection(AppConstants.colBookings)
        .where('Seller_ID', isEqualTo: uidA)
        .where('Collector_ID', isEqualTo: uidB)
        .get();
    if (asSeller.docs
        .any((d) => _activeBookingStatuses.contains(d.data()['Status']))) {
      return true;
    }
    final asCollector = await _db
        .collection(AppConstants.colBookings)
        .where('Seller_ID', isEqualTo: uidB)
        .where('Collector_ID', isEqualTo: uidA)
        .get();
    return asCollector.docs
        .any((d) => _activeBookingStatuses.contains(d.data()['Status']));
  }

  Stream<List<ChatMessage>> userConversations(String uid) => _db
      .collection(AppConstants.colMessages)
      .where('Participants', arrayContains: uid)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));

  Future<String> displayNameFor(String uid) async {
    final doc = await _db.collection(AuthService.colAccount).doc(uid).get();
    return doc.data()?['Display_Name'] ?? 'Unknown';
  }

  // ─── Users (Table 7 UserAccount + Table 8/9 subcollections) ────

  Stream<List<Map<String, dynamic>>> listUsers() => _db
      .collection(AuthService.colAccount)
      .snapshots()
      .map((s) => s.docs.map((d) => {...d.data(), 'uid': d.id}).toList());

  Future<Map<String, dynamic>?> collectorProfile(String uid) async {
    final doc = await _db
        .collection(AuthService.colAccount)
        .doc(uid)
        .collection(AuthService.colCollector)
        .doc(uid)
        .get();
    return doc.data();
  }

  Future<void> setCollectorVerification(String uid, String status) async {
    await _db
        .collection(AuthService.colAccount)
        .doc(uid)
        .collection(AuthService.colCollector)
        .doc(uid)
        .update({'Verification_Status': status});
    await _db.collection(AuthService.colAccount).doc(uid).update(
        {'Role': status == 'Verified' ? 'VerifiedCollector' : 'Collector'});
  }
}
