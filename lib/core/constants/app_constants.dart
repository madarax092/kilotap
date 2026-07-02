/// KiloTap App Constants
class AppConstants {
  AppConstants._();

  static const String appName = 'KiloTap';
  static const String appTagline = 'Tap the App. Trade the Scrap.';

  // ─── Roles ─────────────────────────────────────────────────────────────────
  static const String roleHousehold = 'Household';
  static const String roleCollector = 'Collector';
  static const String roleAdmin = 'Admin';

  // ─── Booking Status ────────────────────────────────────────────────────────
  static const String statusPending = 'Pending';
  static const String statusAccepted = 'Accepted';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  // ─── Verification Status ───────────────────────────────────────────────────
  static const String verifyPending = 'Pending';
  static const String verifyVerified = 'Verified';
  static const String verifyRejected = 'Rejected';

  // ─── Vehicle Types ─────────────────────────────────────────────────────────
  static const List<String> vehicleTypes = [
    'Pushcart (Kariton)',
    'Tricycle / Sidecar',
    'Multicab / Truck',
    'Single Motorcycle',
  ];

  // ─── Firestore Collections ─────────────────────────────────────────────────
  static const String colSellers = 'sellers';
  static const String colCollectors = 'collectors';
  static const String colBookings = 'bookings';
  static const String colBookingItems = 'bookingItems';
  static const String colRatings = 'ratings';
  static const String colNotifications = 'notifications';
  static const String colAuditLogs = 'auditLogs';

  // ─── Audit Action Types ────────────────────────────────────────────────────
  static const String auditVerifyCollector = 'VERIFY_COLLECTOR';
  static const String auditSuspendUser = 'SUSPEND_USER';
  static const String auditResolveReport = 'RESOLVE_REPORT';

  // ─── Omega Thresholds ──────────────────────────────────────────────────────
  static const double omegaLight = 0.20;
  static const double omegaMedium = 0.50;
  // Omega ≤ 0.20 → Pushcart | 0.20–0.50 → Tricycle | > 0.50 → Truck
}
