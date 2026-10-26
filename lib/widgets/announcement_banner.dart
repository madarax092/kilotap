import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/system_settings.dart';
import '../services/auth_state.dart';
import '../services/system_settings_service.dart';

/// The admin's announcement from System Settings, when one is on for the
/// signed-in user's role. Takes no space otherwise.
class AnnouncementBanner extends StatelessWidget {
  final EdgeInsets padding;
  const AnnouncementBanner(
      {super.key,
      this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 16)});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SystemSettings>(
      valueListenable: SystemSettingsService.instance.current,
      builder: (context, settings, _) {
        final text = settings.announcementFor(AuthState.instance.role ?? '');
        if (text.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: padding,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.campaign_outlined,
                  color: AppColors.buyerBlue, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4)),
              ),
            ]),
          ),
        );
      },
    );
  }
}
