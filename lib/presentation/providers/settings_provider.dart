import 'package:flutter/material.dart';
import '../../data/database/dao/settings_dao.dart';
import '../../data/database/dao/audit_log_dao.dart';
import '../../data/database/database_helper.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsDao _settingsDao = SettingsDao();
  final AuditLogDao _auditDao = AuditLogDao();

  bool _isMaintenanceMode = false;
  bool _isDemoMode = true;
  bool _notificationsEnabled = true;
  double _dailyPaymentCap = 2000.0;

  bool get isMaintenanceMode => _isMaintenanceMode;
  bool get isDemoMode => _isDemoMode;
  bool get notificationsEnabled => _notificationsEnabled;
  double get dailyPaymentCap => _dailyPaymentCap;

  Future<void> loadSettings() async {
    try {
      final settings = await _settingsDao.getSettings();
      _isMaintenanceMode = settings.maintenanceMode;
      _isDemoMode = settings.demoMode;
      _notificationsEnabled = settings.notificationEnabled;
      _dailyPaymentCap = settings.dailyPaymentCap;
      notifyListeners();
    } catch (e) {
      // Use defaults on error
      notifyListeners();
    }
  }

  Future<void> setMaintenanceMode(bool value) async {
    _isMaintenanceMode = value;
    await _settingsDao.setMaintenanceMode(value);
    await _auditDao.log(
      actionType: 'maintenance_mode_changed',
      details: {'enabled': value},
    );
    notifyListeners();
  }

  Future<void> setDemoMode(bool value) async {
    _isDemoMode = value;
    await _settingsDao.setDemoMode(value);
    await _auditDao.log(
      actionType: 'demo_mode_changed',
      details: {'enabled': value},
    );
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _settingsDao.setNotificationEnabled(value);
    notifyListeners();
  }

  Future<void> setDailyPaymentCap(double value) async {
    _dailyPaymentCap = value;
    await _settingsDao.setDailyPaymentCap(value);
    await _auditDao.log(
      actionType: 'daily_cap_changed',
      details: {'cap': value},
    );
    notifyListeners();
  }

  Future<void> resetDemoData() async {
    await DatabaseHelper.instance.resetDemoData();
    await loadSettings();
  }
}
