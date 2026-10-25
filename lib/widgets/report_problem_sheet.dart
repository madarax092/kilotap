import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_state.dart';
import '../services/firestore_service.dart';

// Reasons a household can give about its collector, and a collector about
// the household. Kept to conduct and logistics — never price or payment.
const List<String> _householdReasons = [
  'Collector did not arrive',
  'Late or no update',
  'Rude or unprofessional',
  'Took the wrong items or left items behind',
  'Unsafe behavior',
  'Other',
];
const List<String> _collectorReasons = [
  'Household not present',
  'Items not as described',
  'Wrong pickup location',
  'Rude or unsafe behavior',
  'Other',
];

/// Lets the signed-in household or collector report the other party of
/// [bookingId]. The report goes to the admin Reports screen. One report per
/// person per booking.
Future<void> showReportProblemSheet(BuildContext context,
    {required String bookingId}) async {
  final svc = FirestoreService();
  final uid = AuthState.instance.uid ?? '';
  final messenger = ScaffoldMessenger.of(context);

  final booking = await svc.getBooking(bookingId);
  if (booking == null) {
    messenger.showSnackBar(
        const SnackBar(content: Text('This pickup could not be loaded.')));
    return;
  }
  final iAmSeller = booking.sellerId == uid;
  final targetId = iAmSeller ? booking.collectorId : booking.sellerId;
  if (targetId.isEmpty) {
    messenger.showSnackBar(const SnackBar(
        content: Text('No collector has accepted this pickup yet.')));
    return;
  }
  if (await svc.hasReported(uid, bookingId)) {
    messenger.showSnackBar(const SnackBar(
        content: Text('You already reported this pickup. An admin will '
            'review it.')));
    return;
  }
  final targetName = await svc.displayNameFor(targetId);
  if (!context.mounted) return;

  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _ReportForm(
      bookingId: bookingId,
      targetId: targetId,
      targetName: targetName,
      targetRole:
          iAmSeller ? AppConstants.roleCollector : AppConstants.roleHousehold,
      reasons: iAmSeller ? _householdReasons : _collectorReasons,
    ),
  );
  if (sent == true) {
    messenger.showSnackBar(const SnackBar(
        content: Text('Report sent. An admin will review it.')));
  }
}

class _ReportForm extends StatefulWidget {
  final String bookingId, targetId, targetName, targetRole;
  final List<String> reasons;
  const _ReportForm({
    required this.bookingId,
    required this.targetId,
    required this.targetName,
    required this.targetRole,
    required this.reasons,
  });

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  String? _reason;
  final _details = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_reason == null) {
      setState(() => _error = 'Choose what happened.');
      return;
    }
    if (_details.text.trim().length < 10) {
      setState(() => _error = 'Describe what happened (at least 10 characters).');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await FirestoreService().createReport({
        'Reporter_ID': AuthState.instance.uid,
        'Reporter_Role': AuthState.instance.role,
        'Target_ID': widget.targetId,
        'Target_Role': widget.targetRole,
        'Booking_ID': widget.bookingId,
        'Category': _reason,
        'Description': _details.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = 'Could not send the report: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortId = widget.bookingId.length >= 6
        ? widget.bookingId.substring(0, 6).toUpperCase()
        : widget.bookingId.toUpperCase();
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report a problem',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('About ${widget.targetName} · pickup #$shortId',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const Text('What happened?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in widget.reasons)
                  ChoiceChip(
                    label: Text(r, style: const TextStyle(fontSize: 12)),
                    selected: _reason == r,
                    selectedColor: AppColors.sellerGreen.withValues(alpha: 0.15),
                    onSelected: _sending
                        ? null
                        : (_) => setState(() {
                              _reason = r;
                              _error = null;
                            }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _details,
              enabled: !_sending,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Details',
                hintText: 'What happened, and when?',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            const Text(
                'An admin reviews every report. The other person is not told '
                'who reported them unless the admin needs to ask them about it.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _sending ? null : _send,
                child: Text(_sending ? 'Sending...' : 'Send report',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
