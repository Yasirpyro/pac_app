import 'package:flutter/material.dart';
import '../../data/database/dao/bill_dao.dart';
import '../../data/database/dao/audit_log_dao.dart';
import '../../data/database/dao/reminder_dao.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/services/notification_service.dart';

class BillsProvider extends ChangeNotifier {
  final BillDao _billDao = BillDao();
  final AuditLogDao _auditDao = AuditLogDao();
  final ReminderDao _reminderDao = ReminderDao();
  final NotificationService _notificationService = NotificationService();

  List<BillModel> _bills = [];
  Map<int, ReminderModel> _reminders = {};
  bool _isLoading = false;
  String? _error;

  List<BillModel> get bills => _bills;
  Map<int, ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BillModel> get pendingBills =>
      _bills.where((b) => b.status == 'Pending').toList();

  List<BillModel> get scheduledBills =>
      _bills.where((b) =>
        b.status == 'Scheduled' ||
        (b.status == 'Pending' && _reminders.containsKey(b.id))
      ).toList();

  List<BillModel> get paidBills =>
      _bills.where((b) => b.status == 'Paid').toList();

  List<BillModel> get queuedBills =>
      _bills.where((b) => b.status == 'Queued').toList();

  List<BillModel> get billsNeedingAttention {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _bills.where((b) {
      if (b.status != 'Pending') return false;

      final dueDate = DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day);
      final days = dueDate.difference(today).inDays;

      // Due today or overdue (regardless of amount)
      if (days <= 0) return true;

      // Due within 5 days AND amount >= 50
      if (days <= 5 && b.amount >= 50.0) return true;

      return false;
    }).toList();
  }

  List<BillModel> get billsDueTodayOrOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _bills.where((b) {
      if (b.status != 'Pending') return false;
      final dueDate = DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day);
      return dueDate.compareTo(today) <= 0;
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
      await _loadReminders();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadReminders() async {
    final remindersList = await _reminderDao.getAllReminders();
    _reminders = {for (var r in remindersList) r.billId: r};
  }

  Future<BillModel?> getBillById(int id) async {
    return await _billDao.getBillById(id);
  }

  Future<void> setReminder(int billId, DateTime reminderDate) async {
    try {
      // 1. Remove existing reminder if any
      await removeReminder(billId);

      // 2. Create new reminder
      final reminder = ReminderModel(
        billId: billId,
        reminderDate: reminderDate,
      );
      await _reminderDao.insertReminder(reminder);

      // 3. Schedule notification
      final bill = await getBillById(billId);
      if (bill != null) {
        await _notificationService.scheduleUserReminder(bill, reminderDate);
      }

      // 4. Audit log
      await _auditDao.log(
        actionType: 'reminder_set',
        details: {
          'bill_id': billId,
          'reminder_date': reminderDate.toIso8601String(),
        },
      );

      // 5. Reload state
      await _loadReminders();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeReminder(int billId) async {
    try {
      await _reminderDao.deleteReminderByBillId(billId);
      await _notificationService.cancelUserReminder(billId);

      // Audit log only if we actually had one (optional, but good for tracking)
      if (_reminders.containsKey(billId)) {
         await _auditDao.log(
          actionType: 'reminder_removed',
          details: {'bill_id': billId},
        );
      }

      await _loadReminders();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createBill(BillModel bill) async {
    try {
      final id = await _billDao.insertBill(bill);

      // Schedule notifications
      final createdBill = bill.copyWith(id: id);
      await _notificationService.scheduleNotificationsForBill(createdBill);

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

      // Reschedule notifications
      await _notificationService.scheduleNotificationsForBill(bill);

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

      // Cancel notifications
      await _notificationService.cancelNotificationsForBill(id);

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

      // Cancel notifications for paid bill
      await _notificationService.cancelNotificationsForBill(id);

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

  Future<void> rescheduleAllNotifications() async {
    await _notificationService.cancelAll();
    final bills = await _billDao.getAllBills();

    // Reschedule standard notifications
    for (final bill in bills) {
      if (bill.status == 'Pending') {
        await _notificationService.scheduleNotificationsForBill(bill);
      }
    }

    // Reschedule custom reminders
    final reminders = await _reminderDao.getAllReminders();
    for (final reminder in reminders) {
      final bill = bills.firstWhere((b) => b.id == reminder.billId, orElse: () => BillModel(id: -1, payeeName: '', amount: 0, dueDate: DateTime.now(), category: 'Other'));
      if (bill.id != -1 && bill.status == 'Pending') {
        await _notificationService.scheduleUserReminder(bill, reminder.reminderDate);
      }
    }
  }
}
