// ─── System settings (systemSettings/global — not a numbered paper table) ───
// Platform-wide values an admin can change in System Settings. A missing
// document or field falls back to the default, which matches how the app
// behaved before these were configurable. The vehicle weight thresholds
// (paper 2.3.2.2) and the detector's confidence threshold are deliberately
// not here: they must match the paper and the published model results.

class SystemSettings {
  // Dispatch (read by the Cloud Functions in functions/index.js).
  final int dispatchWaveSize;
  final int dispatchRemindAfterMin;
  final int dispatchWidenEveryMin;
  final int dispatchWindowMin;

  // Bookings.
  final int cancelWindowMin;
  final bool bookingsPaused;
  final String bookingsPausedMessage;

  // Announcement banner on the dashboards.
  final bool announcementOn;
  final String announcementText;
  final String announcementAudience; // 'All' | 'Household' | 'Collector'

  // Support contact shown in Help & Support.
  final String supportEmail;
  final String supportPhone;

  const SystemSettings({
    this.dispatchWaveSize = 5,
    this.dispatchRemindAfterMin = 5,
    this.dispatchWidenEveryMin = 10,
    this.dispatchWindowMin = 60,
    this.cancelWindowMin = 2,
    this.bookingsPaused = false,
    this.bookingsPausedMessage = '',
    this.announcementOn = false,
    this.announcementText = '',
    this.announcementAudience = 'All',
    this.supportEmail = 'support@kilotap.com',
    this.supportPhone = '+63 917 123 4567',
  });

  static const defaults = SystemSettings();

  static const audiences = ['All', 'Household', 'Collector'];

  // Allowed ranges, shared by the settings form and fromMap (the Cloud
  // Functions apply the same ranges to the dispatch values).
  static const waveSizeRange = (1, 20);
  static const remindAfterRange = (1, 60);
  static const widenEveryRange = (1, 60);
  static const windowRange = (10, 240);
  static const cancelWindowRange = (0, 60);

  static int _int(dynamic v, int fallback, (int, int) range) {
    final n = v is num ? v.toInt() : int.tryParse('$v');
    if (n == null || n < range.$1 || n > range.$2) return fallback;
    return n;
  }

  factory SystemSettings.fromMap(Map<String, dynamic>? m) {
    const d = defaults;
    if (m == null) return d;
    final audience = m['Announcement_Audience'] as String? ?? d.announcementAudience;
    return SystemSettings(
      dispatchWaveSize:
          _int(m['Dispatch_Wave_Size'], d.dispatchWaveSize, waveSizeRange),
      dispatchRemindAfterMin: _int(m['Dispatch_Remind_After_Min'],
          d.dispatchRemindAfterMin, remindAfterRange),
      dispatchWidenEveryMin: _int(m['Dispatch_Widen_Every_Min'],
          d.dispatchWidenEveryMin, widenEveryRange),
      dispatchWindowMin:
          _int(m['Dispatch_Window_Min'], d.dispatchWindowMin, windowRange),
      cancelWindowMin:
          _int(m['Cancel_Window_Min'], d.cancelWindowMin, cancelWindowRange),
      bookingsPaused: m['Bookings_Paused'] == true,
      bookingsPausedMessage: m['Bookings_Paused_Message'] as String? ?? '',
      announcementOn: m['Announcement_On'] == true,
      announcementText: m['Announcement_Text'] as String? ?? '',
      announcementAudience:
          audiences.contains(audience) ? audience : d.announcementAudience,
      supportEmail: (m['Support_Email'] as String?)?.trim().isNotEmpty == true
          ? m['Support_Email'] as String
          : d.supportEmail,
      supportPhone: (m['Support_Phone'] as String?)?.trim().isNotEmpty == true
          ? m['Support_Phone'] as String
          : d.supportPhone,
    );
  }

  Map<String, dynamic> toMap() => {
        'Dispatch_Wave_Size': dispatchWaveSize,
        'Dispatch_Remind_After_Min': dispatchRemindAfterMin,
        'Dispatch_Widen_Every_Min': dispatchWidenEveryMin,
        'Dispatch_Window_Min': dispatchWindowMin,
        'Cancel_Window_Min': cancelWindowMin,
        'Bookings_Paused': bookingsPaused,
        'Bookings_Paused_Message': bookingsPausedMessage,
        'Announcement_On': announcementOn,
        'Announcement_Text': announcementText,
        'Announcement_Audience': announcementAudience,
        'Support_Email': supportEmail,
        'Support_Phone': supportPhone,
      };

  /// The announcement to show a user of [role], or '' for none.
  String announcementFor(String role) {
    if (!announcementOn || announcementText.trim().isEmpty) return '';
    if (announcementAudience != 'All' && announcementAudience != role) {
      return '';
    }
    return announcementText.trim();
  }

  String get pausedMessage => bookingsPausedMessage.trim().isNotEmpty
      ? bookingsPausedMessage.trim()
      : 'New pickup requests are paused for now. Please try again later.';

  /// One line per changed field, "Field: old -> new", for the audit log.
  List<String> changesFrom(SystemSettings old) {
    final before = old.toMap();
    final after = toMap();
    return [
      for (final k in after.keys)
        if ('${before[k]}' != '${after[k]}')
          '$k: "${before[k]}" -> "${after[k]}"',
    ];
  }
}
