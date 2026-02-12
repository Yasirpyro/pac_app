import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ReferenceGenerator {
  static const _uuid = Uuid();

  static String generate() {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final short = _uuid.v4().split('-').first.toUpperCase();
    return 'PAC-$today-$short';
  }
}
