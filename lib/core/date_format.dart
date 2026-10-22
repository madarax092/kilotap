import '../models/booking.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Oct 18, 2026"
String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// "3:05 PM"
String formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// "Oct 18, 2026, 3:05 PM"
String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

/// "ASAP" or the scheduled date and time of a booking.
String pickupScheduleLabel(Booking b) {
  if (b.pickupType == 'Scheduled' && b.scheduledDate != null) {
    return formatDateTime(b.scheduledDate!);
  }
  return 'ASAP';
}
