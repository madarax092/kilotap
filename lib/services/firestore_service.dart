import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../core/account_status.dart';
import '../core/constants/app_constants.dart';
import '../core/vehicle_verification.dart';
import '../core/verification_docs.dart';
import '../models/booking.dart';
import '../models/booking_item.dart';
import '../models/rating.dart';
import '../models/notification.dart';
import '../models/audit_log.dart';
import '../models/message.dart';
import '../models/report.dart';
import 'auth_service.dart';
import 'auth_state.dart';

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

  // Writes the booking (Table 10) and all its items (Table 11) in one atomic
  // batch, so the new-booking Cloud Function always sees the items when it
  // fires and can match them against collector material preferences.
  // Booking ID made on the phone, so a request saved offline keeps the same
  // ID when it is finally sent (no duplicate bookings).
  String newBookingId() => _db.collection(AppConstants.colBookings).doc().id;

  // With offline persistence the batch is applied locally and queued by
  // Firestore until the server is reachable, so the UI only waits a short
  // while for the server's acknowledgement instead of hanging offline.
  Future<String> createBookingWithItems(
      Map<String, dynamic> booking, List<Map<String, dynamic>> items,
      {String? bookingId}) async {
    final batch = _db.batch();
    final bookingRef = _db.collection(AppConstants.colBookings).doc(bookingId);
    booking['Booking_ID'] = bookingRef.id;
    booking['Created_At'] = FieldValue.serverTimestamp();
    batch.set(bookingRef, booking);
    for (final item in items) {
      final itemRef = _db.collection(AppConstants.colBookingItems).doc();
      item['Item_ID'] = itemRef.id;
      item['Booking_ID'] = bookingRef.id;
      batch.set(itemRef, item);
    }
    final commit = batch.commit();
    try {
      await commit.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      commit.catchError((Object e) {
        debugPrint('Queued booking ${bookingRef.id} failed to sync: $e');
      });
    }
    return bookingRef.id;
  }

  Stream<Booking?> bookingStream(String id) => _db
      .collection(AppConstants.colBookings)
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Booking.fromMap(d.id, d.data()!) : null);

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

  // orderBy is done in Dart, not Firestore, for these three — combining a
  // where() on one field with orderBy() on a different field requires a
  // composite index; none is deployed for this project, so the query would
  // throw failed-precondition at runtime instead of returning results.
  Stream<List<Booking>> sellerBookings(String sellerId) => _db
      .collection(AppConstants.colBookings)
      .where('Seller_ID', isEqualTo: sellerId)
      .snapshots()
      .map((s) => _sortByCreatedAtDesc(
          s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList()));

  Stream<List<Booking>> collectorBookings(String collectorId) => _db
      .collection(AppConstants.colBookings)
      .where('Collector_ID', isEqualTo: collectorId)
      .snapshots()
      .map((s) => _sortByCreatedAtDesc(
          s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList()));

  Stream<List<Booking>> availableBookings() => _db
      .collection(AppConstants.colBookings)
      .where('Status', isEqualTo: 'Pending')
      .snapshots()
      .map((s) => _sortByCreatedAtDesc(
          s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList()));

  List<Booking> _sortByCreatedAtDesc(List<Booking> bookings) {
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookings;
  }

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

  // Sorted newest-first in Dart: combining the Recipient_ID filter with an
  // orderBy on Timestamp would need a composite index.
  Stream<List<AppNotification>> userNotifications(String recipientId) => _db
      .collection(AppConstants.colNotifications)
      .where('Recipient_ID', isEqualTo: recipientId)
      .snapshots()
      .map((s) {
        final list =
            s.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      });

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
    data['Ip_Adress'] ??= await _lookupPublicIp();
    await ref.set(data);
  }

  Future<String> _lookupPublicIp() async {
    try {
      final res = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as Map<String, dynamic>)['ip'] ?? '';
      }
    } catch (_) {
      // Offline or lookup failed — leave Ip_Adress blank rather than fail the log.
    }
    return '';
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

  // Hard cap enforced client-side before any Cloudinary upload — the
  // unsigned preset itself has no server-side size limit.
  static const int maxUploadBytes = 5 * 1024 * 1024;

  // Smaller cap for the Digital ID photo — it's shown as a small thumbnail,
  // and the picker already downscales it well under this.
  static const int maxIdPhotoBytes = 2 * 1024 * 1024;

  Future<String> _uploadToCloudinary(File file,
      {String resourceType = 'image', int maxBytes = maxUploadBytes}) async {
    if (await file.length() > maxBytes) {
      throw Exception(
          'File is larger than ${maxBytes ~/ (1024 * 1024)}MB — please choose a smaller one.');
    }
    return _postToCloudinary(
        await http.MultipartFile.fromPath('file', file.path), resourceType);
  }

  Future<String> _postToCloudinary(
      http.MultipartFile upload, String resourceType) async {
    if (AppConstants.cloudinaryCloudName == 'YOUR_CLOUDINARY_CLOUD_NAME') {
      throw Exception(
          'Cloudinary is not configured — set cloudinaryCloudName and cloudinaryUploadPreset in app_constants.dart');
    }
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/$resourceType/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
      ..files.add(upload);
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: $body');
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }

  Future<String> uploadChatImage(
          File file, String senderId, String recipientId) =>
      _uploadToCloudinary(file);

  Future<String> uploadBookingPhoto(File file) => _uploadToCloudinary(file);

  // Photo for one entry of ScrapCollector.Vehicles — needed for an admin to
  // approve a vehicle added after the collector was already verified.
  Future<String> uploadVehiclePhoto(File file) => _uploadToCloudinary(file);

  // ─── Digital ID (ScrapCollector, Table 9) ──────────────────────

  Future<String> uploadIdPhoto(File file) =>
      _uploadToCloudinary(file, maxBytes: maxIdPhotoBytes);

  // Signature is drawn in-app and exported straight to PNG bytes, so it
  // never touches the filesystem.
  Future<String> uploadSignature(Uint8List pngBytes) => _postToCloudinary(
      http.MultipartFile.fromBytes('file', pngBytes, filename: 'signature.png'),
      'image');

  // ─── Verification Documents (part of ScrapCollector, Table 9) ──────

  // 'auto' lets Cloudinary route photos through its image pipeline (so they
  // still get thumbnail/transform support) while PDFs/Word docs go through
  // as raw files — same endpoint handles both since the collector can pick
  // either a camera photo or a document file for any of the three doc types.
  Future<String> uploadVerificationDoc(File file) =>
      _uploadToCloudinary(file, resourceType: 'auto');

  // Verification_Docs is a plain array field (not subdocuments), so a
  // single-entry change means reading the whole array, replacing the
  // matching {type, url, status} map, and writing it back.
  Future<void> setVerificationDocUrl(
      String uid, String docType, String url) async {
    final ref = _db
        .collection(AppConstants.colAccount)
        .doc(uid)
        .collection(AppConstants.colCollector)
        .doc(uid);
    final doc = await ref.get();
    final docs = normalizeVerificationDocs(List<Map<String, dynamic>>.from(
        (doc.data()?['Verification_Docs'] as List<dynamic>? ?? [])
            .map((d) => Map<String, dynamic>.from(d as Map))));
    final i = docs.indexWhere((d) => d['type'] == docType);
    final updated = {'type': docType, 'url': url, 'status': 'pending'};
    if (i >= 0) {
      docs[i] = updated;
    } else {
      docs.add(updated);
    }
    // A new clearance needs a new review, so the old badge comes off.
    await ref.update({
      'Verification_Docs': docs,
      if (docType == barangayClearanceDocType) 'Barangay_Cleared': false,
    });
  }

  // Applies the admin's overall decision to every individual document's
  // status, instead of leaving them stuck on 'pending' forever.
  Future<void> setAllVerificationDocsStatus(String uid, String status) async {
    final ref = _db
        .collection(AppConstants.colAccount)
        .doc(uid)
        .collection(AppConstants.colCollector)
        .doc(uid);
    final doc = await ref.get();
    final docs = List<Map<String, dynamic>>.from(
        (doc.data()?['Verification_Docs'] as List<dynamic>? ?? [])
            .map((d) => Map<String, dynamic>.from(d as Map)));
    // A slot with nothing uploaded (the optional Barangay Clearance) keeps
    // 'pending', so it can't count as an approved document later.
    final updated = docs
        .map((d) => isDocUploaded(d) ? {...d, 'status': status.toLowerCase()} : d)
        .toList();
    final clearanceUploaded =
        isDocUploaded(verificationDocOf(updated, barangayClearanceDocType));
    await ref.update({
      'Verification_Docs': updated,
      'Barangay_Cleared': clearanceUploaded && status == 'Verified',
    });
  }

  // Decides one document on its own — used for a Barangay Clearance a
  // collector uploads after their account was already verified.
  Future<void> setVerificationDocStatus(
      String uid, String docType, String status) async {
    final ref = _db
        .collection(AppConstants.colAccount)
        .doc(uid)
        .collection(AppConstants.colCollector)
        .doc(uid);
    final doc = await ref.get();
    final docs = verificationDocsFrom(doc.data())
        .map((d) =>
            d['type'] == docType ? {...d, 'status': status.toLowerCase()} : d)
        .toList();
    await ref.update({
      'Verification_Docs': docs,
      if (docType == barangayClearanceDocType)
        'Barangay_Cleared': status == 'Verified',
    });
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

  Future<Map<String, dynamic>?> userAccount(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _db.collection(AuthService.colAccount).doc(uid).get();
    return doc.data();
  }

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

  // Role stays 'Collector' regardless of verification outcome —
  // 'VerifiedCollector' is a computed permission tier derived in
  // AuthState._effectiveRole from Verification_Status, never a value stored
  // in Firestore's Role field (see auth_state.dart). Writing it there breaks
  // every `role == 'Collector'` routing check in the app.
  Future<void> setCollectorVerification(String uid, String status) async {
    await _db
        .collection(AuthService.colAccount)
        .doc(uid)
        .collection(AuthService.colCollector)
        .doc(uid)
        .update({'Verification_Status': status});
  }

  // ─── Per-vehicle approval (ScrapCollector.Verified_Vehicles) ───────

  DocumentReference<Map<String, dynamic>> _collectorRef(String uid) => _db
      .collection(AuthService.colAccount)
      .doc(uid)
      .collection(AuthService.colCollector)
      .doc(uid);

  // On full verification every vehicle the collector registered so far is
  // approved — the admin reviewed them as part of the application.
  Future<void> approveAllVehicles(String uid) async {
    final data = (await _collectorRef(uid).get()).data() ?? {};
    final types = (data['Vehicles'] as List<dynamic>? ?? const [])
        .map((v) => (v as Map)['Vehicle_Type'] as String? ?? '')
        .where((t) => t.isNotEmpty)
        .toSet();
    final active = data['Vehicle_Type'];
    if (active is String && active.isNotEmpty) types.add(active);
    await _collectorRef(uid).update({'Verified_Vehicles': types.toList()});
  }

  // Read-modify-write rather than arrayUnion: a collector verified before
  // this field existed has no stored list yet, and arrayUnion would drop
  // their implicitly-approved active vehicle.
  Future<void> approveVehicle(String uid, String vehicleType) async {
    final data = (await _collectorRef(uid).get()).data();
    final approved = {...effectiveVerifiedVehicles(data), vehicleType};
    await _collectorRef(uid).update({'Verified_Vehicles': approved.toList()});
  }

  // A rejected vehicle is removed from the collector's list, so they can
  // re-add it with a clearer photo instead of it sitting pending forever.
  Future<void> rejectVehicle(String uid, String vehicleType) async {
    final data = (await _collectorRef(uid).get()).data() ?? {};
    final vehicles = (data['Vehicles'] as List<dynamic>? ?? const [])
        .map((v) => Map<String, dynamic>.from(v as Map))
        .where((v) => v['Vehicle_Type'] != vehicleType)
        .toList();
    await _collectorRef(uid).update({'Vehicles': vehicles});
  }

  // ─── Account moderation (UserAccount.Account_Status) ───────────

  /// Admin only. Suspends, closes or reactivates an account. Nothing is
  /// deleted. When an account is blocked, its open bookings are settled so
  /// the other party is not left waiting: a blocked household's Pending and
  /// Accepted bookings are cancelled, and a blocked collector's Accepted
  /// bookings go back to Pending for another collector. Returns a short
  /// summary of what was changed, which is also written to the audit log.
  Future<String> setAccountStatus({
    required String uid,
    required String role,
    required String status,
    String reason = '',
  }) async {
    final adminId = AuthState.instance.uid ?? '';
    await _db.collection(AppConstants.colAccount).doc(uid).update({
      'Account_Status': status,
      'Status_Reason': reason.trim(),
      'Status_Changed_At': FieldValue.serverTimestamp(),
      'Status_Changed_By': adminId,
    });

    var cancelled = 0;
    var reopened = 0;
    if (isAccountBlocked(status)) {
      if (role == AppConstants.roleCollector) {
        try {
          await _collectorRef(uid).update({'Online_Status': false});
        } catch (_) {
          // No collector profile yet — nothing to take offline.
        }
        final assigned = await _db
            .collection(AppConstants.colBookings)
            .where('Collector_ID', isEqualTo: uid)
            .get();
        for (final d in assigned.docs) {
          if (d.data()['Status'] != AppConstants.statusAccepted) continue;
          await d.reference.update(
              {'Status': AppConstants.statusPending, 'Collector_ID': ''});
          reopened++;
          await sendNotification({
            'Recipient_ID': d.data()['Seller_ID'],
            'Booking_ID': d.id,
            'Title': 'Your pickup is open again',
            'Message': 'Your collector is no longer available. Your request '
                'is visible to other collectors again.',
            'Type': 'booking_reopened',
          });
        }
      } else if (role == AppConstants.roleHousehold) {
        final own = await _db
            .collection(AppConstants.colBookings)
            .where('Seller_ID', isEqualTo: uid)
            .get();
        for (final d in own.docs) {
          final s = d.data()['Status'];
          if (s != AppConstants.statusPending &&
              s != AppConstants.statusAccepted) {
            continue;
          }
          await d.reference.update({'Status': AppConstants.statusCancelled});
          cancelled++;
          final collectorId = d.data()['Collector_ID'] as String? ?? '';
          if (collectorId.isNotEmpty) {
            await sendNotification({
              'Recipient_ID': collectorId,
              'Booking_ID': d.id,
              'Title': 'Booking cancelled',
              'Message': 'A pickup you accepted was cancelled because the '
                  'household account is no longer active.',
              'Type': 'booking_cancelled',
            });
          }
        }
      }
    }

    final action = status == accountSuspended
        ? AppConstants.auditSuspendUser
        : status == accountClosed
            ? AppConstants.auditCloseAccount
            : AppConstants.auditReactivateUser;
    final verb = status == accountSuspended
        ? 'suspended'
        : status == accountClosed
            ? 'closed'
            : 'reactivated';
    final parts = <String>[
      'Admin $verb this $role account.',
      if (reason.trim().isNotEmpty) 'Reason: ${reason.trim()}.',
      if (cancelled > 0) '$cancelled open booking(s) cancelled.',
      if (reopened > 0) '$reopened accepted booking(s) reopened for others.',
    ];
    final summary = parts.join(' ');
    await logAction({
      'Actor_ID': adminId,
      'Action': action,
      'Target_ID': uid,
      'Description': summary,
    });
    await sendNotification({
      'Recipient_ID': uid,
      'Title': status == accountActive
          ? 'Account reactivated'
          : (status == accountClosed ? 'Account closed' : 'Account suspended'),
      'Message': status == accountActive
          ? 'Your KiloTap account is active again.'
          : blockedAccountMessage(status, reason),
      'Type': 'account_status',
    });
    return summary;
  }

  // ─── Reports (not a numbered paper table) ───────────────────────

  Future<void> createReport(Map<String, dynamic> data) async {
    final ref = _db.collection(AppConstants.colReports).doc();
    data['Report_ID'] = ref.id;
    data['Status'] = 'Open';
    data['Admin_Action'] = 'None';
    data['Admin_Note'] = '';
    data['Created_At'] = FieldValue.serverTimestamp();
    data['Updated_At'] = FieldValue.serverTimestamp();
    await ref.set(data);
  }

  /// Every report, newest first (admin).
  Stream<List<Report>> allReports() => _db
      .collection(AppConstants.colReports)
      .orderBy('Created_At', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Report.fromMap(d.id, d.data())).toList());

  /// True if [reporterId] already reported this booking (one report each).
  Future<bool> hasReported(String reporterId, String bookingId) async {
    final s = await _db
        .collection(AppConstants.colReports)
        .where('Reporter_ID', isEqualTo: reporterId)
        .get();
    return s.docs.any((d) => d.data()['Booking_ID'] == bookingId);
  }

  Future<void> updateReport(String reportId, Map<String, dynamic> data) async {
    data['Updated_At'] = FieldValue.serverTimestamp();
    await _db.collection(AppConstants.colReports).doc(reportId).update(data);
  }
}
