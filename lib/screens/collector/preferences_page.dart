import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/material_preferences.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final List<String> _selected = ['Metal', 'Appliances'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Material Preferences',
            style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: const Color(0xFFE5E7EB), height: 1.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          const Text(
            'Select the materials you buy. You will only receive notifications for bookings that include at least one of these categories.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MaterialPreferences.categories.map((category) {
              final isSelected = _selected.contains(category);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selected.remove(category);
                    } else {
                      _selected.add(category);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.buyerBlue.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.buyerBlue.withOpacity(0.4)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        size: 20,
                        color: isSelected ? AppColors.buyerBlue : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.buyerBlue : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (_selected.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
              ),
              child: const Text(
                'If nothing is selected, you will receive all booking notifications.',
                style: TextStyle(fontSize: 13, color: Color(0xFFB45309), height: 1.4),
              ),
            ),
          if (_selected.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'You will receive bookings that include: ${_selected.join(", ")}',
              style: const TextStyle(fontSize: 12, color: AppColors.buyerBlue, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buyerBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Preferences saved successfully.'),
                  backgroundColor: AppColors.buyerBlue,
                ));
              },
              child: const Text('SAVE PREFERENCES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
