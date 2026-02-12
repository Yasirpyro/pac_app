import 'package:sqflite/sqflite.dart';
import '../../../core/constants/database_constants.dart';
import '../database_helper.dart';
import '../../models/bill_history_model.dart';

class BillHistoryDao {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<BillHistoryModel>> getHistoryForPayee(String payeeName) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableBillHistory,
      where: 'payee_name = ?',
      whereArgs: [payeeName],
      orderBy: 'payment_date DESC',
    );
    return result.map((map) => BillHistoryModel.fromMap(map)).toList();
  }

  Future<double?> getAverageAmountForPayee(String payeeName) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT AVG(amount) as avg_amount FROM ${DatabaseConstants.tableBillHistory} '
      'WHERE payee_name = ?',
      [payeeName],
    );
    if (result.isEmpty || result.first['avg_amount'] == null) return null;
    return (result.first['avg_amount'] as num).toDouble();
  }

  Future<int> insertHistory(BillHistoryModel history) async {
    final db = await _db;
    return await db.insert(DatabaseConstants.tableBillHistory, history.toMap());
  }

  Future<int> insertHistoryTxn(DatabaseExecutor txn, BillHistoryModel history) {
    return txn.insert(DatabaseConstants.tableBillHistory, history.toMap());
  }

  Future<List<BillHistoryModel>> getAllHistory() async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableBillHistory,
      orderBy: 'payment_date DESC',
    );
    return result.map((map) => BillHistoryModel.fromMap(map)).toList();
  }
}
