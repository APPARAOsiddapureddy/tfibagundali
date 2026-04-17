import 'package:intl/intl.dart';

class IstUtils {
  // India Standard Time is UTC+5:30. We keep helpers simple and predictable.
  static DateTime nowIst() => DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

  static String formatDateIst(DateTime utcOrLocal, {String pattern = 'dd MMM yyyy'}) {
    final ist = utcOrLocal.toUtc().add(const Duration(hours: 5, minutes: 30));
    return DateFormat(pattern).format(ist);
  }
}

