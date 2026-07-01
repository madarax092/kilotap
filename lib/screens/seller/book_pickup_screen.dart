import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/seller_provider.dart';
import '../../widgets/common/custom_button.dart';

class BookPickupScreen extends ConsumerStatefulWidget {
  const BookPickupScreen({super.key});

  @override
  ConsumerState<BookPickupScreen> createState() => _BookPickupScreenState();
}

class _BookPickupScreenState extends ConsumerState<BookPickupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedScrapType;
  String? _selectedScrapIcon;
  double _estimatedWeightKg = 5.0;
  String _selectedTimeSlot = AppConstants.timeSlots[0];
  int _scheduleDayOffset = 0; // 0=today, 1=tomorrow, 2=custom
  DateTime _customDate = DateTime.now().add(const Duration(days: 2));

  double get _estimatedValue {
    final scrap = AppConstants.scrapTypes
        .where((s) => s.name == _selectedScrapType)
        .firstOrNull;
    if (scrap == null) return 0;
    return scrap.pricePerKg * _estimatedWeightKg;
  }

  DateTime get _scheduledAt {
    final now = DateTime.now();
    if (_scheduleDayOffset == 0) return now;
    if (_scheduleDayOffset == 1) return now.add(const Duration(days: 1));
    return _customDate;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedScrapType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a scrap type')),
      );
      return;
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final success = await ref.read(bookPickupProvider.notifier).bookPickup(
          sellerId: user.uid,
          sellerName: user.displayName,
          scrapType: _selectedScrapType!,
          scrapTypeIcon: _selectedScrapIcon ?? '📦',
          estimatedWeightKg: _estimatedWeightKg,
          estimatedValue: _estimatedValue,
          address: _addressCtrl.text.trim(),
          scheduledAt: _scheduledAt,
          timeSlot: _selectedTimeSlot,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup booked successfully! 🎉'),
            backgroundColor: AppColors.sellerGreen,
          ),
        );
        context.pop();
      }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookPickupProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.appCanvas,
      appBar: AppBar(
        title: const Text('Book a Pickup'),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Schedule a scrap collection',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              // Section 1: Scrap Type
              _buildSectionCard(
                title: 'What are you selling?',
                child: _buildScrapTypeSelector(),
              ),
              const SizedBox(height: 16),

              // Section 2: Weight
              _buildSectionCard(
                title: 'Estimated Weight',
                child: _buildWeightSelector(),
              ),
              const SizedBox(height: 16),

              // Section 3: Pickup Address
              _buildSectionCard(
                title: 'Pickup Address',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: InputDecoration(
                        hintText: '123 Rizal Ave, Quezon City',
                        prefixIcon: const Icon(Icons.location_on_outlined,
                            color: AppColors.textHint, size: 20),
                      ),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        '📍 Use current location',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.sellerGreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 4: Schedule
              _buildSectionCard(
                title: 'Select Date & Time',
                child: _buildScheduleSelector(),
              ),
              const SizedBox(height: 16),

              // Section 5: Notes
              _buildSectionCard(
                title: 'Additional Notes (Optional)',
                child: TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Any special instructions...',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Confirm button
              KiloTapButton(
                label: 'Confirm Booking',
                backgroundColor: AppColors.sellerGreen,
                icon: Icons.check_circle_outline,
                isLoading: isLoading,
                onPressed: _handleConfirmBooking,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildScrapTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.scrapTypes.map((scrap) {
        final isSelected = _selectedScrapType == scrap.name;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedScrapType = scrap.name;
            _selectedScrapIcon = scrap.icon;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sellerGreen : AppColors.inputBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.sellerGreen : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(scrap.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  scrap.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.pureWhite : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightSelector() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '${_estimatedWeightKg.toStringAsFixed(0)} kg',
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.sellerGreen),
            ),
            const Spacer(),
            if (_selectedScrapType != null)
              Text(
                'Est. value: ₱${_estimatedValue.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.sellerGreen),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.sellerGreen,
            thumbColor: AppColors.sellerGreen,
            overlayColor: AppColors.sellerGreenSurface,
            inactiveTrackColor: AppColors.inputBackground,
          ),
          child: Slider(
            value: _estimatedWeightKg,
            min: 0.5,
            max: 100,
            divisions: 199,
            onChanged: (v) => setState(() => _estimatedWeightKg = v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0.5 kg', style: AppTextStyles.caption),
            Text('100 kg', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day selector
        Row(
          children: [
            _DayChip(label: 'Today', isSelected: _scheduleDayOffset == 0,
                onTap: () => setState(() => _scheduleDayOffset = 0)),
            const SizedBox(width: 8),
            _DayChip(label: 'Tomorrow', isSelected: _scheduleDayOffset == 1,
                onTap: () => setState(() => _scheduleDayOffset = 1)),
            const SizedBox(width: 8),
            _DayChip(label: 'Pick Date', isSelected: _scheduleDayOffset == 2,
                onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _customDate,
                firstDate: DateTime.now().add(const Duration(days: 2)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() {
                  _customDate = picked;
                  _scheduleDayOffset = 2;
                });
              }
            }),
          ],
        ),
        const SizedBox(height: 12),
        // Time slot
        Text('Time Slot', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTimeSlot,
          decoration: const InputDecoration(),
          items: AppConstants.timeSlots.map((slot) {
            return DropdownMenuItem(value: slot, child: Text(slot));
          }).toList(),
          onChanged: (v) => setState(() => _selectedTimeSlot = v!),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sellerGreen : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.sellerGreen : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.pureWhite : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
