class _ItemWeight {
  final double weightKg;
  final String sizeClass;

  const _ItemWeight({
    required this.weightKg,
    required this.sizeClass,
  });
}

class ScrapWeightService {
  ScrapWeightService._();

  static final ScrapWeightService instance = ScrapWeightService._();

  static const Map<String, _ItemWeight> _cache = {
    // Appliances
    'refrigerator_standard': _ItemWeight(weightKg: 100.0, sizeClass: 'Heavy Override'),
    'washing_machine':       _ItemWeight(weightKg: 65.0, sizeClass: 'Heavy Override'),
    'freezer':               _ItemWeight(weightKg: 65.0, sizeClass: 'Heavy Override'),
    'dishwasher':            _ItemWeight(weightKg: 50.0, sizeClass: 'Large'),
    'clothes_dryer':         _ItemWeight(weightKg: 49.0, sizeClass: 'Large'),
    'stove_range':           _ItemWeight(weightKg: 46.0, sizeClass: 'Large'),
    'electric_cooker':       _ItemWeight(weightKg: 46.0, sizeClass: 'Large'),
    'window_aircon':         _ItemWeight(weightKg: 25.0, sizeClass: 'Large'),
    'microwave_oven':        _ItemWeight(weightKg: 15.0, sizeClass: 'Medium'),
    'vacuum_cleaner':        _ItemWeight(weightKg: 8.0, sizeClass: 'Small'),

    // E-Waste
    'crt_television':        _ItemWeight(weightKg: 31.6, sizeClass: 'Large'),
    'microwave':             _ItemWeight(weightKg: 15.0, sizeClass: 'Medium'),
    'hi_fi_system':          _ItemWeight(weightKg: 10.0, sizeClass: 'Medium'),
    'desktop_computer':      _ItemWeight(weightKg: 10.0, sizeClass: 'Medium'),
    'printer':               _ItemWeight(weightKg: 6.5, sizeClass: 'Small'),
    'video_recorder_dvd':    _ItemWeight(weightKg: 5.0, sizeClass: 'Small'),
    'lcd_screen':            _ItemWeight(weightKg: 4.7, sizeClass: 'Small'),
    'laptop_computer':       _ItemWeight(weightKg: 3.5, sizeClass: 'Small'),
    'electric_drill':        _ItemWeight(weightKg: 2.0, sizeClass: 'Small'),
    'mobile_phone':          _ItemWeight(weightKg: 0.1, sizeClass: 'Small'),

    // Metal & Construction
    'cast_iron_bathtub':     _ItemWeight(weightKg: 135.0, sizeClass: 'Heavy Override'),
    'tire_truck':            _ItemWeight(weightKg: 50.0, sizeClass: 'Large'),
    'metal_sheet_1sqm':      _ItemWeight(weightKg: 8.0, sizeClass: 'Medium'),
    'tire_car':              _ItemWeight(weightKg: 8.0, sizeClass: 'Medium'),
    'metal_pipe_1m':         _ItemWeight(weightKg: 3.5, sizeClass: 'Large'),
    'metal_rod_1m':          _ItemWeight(weightKg: 2.0, sizeClass: 'Medium'),
    'metal_bolt':            _ItemWeight(weightKg: 0.05, sizeClass: 'Small'),

    // Glass, Paper & Plastics
    'cardboard_box_large':   _ItemWeight(weightKg: 1.2, sizeClass: 'Medium'),
    'glass_bottle_1L':       _ItemWeight(weightKg: 0.65, sizeClass: 'Small'),
    'glass_bottle_330ml':    _ItemWeight(weightKg: 0.35, sizeClass: 'Small'),
    'cardboard_box_small':   _ItemWeight(weightKg: 0.3, sizeClass: 'Small'),
    'plastic_bottle_1L':     _ItemWeight(weightKg: 0.04, sizeClass: 'Small'),
    'plastic_bottle_500ml':  _ItemWeight(weightKg: 0.03, sizeClass: 'Small'),
  };

  double? getWeight(String className) {
    return _cache[className]?.weightKg;
  }

  String getSizeClass(String className) {
    return _cache[className]?.sizeClass ?? 'Small';
  }

  static const List<String> supportedClasses = [
    'refrigerator_standard', 'washing_machine', 'freezer', 'dishwasher',
    'clothes_dryer', 'stove_range', 'electric_cooker', 'window_aircon',
    'microwave_oven', 'vacuum_cleaner', 'crt_television', 'microwave',
    'hi_fi_system', 'desktop_computer', 'printer', 'video_recorder_dvd',
    'lcd_screen', 'laptop_computer', 'electric_drill', 'mobile_phone',
    'cast_iron_bathtub', 'tire_truck', 'metal_sheet_1sqm', 'tire_car',
    'metal_pipe_1m', 'metal_rod_1m', 'metal_bolt', 'cardboard_box_large',
    'glass_bottle_1L', 'glass_bottle_330ml', 'cardboard_box_small',
    'plastic_bottle_1L', 'plastic_bottle_500ml',
  ];

  static const List<String> vehicleTypes = [
    'Pushcart',
    'Tricycle',
    'Multicab',
    'Truck',
  ];
}
