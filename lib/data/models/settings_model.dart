class SettingsModel {
  final int? id;
  final double dailyPaymentCap;
  final bool maintenanceMode;
  final bool demoMode;
  final bool notificationEnabled;

  SettingsModel({
    this.id,
    this.dailyPaymentCap = 2000.0,
    this.maintenanceMode = false,
    this.demoMode = true,
    this.notificationEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'daily_payment_cap': dailyPaymentCap,
      'maintenance_mode': maintenanceMode ? 1 : 0,
      'demo_mode': demoMode ? 1 : 0,
      'notification_enabled': notificationEnabled ? 1 : 0,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'] as int?,
      dailyPaymentCap: (map['daily_payment_cap'] as num).toDouble(),
      maintenanceMode: (map['maintenance_mode'] as int) == 1,
      demoMode: (map['demo_mode'] as int) == 1,
      notificationEnabled: (map['notification_enabled'] as int) == 1,
    );
  }
}
