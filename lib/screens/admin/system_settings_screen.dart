import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/input_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../models/system_settings.dart';
import '../../services/system_settings_service.dart';

/// Admin-only platform settings (systemSettings/global). Every save writes
/// one UPDATE_SETTINGS audit entry with each changed value, old and new.
class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late SystemSettings _s = SystemSettingsService.instance.current.value;

  late final _waveCtrl = TextEditingController(text: '${_s.dispatchWaveSize}');
  late final _remindCtrl =
      TextEditingController(text: '${_s.dispatchRemindAfterMin}');
  late final _widenCtrl =
      TextEditingController(text: '${_s.dispatchWidenEveryMin}');
  late final _windowCtrl =
      TextEditingController(text: '${_s.dispatchWindowMin}');
  late final _cancelCtrl = TextEditingController(text: '${_s.cancelWindowMin}');
  late final _pausedMsgCtrl =
      TextEditingController(text: _s.bookingsPausedMessage);
  late final _announceCtrl = TextEditingController(text: _s.announcementText);
  late final _emailCtrl = TextEditingController(text: _s.supportEmail);
  late final _phoneCtrl = TextEditingController(text: _s.supportPhone);

  late bool _paused = _s.bookingsPaused;
  late bool _announceOn = _s.announcementOn;
  late String _audience = _s.announcementAudience;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _waveCtrl,
      _remindCtrl,
      _widenCtrl,
      _windowCtrl,
      _cancelCtrl,
      _pausedMsgCtrl,
      _announceCtrl,
      _emailCtrl,
      _phoneCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _range(String? v, (int, int) range) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null) return 'Enter a whole number';
    if (n < range.$1 || n > range.$2) {
      return 'Must be from ${range.$1} to ${range.$2}';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = SystemSettings(
      dispatchWaveSize: int.parse(_waveCtrl.text.trim()),
      dispatchRemindAfterMin: int.parse(_remindCtrl.text.trim()),
      dispatchWidenEveryMin: int.parse(_widenCtrl.text.trim()),
      dispatchWindowMin: int.parse(_windowCtrl.text.trim()),
      cancelWindowMin: int.parse(_cancelCtrl.text.trim()),
      bookingsPaused: _paused,
      bookingsPausedMessage: _pausedMsgCtrl.text.trim(),
      announcementOn: _announceOn,
      announcementText: _announceCtrl.text.trim(),
      announcementAudience: _audience,
      supportEmail: _emailCtrl.text.trim(),
      supportPhone: _phoneCtrl.text.trim(),
    );
    setState(() => _saving = true);
    try {
      final changed = await SystemSettingsService.instance.save(updated);
      if (!mounted) return;
      _s = updated;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(changed == 0
            ? 'Nothing changed.'
            : 'Saved $changed change${changed == 1 ? '' : 's'}. Recorded in the audit log.'),
        backgroundColor: changed == 0 ? null : AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not save settings: $e'),
          backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('System Settings',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _Section(
              title: 'DISPATCH',
              note: 'How collectors are alerted about a new pickup. Every '
                  'eligible collector can still see it in Find Scrap.',
              children: [
                _NumberField(
                    label: 'Collectors alerted per wave',
                    controller: _waveCtrl,
                    validator: (v) =>
                        _range(v, SystemSettings.waveSizeRange)),
                _NumberField(
                    label: 'Remind them after (minutes)',
                    controller: _remindCtrl,
                    validator: (v) =>
                        _range(v, SystemSettings.remindAfterRange)),
                _NumberField(
                    label: 'Alert the next wave every (minutes)',
                    controller: _widenCtrl,
                    validator: (v) =>
                        _range(v, SystemSettings.widenEveryRange)),
                _NumberField(
                    label: 'Stop alerting after (minutes)',
                    controller: _windowCtrl,
                    validator: (v) => _range(v, SystemSettings.windowRange)),
              ],
            ),
            _Section(
              title: 'BOOKINGS',
              children: [
                _NumberField(
                    label: 'Household can cancel a pending request within (minutes)',
                    controller: _cancelCtrl,
                    validator: (v) =>
                        _range(v, SystemSettings.cancelWindowRange)),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pause new pickup requests',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                        'Households cannot submit until you turn this off',
                        style: TextStyle(fontSize: 12)),
                    value: _paused,
                    activeThumbColor: AppColors.adminRed,
                    onChanged: (v) => setState(() => _paused = v),
                  ),
                ),
                if (_paused)
                  _TextField(
                    label: 'Message shown to households',
                    hint: 'New pickup requests are paused for now.',
                    controller: _pausedMsgCtrl,
                    maxLines: 2,
                  ),
              ],
            ),
            _Section(
              title: 'ANNOUNCEMENT',
              note: 'A banner on the dashboard.',
              children: [
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show announcement',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    value: _announceOn,
                    activeThumbColor: AppColors.adminRed,
                    onChanged: (v) => setState(() => _announceOn = v),
                  ),
                ),
                if (_announceOn) ...[
                  _TextField(
                    label: 'Announcement',
                    hint: 'e.g. No pickups on Nov 1 (holiday).',
                    controller: _announceCtrl,
                    maxLines: 3,
                    validator: (v) => validateRequired(v, 'announcement'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _audience,
                    decoration: _decoration('Show to'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('Everyone')),
                      DropdownMenuItem(
                          value: 'Household', child: Text('Households only')),
                      DropdownMenuItem(
                          value: 'Collector', child: Text('Collectors only')),
                    ],
                    onChanged: (v) => setState(() => _audience = v ?? 'All'),
                  ),
                ],
              ],
            ),
            _Section(
              title: 'SUPPORT CONTACT',
              note: 'Shown in Help & Support for every role.',
              children: [
                _TextField(
                  label: 'Support email',
                  hint: 'support@kilotap.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                _TextField(
                  label: 'Support phone',
                  hint: '+63 9XX XXX XXXX',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) => validateRequired(v, 'support phone'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('SAVE SETTINGS',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _decoration(String label, [String? hint]) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c));
  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorMaxLines: 2,
    filled: true,
    fillColor: Colors.white,
    border: border(const Color(0xFFE5E7EB)),
    enabledBorder: border(const Color(0xFFE5E7EB)),
    focusedBorder: border(AppColors.adminRed),
    errorBorder: border(AppColors.error),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final String? note;
  final List<Widget> children;
  const _Section({required this.title, this.note, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(note!,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  const _NumberField(
      {required this.label, required this.controller, required this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validator,
        decoration: _decoration(label),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _decoration(label, hint),
      ),
    );
  }
}
