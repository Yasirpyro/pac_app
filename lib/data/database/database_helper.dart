import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/database_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Bills table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBills} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payee_name TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        due_date TEXT NOT NULL,
        category TEXT NOT NULL CHECK(category IN ('Utilities', 'Insurance', 'Subscriptions', 'Other')),
        status TEXT NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'Scheduled', 'Paid', 'Queued')),
        reference_id TEXT UNIQUE,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePayments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_id INTEGER NOT NULL,
        reference_id TEXT NOT NULL UNIQUE,
        scheduled_date TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Scheduled' CHECK(status IN ('Queued', 'Scheduled', 'Simulated')),
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (bill_id) REFERENCES ${DatabaseConstants.tableBills}(id)
      )
    ''');

    // Audit logs table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableAuditLogs} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT DEFAULT (datetime('now')),
        action_type TEXT NOT NULL,
        reference_id TEXT,
        details TEXT,
        user_note TEXT
      )
    ''');

    // Cashflow inputs table (single row)
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCashflowInputs} (
        id INTEGER PRIMARY KEY,
        current_balance REAL NOT NULL DEFAULT 0,
        next_payday_date TEXT NOT NULL,
        safety_buffer REAL NOT NULL DEFAULT 500,
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // Settings table (single row)
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSettings} (
        id INTEGER PRIMARY KEY,
        daily_payment_cap REAL NOT NULL DEFAULT 2000,
        maintenance_mode INTEGER NOT NULL DEFAULT 0,
        demo_mode INTEGER NOT NULL DEFAULT 1,
        notification_enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Bill history table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBillHistory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payee_name TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL
      )
    ''');

    // Indexes
    await db.execute('''
      CREATE INDEX idx_bills_status ON ${DatabaseConstants.tableBills}(status)
    ''');
    await db.execute('''
      CREATE INDEX idx_bills_due_date ON ${DatabaseConstants.tableBills}(due_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_payments_bill_id ON ${DatabaseConstants.tablePayments}(bill_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_payments_scheduled ON ${DatabaseConstants.tablePayments}(scheduled_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_audit_timestamp ON ${DatabaseConstants.tableAuditLogs}(timestamp)
    ''');
    await db.execute('''
      CREATE INDEX idx_history_payee ON ${DatabaseConstants.tableBillHistory}(payee_name)
    ''');

    // Seed default data
    await _seedDefaultData(db);
  }

  Future<void> _seedDefaultData(Database db) async {
    // Default settings
    await db.insert(DatabaseConstants.tableSettings, {
      'id': 1,
      'daily_payment_cap': 2000.0,
      'maintenance_mode': 0,
      'demo_mode': 1,
      'notification_enabled': 1,
    });

    // Default cashflow inputs
    final nextPayday = DateTime.now().add(const Duration(days: 7));
    await db.insert(DatabaseConstants.tableCashflowInputs, {
      'id': 1,
      'current_balance': 2800.0,
      'next_payday_date': nextPayday.toIso8601String().split('T')[0],
      'safety_buffer': 500.0,
    });

    // Seed demo bills
    await _seedDemoBills(db);

    // Seed bill history for anomaly detection
    await _seedBillHistory(db);

    // Log initial setup
    await db.insert(DatabaseConstants.tableAuditLogs, {
      'action_type': 'app_initialized',
      'details': '{"version": "1.0.0", "demo_mode": true}',
      'user_note': 'First launch with demo data',
    });
  }

  Future<void> _seedDemoBills(Database db) async {
    final now = DateTime.now();

    final demoBills = [
      {
        'payee_name': 'ComEd Electric',
        'amount': 145.50,
        'due_date': now.add(const Duration(days: 3)).toIso8601String().split('T')[0],
        'category': 'Utilities',
        'status': 'Pending',
      },
      {
        'payee_name': 'Nicor Gas',
        'amount': 89.00,
        'due_date': now.add(const Duration(days: 5)).toIso8601String().split('T')[0],
        'category': 'Utilities',
        'status': 'Pending',
      },
      {
        'payee_name': 'State Farm Insurance',
        'amount': 220.00,
        'due_date': now.add(const Duration(days: 10)).toIso8601String().split('T')[0],
        'category': 'Insurance',
        'status': 'Pending',
      },
      {
        'payee_name': 'Netflix',
        'amount': 15.99,
        'due_date': now.add(const Duration(days: 12)).toIso8601String().split('T')[0],
        'category': 'Subscriptions',
        'status': 'Pending',
      },
      {
        'payee_name': 'Water Utility',
        'amount': 65.00,
        'due_date': now.add(const Duration(days: -2)).toIso8601String().split('T')[0],
        'category': 'Utilities',
        'status': 'Pending',
      },
    ];

    for (final bill in demoBills) {
      await db.insert(DatabaseConstants.tableBills, bill);
    }
  }

  Future<void> _seedBillHistory(Database db) async {
    final histories = [
      {'payee_name': 'ComEd Electric', 'amount': 135.00, 'payment_date': '2026-01-15'},
      {'payee_name': 'ComEd Electric', 'amount': 142.00, 'payment_date': '2025-12-15'},
      {'payee_name': 'ComEd Electric', 'amount': 128.50, 'payment_date': '2025-11-15'},
      {'payee_name': 'Nicor Gas', 'amount': 85.00, 'payment_date': '2026-01-10'},
      {'payee_name': 'Nicor Gas', 'amount': 92.00, 'payment_date': '2025-12-10'},
      {'payee_name': 'Nicor Gas', 'amount': 78.00, 'payment_date': '2025-11-10'},
      {'payee_name': 'State Farm Insurance', 'amount': 220.00, 'payment_date': '2026-01-20'},
      {'payee_name': 'State Farm Insurance', 'amount': 220.00, 'payment_date': '2025-12-20'},
      {'payee_name': 'Netflix', 'amount': 15.99, 'payment_date': '2026-01-28'},
      {'payee_name': 'Netflix', 'amount': 15.99, 'payment_date': '2025-12-28'},
      {'payee_name': 'Water Utility', 'amount': 62.00, 'payment_date': '2026-01-05'},
      {'payee_name': 'Water Utility', 'amount': 58.00, 'payment_date': '2025-12-05'},
    ];

    for (final h in histories) {
      await db.insert(DatabaseConstants.tableBillHistory, h);
    }
  }

  Future<void> resetDemoData() async {
    final db = await database;
    await db.delete(DatabaseConstants.tableBills);
    await db.delete(DatabaseConstants.tablePayments);
    await db.delete(DatabaseConstants.tableAuditLogs);
    await db.delete(DatabaseConstants.tableBillHistory);

    // Reset cashflow
    await db.update(
      DatabaseConstants.tableCashflowInputs,
      {
        'current_balance': 2800.0,
        'next_payday_date': DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
        'safety_buffer': 500.0,
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    // Reset settings
    await db.update(
      DatabaseConstants.tableSettings,
      {
        'daily_payment_cap': 2000.0,
        'maintenance_mode': 0,
        'demo_mode': 1,
        'notification_enabled': 1,
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    // Re-seed
    await _seedDemoBills(db);
    await _seedBillHistory(db);

    await db.insert(DatabaseConstants.tableAuditLogs, {
      'action_type': 'demo_data_reset',
      'details': '{"reset": true}',
      'user_note': 'Demo data has been reset',
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
