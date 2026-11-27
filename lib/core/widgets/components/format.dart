import 'package:intl/intl.dart';

final _thousands = NumberFormat('#,##0');

/// 1284 → "1,284"
String formatCount(int value) => _thousands.format(value);

/// 반응 수 표시: 1만 이상은 "1.2만", 그 아래는 "1,284"
String formatReactionCount(int value) {
  if (value < 10000) return formatCount(value);
  final man = value / 10000;
  final text = man >= 10 ? man.toStringAsFixed(0) : man.toStringAsFixed(1);
  return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text}만';
}

/// 가입일부터 지난 날: 412 → "D+412"
String formatDayCount(int days) => 'D+${formatCount(days)}';
