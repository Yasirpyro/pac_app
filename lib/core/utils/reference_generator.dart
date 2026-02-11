import 'package:intl/intl.dart';

class ReferenceGenerator {
  static int _dailyCounter = 0;
  static String? _currentDate;

  static String generate() {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());

    if (_currentDate != today) {
      _currentDate = today;
      _dailyCounter = 0;
    }

    _dailyCounter++;
    return 'PAC-$today-${_dailyCounter.toString().padLeft(3, '0')}';
  }
}
