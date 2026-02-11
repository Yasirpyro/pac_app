import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('MMM d, y');
  static final _dateTimeFormat = DateFormat('MMM d, y h:mm a');
  static final _shortDateFormat = DateFormat('MM/dd');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String formatDaysUntilDue(int days) {
    if (days == 0) return 'Due today!';
    if (days < 0) return 'Overdue by ${-days} day${-days == 1 ? '' : 's'}';
    return '$days day${days == 1 ? '' : 's'} until due';
  }
}
