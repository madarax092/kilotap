import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/app_permissions.dart';
import '../services/cache_service.dart';

const _promptShownKey = 'permission_prompt_shown';

/// After the first sign-in on this phone, explains why KiloTap needs
/// notifications and location, then asks for both. Shown once per install.
Future<void> maybeShowFirstRunPermissionPrompt(BuildContext context) async {
  try {
    if (CacheService.instance.getPref(_promptShownKey) == true) return;
    final notifOk = await AppPermission.notifications.isGranted;
    final locationOk = await AppPermission.location.isGranted;
    await CacheService.instance.setPref(_promptShownKey, true);
    if (notifOk && locationOk) return;
    if (!context.mounted) return;
    final allow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Turn on notifications and location'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Reason(Icons.notifications_outlined, 'Notifications',
                'So you are alerted when a pickup is accepted, a collector is on the way, or a new request is near you.'),
            SizedBox(height: 12),
            _Reason(Icons.location_on_outlined, 'Location',
                'So KiloTap can find your place automatically and match pickups with nearby collectors.'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not now')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Turn on')),
        ],
      ),
    );
    if (allow != true) return;
    if (!notifOk) await AppPermission.notifications.request();
    if (!locationOk) await AppPermission.location.request();
  } catch (_) {
    // Never block the dashboard on a permission prompt.
  }
}

class _Reason extends StatelessWidget {
  final IconData icon;
  final String title, text;
  const _Reason(this.icon, this.title, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppColors.sellerGreen, size: 22),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(text,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
        ]),
      ),
    ]);
  }
}

/// Place once on each dashboard: runs the first-run prompt after the first
/// frame and takes no space.
class FirstRunPermissionPrompt extends StatefulWidget {
  const FirstRunPermissionPrompt({super.key});

  @override
  State<FirstRunPermissionPrompt> createState() =>
      _FirstRunPermissionPromptState();
}

class _FirstRunPermissionPromptState extends State<FirstRunPermissionPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) maybeShowFirstRunPermissionPrompt(context);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// One permission as a row with its live status and a Turn on button
/// (used in Pickup Preferences).
class PermissionStatusTile extends StatefulWidget {
  final AppPermission permission;
  final String reason;
  const PermissionStatusTile(
      {super.key, required this.permission, required this.reason});

  @override
  State<PermissionStatusTile> createState() => _PermissionStatusTileState();
}

class _PermissionStatusTileState extends State<PermissionStatusTile>
    with WidgetsBindingObserver {
  bool? _granted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Coming back from the phone's settings may have changed the answer.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final g = await widget.permission.isGranted;
    if (mounted) setState(() => _granted = g);
  }

  Future<void> _turnOn() async {
    await widget.permission.request();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final granted = _granted ?? false;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(widget.permission.icon,
            color: granted ? AppColors.sellerGreen : AppColors.textMuted),
        title: Text(widget.permission.label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        subtitle: Text(
            _granted == null
                ? 'Checking...'
                : granted
                    ? 'On. ${widget.reason}'
                    : 'Off. ${widget.reason}',
            style: const TextStyle(fontSize: 12)),
        trailing: granted
            ? const Icon(Icons.check_circle, color: AppColors.sellerGreen)
            : TextButton(onPressed: _turnOn, child: const Text('Turn on')),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
