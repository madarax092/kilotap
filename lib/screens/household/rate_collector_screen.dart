import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';

class RateCollectorScreen extends StatefulWidget {
  final String collectorId;
  final String bookingId;
  final String collectorName;

  const RateCollectorScreen({
    super.key,
    required this.collectorId,
    required this.bookingId,
    required this.collectorName,
  });

  @override
  State<RateCollectorScreen> createState() => _RateCollectorScreenState();
}

class _RateCollectorScreenState extends State<RateCollectorScreen> {
  static const _tagOptions = [
    'On Time',
    'Professional',
    'Handled Carefully',
    'Good Communication',
  ];

  int _rating = 5;
  final Set<String> _selectedTags = {};
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await FirestoreService().createRating({
        'Booking_ID': widget.bookingId,
        'Seller_ID': AuthState.instance.uid,
        'Collector_ID': widget.collectorId,
        'Score': _rating,
        'Feedback_Text': _commentController.text.trim(),
        'Tags': _selectedTags.toList(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.collectorName.trim().isNotEmpty
        ? widget.collectorName
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0])
            .join()
            .toUpperCase()
        : '?';
    return Scaffold(
      backgroundColor: Colors.black38,
      body: Center(
          child: Container(
        margin: const EdgeInsets.all(28),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40)
            ]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Rate Your Collector',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('How was your experience?',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppColors.buyerBlue, shape: BoxShape.circle),
                  child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(widget.collectorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                  ])),
            ]),
          ),
          const SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  5,
                  (i) => IconButton(
                        iconSize: 36,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            color: AppColors.star),
                        onPressed: () => setState(() => _rating = i + 1),
                      ))),
          const SizedBox(height: 16),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tagOptions
                  .map((t) => GestureDetector(
                        onTap: () => setState(() => _selectedTags.contains(t)
                            ? _selectedTags.remove(t)
                            : _selectedTags.add(t)),
                        child: Chip(
                          label: Text(t,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                          backgroundColor: _selectedTags.contains(t)
                              ? AppColors.sellerGreen
                              : AppColors.inputGrey,
                          labelStyle: TextStyle(
                              color: _selectedTags.contains(t)
                                  ? Colors.white
                                  : AppColors.textSecondary),
                        ),
                      ))
                  .toList()),
          const SizedBox(height: 16),
          TextField(
              controller: _commentController,
              decoration: InputDecoration(
                  hintText: 'Add a comment (optional)...',
                  filled: true,
                  fillColor: AppColors.inputGrey,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.divider))),
              maxLines: 2),
          const SizedBox(height: 20),
          SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sellerGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('SUBMIT RATING',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)))),
        ]),
      )),
    );
  }
}
