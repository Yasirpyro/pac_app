import 'package:flutter/material.dart';
import '../../data/database/dao/bill_dao.dart';
import '../../data/database/dao/payment_dao.dart';
import '../../data/database/dao/cashflow_dao.dart';
import '../../data/database/dao/audit_log_dao.dart';
import '../../data/database/dao/bill_history_dao.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/bill_history_model.dart';
import '../../data/services/auth_service.dart';
import '../../core/utils/reference_generator.dart';

class PaymentProvider extends ChangeNotifier {
  final BillDao _billDao = BillDao();
  final PaymentDao _paymentDao = PaymentDao();
  final CashflowDao _cashflowDao = CashflowDao();
  final AuditLogDao _auditDao = AuditLogDao();
  final BillHistoryDao _historyDao = BillHistoryDao();
  final AuthService _authService = AuthService();

  bool _isProcessing = false;
  String? _error;
  String? _lastReferenceId;

  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get lastReferenceId => _lastReferenceId;

  Future<bool> authenticate() async {
    return await _authService.authenticate();
  }

  Future<bool> schedulePayment({
    required int billId,
    required DateTime scheduledDate,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final bill = await _billDao.getBillById(billId);
      if (bill == null) {
        _error = 'Bill not found';
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      // Generate reference ID
      final referenceId = ReferenceGenerator.generate();
      _lastReferenceId = referenceId;

      // Create payment record
      final payment = PaymentModel(
        billId: billId,
        referenceId: referenceId,
        scheduledDate: scheduledDate,
        amount: bill.amount,
        status: 'Scheduled',
      );
      await _paymentDao.insertPayment(payment);

      // Update bill status
      await _billDao.updateBillStatus(billId, 'Scheduled', referenceId: referenceId);

      // Deduct from balance (simulated)
      final cashflow = await _cashflowDao.getCashflowInputs();
      await _cashflowDao.updateBalance(cashflow.currentBalance - bill.amount);

      // Add to bill history
      await _historyDao.insertHistory(BillHistoryModel(
        payeeName: bill.payeeName,
        amount: bill.amount,
        paymentDate: scheduledDate,
      ));

      // Audit log
      await _auditDao.log(
        actionType: 'payment_scheduled',
        referenceId: referenceId,
        details: {
          'bill_id': billId,
          'payee': bill.payeeName,
          'amount': bill.amount,
          'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
        },
      );

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> queuePayment({required int billId}) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final bill = await _billDao.getBillById(billId);
      if (bill == null) {
        _error = 'Bill not found';
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      final referenceId = ReferenceGenerator.generate();
      _lastReferenceId = referenceId;

      final payment = PaymentModel(
        billId: billId,
        referenceId: referenceId,
        scheduledDate: DateTime.now(),
        amount: bill.amount,
        status: 'Queued',
      );
      await _paymentDao.insertPayment(payment);

      await _billDao.updateBillStatus(billId, 'Queued', referenceId: referenceId);

      await _auditDao.log(
        actionType: 'payment_queued',
        referenceId: referenceId,
        details: {
          'bill_id': billId,
          'payee': bill.payeeName,
          'amount': bill.amount,
          'reason': 'maintenance_mode',
        },
      );

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }
}
