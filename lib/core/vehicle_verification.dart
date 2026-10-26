// Per-vehicle approval (ScrapCollector.Verified_Vehicles, admin-only — see
// firestore.rules). A verified collector can only go online with, and accept
// bookings for, a vehicle type an admin has approved; a vehicle added after
// verification stays pending until approved.

List<String> effectiveVerifiedVehicles(Map<String, dynamic>? collector) {
  if (collector == null) return const [];
  final stored = collector['Verified_Vehicles'];
  if (stored is List) return List<String>.from(stored);
  // Collectors verified before per-vehicle approval existed: the vehicle
  // they were active with counts as approved. firestore.rules applies the
  // same fallback, so both sides agree.
  if (collector['Verification_Status'] == 'Verified') {
    final active = collector['Vehicle_Type'];
    if (active is String && active.isNotEmpty) return [active];
  }
  return const [];
}

// Plate number of one registered vehicle (ScrapCollector.Vehicles[] entry
// field Plate_Number — not in the paper's Table 9). A pushcart has no plate.
bool vehicleNeedsPlate(String vehicleType) => vehicleType != 'Pushcart';

String plateNumberOf(Map<String, dynamic>? collector, String vehicleType) {
  final vehicles = collector?['Vehicles'] as List<dynamic>? ?? const [];
  for (final v in vehicles) {
    if (v is Map && v['Vehicle_Type'] == vehicleType) {
      return (v['Plate_Number'] as String? ?? '').trim();
    }
  }
  return '';
}

// Vehicle types a verified collector has registered but an admin hasn't
// approved yet. Empty for unverified collectors — their whole account is
// still under review, so per-vehicle approval doesn't apply yet.
List<String> pendingVehicleTypes(Map<String, dynamic>? collector) {
  if (collector == null || collector['Verification_Status'] != 'Verified') {
    return const [];
  }
  final approved = effectiveVerifiedVehicles(collector);
  final vehicles = (collector['Vehicles'] as List<dynamic>? ?? const [])
      .map((v) => (v as Map)['Vehicle_Type'] as String? ?? '')
      .where((t) => t.isNotEmpty && !approved.contains(t))
      .toSet()
      .toList();
  return vehicles;
}
