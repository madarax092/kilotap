import '../services/scrap_weight_service.dart';

class VolumeClassifier {
  VolumeClassifier._();

  static const Map<String, int> _priority = {
    'Small': 1,
    'Medium': 2,
    'Large': 3,
    'Heavy Override': 4,
  };

  static const Map<String, String> vehicleMap = {
    'Small': 'Pushcart',
    'Medium': 'Tricycle',
    'Large': 'Multicab',
    'Heavy Override': 'Truck',
  };

  static String getTotalVolume(List<String> detectedClasses) {
    if (detectedClasses.isEmpty) return 'Small';
    int maxPriority = 0;
    String maxClass = 'Small';

    for (final className in detectedClasses) {
      final size = ScrapWeightService.instance.getSizeClass(className);
      final priority = _priority[size] ?? 1;
      if (priority > maxPriority) {
        maxPriority = priority;
        maxClass = size;
      }
    }
    return maxClass;
  }

  static String getRecommendedVehicle(String totalVolume) {
    return vehicleMap[totalVolume] ?? 'Tricycle';
  }

  static double getTotalWeight(List<String> detectedClasses) {
    double total = 0.0;
    for (final className in detectedClasses) {
      total += ScrapWeightService.instance.getWeight(className) ?? 0.0;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  static List<String> getAvailableVehicles(String totalVolume) {
    return ScrapWeightService.vehicleTypes;
  }
}
