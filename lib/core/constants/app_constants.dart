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
  static const String roleAdmin = 'admin';

  // ─── Booking Status ────────────────────────────────────────────────────────
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusEnRoute = 'en_route';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusDisputed = 'disputed';

  // ─── Time Slots ────────────────────────────────────────────────────────────
  static const List<String> timeSlots = [
    'Morning (8am - 12pm)',
    'Afternoon (12pm - 5pm)',
    'Evening (5pm - 8pm)',
  ];

  // ─── Vehicle Types ─────────────────────────────────────────────────────────
  static const List<String> vehicleTypes = [
    'Pushcart (Kariton)',
    'Tricycle / Sidecar',
    'Multicab / Truck',
    'Single Motorcycle',
  ];

  // ─── Firestore Collections ─────────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colCollectors = 'collectors';
  static const String colBookings = 'bookings';
  static const String colBookingItems = 'bookingItems';
  static const String colRatings = 'ratings';
  static const String colSubdivisionAccess = 'subdivisionAccess';

  // ─── Rating Categories ─────────────────────────────────────────────────────
  static const List<String> ratingCategories = [
    'On_Time',
    'Professional',
    'Careful_Handling',
    'Good_Communication',
  ];

  // ─── Shared Prefs Keys ─────────────────────────────────────────────────────
  static const String prefUserRole = 'user_role';
  static const String prefUserToken = 'user_token';
  static const String prefOnboarded = 'onboarded';
}
