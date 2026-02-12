import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/database_constants.dart';
import '../database_helper.dart';
import '../../models/audit_log_model.dart';

class AuditLogDao {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<AuditLogModel>> getAllLogs({int limit = 50}) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableAuditLogs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => AuditLogModel.fromMap(map)).toList();
  }

  Future<int> log({
    required String actionType,
    String? referenceId,
    Map<String, dynamic>? details,
    String? userNote,
  }) async {
    final db = await _db;
    return _logOn(db, actionType: actionType, referenceId: referenceId, details: details, userNote: userNote);
  }

  Future<int> logTxn(
    DatabaseExecutor txn, {
    required String actionType,
    String? referenceId,
    Map<String, dynamic>? details,
    String? userNote,
  }) {
    return _logOn(txn, actionType: actionType, referenceId: referenceId, details: details, userNote: userNote);
  }

  Future<int> _logOn(
    DatabaseExecutor db, {
    required String actionType,
    String? referenceId,
    Map<String, dynamic>? details,
    String? userNote,
  }) async {
    return await db.insert(DatabaseConstants.tableAuditLogs, {
      'action_type': actionType,
      'reference_id': referenceId,
      'details': details != null ? jsonEncode(details) : null,
      'user_note': userNote,
    });
  }

  Future<List<AuditLogModel>> getLogsByAction(String actionType) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableAuditLogs,
      where: 'action_type = ?',
      whereArgs: [actionType],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => AuditLogModel.fromMap(map)).toList();
  }

  Future<List<AuditLogModel>> getLogsByReference(String referenceId) async {
    final db = await _db;
    final result = await db.query(
      DatabaseConstants.tableAuditLogs,
      where: 'reference_id = ?',
      whereArgs: [referenceId],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => AuditLogModel.fromMap(map)).toList();
  }
}
