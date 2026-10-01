import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/auth_state.dart';

class VehicleDetailsPage extends StatefulWidget {
  const VehicleDetailsPage({super.key});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleEntry {
  String type;
  final TextEditingController capacityCtrl;
  _VehicleEntry({required this.type, required this.capacityCtrl});
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  static const _maxVehicles = 2;
  late final List<_VehicleEntry> _entries = _loadEntries();
  bool _saving = false;

  List<_VehicleEntry> _loadEntries() {
    final stored = AuthState.instance.vehicles;
    if (stored.isEmpty) {
      return [
        _VehicleEntry(
            type: 'Pushcart', capacityCtrl: TextEditingController(text: '20')),
      ];
    }
    return stored
        .map((v) => _VehicleEntry(
              type: v['Vehicle_Type'] as String? ?? 'Pushcart',
              capacityCtrl: TextEditingController(
                  text: '${(v['Vehicle_Capacity_Kg'] as num?) ?? 20}'),
            ))
        .toList();
  }

  void _addVehicle() {
    if (_entries.length >= _maxVehicles) return;
    setState(() => _entries.add(_VehicleEntry(
        type: 'Pushcart', capacityCtrl: TextEditingController(text: '20'))));
  }

  void _removeVehicle(int i) {
    if (_entries.length <= 1) return;
    setState(() {
      _entries[i].capacityCtrl.dispose();
      _entries.removeAt(i);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final vehicles = _entries
        .map((e) => {
              'Vehicle_Type': e.type,
              'Vehicle_Capacity_Kg': double.tryParse(e.capacityCtrl.text) ?? 0,
            })
        .toList();
    await AuthService.instance.updateCollectorVehicles(vehicles);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.capacityCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Vehicle Details',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 12),
          const Text(
              'Register up to 2 vehicles. You\'ll choose which one is active before going online.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          for (var i = 0; i < _entries.length; i++) ...[
            _VehicleCard(
              entry: _entries[i],
              onTypeChanged: (v) => setState(() => _entries[i].type = v),
              onRemove: _entries.length > 1 ? () => _removeVehicle(i) : null,
            ),
            const SizedBox(height: 10),
          ],
          if (_entries.length < _maxVehicles)
            OutlinedButton.icon(
              onPressed: _addVehicle,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.buyerBlue,
                side: const BorderSide(color: AppColors.buyerBlue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Vehicle'),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'The system recommends but does not enforce. You decide if your vehicle can handle each booking.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buyerBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final _VehicleEntry entry;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback? onRemove;

  const _VehicleCard(
      {required this.entry, required this.onTypeChanged, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        ListTile(
          leading: const Icon(Icons.local_shipping_outlined,
              color: AppColors.textSecondary, size: 22),
          title: const Text('Vehicle Type',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          trailing: SizedBox(
            width: onRemove != null ? 160 : 140,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: entry.type,
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.buyerBlue),
                      items: AppConstants.vehicleTypes
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => onTypeChanged(v!),
                    ),
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: AppColors.textSecondary),
                    onPressed: onRemove,
                  ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        ListTile(
          leading: const Icon(Icons.scale_outlined,
              color: AppColors.textSecondary, size: 22),
          title: const Text('Max Capacity (kg)',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          trailing: SizedBox(
            width: 80,
            child: TextField(
              controller: entry.capacityCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'kg',
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ]),
    );
  }
}
