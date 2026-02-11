import 'package:flutter/material.dart';
import '../../data/database/dao/cashflow_dao.dart';
import '../../data/database/dao/audit_log_dao.dart';
import '../../data/models/cashflow_input_model.dart';

class CashflowProvider extends ChangeNotifier {
  final CashflowDao _cashflowDao = CashflowDao();
  final AuditLogDao _auditDao = AuditLogDao();

  double _currentBalance = 2800.0;
  DateTime _nextPayday = DateTime.now().add(const Duration(days: 7));
  double _safetyBuffer = 500.0;

  double get currentBalance => _currentBalance;
  DateTime get nextPayday => _nextPayday;
  double get safetyBuffer => _safetyBuffer;

  Future<void> loadCashflow() async {
    try {
      final cashflow = await _cashflowDao.getCashflowInputs();
      _currentBalance = cashflow.currentBalance;
      _nextPayday = cashflow.nextPaydayDate;
      _safetyBuffer = cashflow.safetyBuffer;
      notifyListeners();
    } catch (e) {
      // Use defaults on error
      notifyListeners();
    }
  }

  Future<void> updateBalance(double balance) async {
    _currentBalance = balance;
    await _cashflowDao.updateBalance(balance);
    notifyListeners();
  }

  Future<void> updateNextPayday(DateTime date) async {
    _nextPayday = date;
    await _cashflowDao.updateCashflow(CashflowInputModel(
      currentBalance: _currentBalance,
      nextPaydayDate: date,
      safetyBuffer: _safetyBuffer,
    ));
    notifyListeners();
  }

  Future<void> updateSafetyBuffer(double buffer) async {
    _safetyBuffer = buffer;
    await _cashflowDao.updateCashflow(CashflowInputModel(
      currentBalance: _currentBalance,
      nextPaydayDate: _nextPayday,
      safetyBuffer: buffer,
    ));
    notifyListeners();
  }

  Future<void> updateAll({
    required double balance,
    required DateTime nextPayday,
    required double safetyBuffer,
  }) async {
    _currentBalance = balance;
    _nextPayday = nextPayday;
    _safetyBuffer = safetyBuffer;
    await _cashflowDao.updateCashflow(CashflowInputModel(
      currentBalance: balance,
      nextPaydayDate: nextPayday,
      safetyBuffer: safetyBuffer,
    ));
    await _auditDao.log(
      actionType: 'cashflow_updated',
      details: {
        'balance': balance,
        'next_payday': nextPayday.toIso8601String().split('T')[0],
        'safety_buffer': safetyBuffer,
      },
    );
    notifyListeners();
  }
}
