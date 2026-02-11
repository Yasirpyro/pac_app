import 'package:flutter/material.dart';
import '../../data/database/dao/bill_dao.dart';
import '../../data/database/dao/bill_history_dao.dart';
import '../../data/database/dao/payment_dao.dart';
import '../../data/database/dao/settings_dao.dart';
import '../../data/services/recommendation_service.dart';
import '../../data/services/safety_check_service.dart';
import '../../data/services/ai_service.dart';
import '../../domain/entities/recommendation.dart';
import '../providers/cashflow_provider.dart';
import '../../data/models/cashflow_input_model.dart';

class RecommendationProvider extends ChangeNotifier {
  final BillDao _billDao = BillDao();
  final BillHistoryDao _historyDao = BillHistoryDao();
  final PaymentDao _paymentDao = PaymentDao();
  final SettingsDao _settingsDao = SettingsDao();

  late final RecommendationService _recommendationService;
  late final SafetyCheckService _safetyCheckService;
  late final AIService _aiService;

  Recommendation? _recommendation;
  SafetyCheckResult? _safetyCheck;
  String? _rationale;
  bool _isLoading = false;
  String? _error;

  RecommendationProvider() {
    _recommendationService = RecommendationService();
    _safetyCheckService = SafetyCheckService(
      historyDao: _historyDao,
      paymentDao: _paymentDao,
      settingsDao: _settingsDao,
    );
    _aiService = AIService(settingsDao: _settingsDao);
  }

  Recommendation? get recommendation => _recommendation;
  SafetyCheckResult? get safetyCheck => _safetyCheck;
  String? get rationale => _rationale;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getRecommendation({
    required int billId,
    required CashflowProvider cashflowProvider,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load bill from database
      final bill = await _billDao.getBillById(billId);
      if (bill == null) {
        _error = 'Bill not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Create cashflow input model
      final cashflow = CashflowInputModel(
        currentBalance: cashflowProvider.currentBalance,
        nextPaydayDate: cashflowProvider.nextPayday,
        safetyBuffer: cashflowProvider.safetyBuffer,
      );

      // Get recommendation
      _recommendation = _recommendationService.getRecommendation(
        bill: bill,
        cashflow: cashflow,
      );

      // Run safety checks
      final suggestedDate = _recommendation!.suggestedDate ?? DateTime.now();
      _safetyCheck = await _safetyCheckService.checkPaymentSafety(
        billAmount: bill.amount,
        payeeName: bill.payeeName,
        scheduledDate: suggestedDate,
        cashflow: cashflow,
      );

      // Generate AI rationale
      try {
        _rationale = await _aiService.generateRationale(
          payee: bill.payeeName,
          amount: bill.amount,
          dueDate: bill.dueDate.toIso8601String().split('T')[0],
          currentBalance: cashflow.currentBalance,
          nextPayday: cashflow.nextPaydayDate.toIso8601String().split('T')[0],
          safetyBuffer: cashflow.safetyBuffer,
          recommendation: _recommendation!.type.name,
        );
      } catch (e) {
        // Use recommendation's built-in rationale if AI service fails
        _rationale = _recommendation!.rationale;
      }
    } catch (e) {
      _error = 'Failed to generate recommendation: ${e.toString()}';
      _recommendation = null;
      _safetyCheck = null;
      _rationale = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRecommendation() {
    _recommendation = null;
    _safetyCheck = null;
    _rationale = null;
    _error = null;
    notifyListeners();
  }
}
