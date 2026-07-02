import 'package:cloud_firestore/cloud_firestore.dart';

/// tblAuditLog — Admin action tracking for accountability
/// Firestore: 'auditLogs' collection
class AuditLogModel {
  final String logId;
  final String adminId;   // FK → tblScrapSeller (admin account)
  final String targetId;  // ID of the document that was modified
  final String actionType; // VERIFY_COLLECTOR, SUSPEND_USER, RESOLVE_REPORT
  final String? oldValue;
  final String? newValue;
  final DateTime timestamp;

  const AuditLogModel({
    required this.logId,
    required this.adminId,
    required this.targetId,
    required this.actionType,
    this.oldValue,
    this.newValue,
    required this.timestamp,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLogModel(
      logId: doc.id,
      adminId: data['Admin_ID'] ?? '',
      targetId: data['Target_ID'] ?? '',
      actionType: data['ActionType'] ?? '',
      oldValue: data['OldValue'],
      newValue: data['NewValue'],
      timestamp: (data['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'Admin_ID': adminId,
    'Target_ID': targetId,
    'ActionType': actionType,
    'OldValue': oldValue,
    'NewValue': newValue,
    'Timestamp': Timestamp.fromDate(timestamp),
  };
}
