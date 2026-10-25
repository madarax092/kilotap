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
    'Pushcart',
    'Tricycle',
    'Multicab',
    'Truck',
  ];

  // ─── Firestore Collections (Tables 6-13) ───────────────────────────────────
  static const String colAccount = 'UserAccount';
  static const String colSeller = 'ScrapSeller';
  static const String colCollector = 'ScrapCollector';
  static const String colBookings = 'bookings';
  static const String colBookingItems = 'bookingItems';
  static const String colRatings = 'ratings';
  static const String colNotifications = 'notifications';
  static const String colAuditLogs = 'auditLogs';
  static const String colMessages = 'messages';
  // Not a numbered paper table — user reports reviewed by an admin.
  static const String colReports = 'reports';

  // ─── Audit Action Types ────────────────────────────────────────────────────
  static const String auditVerifyCollector = 'VERIFY_COLLECTOR';
  static const String auditSuspendUser = 'SUSPEND_USER';
  static const String auditCloseAccount = 'CLOSE_ACCOUNT';
  static const String auditReactivateUser = 'REACTIVATE_USER';
  static const String auditResolveReport = 'RESOLVE_REPORT';
  static const String auditDismissReport = 'DISMISS_REPORT';
  static const String auditInvestigateReport = 'INVESTIGATE_REPORT';
  static const String auditWarnUser = 'WARN_USER';

  // ─── Spatial Area Ratio Threshold (Paper §2.3.1.3, τ = 0.50) ──────────────
  static const double spatialAreaThreshold = 0.50;

  // ─── Google Maps API (replace with real key on your local machine) ─────────
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // ─── Cloudinary (unsigned upload, for chat photo attachments) ──────────────
  static const String cloudinaryCloudName = 'iqsnzgli';
  static const String cloudinaryUploadPreset = 'iqsnzgli';
}
