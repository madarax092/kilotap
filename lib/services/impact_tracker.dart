class RecyclingImpactTracker {
  RecyclingImpactTracker._();

  static const double kgPerTree = 45.0;

  static double getTotalKg(List<Map<String, dynamic>> completedBookings) {
    double total = 0.0;
    for (final booking in completedBookings) {
      total += (booking['weightKg'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }

  static int getTreesSaved(double totalKg) {
    return (totalKg / kgPerTree).ceil();
  }

  static String getImpactSummary(double totalKg) {
    final trees = getTreesSaved(totalKg);
    return '$trees';
  }

  static String getImpactDescription(double totalKg) {
    final trees = getTreesSaved(totalKg);
    return 'You have recycled ${totalKg.toStringAsFixed(1)} kg this month. '
        'Equivalent to $trees ${trees == 1 ? 'tree' : 'trees'} saved.';
  }
}
