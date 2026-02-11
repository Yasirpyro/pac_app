import 'package:sqflite/sqflite.dart';
import '../../../core/constants/database_constants.dart';
import '../database_helper.dart';
import '../../models/bill_model.dart';

class BillDao {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<BillModel>> getAllBills() async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableBills,
      orderBy: 'due_date ASC',
    );
    return result.map((map) => BillModel.fromMap(map)).toList();
  }

  Future<List<BillModel>> getBillsByStatus(String status) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableBills,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'due_date ASC',
    );
    return result.map((map) => BillModel.fromMap(map)).toList();
  }

  Future<BillModel?> getBillById(int id) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableBills,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return BillModel.fromMap(result.first);
  }

  Future<int> insertBill(BillModel bill) async {
    final db = await _db;
    return await db.insert(DatabaseConstants.tableBills, bill.toMap());
  }

  Future<int> updateBill(BillModel bill) async {
    final db = await _db;
    final map = bill.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      DatabaseConstants.tableBills,
      map,
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> updateBillStatus(int id, String status, {String? referenceId}) async {
    final db = await _db;
    final map = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (referenceId != null) {
      map['reference_id'] = referenceId;
    }
    return await db.update(
      DatabaseConstants.tableBills,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBill(int id) async {
    final db = await _db;
    return await db.delete(
      DatabaseConstants.tableBills,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BillModel>> getUpcomingBills({int days = 7}) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String().split('T')[0];
    final futureDate = DateTime.now().add(Duration(days: days)).toIso8601String().split('T')[0];
    final result = await db.query(
      DatabaseConstants.tableBills,
      where: 'status = ? AND due_date BETWEEN ? AND ?',
      whereArgs: ['Pending', now, futureDate],
      orderBy: 'due_date ASC',
    );
    return result.map((map) => BillModel.fromMap(map)).toList();
  }

  Future<List<BillModel>> getOverdueBills() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.query(
      DatabaseConstants.tableBills,
      where: 'status = ? AND due_date < ?',
      whereArgs: ['Pending', now],
      orderBy: 'due_date ASC',
    );
    return result.map((map) => BillModel.fromMap(map)).toList();
  }
}
