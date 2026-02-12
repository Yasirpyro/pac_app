import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/reminder_model.dart';
import '../../../core/constants/database_constants.dart';

class ReminderDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertReminder(ReminderModel reminder) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseConstants.tableReminders, reminder.toMap());
  }

  Future<int> insertReminderTxn(Transaction txn, ReminderModel reminder) async {
    return await txn.insert(DatabaseConstants.tableReminders, reminder.toMap());
  }

  Future<ReminderModel?> getReminderByBillId(int billId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReminders,
      where: 'bill_id = ?',
      whereArgs: [billId],
    );

    if (maps.isNotEmpty) {
      return ReminderModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ReminderModel>> getAllReminders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableReminders,
      orderBy: 'reminder_date ASC',
    );

    return List.generate(maps.length, (i) {
      return ReminderModel.fromMap(maps[i]);
    });
  }

  Future<int> deleteReminder(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableReminders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReminderByBillId(int billId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseConstants.tableReminders,
      where: 'bill_id = ?',
      whereArgs: [billId],
    );
  }
}
