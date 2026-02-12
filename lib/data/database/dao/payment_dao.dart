import 'package:sqflite/sqflite.dart';
import '../../../core/constants/database_constants.dart';
import '../database_helper.dart';
import '../../models/payment_model.dart';

class PaymentDao {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<PaymentModel>> getAllPayments() async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tablePayments,
      orderBy: 'scheduled_date DESC',
    );
    return result.map((map) => PaymentModel.fromMap(map)).toList();
  }

  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tablePayments,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'scheduled_date ASC',
    );
    return result.map((map) => PaymentModel.fromMap(map)).toList();
  }

  Future<PaymentModel?> getPaymentByBillId(int billId) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tablePayments,
      where: 'bill_id = ?',
      whereArgs: [billId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return PaymentModel.fromMap(result.first);
  }

  Future<int> insertPayment(PaymentModel payment) async {
    final db = await _db;
    return await db.insert(DatabaseConstants.tablePayments, payment.toMap());
  }

  Future<int> insertPaymentTxn(DatabaseExecutor txn, PaymentModel payment) {
    return txn.insert(DatabaseConstants.tablePayments, payment.toMap());
  }

  Future<int> updatePaymentStatus(int id, String status) async {
    final db = await _db;
    return await db.update(
      DatabaseConstants.tablePayments,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePaymentStatusTxn(DatabaseExecutor txn, String referenceId, String status) {
    return txn.update(
      DatabaseConstants.tablePayments,
      {'status': status},
      where: 'reference_id = ?',
      whereArgs: [referenceId],
    );
  }


  Future<int> deletePayment(int id) async {
    final db = await _db;
    return await db.delete(
      DatabaseConstants.tablePayments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalScheduledForDate(DateTime date) async {
    final db = await _db;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${DatabaseConstants.tablePayments} '
      'WHERE scheduled_date = ? AND status IN (?, ?)',
      [dateStr, 'Scheduled', 'Queued'],
    );
    final value = result.first['total'];
    if (value == null) return 0.0;
    return (value as num).toDouble();
  }

  Future<List<PaymentModel>> getQueuedPayments() async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tablePayments,
      where: 'status = ?',
      whereArgs: ['Queued'],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => PaymentModel.fromMap(map)).toList();
  }
}
