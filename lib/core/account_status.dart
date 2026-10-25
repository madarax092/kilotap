// Account moderation status (UserAccount.Account_Status). Not one of the
// paper's Table 7 fields: added so an admin can suspend or close an account
// without deleting it, which keeps bookings, ratings and the audit trail
// intact. A missing field means Active (accounts created before it existed).
// firestore.rules reads the same field and refuses activity from blocked
// accounts, and the dispatch Cloud Function skips them.

const String accountActive = 'Active';
const String accountSuspended = 'Suspended';
const String accountClosed = 'Closed';

String accountStatusOf(Map<String, dynamic>? userAccount) {
  final s = userAccount?['Account_Status'];
  return s is String && s.isNotEmpty ? s : accountActive;
}

bool isAccountBlocked(String status) => status != accountActive;

// What a blocked user is told when sign-in or an open session is refused.
String blockedAccountMessage(String status, String reason) {
  final why = reason.trim().isEmpty ? '' : ' Reason: ${reason.trim()}.';
  final what = status == accountClosed
      ? 'This KiloTap account has been closed.'
      : 'This KiloTap account has been suspended.';
  return '$what$why Contact KiloTap support if you think this is a mistake.';
}
