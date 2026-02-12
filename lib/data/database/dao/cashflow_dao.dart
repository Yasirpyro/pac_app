import 'package:sqflite/sqflite.dart';
import '../../../core/constants/database_constants.dart';
import '../database_helper.dart';
import '../../models/cashflow_input_model.dart';

class CashflowDao {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<CashflowInputModel> getCashflowInputs() async {
    final db = await _db;
    return _getCashflowOn(db);
  }

  Future<CashflowInputModel> getCashflowInputsTxn(DatabaseExecutor txn) {
    return _getCashflowOn(txn);
  }

  Future<CashflowInputModel> _getCashflowOn(DatabaseExecutor db) async {
    final result = await db.query(
      DatabaseConstants.tableCashflowInputs,
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isEmpty) {
      return CashflowInputModel(
        currentBalance: 2800.0,
        nextPaydayDate: DateTime.now().add(const Duration(days: 7)),
        safetyBuffer: 500.0,
      );
    }
    return CashflowInputModel.fromMap(result.first);
  }

  Future<int> updateCashflow(CashflowInputModel cashflow) async {
    final db = await _db;
    final map = cashflow.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      DatabaseConstants.tableCashflowInputs,
      map,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> updateBalance(double balance) async {
    final db = await _db;
    return _updateBalanceOn(db, balance);
  }

  Future<int> updateBalanceTxn(DatabaseExecutor txn, double balance) {
    return _updateBalanceOn(txn, balance);
  }

  Future<int> _updateBalanceOn(DatabaseExecutor db, double balance) async {
    return await db.update(
      DatabaseConstants.tableCashflowInputs,
      {
        'current_balance': balance,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
