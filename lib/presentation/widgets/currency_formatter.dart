import 'package:easy_localization/easy_localization.dart';

class CurrencyFormatter {
  static final NumberFormat _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num value) {
    return _idr.format(value);
  }

  static String formatCompact(num value) {
    return NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }
}
