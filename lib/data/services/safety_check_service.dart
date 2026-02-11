import '../database/dao/bill_history_dao.dart';
import '../database/dao/payment_dao.dart';
import '../database/dao/settings_dao.dart';
import '../models/cashflow_input_model.dart';

class SafetyCheckResult {
  final bool hasWarnings;
  final bool hasInsufficientFunds;
  final bool hasAnomaly;
  final bool exceedsDailyCap;
  final List<String> messages;
  final double? remainingBalance;
  final double? averageAmount;
  final double? deviationPercent;

  SafetyCheckResult({
    required this.hasWarnings,
    required this.hasInsufficientFunds,
    required this.hasAnomaly,
    required this.exceedsDailyCap,
    required this.messages,
    this.remainingBalance,
    this.averageAmount,
    this.deviationPercent,
  });

  factory SafetyCheckResult.safe() {
    return SafetyCheckResult(
      hasWarnings: false,
      hasInsufficientFunds: false,
      hasAnomaly: false,
      exceedsDailyCap: false,
      messages: [],
    );
  }
}

class SafetyCheckService {
  final BillHistoryDao _historyDao;
  final PaymentDao _paymentDao;
  final SettingsDao _settingsDao;

  SafetyCheckService({
    required BillHistoryDao historyDao,
    required PaymentDao paymentDao,
    required SettingsDao settingsDao,
  })  : _historyDao = historyDao,
        _paymentDao = paymentDao,
        _settingsDao = settingsDao;

  Future<SafetyCheckResult> checkPaymentSafety({
    required double billAmount,
    required String payeeName,
    required DateTime scheduledDate,
    required CashflowInputModel cashflow,
  }) async {
    final messages = <String>[];
    bool hasInsufficientFunds = false;
    bool hasAnomaly = false;
    bool exceedsDailyCap = false;
    double? remainingBalance;
    double? averageAmount;
    double? deviationPercent;

    try {
      // Check 1: Insufficient funds
      final balanceAfterPayment = cashflow.currentBalance - billAmount;
      remainingBalance = balanceAfterPayment;

      if (balanceAfterPayment < cashflow.safetyBuffer) {
        hasInsufficientFunds = true;
        final deficit = cashflow.safetyBuffer - balanceAfterPayment;
        messages.add(
            'Low Balance Risk: Paying this will leave you \$${deficit.toStringAsFixed(2)} below your safety buffer of \$${cashflow.safetyBuffer.toStringAsFixed(0)}.');
      }

      // Check 2: Anomaly detection
      final avgAmount = await _historyDao.getAverageAmountForPayee(payeeName);
      if (avgAmount != null && avgAmount > 0) {
        averageAmount = avgAmount;
        final deviation = ((billAmount - avgAmount) / avgAmount).abs();
        deviationPercent = deviation * 100;

        if (deviation > 0.30) {
          hasAnomaly = true;
          final direction = billAmount > avgAmount ? 'higher' : 'lower';
          messages.add(
              'Unusual Amount: This bill is ${deviationPercent.toStringAsFixed(0)}% $direction than usual (\$${avgAmount.toStringAsFixed(2)}). Please verify.');
        }
      }

      // Check 3: Daily cap
      final settings = await _settingsDao.getSettings();
      final totalScheduledForDate =
          await _paymentDao.getTotalScheduledForDate(scheduledDate);
      final totalWithThisBill = totalScheduledForDate + billAmount;

      if (totalWithThisBill > settings.dailyPaymentCap) {
        exceedsDailyCap = true;
        final excess = totalWithThisBill - settings.dailyPaymentCap;
        messages.add(
            'Daily Limit Exceeded: Adding this payment (\$${billAmount.toStringAsFixed(2)}) would exceed your daily cap of \$${settings.dailyPaymentCap.toStringAsFixed(0)} by \$${excess.toStringAsFixed(2)}.');
      }
    } catch (e) {
      // Handle errors gracefully
      messages.add('Safety check encountered an error: ${e.toString()}');
    }

    final hasWarnings =
        hasInsufficientFunds || hasAnomaly || exceedsDailyCap || messages.isNotEmpty;

    return SafetyCheckResult(
      hasWarnings: hasWarnings,
      hasInsufficientFunds: hasInsufficientFunds,
      hasAnomaly: hasAnomaly,
      exceedsDailyCap: exceedsDailyCap,
      messages: messages,
      remainingBalance: remainingBalance,
      averageAmount: averageAmount,
      deviationPercent: deviationPercent,
    );
  }
}
