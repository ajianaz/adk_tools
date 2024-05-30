import 'package:intl/intl.dart';

class ConvertType {
  static double toDouble(dynamic value) {
    try {
      return double.parse(value.toString());
    } catch (e) {
      rethrow;
    }
  }

  static int toInt(String value) {
    if (value.isEmpty) {
      return 0;
    } else {
      try {
        return int.parse(
          value,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  static String formatedDate(
      {required String value, String? format = "dd MMM yyy"}) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime date = dateFormat.parse(value);
    return DateFormat(format, 'id').format(date);
  }
}
