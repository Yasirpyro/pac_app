class AppConstants {
  static const String appName = 'Payment Assurance Copilot';
  static const String appVersion = '1.0.0';

  // Bill categories
  static const List<String> billCategories = [
    'Utilities',
    'Insurance',
    'Subscriptions',
    'Other',
  ];

  // Bill statuses
  static const String statusPending = 'Pending';
  static const String statusScheduled = 'Scheduled';
  static const String statusPaid = 'Paid';
  static const String statusQueued = 'Queued';

  // Payment statuses
  static const String paymentQueued = 'Queued';
  static const String paymentScheduled = 'Scheduled';
  static const String paymentSimulated = 'Simulated';

  // Defaults
  static const double defaultDailyPaymentCap = 2000.0;
  static const double defaultSafetyBuffer = 500.0;
  static const double defaultBalance = 2800.0;
  static const int dueSoonDays = 7;

  // AI
  static const int aiTimeoutSeconds = 3;
  static const int aiMaxTokens = 100;
  static const String aiModel = 'claude-haiku-4-5';
}
