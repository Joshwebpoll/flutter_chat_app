//Format the Timestamp
import 'package:intl/intl.dart';

String formatTime(DateTime dt) {
  return DateFormat('hh:mm a').format(dt.toLocal()); // e.g. "10:30 AM"
}

//"Yesterday", "Today", or Full Date
String formatChatTime(DateTime date) {
  final now = DateTime.now();
  final localDate = date.toLocal();

  final difference = now.difference(localDate);

  if (difference.inDays == 0) {
    return DateFormat('hh:mm a').format(localDate); // Today
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return DateFormat.EEEE().format(localDate); // e.g. "Monday"
  } else {
    return DateFormat.yMd().format(localDate); // e.g. "7/11/2025"
  }
}
