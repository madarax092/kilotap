// ─── Weight Lookup ───
///
/// Maps detected class names to estimated weights.
/// Cache: Hive (local), syncs from Firestore ScrapWeight collection.
/// Fallback: hardcoded defaults if offline.

class WeightLookup {
  // TODO: Load from Firestore → cache in Hive
  // double getWeight(String className, String sizeClass) { ... }
  // void syncFromFirestore() { ... }
}
