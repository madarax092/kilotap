import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PrePickupChecklist extends StatefulWidget {
  final List<String> detectedClasses;
  final VoidCallback? onClose;

  const PrePickupChecklist({super.key, required this.detectedClasses, this.onClose});

  @override
  State<PrePickupChecklist> createState() => _PrePickupChecklistState();
}

class _PrePickupChecklistState extends State<PrePickupChecklist> {
  final Map<String, bool> _checked = {};

  static const Map<String, List<String>> _checklistByCategory = {
    'Plastic Bottles': [
      'Empty all liquids from bottles',
      'Remove caps and lids',
      'Place in sack or bag',
    ],
    'Glass Bottles': [
      'Empty all liquids from bottles',
      'Keep separate from other items',
      'Wrap in newspaper to prevent breakage',
    ],
    'Cardboard': [
      'Flatten all boxes',
      'Remove tape and staples',
      'Bundle together with string',
    ],
    'Scrap Metal': [
      'Separate sharp items',
      'Place in sturdy container',
      'Keep away from children and pets',
    ],
    'E-Waste': [
      'Remove batteries if possible',
      'Keep screens and glass protected',
      'Place cords and chargers together',
    ],
    'Appliances': [
      'Clear path to the item',
      'Unplug and disconnect all cables',
      'Remove contents if fridge or freezer',
    ],
    'General': [
      'Place all items near gate or door',
      'Ensure clear path for collector',
      'Keep pets secured in separate area',
    ],
  };

  List<String> get _relevantItems {
    final items = <String>[];
    for (final className in widget.detectedClasses) {
      if (className.contains('plastic')) {
        items.addAll(_checklistByCategory['Plastic Bottles']!);
      } else if (className.contains('glass')) {
        items.addAll(_checklistByCategory['Glass Bottles']!);
      } else if (className.contains('cardboard')) {
        items.addAll(_checklistByCategory['Cardboard']!);
      } else if (className.contains('metal')) {
        items.addAll(_checklistByCategory['Scrap Metal']!);
      } else if (className.contains('refrigerator') ||
                 className.contains('washing') ||
                 className.contains('aircon') ||
                 className.contains('cooker')) {
        items.addAll(_checklistByCategory['Appliances']!);
      } else if (className.contains('computer') ||
                 className.contains('laptop') ||
                 className.contains('tv') ||
                 className.contains('television') ||
                 className.contains('printer') ||
                 className.contains('phone')) {
        items.addAll(_checklistByCategory['E-Waste']!);
      }
    }
    items.addAll(_checklistByCategory['General']!);
    return items.toSet().toList();
  }

  int get _checkedCount => _checked.values.where((v) => v).length;

  @override
  void initState() {
    super.initState();
    for (final item in _relevantItems) {
      _checked[item] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _relevantItems;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Prepare for Pickup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Complete these steps before the collector arrives.',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 10),
            // Optional note — aligns with survey finding
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.buyerBlue.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.buyerBlue.withOpacity(0.1)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.buyerBlue, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Optional — your collector can help with segregation on arrival.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              return CheckboxListTile(
                value: _checked[item] ?? false,
                onChanged: (val) {
                  setState(() {
                    _checked[item] = val ?? false;
                  });
                },
                title: Text(item, style: const TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sellerGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_checkedCount > 0
                    ? 'Done ($_checkedCount of ${items.length} checked)'
                    : 'Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
