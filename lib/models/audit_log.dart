import 'package:cloud_firestore/cloud_firestore.dart';

/// Table 12: AuditLog
class AuditLog {
  final String logId;
  final String adminId;
  final String targetId;
  final String actionType;
  final String oldValue;
  final String newValue;
  final DateTime timestamp;

  const AuditLog({required this.logId, required this.adminId,
      required this.targetId, required this.actionType,
      this.oldValue = '', this.newValue = '', required this.timestamp});

  factory AuditLog.fromMap(String id, Map<String, dynamic> m) => AuditLog(
    logId: m['Log_ID'] ?? id,
    adminId: m['Admin_ID'] ?? '',
    targetId: m['Target_ID'] ?? '',
    actionType: m['ActionType'] ?? '',
    oldValue: m['OldValue'] ?? '',
    newValue: m['NewValue'] ?? '',
    timestamp: (m['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
