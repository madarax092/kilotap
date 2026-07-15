class MaterialPreferences {
  MaterialPreferences._();

  static const List<String> categories = [
    'Metal',
    'Plastic',
    'Glass',
    'Cardboard',
    'Appliances',
    'E-Waste',
  ];

  static const Map<String, List<String>> categoryMap = {
    'Metal': [
      'metal_pipe_1m', 'metal_bolt', 'metal_sheet_1sqm', 'metal_rod_1m',
      'tire_car', 'tire_truck', 'cast_iron_bathtub',
    ],
    'Plastic': ['plastic_bottle_1L', 'plastic_bottle_500ml'],
    'Glass': ['glass_bottle_1L', 'glass_bottle_330ml'],
    'Cardboard': ['cardboard_box_large', 'cardboard_box_small'],
    'Appliances': [
      'refrigerator_standard', 'washing_machine', 'freezer', 'dishwasher',
      'window_aircon', 'microwave_oven', 'electric_cooker', 'stove_range',
      'clothes_dryer', 'vacuum_cleaner', 'electric_fan',
    ],
    'E-Waste': [
      'crt_television', 'desktop_computer', 'laptop_computer', 'printer',
      'lcd_screen', 'mobile_phone', 'hi_fi_system', 'video_recorder_dvd',
      'electric_drill', 'microwave',
    ],
  };

  static bool matchesPreference(
    List<String> detectedClasses,
    List<String> preferredCategories,
  ) {
    if (preferredCategories.isEmpty) return true;

    for (final className in detectedClasses) {
      for (final category in preferredCategories) {
        final classList = categoryMap[category];
        if (classList != null && classList.contains(className)) {
          return true;
        }
      }
    }
    return false;
  }

  static List<String> getCategoriesFor(List<String> detectedClasses) {
    final result = <String>{};
    for (final className in detectedClasses) {
      for (final entry in categoryMap.entries) {
        if (entry.value.contains(className)) {
          result.add(entry.key);
        }
      }
    }
    return result.toList();
  }

  static List<String> formatForDisplay(List<String> categories) {
    if (categories.isEmpty) return ['All Materials'];
    return categories;
  }
}
