import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/notification.dart';
import '../services/auth_state.dart';
import '../services/firestore_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'booking_accepted':
        return Icons.local_shipping_outlined;
      case 'booking_completed':
        return Icons.check_circle_outline;
      case 'booking_cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AuthState.instance.isCollector
        ? AppColors.buyerBlue
        : AppColors.sellerGreen;
    final top = MediaQuery.of(context).padding.top;
    final svc = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: top + 16, left: 20, right: 20, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                const Text('Notifications',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppNotification>>(
              stream: svc.userNotifications(AuthState.instance.uid ?? ''),
              builder: (context, snapshot) {
                final notifications =
                    snapshot.data ?? const <AppNotification>[];
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('No notifications yet.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final n = notifications[i];
                    return Material(
                      color: n.isRead
                          ? Colors.white
                          : accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          if (!n.isRead) {
                            svc.markNotificationRead(n.notificationId);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.12),
                                    shape: BoxShape.circle),
                                child: Icon(_iconFor(n.type),
                                    color: accent, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(n.message,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary)),
                                    const SizedBox(height: 6),
                                    Text(_timeAgo(n.timestamp),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                      color: accent, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
