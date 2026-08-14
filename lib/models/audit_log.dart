import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Table 14: AuditLog ───

class AuditLog {
  final String logId;
  final String actorId;
  final String action;
  final String targetId;
  final String description;
  final DateTime createAt;
  final String ipAddress;

  const AuditLog({
    required this.logId,
    required this.actorId,
    required this.action,
    required this.targetId,
    this.description = '',
    required this.createAt,
    this.ipAddress = '',
  });

  factory AuditLog.fromMap(String id, Map<String, dynamic> m) => AuditLog(
    logId: m['Log_ID'] ?? id,
    actorId: m['Actor_ID'] ?? '',
    action: m['Action'] ?? '',
    targetId: m['Target_ID'] ?? '',
    description: m['Description'] ?? '',
    createAt: (m['Create_At'] as Timestamp?)?.toDate() ?? DateTime.now(),
    ipAddress: m['Ip_Adress'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'Log_ID': logId,
    'Actor_ID': actorId,
    'Action': action,
    'Target_ID': targetId,
    'Description': description,
    'Create_At': createAt,
    'Ip_Adress': ipAddress,
  };
}
