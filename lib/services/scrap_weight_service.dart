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

    'cast_iron_bathtub':     _ItemWeight(weightKg: 135.0, sizeClass: 'Heavy Override'),
    'tire_truck':            _ItemWeight(weightKg: 50.0, sizeClass: 'Large'),
    'metal_sheet_1sqm':      _ItemWeight(weightKg: 8.0, sizeClass: 'Medium'),
    'tire_car':              _ItemWeight(weightKg: 8.0, sizeClass: 'Medium'),
    'metal_pipe_1m':         _ItemWeight(weightKg: 68.0, sizeClass: 'Large'),
    'metal_rod_1m':          _ItemWeight(weightKg: 2.0, sizeClass: 'Medium'),
    'metal_bolt':            _ItemWeight(weightKg: 0.05, sizeClass: 'Small'),

    'cardboard_box_large':   _ItemWeight(weightKg: 1.2, sizeClass: 'Medium'),
    'glass_bottle_1L':       _ItemWeight(weightKg: 0.65, sizeClass: 'Small'),
    'glass_bottle_330ml':    _ItemWeight(weightKg: 0.35, sizeClass: 'Small'),
    'cardboard_box_small':   _ItemWeight(weightKg: 0.3, sizeClass: 'Small'),
    'plastic_bottle_1L':     _ItemWeight(weightKg: 0.04, sizeClass: 'Small'),
    'plastic_bottle_500ml':  _ItemWeight(weightKg: 0.03, sizeClass: 'Small'),

    'electric_fan':          _ItemWeight(weightKg: 3.4, sizeClass: 'Small'),
    'splittype_aircon':      _ItemWeight(weightKg: 35.0, sizeClass: 'Large'),
    'flatscreentv':          _ItemWeight(weightKg: 6.0, sizeClass: 'Medium'),
    'car_battery':           _ItemWeight(weightKg: 19.0, sizeClass: 'Medium'),
    'mouse':                 _ItemWeight(weightKg: 0.1, sizeClass: 'Small'),
    'keyboard':              _ItemWeight(weightKg: 0.7, sizeClass: 'Small'),

    // Merged class (dry cell, phone/laptop and vehicle batteries); car_battery
    // above keeps the 19 kg estimate for a lead-acid battery.
    'battery':               _ItemWeight(weightKg: 0.5, sizeClass: 'Small'),
    'cardboard':             _ItemWeight(weightKg: 0.6, sizeClass: 'Medium'),
    'copper':                _ItemWeight(weightKg: 1.0, sizeClass: 'Small'),
    'electronic_battery':    _ItemWeight(weightKg: 0.3, sizeClass: 'Small'),
    'electronic_waste':      _ItemWeight(weightKg: 1.0, sizeClass: 'Small'),
    'hair_dryer':            _ItemWeight(weightKg: 1.0, sizeClass: 'Small'),
    'motorcycle_block':      _ItemWeight(weightKg: 15.0, sizeClass: 'Medium'),
    'plastic_hdpe':          _ItemWeight(weightKg: 0.1, sizeClass: 'Small'),
    'plastic_pet':           _ItemWeight(weightKg: 0.05, sizeClass: 'Small'),
    'vehicle_part_big':      _ItemWeight(weightKg: 10.0, sizeClass: 'Large'),

    // Estimates for the scanner's newer sub-classes; the seller can correct
    // the weight on the Sell Scrap screen.
    'glass_bottle':          _ItemWeight(weightKg: 0.5, sizeClass: 'Small'),
    'metal_can':             _ItemWeight(weightKg: 0.02, sizeClass: 'Small'),
    'paper':                 _ItemWeight(weightKg: 0.2, sizeClass: 'Small'),
    'plastic_bottle':        _ItemWeight(weightKg: 0.03, sizeClass: 'Small'),
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
    'electric_fan', 'splittype_aircon', 'flatscreentv', 'car_battery',
    'mouse', 'keyboard',
    'battery', 'cardboard', 'copper', 'electronic_battery',
    'electronic_waste', 'hair_dryer', 'motorcycle_block', 'plastic_hdpe',
    'plastic_pet', 'vehicle_part_big',
    'glass_bottle', 'metal_can', 'paper', 'plastic_bottle',
  ];

  // ─── Sell Scrap item picker ───
  // supportedClasses above is the full weight table (old bookings still use
  // every name in it). The picker shows one plain-language item per material
  // instead, so households don't choose between overlapping entries such as
  // Plastic Pet / Plastic Bottle / Plastic Bottle 500ml.

  /// Items offered in the Sell Scrap picker, with their display names.
  static const Map<String, String> pickerLabels = {
    'copper': 'Copper',
    'metal_can': 'Metal Cans',
    'metal_sheet_1sqm': 'Metal Sheet (per sq. m)',
    'metal_pipe_1m': 'Metal Pipe (per meter)',
    'metal_rod_1m': 'Metal Rod (per meter)',
    'metal_bolt': 'Metal Bolts',
    'tire_car': 'Car Tire',
    'tire_truck': 'Truck Tire',
    'cast_iron_bathtub': 'Cast Iron Bathtub',
    'motorcycle_block': 'Motorcycle Engine Block',
    'vehicle_part_big': 'Large Vehicle Part',
    'plastic_pet': 'Plastic Bottles (PET)',
    'plastic_hdpe': 'Plastic Containers (HDPE)',
    'glass_bottle': 'Glass Bottles',
    'cardboard': 'Cardboard',
    'paper': 'Paper',
    'refrigerator_standard': 'Refrigerator',
    'freezer': 'Freezer',
    'washing_machine': 'Washing Machine',
    'clothes_dryer': 'Clothes Dryer',
    'dishwasher': 'Dishwasher',
    'splittype_aircon': 'Split-type Aircon',
    'window_aircon': 'Window-type Aircon',
    'microwave': 'Microwave',
    'stove_range': 'Stove / Range',
    'electric_cooker': 'Electric Cooker',
    'vacuum_cleaner': 'Vacuum Cleaner',
    'electric_fan': 'Electric Fan',
    'hair_dryer': 'Hair Dryer',
    'crt_television': 'CRT TV (old box type)',
    'flatscreentv': 'Flatscreen TV / Monitor',
    'desktop_computer': 'Desktop Computer',
    'laptop_computer': 'Laptop',
    'printer': 'Printer',
    'mobile_phone': 'Mobile Phone',
    'hi_fi_system': 'Hi-Fi / Stereo',
    'video_recorder_dvd': 'DVD / Video Player',
    'electric_drill': 'Electric Drill',
    'keyboard': 'Keyboard',
    'mouse': 'Mouse',
    'battery': 'Battery (small)',
    'car_battery': 'Car / Motorcycle Battery',
  };

  /// One-line hint shown under a picker item.
  static const Map<String, String> pickerHints = {
    'plastic_pet': 'Clear water and soft-drink bottles, any size',
    'plastic_hdpe': 'Gallons, shampoo and detergent bottles',
    'metal_can': 'Soft-drink, beer and food cans',
    'glass_bottle': 'Any size',
    'paper': 'Newspaper, office paper, magazines',
    'cardboard': 'Boxes, cartons',
    'battery': 'Phone, laptop and dry-cell batteries',
    'car_battery': 'Lead-acid vehicle batteries',
    'flatscreentv': 'LCD/LED TVs and computer monitors',
  };

  /// Other words households type for a picker item (lowercase).
  static const Map<String, String> pickerAliases = {
    'plastic bottle': 'plastic_pet',
    'plastic bottles': 'plastic_pet',
    'pet': 'plastic_pet',
    'pet bottle': 'plastic_pet',
    'water bottle': 'plastic_pet',
    'mineral water bottle': 'plastic_pet',
    'softdrinks bottle': 'plastic_pet',
    'soft drink bottle': 'plastic_pet',
    '500ml bottle': 'plastic_pet',
    '1l bottle': 'plastic_pet',
    '1.5l bottle': 'plastic_pet',
    'hdpe': 'plastic_hdpe',
    'gallon': 'plastic_hdpe',
    'plastic gallon': 'plastic_hdpe',
    'plastic container': 'plastic_hdpe',
    'shampoo bottle': 'plastic_hdpe',
    'detergent bottle': 'plastic_hdpe',
    'can': 'metal_can',
    'cans': 'metal_can',
    'lata': 'metal_can',
    'tin can': 'metal_can',
    'aluminum can': 'metal_can',
    'soda can': 'metal_can',
    'bote': 'glass_bottle',
    'glass': 'glass_bottle',
    'glass bottle': 'glass_bottle',
    'karton': 'cardboard',
    'carton': 'cardboard',
    'box': 'cardboard',
    'boxes': 'cardboard',
    'papel': 'paper',
    'newspaper': 'paper',
    'diyaryo': 'paper',
    'dyaryo': 'paper',
    'tanso': 'copper',
    'copper wire': 'copper',
    'phone': 'mobile_phone',
    'cellphone': 'mobile_phone',
    'cell phone': 'mobile_phone',
    'smartphone': 'mobile_phone',
    'ref': 'refrigerator_standard',
    'fridge': 'refrigerator_standard',
    'aircon': 'splittype_aircon',
    'washer': 'washing_machine',
    'microwave oven': 'microwave',
    'tv': 'flatscreentv',
    'television': 'flatscreentv',
    'lcd tv': 'flatscreentv',
    'led tv': 'flatscreentv',
    'monitor': 'flatscreentv',
    'crt': 'crt_television',
    'old tv': 'crt_television',
    'computer': 'desktop_computer',
    'pc': 'desktop_computer',
    'fan': 'electric_fan',
    'bentilador': 'electric_fan',
    'baterya': 'battery',
    'car battery': 'car_battery',
    'engine block': 'motorcycle_block',
    'cylinder block': 'motorcycle_block',
  };

  /// Weight-table names that are no longer offered in the picker, mapped to
  /// the item that replaced them. The scanner's plastic_bottle class lands
  /// here too until the retrained model (which merges it) is bundled.
  static const Map<String, String> legacyPickerClass = {
    'plastic_bottle': 'plastic_pet',
    'plastic_bottle_1L': 'plastic_pet',
    'plastic_bottle_500ml': 'plastic_pet',
    'glass_bottle_1L': 'glass_bottle',
    'glass_bottle_330ml': 'glass_bottle',
    'cardboard_box_small': 'cardboard',
    'cardboard_box_large': 'cardboard',
    'microwave_oven': 'microwave',
    'lcd_screen': 'flatscreentv',
    'electronic_battery': 'battery',
  };

  /// The picker item for [className] (legacy names redirected).
  static String pickerClassFor(String className) {
    return legacyPickerClass[className] ?? className;
  }

  /// Display name for a weight-table class.
  static String labelFor(String className) {
    return pickerLabels[className] ?? humanize(className);
  }

  static String humanize(String key) {
    return key.split('_').map((w) {
      if (w.isEmpty) return w;
      if (w.contains(RegExp(r'[0-9]'))) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  /// The picker item that typed text names exactly (label, alias, or an old
  /// weight-table name), or null when it is a new item.
  static String? resolveTyped(String text) {
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return null;
    for (final entry in pickerLabels.entries) {
      if (entry.value.toLowerCase() == t ||
          humanize(entry.key).toLowerCase() == t) {
        return entry.key;
      }
    }
    final alias = pickerAliases[t];
    if (alias != null) return alias;
    for (final entry in legacyPickerClass.entries) {
      if (humanize(entry.key).toLowerCase() == t) return entry.value;
    }
    return null;
  }

  /// Picker items whose label, hint or an alias contains [query].
  static List<String> searchPicker(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return pickerLabels.keys.toList();
    final hits = <String>{};
    for (final entry in pickerLabels.entries) {
      if (entry.value.toLowerCase().contains(q) ||
          (pickerHints[entry.key]?.toLowerCase().contains(q) ?? false)) {
        hits.add(entry.key);
      }
    }
    for (final entry in pickerAliases.entries) {
      if (entry.key.contains(q)) hits.add(entry.value);
    }
    return hits.toList();
  }

  static const List<String> vehicleTypes = [
    'Pushcart',
    'Tricycle',
    'Multicab',
    'Truck',
  ];
}
