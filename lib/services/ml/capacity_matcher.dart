// ─── Capacity Matcher ───

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

  static VehicleSize match({
    required double totalKg,
    required List<String> sizeClasses,
  }) {
    VehicleSize size = _byWeight(totalKg);

    if (sizeClasses.contains('Heavy Override')) {
      size = _bumpUp(size);
    }

    return size;
  }

  static VehicleSize _byWeight(double totalKg) {
    if (totalKg < 20) return VehicleSize.pushcart;
    if (totalKg < 100) return VehicleSize.tricycle;
    if (totalKg < 500) return VehicleSize.multicab;
    return VehicleSize.truck;
  }

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
