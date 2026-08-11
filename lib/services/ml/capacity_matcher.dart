// ─── Capacity Matcher ───
///
/// Matches total scrap weight to required vehicle type.
/// Enum: Pushcart, Tricycle Sidecar, Multicab, Truck.
///
///   < 20 kg     → Pushcart
///   < 100 kg    → Tricycle Sidecar
///   < 500 kg    → Multicab
///   >= 500 kg   → Truck
///
/// Heavy Override: any item with SizeClass "Heavy Override"
/// forces next vehicle size up.

enum VehicleSize { pushcart, tricycle, multicab, truck }

class CapacityMatcher {
  // TODO: Implement matching logic
  // VehicleSize match(double totalKg, List<String> sizeClasses) { ... }
}
