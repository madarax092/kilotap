import 'package:cloud_firestore/cloud_firestore.dart';

/// Table 14: AuditLog
class AuditLog {
  final String logId;
  final String actorId;
  final String action;
  final String targetId;
  final String previousValue;
  final String newValue;
  final String reason;
  final DateTime timestamp;

  const AuditLog({
    required this.logId,
    required this.actorId,
    required this.action,
    required this.targetId,
    this.previousValue = '',
    this.newValue = '',
    this.reason = '',
    required this.timestamp,
  });

  factory AuditLog.fromMap(String id, Map<String, dynamic> m) => AuditLog(
    logId: m['Log_ID'] ?? id,
    actorId: m['Actor_ID'] ?? '',
    action: m['Action'] ?? '',
    targetId: m['Target_ID'] ?? '',
    previousValue: m['Previous_Value'] ?? '',
    newValue: m['New_Value'] ?? '',
    reason: m['Reason'] ?? '',
    timestamp: (m['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
