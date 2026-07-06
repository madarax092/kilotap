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

  // ─── Firestore Collections (Tables 6-13) ───────────────────────────────────
  static const String colBookings = 'bookings';
  static const String colBookingItems = 'bookingItems';
  static const String colRatings = 'ratings';
  static const String colNotifications = 'notifications';
  static const String colAuditLogs = 'auditLogs';
  // UserAccount, ScrapSeller, ScrapCollector use subcollection pattern — see auth_service.dart

  // ─── Audit Action Types ────────────────────────────────────────────────────
  static const String auditVerifyCollector = 'VERIFY_COLLECTOR';
  static const String auditSuspendUser = 'SUSPEND_USER';
  static const String auditResolveReport = 'RESOLVE_REPORT';

  // ─── Spatial Area Ratio Threshold (Paper §2.3.1.3, τ = 0.50) ──────────────
  static const double spatialAreaThreshold = 0.50;
  // ≤ 0.50 → Tricycle Sidecar | > 0.50 → Heavy Hauling Truck
}
