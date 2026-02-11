import 'package:sqflite/sqflite.dart';
import '../../../core/constants/database_constants.dart';
import '../database_helper.dart';
import '../../models/settings_model.dart';

class SettingsDao {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<SettingsModel> getSettings() async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableSettings,
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isEmpty) {
      return SettingsModel();
    }
    return SettingsModel.fromMap(result.first);
  }

  Future<int> updateSettings(SettingsModel settings) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tableSettings,
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> setMaintenanceMode(bool enabled) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tableSettings,
      {'maintenance_mode': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> setDemoMode(bool enabled) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tableSettings,
      {'demo_mode': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> setDailyPaymentCap(double cap) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tableSettings,
      {'daily_payment_cap': cap},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> setNotificationEnabled(bool enabled) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tableSettings,
      {'notification_enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
