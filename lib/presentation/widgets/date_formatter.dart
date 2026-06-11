import 'package:easy_localization/easy_localization.dart';

class DateFormatter {
  static String format(String date) {
    final parsed = DateTime.parse(date);

    return DateFormat(
      'dd MMM yyyy',
    ).format(parsed);
  }

  static String formatShort(String date) {
    final parsed = DateTime.parse(date);

    return DateFormat(
      'dd/MM/yyyy',
    ).format(parsed);
  }

  static String formatLong(String date) {
    final parsed = DateTime.parse(date);

    return DateFormat(
      'EEEE, dd MMMM yyyy',
    ).format(parsed);
  }
}
