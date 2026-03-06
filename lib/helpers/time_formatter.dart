import 'package:intl/intl.dart';

String formatRelativeTime(
  DateTime time, {
  String fallbackPattern = 'MM-dd HH:mm',
}) {
  final localTime = time.toLocal();
  final now = DateTime.now();
  final diff = now.difference(localTime);

  if (diff.isNegative) {
    return DateFormat(fallbackPattern).format(localTime);
  }
  if (diff.inMinutes < 1) {
    return '刚刚';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes}分钟前';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}小时前';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}天前';
  }
  return DateFormat(fallbackPattern).format(localTime);
}
