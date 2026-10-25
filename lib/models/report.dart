import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Report (not one of the paper's numbered Tables 7-15) ───
// A household or collector reporting the other party of a booking; reviewed
// by an admin in screens/admin/reports_screen.dart.

class Report {
  final String reportId;
  final String reporterId;
  final String reporterRole;
  final String targetId;
  final String targetRole;
  final String bookingId;
  final String category;
  final String description;
  // 'Open' | 'Investigating' | 'Resolved' | 'Dismissed'
  final String status;
  // 'None' | 'Warned' | 'Suspended'
  final String adminAction;
  final String adminNote;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Report({
    required this.reportId,
    required this.reporterId,
    this.reporterRole = '',
    required this.targetId,
    this.targetRole = '',
    required this.bookingId,
    required this.category,
    this.description = '',
    this.status = 'Open',
    this.adminAction = 'None',
    this.adminNote = '',
    required this.createdAt,
    this.updatedAt,
  });

  bool get isClosed => status == 'Resolved' || status == 'Dismissed';

  factory Report.fromMap(String id, Map<String, dynamic> m) => Report(
        reportId: m['Report_ID'] ?? id,
        reporterId: m['Reporter_ID'] ?? '',
        reporterRole: m['Reporter_Role'] ?? '',
        targetId: m['Target_ID'] ?? '',
        targetRole: m['Target_Role'] ?? '',
        bookingId: m['Booking_ID'] ?? '',
        category: m['Category'] ?? '',
        description: m['Description'] ?? '',
        status: m['Status'] ?? 'Open',
        adminAction: m['Admin_Action'] ?? 'None',
        adminNote: m['Admin_Note'] ?? '',
        createdAt: (m['Created_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (m['Updated_At'] as Timestamp?)?.toDate(),
      );
}
