/// KiloTap App Constants
class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'KiloTap';
  static const String appTagline = '"Tap the App. Trade the Scrap."';
  static const String termsOfServiceUrl = 'https://kilotap.app/terms';
  static const String privacyPolicyUrl = 'https://kilotap.app/privacy';

  // ─── User Roles ────────────────────────────────────────────────────────────
  static const String roleSeller = 'seller';
  static const String roleBuyer = 'buyer';

  // ─── Account Types (Seller) ────────────────────────────────────────────────
  static const String accountIndividual = 'individual';
  static const String accountBusiness = 'business';

  // ─── Scrap Types ───────────────────────────────────────────────────────────
  static const List<ScrapType> scrapTypes = [
    ScrapType(id: 'plastic', name: 'Plastic', icon: '♻️', pricePerKg: 15.0),
    ScrapType(id: 'metals', name: 'Metals', icon: '🔩', pricePerKg: 80.0),
    ScrapType(id: 'appliances', name: 'Appliances', icon: '🔌', pricePerKg: 50.0),
    ScrapType(id: 'paper', name: 'Paper', icon: '📄', pricePerKg: 5.0),
    ScrapType(id: 'glass', name: 'Glass', icon: '🪟', pricePerKg: 3.0),
    ScrapType(id: 'mixed', name: 'Mixed Scrap', icon: '📦', pricePerKg: 25.0),
  ];

  // ─── Pickup Status ─────────────────────────────────────────────────────────
  static const String statusPending = 'pending';
  static const String statusAssigned = 'assigned';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // ─── Time Slots ────────────────────────────────────────────────────────────
  static const List<String> timeSlots = [
    'Morning (8am - 12pm)',
    'Afternoon (12pm - 5pm)',
    'Evening (5pm - 8pm)',
  ];

  // ─── Vehicle Types (Buyer) ─────────────────────────────────────────────────
  static const List<String> vehicleTypes = [
    'Tricycle',
    'Motorcycle with Sidecar',
    'Kuliglig',
    'Small Truck',
    'Pickup Truck',
    'Van',
  ];

  // ─── Firestore Collections ─────────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colPickups = 'pickups';
  static const String colMarketPrices = 'market_prices';

  // ─── Shared Prefs Keys ─────────────────────────────────────────────────────
  static const String prefUserRole = 'user_role';
  static const String prefUserToken = 'user_token';
  static const String prefOnboarded = 'onboarded';
}

class ScrapType {
  final String id;
  final String name;
  final String icon;
  final double pricePerKg;

  const ScrapType({
    required this.id,
    required this.name,
    required this.icon,
    required this.pricePerKg,
  });
}
