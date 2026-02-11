import 'package:flutter/material.dart';
import '../../data/database/dao/bill_dao.dart';
import '../../data/database/dao/audit_log_dao.dart';
import '../../data/models/bill_model.dart';

class BillsProvider extends ChangeNotifier {
  final BillDao _billDao = BillDao();
  final AuditLogDao _auditDao = AuditLogDao();

  List<BillModel> _bills = [];
  bool _isLoading = false;
  String? _error;

  List<BillModel> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BillModel> get pendingBills =>
      _bills.where((b) => b.status == 'Pending').toList();

  List<BillModel> get scheduledBills =>
      _bills.where((b) => b.status == 'Scheduled').toList();

  List<BillModel> get paidBills =>
      _bills.where((b) => b.status == 'Paid').toList();

  List<BillModel> get queuedBills =>
      _bills.where((b) => b.status == 'Queued').toList();

  List<BillModel> get billsNeedingAttention {
    final now = DateTime.now();
    return _bills.where((b) {
      if (b.status != 'Pending') return false;
      final days = b.dueDate.difference(now).inDays;
      return days <= 7;
    }).toList();
  }

  double get totalPendingAmount =>
      pendingBills.fold(0, (sum, b) => sum + b.amount);

  Future<void> loadBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bills = await _billDao.getAllBills();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<BillModel?> getBillById(int id) async {
    return await _billDao.getBillById(id);
  }

  Future<void> createBill(BillModel bill) async {
    try {
      final id = await _billDao.insertBill(bill);
      await _auditDao.log(
        actionType: 'bill_created',
        details: {
          'bill_id': id,
          'payee': bill.payeeName,
          'amount': bill.amount,
          'due_date': bill.dueDate.toIso8601String().split('T')[0],
          'category': bill.category,
        },
      );
      await loadBills();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateBill(BillModel bill) async {
    try {
      await _billDao.updateBill(bill);
      await _auditDao.log(
        actionType: 'bill_updated',
        details: {
          'bill_id': bill.id,
          'payee': bill.payeeName,
          'amount': bill.amount,
        },
      );
      await loadBills();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBill(int id) async {
    try {
      final bill = await _billDao.getBillById(id);
      await _billDao.deleteBill(id);
      await _auditDao.log(
        actionType: 'bill_deleted',
        details: {
          'bill_id': id,
          'payee': bill?.payeeName,
        },
      );
      await loadBills();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsPaid(int id) async {
    try {
      await _billDao.updateBillStatus(id, 'Paid');
      await _auditDao.log(
        actionType: 'bill_marked_paid',
        details: {'bill_id': id},
      );
      await loadBills();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
