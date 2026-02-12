import 'package:flutter/material.dart';
import '../../data/database/dao/bill_dao.dart';
import '../../data/database/dao/payment_dao.dart';
import '../../data/database/dao/cashflow_dao.dart';
import '../../data/database/dao/audit_log_dao.dart';
import '../../data/database/dao/bill_history_dao.dart';
import '../../data/database/database_helper.dart';
import '../../core/constants/database_constants.dart';
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

      // Wrap all mutations in a single DB transaction for atomicity
      await DatabaseHelper.instance.transaction((txn) async {
        // Create payment record
        final payment = PaymentModel(
          billId: billId,
          referenceId: referenceId,
          scheduledDate: scheduledDate,
          amount: bill.amount,
          status: 'Scheduled',
        );
        await _paymentDao.insertPaymentTxn(txn, payment);

        // Update bill status
        await _billDao.updateBillStatusTxn(txn, billId, 'Scheduled', referenceId: referenceId);

        // Deduct from balance (simulated)
        // For scheduled payments, we might NOT want to deduct immediately depending on requirements,
        // but the current implementation DOES deduct.
        // Based on "Pay Now" requirements implying immediate deduction,
        // and "Scheduled" usually implying future deduction, strictly speaking we might want to wait.
        // However, the current code deducts immediately.
        // For this task, I will keep existing logic for schedulePayment but ensure PayNow is distinct.
        // Actually, let's stick to the plan: Pay Now -> Paid/Simulated. Schedule -> Scheduled.

        final cashflow = await _cashflowDao.getCashflowInputsTxn(txn);
        await _cashflowDao.updateBalanceTxn(txn, cashflow.currentBalance - bill.amount);

        // Add to bill history
        await _historyDao.insertHistoryTxn(txn, BillHistoryModel(
          payeeName: bill.payeeName,
          amount: bill.amount,
          paymentDate: scheduledDate,
        ));

        // Audit log
        await _auditDao.logTxn(
          txn,
          actionType: 'payment_scheduled',
          referenceId: referenceId,
          details: {
            'bill_id': billId,
            'payee': bill.payeeName,
            'amount': bill.amount,
            'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
          },
        );
      });

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

  Future<bool> processImmediatePayment({
    required int billId,
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

      final referenceId = ReferenceGenerator.generate();
      _lastReferenceId = referenceId;
      final now = DateTime.now();

      await DatabaseHelper.instance.transaction((txn) async {
        // Create payment record as Simulated
        final payment = PaymentModel(
          billId: billId,
          referenceId: referenceId,
          scheduledDate: now,
          amount: bill.amount,
          status: 'Simulated',
        );
        await _paymentDao.insertPaymentTxn(txn, payment);

        // Update bill status to Paid
        await _billDao.updateBillStatusTxn(txn, billId, 'Paid', referenceId: referenceId);

        // Deduct from balance
        final cashflow = await _cashflowDao.getCashflowInputsTxn(txn);
        await _cashflowDao.updateBalanceTxn(txn, cashflow.currentBalance - bill.amount);

        // Add to bill history
        await _historyDao.insertHistoryTxn(txn, BillHistoryModel(
          payeeName: bill.payeeName,
          amount: bill.amount,
          paymentDate: now,
        ));

        // Audit log
        await _auditDao.logTxn(
          txn,
          actionType: 'payment_paid_now_simulated',
          referenceId: referenceId,
          details: {
            'bill_id': billId,
            'payee': bill.payeeName,
            'amount': bill.amount,
            'payment_date': now.toIso8601String(),
          },
        );
      });

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

  Future<bool> completeScheduledPayment(int billId) async {
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

      // Check if there is a payment record
      // We need to update the existing payment record status from Scheduled to Simulated
      // But PaymentDao doesn't have a getByBillId exposed easily here,
      // let's check PaymentDao content.
      // Assuming we can find it via reference_id from bill if available, or just create a new one/update logic.
      // Bill model has referenceId.

      final referenceId = bill.referenceId;
      if (referenceId == null) {
          _error = 'No payment reference found for this bill';
          _isProcessing = false;
          notifyListeners();
          return false;
      }

      await DatabaseHelper.instance.transaction((txn) async {
        // Update payment status to Simulated
        // We need a method in PaymentDao to update status by referenceId
        await _paymentDao.updatePaymentStatusTxn(txn, referenceId, 'Simulated');

        // Update bill status to Paid
        await _billDao.updateBillStatusTxn(txn, billId, 'Paid');

        // Note: Balance was already deducted when scheduled in the current implementation of schedulePayment.
        // So we don't deduct again.

        // Audit log
        await _auditDao.logTxn(
          txn,
          actionType: 'scheduled_payment_completed_simulated',
          referenceId: referenceId,
          details: {
            'bill_id': billId,
            'payee': bill.payeeName,
            'amount': bill.amount,
            'completion_date': DateTime.now().toIso8601String(),
          },
        );
      });

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

      await DatabaseHelper.instance.transaction((txn) async {
        final payment = PaymentModel(
          billId: billId,
          referenceId: referenceId,
          scheduledDate: DateTime.now(),
          amount: bill.amount,
          status: 'Queued',
        );
        await _paymentDao.insertPaymentTxn(txn, payment);

        await _billDao.updateBillStatusTxn(txn, billId, 'Queued', referenceId: referenceId);

        await _auditDao.logTxn(
          txn,
          actionType: 'payment_queued',
          referenceId: referenceId,
          details: {
            'bill_id': billId,
            'payee': bill.payeeName,
            'amount': bill.amount,
            'reason': 'maintenance_mode',
          },
        );
      });

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

  Future<bool> processQueuedPayment(int billId) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final bill = await _billDao.getBillById(billId);
      if (bill == null) throw Exception('Bill not found');

      final referenceId = bill.referenceId;
      if (referenceId == null) throw Exception('No reference ID for queued bill');

      await DatabaseHelper.instance.transaction((txn) async {
        // 1. Update Payment status to Simulated
        await _paymentDao.updatePaymentStatusTxn(txn, referenceId, 'Simulated');

        // 2. Update Bill status to Paid
        await _billDao.updateBillStatusTxn(txn, billId, 'Paid');

        // 3. Deduct balance (was not deducted during queueing)
        final cashflow = await _cashflowDao.getCashflowInputsTxn(txn);
        await _cashflowDao.updateBalanceTxn(txn, cashflow.currentBalance - bill.amount);

        // 4. Add to history
        await _historyDao.insertHistoryTxn(txn, BillHistoryModel(
          payeeName: bill.payeeName,
          amount: bill.amount,
          paymentDate: DateTime.now(),
        ));

        // 5. Audit log
        await _auditDao.logTxn(
          txn,
          actionType: 'queued_payment_completed_simulated',
          referenceId: referenceId,
          details: {
            'bill_id': billId,
            'amount': bill.amount,
          },
        );
      });

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

  Future<bool> removeQueuedPayment(int billId) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final bill = await _billDao.getBillById(billId);
      if (bill == null) throw Exception('Bill not found');

      final payment = await _paymentDao.getPaymentByBillId(billId);
      if (payment == null) throw Exception('Payment record not found');

      await DatabaseHelper.instance.transaction((txn) async {
        // 1. Delete payment record
        // Note: We added deletePayment(int id) to DAO earlier, but inside transaction we might need raw delete
        // or just use the non-txn version if we don't need strict atomicity across multiple tables for a delete?
        // Actually, we are updating bill status too, so transaction is safer.
        // Since PaymentDao.deletePayment is not transaction-aware (doesn't take txn),
        // I will use txn.delete directly.
        await txn.delete(
          DatabaseConstants.tablePayments,
          where: 'id = ?',
          whereArgs: [payment.id],
        );

        // 2. Revert Bill status to Pending
        await _billDao.updateBillStatusTxn(txn, billId, 'Pending', referenceId: null);

        // 3. Audit log
        await _auditDao.logTxn(
          txn,
          actionType: 'queued_payment_removed',
          details: {
            'bill_id': billId,
            'payee': bill.payeeName,
          },
        );
      });

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
