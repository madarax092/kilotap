import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VehicleDetailsPage extends StatefulWidget {
  const VehicleDetailsPage({super.key});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  String _vehicleType = 'Tricycle';
  final _capacityController = TextEditingController(text: '200');

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Vehicle Details',
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
          const Text('Vehicle information is used for capacity matching',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          // Vehicle type
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: ListTile(
              leading: const Icon(Icons.local_shipping_outlined, color: Color(0xFF9CA3AF), size: 22),
              title: const Text('Vehicle Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              trailing: SizedBox(
                width: 140,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _vehicleType,
                    isDense: true,
                    icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.buyerBlue),
                    items: ['Pushcart', 'Tricycle', 'Multicab', 'Truck']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _vehicleType = v!),
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          // Capacity
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: ListTile(
              leading: const Icon(Icons.scale_outlined, color: Color(0xFF9CA3AF), size: 22),
              title: const Text('Max Capacity (kg)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'kg',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'The system recommends but does not enforce. You decide if your vehicle can handle each booking.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFB45309), height: 1.4),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 30),
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
                  content: Text('Vehicle details saved successfully.'),
                  backgroundColor: AppColors.buyerBlue,
                ));
              },
              child: const Text('SAVE VEHICLE DETAILS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
