// ─── Capacity Matcher ───
///
/// Matches total scrap weight + item sizes to required vehicle type.
/// Vehicle enum: Pushcart, Tricycle Sidecar, Multicab, Truck.
///
/// Weight thresholds:
///   < 20 kg     → Pushcart
///   < 100 kg    → Tricycle Sidecar
///   < 500 kg    → Multicab
///   >= 500 kg   → Truck
///
/// Heavy Override: any item with SizeClass "Heavy Override"
/// forces the next vehicle size up (single large appliance can't
/// fit in a small vehicle even if the weight is low).

enum VehicleSize {
  pushcart('Pushcart'),
  tricycle('Tricycle Sidecar'),
  multicab('Multicab'),
  truck('Truck');

  final String label;
  const VehicleSize(this.label);
}

class CapacityMatcher {
  CapacityMatcher._();

  /// Matches total weight + size classes to a vehicle.
  ///
  /// [totalKg] — total estimated scrap weight.
  /// [sizeClasses] — list of SizeClass per item (from ScrapWeightService).
  static VehicleSize match({
    required double totalKg,
    required List<String> sizeClasses,
  }) {
    // 1. Base vehicle by weight
    VehicleSize size = _byWeight(totalKg);

    // 2. Heavy Override: bump up one size if any item needs it
    if (sizeClasses.contains('Heavy Override')) {
      size = _bumpUp(size);
    }

    return size;
  }

  /// Base vehicle selection by total weight.
  static VehicleSize _byWeight(double totalKg) {
    if (totalKg < 20) return VehicleSize.pushcart;
    if (totalKg < 100) return VehicleSize.tricycle;
    if (totalKg < 500) return VehicleSize.multicab;
    return VehicleSize.truck;
  }

  /// Bump up one vehicle size (never goes below pushcart, never above truck).
  static VehicleSize _bumpUp(VehicleSize current) {
    switch (current) {
      case VehicleSize.pushcart:
        return VehicleSize.tricycle;
      case VehicleSize.tricycle:
        return VehicleSize.multicab;
      case VehicleSize.multicab:
      case VehicleSize.truck:
        return VehicleSize.truck;
    }
  }

  /// Returns a human-readable explanation for the match.
  static String explain({
    required double totalKg,
    required List<String> sizeClasses,
  }) {
    final base = _byWeight(totalKg);
    final hasOverride = sizeClasses.contains('Heavy Override');
    final result = match(totalKg: totalKg, sizeClasses: sizeClasses);

    if (hasOverride && base != result) {
      return '${base.label} by weight, but a heavy item requires ${result.label}';
    }
    return '${totalKg.toStringAsFixed(1)} kg fits a ${result.label}';
  }
}
