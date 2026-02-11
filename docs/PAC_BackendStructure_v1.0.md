# Backend Architecture & Database Structure: Payment Assurance Copilot (PAC)

**Version:** 1.0  
**Last Updated:** February 10, 2026  
**Purpose:** Complete backend architecture, database schema, and service layer specification  
**Audience:** Developers, Technical Reviewers, AI Code Assistants

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Database Schema](#2-database-schema)
3. [Data Access Layer (DAOs)](#3-data-access-layer-daos)
4. [Repository Layer](#4-repository-layer)
5. [Service Layer](#5-service-layer)
6. [Data Models](#6-data-models)
7. [Database Operations](#7-database-operations)
8. [AI Integration Service](#8-ai-integration-service)
9. [Audit Logging](#9-audit-logging)
10. [Error Handling](#10-error-handling)
11. [Testing Strategy](#11-testing-strategy)
12. [Performance Considerations](#12-performance-considerations)

---

## 1. Architecture Overview

### 1.1 Architecture Pattern

PAC follows a **Clean Architecture** approach with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Screens   │  │   Widgets   │  │  Providers  │  │   Router    │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └─────────────┘    │
│         │                │                │                             │
└─────────┼────────────────┼────────────────┼─────────────────────────────┘
          │                │                │
          └────────────────┴────────┬───────┘
                                    │
┌───────────────────────────────────┼─────────────────────────────────────┐
│                          DOMAIN LAYER                                   │
│                                   │                                     │
│  ┌─────────────┐  ┌──────────────┴──────────────┐  ┌─────────────┐     │
│  │   Models    │  │        Repositories         │  │  Use Cases  │     │
│  │  (Entities) │  │  (Abstract Interfaces)      │  │  (Business) │     │
│  └─────────────┘  └──────────────┬──────────────┘  └─────────────┘     │
│                                  │                                      │
└──────────────────────────────────┼──────────────────────────────────────┘
                                   │
┌──────────────────────────────────┼──────────────────────────────────────┐
│                           DATA LAYER                                    │
│                                  │                                      │
│  ┌───────────────────────────────┴───────────────────────────────┐     │
│  │                    Repository Implementations                  │     │
│  └───────────────────────────────┬──────────────────────────��────┘     │
│                                  │                                      │
│         ┌────────────────────────┼────────────────────────┐            │
│         │                        │                        │            │
│  ┌──────┴──────┐         ┌───────┴───────┐        ┌───────┴───────┐   │
│  │    DAOs     │         │   Services    │        │  API Client   │   │
│  │  (SQLite)   │         │  (Business)   │        │   (Gemini)    │   │
│  └──────┬──────┘         └───────────────┘        └───────────────┘   │
│         │                                                              │
│  ┌──────┴──────┐                                                       │
│  │   SQLite    │                                                       │
│  │  Database   │                                                       │
│  └─────────────┘                                                       │
└────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Layer Responsibilities

| Layer | Responsibility | Components |
|-------|----------------|------------|
| **Presentation** | UI rendering, user input, state management | Screens, Widgets, Providers |
| **Domain** | Business logic, entities, use cases | Models, Repository interfaces |
| **Data** | Data persistence, API calls, caching | DAOs, Repository implementations, Services |

### 1.3 Directory Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/                          # Shared utilities
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── database_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── utils/
│       ├── formatters.dart
│       ├── validators.dart
│       └── reference_generator.dart
│
├── data/                          # Data layer
│   ├── database/
│   │   ├── database_helper.dart   # SQLite initialization
│   │   ├── migrations/
│   │   │   └── migrations.dart
│   │   └── dao/                   # Data Access Objects
│   │       ├── bill_dao.dart
│   │       ├── payment_dao.dart
│   │       ├── audit_log_dao.dart
│   │       ├── cashflow_dao.dart
│   │       ├── settings_dao.dart
│   │       └── bill_history_dao.dart
│   ├── models/                    # Data models (DB representation)
│   │   ├── bill_model.dart
│   │   ├── payment_model.dart
│   │   ├── audit_log_model.dart
│   │   ├── cashflow_input_model.dart
│   │   ├── settings_model.dart
│   │   └── bill_history_model.dart
│   ├── repositories/              # Repository implementations
│   │   ├── bill_repository_impl.dart
│   │   ├── payment_repository_impl.dart
│   │   ├── audit_repository_impl.dart
│   │   ├── cashflow_repository_impl.dart
│   │   └── settings_repository_impl.dart
│   └── services/                  # External services
│       ├── ai_service.dart
│       ├── recommendation_service.dart
│       └── auth_service.dart
│
├── domain/                        # Domain layer
│   ├── entities/                  # Business entities
│   │   ├── bill.dart
│   │   ├── payment.dart
│   │   ├── audit_log.dart
│   ���   ├── cashflow_input.dart
│   │   ├── settings.dart
│   │   └── recommendation.dart
│   ├── repositories/              # Repository interfaces
│   │   ├── bill_repository.dart
│   │   ├── payment_repository.dart
│   │   ├── audit_repository.dart
│   │   ├── cashflow_repository.dart
│   │   └── settings_repository.dart
│   └── usecases/                  # Use cases (business logic)
│       ├── get_bills_usecase.dart
│       ├── create_bill_usecase.dart
│       ├── schedule_payment_usecase.dart
│       ├── get_recommendation_usecase.dart
│       └── check_safety_usecase.dart
│
├── presentation/                  # Presentation layer
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   └── router/
│
└── theme/
    ├── app_colors.dart
    ├── app_spacing.dart
    └── app_theme.dart
```

### 1.4 Dependency Flow

```
Presentation → Domain ← Data
     ↓           ↑        ↓
  Provider → Repository → DAO → SQLite
             (interface)  (impl)
```

**Key Rules:**
1. Presentation depends on Domain only (via repository interfaces)
2. Data implements Domain interfaces
3. Domain has no external dependencies
4. Data layer handles all I/O (database, network)

---

## 2. Database Schema

### 2.1 Entity Relationship Diagram

```
┌─────────────────────┐       ┌─────────────────────┐
│       bills         │       │      payments       │
├─────────────────────┤       ├─────────────────────┤
│ id (PK)             │──────<│ id (PK)             │
│ payee_name          │       │ bill_id (FK)        │
│ amount              │       │ reference_id        │
│ due_date            │       │ scheduled_date      │
│ category            │       │ amount              │
│ status              │       │ status              │
│ reference_id        │       │ created_at          │
│ created_at          │       └─────────────────────┘
│ updated_at          │
└─────────────────────┘
          │
          │ (payee_name)
          ↓
┌───────────���─────────┐       ┌─────────────────────┐
│    bill_history     │       │     audit_logs      │
├─────────────────────┤       ├─────────────────────┤
│ id (PK)             │       │ id (PK)             │
│ payee_name          │       │ timestamp           │
│ amount              │       │ action_type         │
│ payment_date        │       │ reference_id        │
└─────────────────────┘       │ details (JSON)      │
                              │ user_note           │
                              └─────────────────────┘

┌─────────────────────┐       ┌─────────────────────┐
│  cashflow_inputs    │       │      settings       │
├─────────────────────┤       ├─────────────────────┤
│ id (PK, always 1)   │       │ id (PK, always 1)   │
│ current_balance     │       │ daily_payment_cap   │
│ next_payday_date    │       │ maintenance_mode    │
│ safety_buffer       │       │ demo_mode           │
│ updated_at          │       │ notification_enabled│
└─────────────────────┘       └─────────────────────┘
```

### 2.2 Table Definitions

#### 2.2.1 bills

Primary table for storing bill records.

```sql
CREATE TABLE bills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    payee_name TEXT NOT NULL,
    amount REAL NOT NULL CHECK(amount > 0 AND amount <= 9999.99),
    due_date TEXT NOT NULL,  -- ISO 8601 format: YYYY-MM-DD
    category TEXT NOT NULL CHECK(category IN ('Utilities', 'Insurance', 'Subscriptions', 'Other')),
    status TEXT NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'Scheduled', 'Paid', 'Queued')),
    reference_id TEXT UNIQUE,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Indexes for common queries
CREATE INDEX idx_bills_due_date ON bills(due_date);
CREATE INDEX idx_bills_status ON bills(status);
CREATE INDEX idx_bills_payee_name ON bills(payee_name);
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique identifier |
| `payee_name` | TEXT | NOT NULL, max 50 chars | Name of bill recipient |
| `amount` | REAL | NOT NULL, > 0, ≤ 9999.99 | Bill amount in dollars |
| `due_date` | TEXT | NOT NULL, ISO 8601 | Payment due date |
| `category` | TEXT | NOT NULL, ENUM | Bill category |
| `status` | TEXT | NOT NULL, ENUM, DEFAULT 'Pending' | Current bill status |
| `reference_id` | TEXT | UNIQUE, NULLABLE | Payment reference (PAC-YYYYMMDD-NNN) |
| `created_at` | TEXT | NOT NULL, DEFAULT NOW | Creation timestamp |
| `updated_at` | TEXT | NOT NULL, DEFAULT NOW | Last update timestamp |

#### 2.2.2 payments

Records of scheduled/queued/simulated payments.

```sql
CREATE TABLE payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bill_id INTEGER NOT NULL,
    reference_id TEXT NOT NULL UNIQUE,
    scheduled_date TEXT NOT NULL,  -- ISO 8601 format
    amount REAL NOT NULL CHECK(amount > 0),
    status TEXT NOT NULL DEFAULT 'Scheduled' CHECK(status IN ('Queued', 'Scheduled', 'Simulated')),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_payments_bill_id ON payments(bill_id);
CREATE INDEX idx_payments_scheduled_date ON payments(scheduled_date);
CREATE INDEX idx_payments_status ON payments(status);
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique identifier |
| `bill_id` | INTEGER | NOT NULL, FK → bills(id) | Associated bill |
| `reference_id` | TEXT | NOT NULL, UNIQUE | Payment reference ID |
| `scheduled_date` | TEXT | NOT NULL, ISO 8601 | When payment will process |
| `amount` | REAL | NOT NULL, > 0 | Payment amount |
| `status` | TEXT | NOT NULL, ENUM | Payment status |
| `created_at` | TEXT | NOT NULL, DEFAULT NOW | Creation timestamp |

#### 2.2.3 audit_logs

Complete audit trail of all user actions and system events.

```sql
CREATE TABLE audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL DEFAULT (datetime('now')),
    action_type TEXT NOT NULL,
    reference_id TEXT,
    details TEXT,  -- JSON format
    user_note TEXT
);

-- Index for chronological queries
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_audit_logs_action_type ON audit_logs(action_type);
CREATE INDEX idx_audit_logs_reference_id ON audit_logs(reference_id);
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique identifier |
| `timestamp` | TEXT | NOT NULL, DEFAULT NOW | When action occurred |
| `action_type` | TEXT | NOT NULL | Type of action (see 9.2) |
| `reference_id` | TEXT | NULLABLE | Associated reference ID |
| `details` | TEXT | NULLABLE, JSON | Structured action details |
| `user_note` | TEXT | NULLABLE | Human-readable description |

#### 2.2.4 cashflow_inputs

Synthetic cashflow data for AI recommendations (single row).

```sql
CREATE TABLE cashflow_inputs (
    id INTEGER PRIMARY KEY CHECK(id = 1),  -- Enforces single row
    current_balance REAL NOT NULL DEFAULT 0 CHECK(current_balance >= 0),
    next_payday_date TEXT NOT NULL,
    safety_buffer REAL NOT NULL DEFAULT 500 CHECK(safety_buffer >= 100 AND safety_buffer <= 2000),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Insert default row on database creation
INSERT INTO cashflow_inputs (id, current_balance, next_payday_date, safety_buffer)
VALUES (1, 2800.00, date('now', '+14 days'), 500.00);
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, CHECK = 1 | Always 1 (single row) |
| `current_balance` | REAL | NOT NULL, ≥ 0 | Synthetic account balance |
| `next_payday_date` | TEXT | NOT NULL, ISO 8601 | Next payday date |
| `safety_buffer` | REAL | NOT NULL, 100-2000 | Minimum balance to maintain |
| `updated_at` | TEXT | NOT NULL, DEFAULT NOW | Last update timestamp |

#### 2.2.5 settings

Application settings (single row).

```sql
CREATE TABLE settings (
    id INTEGER PRIMARY KEY CHECK(id = 1),  -- Enforces single row
    daily_payment_cap REAL NOT NULL DEFAULT 2000 CHECK(daily_payment_cap >= 100 AND daily_payment_cap <= 10000),
    maintenance_mode INTEGER NOT NULL DEFAULT 0 CHECK(maintenance_mode IN (0, 1)),
    demo_mode INTEGER NOT NULL DEFAULT 1 CHECK(demo_mode IN (0, 1)),
    notification_enabled INTEGER NOT NULL DEFAULT 1 CHECK(notification_enabled IN (0, 1))
);

-- Insert default row on database creation
INSERT INTO settings (id, daily_payment_cap, maintenance_mode, demo_mode, notification_enabled)
VALUES (1, 2000.00, 0, 1, 1);
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, CHECK = 1 | Always 1 (single row) |
| `daily_payment_cap` | REAL | NOT NULL, 100-10000 | Max daily payment amount |
| `maintenance_mode` | INTEGER | NOT NULL, 0 or 1 | Maintenance mode toggle |
| `demo_mode` | INTEGER | NOT NULL, 0 or 1, DEFAULT 1 | Demo mode toggle |
| `notification_enabled` | INTEGER | NOT NULL, 0 or 1 | Notifications toggle |

#### 2.2.6 bill_history

Historical payment data for anomaly detection.

```sql
CREATE TABLE bill_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    payee_name TEXT NOT NULL,
    amount REAL NOT NULL CHECK(amount > 0),
    payment_date TEXT NOT NULL
);

-- Index for payee lookups
CREATE INDEX idx_bill_history_payee ON bill_history(payee_name);
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique identifier |
| `payee_name` | TEXT | NOT NULL | Payee for matching |
| `amount` | REAL | NOT NULL, > 0 | Historical amount |
| `payment_date` | TEXT | NOT NULL, ISO 8601 | When payment was made |

### 2.3 Database Initialization

```dart
// lib/data/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../database/migrations/migrations.dart';

class DatabaseHelper {
  static const String _databaseName = 'pac_database.db';
  static const int _databaseVersion = 1;
  
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();
  
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }
  
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payee_name TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0 AND amount <= 9999.99),
        due_date TEXT NOT NULL,
        category TEXT NOT NULL CHECK(category IN ('Utilities', 'Insurance', 'Subscriptions', 'Other')),
        status TEXT NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending', 'Scheduled', 'Paid', 'Queued')),
        reference_id TEXT UNIQUE,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');
    
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_id INTEGER NOT NULL,
        reference_id TEXT NOT NULL UNIQUE,
        scheduled_date TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        status TEXT NOT NULL DEFAULT 'Scheduled' CHECK(status IN ('Queued', 'Scheduled', 'Simulated')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL DEFAULT (datetime('now')),
        action_type TEXT NOT NULL,
        reference_id TEXT,
        details TEXT,
        user_note TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE cashflow_inputs (
        id INTEGER PRIMARY KEY CHECK(id = 1),
        current_balance REAL NOT NULL DEFAULT 0 CHECK(current_balance >= 0),
        next_payday_date TEXT NOT NULL,
        safety_buffer REAL NOT NULL DEFAULT 500 CHECK(safety_buffer >= 100 AND safety_buffer <= 2000),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');
    
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY CHECK(id = 1),
        daily_payment_cap REAL NOT NULL DEFAULT 2000 CHECK(daily_payment_cap >= 100 AND daily_payment_cap <= 10000),
        maintenance_mode INTEGER NOT NULL DEFAULT 0 CHECK(maintenance_mode IN (0, 1)),
        demo_mode INTEGER NOT NULL DEFAULT 1 CHECK(demo_mode IN (0, 1)),
        notification_enabled INTEGER NOT NULL DEFAULT 1 CHECK(notification_enabled IN (0, 1))
      )
    ''');
    
    await db.execute('''
      CREATE TABLE bill_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payee_name TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        payment_date TEXT NOT NULL
      )
    ''');
    
    // Create indexes
    await db.execute('CREATE INDEX idx_bills_due_date ON bills(due_date)');
    await db.execute('CREATE INDEX idx_bills_status ON bills(status)');
    await db.execute('CREATE INDEX idx_bills_payee_name ON bills(payee_name)');
    await db.execute('CREATE INDEX idx_payments_bill_id ON payments(bill_id)');
    await db.execute('CREATE INDEX idx_payments_scheduled_date ON payments(scheduled_date)');
    await db.execute('CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC)');
    await db.execute('CREATE INDEX idx_audit_logs_action_type ON audit_logs(action_type)');
    await db.execute('CREATE INDEX idx_bill_history_payee ON bill_history(payee_name)');
    
    // Insert default data
    await db.insert('cashflow_inputs', {
      'id': 1,
      'current_balance': 2800.00,
      'next_payday_date': DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
      'safety_buffer': 500.00,
    });
    
    await db.insert('settings', {
      'id': 1,
      'daily_payment_cap': 2000.00,
      'maintenance_mode': 0,
      'demo_mode': 1,
      'notification_enabled': 1,
    });
    
    // Seed demo bills
    await _seedDemoData(db);
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
    await Migrations.migrate(db, oldVersion, newVersion);
  }
  
  Future<void> _seedDemoData(Database db) async {
    final now = DateTime.now();
    
    final demoBills = [
      {
        'payee_name': 'ComEd Electric',
        'amount': 180.50,
        'due_date': now.add(const Duration(days: 5)).toIso8601String().split('T')[0],
        'category': 'Utilities',
        'status': 'Pending',
      },
      {
        'payee_name': 'Comcast Internet',
        'amount': 89.00,
        'due_date': now.add(const Duration(days: 1)).toIso8601String().split('T')[0],
        'category': 'Utilities',
        'status': 'Pending',
      },
      {
        'payee_name': 'State Farm Insurance',
        'amount': 145.00,
        'due_date': now.add(const Duration(days: 8)).toIso8601String().split('T')[0],
        'category': 'Insurance',
        'status': 'Pending',
      },
      {
        'payee_name': 'Netflix',
        'amount': 15.99,
        'due_date': now.add(const Duration(days: 10)).toIso8601String().split('T')[0],
        'category': 'Subscriptions',
        'status': 'Pending',
      },
      {
        'payee_name': 'Water Utility',
        'amount': 62.00,
        'due_date': now.add(const Duration(days: 13)).toIso8601String().split('T')[0],
        'category': 'Utilities',
        'status': 'Pending',
      },
    ];
    
    for (final bill in demoBills) {
      await db.insert('bills', bill);
    }
    
    // Seed bill history for anomaly detection
    final historyData = [
      {'payee_name': 'ComEd Electric', 'amount': 165.00, 'payment_date': now.subtract(const Duration(days: 90)).toIso8601String().split('T')[0]},
      {'payee_name': 'ComEd Electric', 'amount': 172.00, 'payment_date': now.subtract(const Duration(days: 60)).toIso8601String().split('T')[0]},
      {'payee_name': 'ComEd Electric', 'amount': 168.00, 'payment_date': now.subtract(const Duration(days: 30)).toIso8601String().split('T')[0]},
      {'payee_name': 'Comcast Internet', 'amount': 89.00, 'payment_date': now.subtract(const Duration(days: 90)).toIso8601String().split('T')[0]},
      {'payee_name': 'Comcast Internet', 'amount': 89.00, 'payment_date': now.subtract(const Duration(days: 60)).toIso8601String().split('T')[0]},
      {'payee_name': 'Comcast Internet', 'amount': 89.00, 'payment_date': now.subtract(const Duration(days: 30)).toIso8601String().split('T')[0]},
    ];
    
    for (final history in historyData) {
      await db.insert('bill_history', history);
    }
    
    // Log seed action
    await db.insert('audit_logs', {
      'action_type': 'system_init',
      'details': '{"action": "demo_data_seeded", "bills_count": ${demoBills.length}}',
      'user_note': 'Demo data seeded on first launch',
    });
  }
  
  Future<void> resetDatabase() async {
    final db = await database;
    
    // Delete all data
    await db.delete('payments');
    await db.delete('bills');
    await db.delete('audit_logs');
    await db.delete('bill_history');
    
    // Reset to defaults
    await db.update('cashflow_inputs', {
      'current_balance': 2800.00,
      'next_payday_date': DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
      'safety_buffer': 500.00,
    });
    
    await db.update('settings', {
      'daily_payment_cap': 2000.00,
      'maintenance_mode': 0,
      'demo_mode': 1,
      'notification_enabled': 1,
    });
    
    // Re-seed demo data
    await _seedDemoData(db);
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
```

---

## 3. Data Access Layer (DAOs)

### 3.1 Base DAO

```dart
// lib/data/database/dao/base_dao.dart

import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

abstract class BaseDao {
  Future<Database> get db async => await DatabaseHelper.instance.database;
  
  String get tableName;
  
  Future<int> insert(Map<String, dynamic> data) async {
    final database = await db;
    return await database.insert(tableName, data);
  }
  
  Future<int> update(Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    final database = await db;
    return await database.update(tableName, data, where: where, whereArgs: whereArgs);
  }
  
  Future<int> delete(String where, List<dynamic> whereArgs) async {
    final database = await db;
    return await database.delete(tableName, where: where, whereArgs: whereArgs);
  }
  
  Future<List<Map<String, dynamic>>> query({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final database = await db;
    return await database.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
}
```

### 3.2 Bill DAO

```dart
// lib/data/database/dao/bill_dao.dart

import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';
import '../../models/bill_model.dart';

class BillDao extends BaseDao {
  @override
  String get tableName => 'bills';
  
  // Create
  Future<int> insertBill(BillModel bill) async {
    return await insert(bill.toMap());
  }
  
  // Read - Single
  Future<BillModel?> getBillById(int id) async {
    final results = await query(where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return BillModel.fromMap(results.first);
  }
  
  // Read - All
  Future<List<BillModel>> getAllBills() async {
    final results = await query(orderBy: 'due_date ASC');
    return results.map((map) => BillModel.fromMap(map)).toList();
  }
  
  // Read - By Status
  Future<List<BillModel>> getBillsByStatus(String status) async {
    final results = await query(
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }
  
  // Read - Due within days
  Future<List<BillModel>> getBillsDueWithinDays(int days) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    final results = await query(
      where: 'due_date <= ? AND status = ?',
      whereArgs: [futureDate.toIso8601String().split('T')[0], 'Pending'],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }
  
  // Read - Overdue
  Future<List<BillModel>> getOverdueBills() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final results = await query(
      where: 'due_date < ? AND status = ?',
      whereArgs: [today, 'Pending'],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }
  
  // Read - Needs attention (due within 7 days or overdue, pending)
  Future<List<BillModel>> getBillsNeedingAttention() async {
    final futureDate = DateTime.now().add(const Duration(days: 7));
    
    final results = await query(
      where: 'due_date <= ? AND status = ?',
      whereArgs: [futureDate.toIso8601String().split('T')[0], 'Pending'],
      orderBy: 'due_date ASC',
    );
    return results.map((map) => BillModel.fromMap(map)).toList();
  }
  
  // Update
  Future<int> updateBill(BillModel bill) async {
    final data = bill.toMap();
    data['updated_at'] = DateTime.now().toIso8601String();
    return await update(data, 'id = ?', [bill.id]);
  }
  
  // Update status
  Future<int> updateBillStatus(int id, String status, {String? referenceId}) async {
    final data = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (referenceId != null) {
      data['reference_id'] = referenceId;
    }
    return await update(data, 'id = ?', [id]);
  }
  
  // Delete
  Future<int> deleteBill(int id) async {
    return await delete('id = ?', [id]);
  }
  
  // Count
  Future<int> getBillCount() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  // Sum of pending bills
  Future<double> getTotalPendingAmount() async {
    final database = await db;
    final result = await database.rawQuery(
      "SELECT SUM(amount) as total FROM $tableName WHERE status = 'Pending'"
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
```

### 3.3 Payment DAO

```dart
// lib/data/database/dao/payment_dao.dart

import 'base_dao.dart';
import '../../models/payment_model.dart';

class PaymentDao extends BaseDao {
  @override
  String get tableName => 'payments';
  
  // Create
  Future<int> insertPayment(PaymentModel payment) async {
    return await insert(payment.toMap());
  }
  
  // Read - By bill ID
  Future<PaymentModel?> getPaymentByBillId(int billId) async {
    final results = await query(where: 'bill_id = ?', whereArgs: [billId]);
    if (results.isEmpty) return null;
    return PaymentModel.fromMap(results.first);
  }
  
  // Read - By reference ID
  Future<PaymentModel?> getPaymentByReferenceId(String referenceId) async {
    final results = await query(where: 'reference_id = ?', whereArgs: [referenceId]);
    if (results.isEmpty) return null;
    return PaymentModel.fromMap(results.first);
  }
  
  // Read - All scheduled
  Future<List<PaymentModel>> getScheduledPayments() async {
    final results = await query(
      where: 'status = ?',
      whereArgs: ['Scheduled'],
      orderBy: 'scheduled_date ASC',
    );
    return results.map((map) => PaymentModel.fromMap(map)).toList();
  }
  
  // Read - All queued (maintenance mode)
  Future<List<PaymentModel>> getQueuedPayments() async {
    final results = await query(
      where: 'status = ?',
      whereArgs: ['Queued'],
      orderBy: 'created_at ASC',
    );
    return results.map((map) => PaymentModel.fromMap(map)).toList();
  }
  
  // Read - Payments on specific date
  Future<List<PaymentModel>> getPaymentsOnDate(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    final results = await query(
      where: 'scheduled_date = ?',
      whereArgs: [dateString],
    );
    return results.map((map) => PaymentModel.fromMap(map)).toList();
  }
  
  // Read - Total amount scheduled for date
  Future<double> getTotalScheduledForDate(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    final database = await db;
    final result = await database.rawQuery(
      "SELECT SUM(amount) as total FROM $tableName WHERE scheduled_date = ? AND status IN ('Scheduled', 'Queued')",
      [dateString],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
  
  // Update status
  Future<int> updatePaymentStatus(int id, String status) async {
    return await update({'status': status}, 'id = ?', [id]);
  }
  
  // Delete
  Future<int> deletePayment(int id) async {
    return await delete('id = ?', [id]);
  }
  
  // Delete by bill ID
  Future<int> deletePaymentByBillId(int billId) async {
    return await delete('bill_id = ?', [billId]);
  }
}
```

### 3.4 Audit Log DAO

```dart
// lib/data/database/dao/audit_log_dao.dart

import 'dart:convert';
import 'base_dao.dart';
import '../../models/audit_log_model.dart';

class AuditLogDao extends BaseDao {
  @override
  String get tableName => 'audit_logs';
  
  // Create
  Future<int> insertLog(AuditLogModel log) async {
    return await insert(log.toMap());
  }
  
  // Convenience method for quick logging
  Future<int> log({
    required String actionType,
    String? referenceId,
    Map<String, dynamic>? details,
    String? userNote,
  }) async {
    return await insert({
      'action_type': actionType,
      'reference_id': referenceId,
      'details': details != null ? jsonEncode(details) : null,
      'user_note': userNote,
    });
  }
  
  // Read - All logs (paginated)
  Future<List<AuditLogModel>> getAllLogs({int limit = 50, int offset = 0}) async {
    final results = await query(
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    return results.map((map) => AuditLogModel.fromMap(map)).toList();
  }
  
  // Read - By action type
  Future<List<AuditLogModel>> getLogsByActionType(String actionType, {int limit = 50}) async {
    final results = await query(
      where: 'action_type = ?',
      whereArgs: [actionType],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return results.map((map) => AuditLogModel.fromMap(map)).toList();
  }
  
  // Read - By reference ID (bill/payment specific logs)
  Future<List<AuditLogModel>> getLogsByReferenceId(String referenceId) async {
    final results = await query(
      where: 'reference_id = ?',
      whereArgs: [referenceId],
      orderBy: 'timestamp DESC',
    );
    return results.map((map) => AuditLogModel.fromMap(map)).toList();
  }
  
  // Read - Recent logs (last 24 hours)
  Future<List<AuditLogModel>> getRecentLogs() async {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    final results = await query(
      where: 'timestamp >= ?',
      whereArgs: [yesterday.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return results.map((map) => AuditLogModel.fromMap(map)).toList();
  }
  
  // Clear all logs (for reset)
  Future<int> clearAllLogs() async {
    final database = await db;
    return await database.delete(tableName);
  }
  
  // Get log count
  Future<int> getLogCount() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return result.first['count'] as int? ?? 0;
  }
}
```

### 3.5 Cashflow DAO

```dart
// lib/data/database/dao/cashflow_dao.dart

import 'base_dao.dart';
import '../../models/cashflow_input_model.dart';

class CashflowDao extends BaseDao {
  @override
  String get tableName => 'cashflow_inputs';
  
  // Read (always returns single row)
  Future<CashflowInputModel> getCashflowInputs() async {
    final results = await query(where: 'id = ?', whereArgs: [1]);
    if (results.isEmpty) {
      throw Exception('Cashflow inputs not initialized');
    }
    return CashflowInputModel.fromMap(results.first);
  }
  
  // Update
  Future<int> updateCashflowInputs(CashflowInputModel inputs) async {
    final data = inputs.toMap();
    data['updated_at'] = DateTime.now().toIso8601String();
    return await update(data, 'id = ?', [1]);
  }
  
  // Update balance only
  Future<int> updateBalance(double newBalance) async {
    return await update(
      {
        'current_balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      },
      'id = ?',
      [1],
    );
  }
  
  // Update payday only
  Future<int> updatePayday(DateTime nextPayday) async {
    return await update(
      {
        'next_payday_date': nextPayday.toIso8601String().split('T')[0],
        'updated_at': DateTime.now().toIso8601String(),
      },
      'id = ?',
      [1],
    );
  }
  
  // Update safety buffer only
  Future<int> updateSafetyBuffer(double buffer) async {
    return await update(
      {
        'safety_buffer': buffer,
        'updated_at': DateTime.now().toIso8601String(),
      },
      'id = ?',
      [1],
    );
  }
}
```

### 3.6 Settings DAO

```dart
// lib/data/database/dao/settings_dao.dart

import 'base_dao.dart';
import '../../models/settings_model.dart';

class SettingsDao extends BaseDao {
  @override
  String get tableName => 'settings';
  
  // Read (always returns single row)
  Future<SettingsModel> getSettings() async {
    final results = await query(where: 'id = ?', whereArgs: [1]);
    if (results.isEmpty) {
      throw Exception('Settings not initialized');
    }
    return SettingsModel.fromMap(results.first);
  }
  
  // Update all settings
  Future<int> updateSettings(SettingsModel settings) async {
    return await update(settings.toMap(), 'id = ?', [1]);
  }
  
  // Toggle maintenance mode
  Future<int> setMaintenanceMode(bool enabled) async {
    return await update({'maintenance_mode': enabled ? 1 : 0}, 'id = ?', [1]);
  }
  
  // Toggle demo mode
  Future<int> setDemoMode(bool enabled) async {
    return await update({'demo_mode': enabled ? 1 : 0}, 'id = ?', [1]);
  }
  
  // Update daily cap
  Future<int> setDailyPaymentCap(double cap) async {
    return await update({'daily_payment_cap': cap}, 'id = ?', [1]);
  }
  
  // Toggle notifications
  Future<int> setNotificationsEnabled(bool enabled) async {
    return await update({'notification_enabled': enabled ? 1 : 0}, 'id = ?', [1]);
  }
  
  // Check if maintenance mode is active
  Future<bool> isMaintenanceMode() async {
    final settings = await getSettings();
    return settings.maintenanceMode;
  }
  
  // Check if demo mode is active
  Future<bool> isDemoMode() async {
    final settings = await getSettings();
    return settings.demoMode;
  }
}
```

### 3.7 Bill History DAO

```dart
// lib/data/database/dao/bill_history_dao.dart

import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';
import '../../models/bill_history_model.dart';

class BillHistoryDao extends BaseDao {
  @override
  String get tableName => 'bill_history';
  
  // Create
  Future<int> insertHistory(BillHistoryModel history) async {
    return await insert(history.toMap());
  }
  
  // Read - By payee name
  Future<List<BillHistoryModel>> getHistoryByPayee(String payeeName) async {
    final results = await query(
      where: 'payee_name = ?',
      whereArgs: [payeeName],
      orderBy: 'payment_date DESC',
      limit: 10,
    );
    return results.map((map) => BillHistoryModel.fromMap(map)).toList();
  }
  
  // Read - Average amount for payee
  Future<double?> getAverageAmountForPayee(String payeeName) async {
    final database = await db;
    final result = await database.rawQuery(
      'SELECT AVG(amount) as avg_amount FROM $tableName WHERE payee_name = ?',
      [payeeName],
    );
    return (result.first['avg_amount'] as num?)?.toDouble();
  }
  
  // Read - Last 3 amounts for payee
  Future<List<double>> getLastThreeAmounts(String payeeName) async {
    final results = await query(
      where: 'payee_name = ?',
      whereArgs: [payeeName],
      orderBy: 'payment_date DESC',
      limit: 3,
    );
    return results.map((map) => (map['amount'] as num).toDouble()).toList();
  }
  
  // Check for anomaly (deviation > 30%)
  Future<Map<String, dynamic>?> checkForAnomaly(String payeeName, double currentAmount) async {
    final avgAmount = await getAverageAmountForPayee(payeeName);
    
    if (avgAmount == null || avgAmount == 0) {
      return null; // No history, no anomaly
    }
    
    final deviation = ((currentAmount - avgAmount) / avgAmount).abs();
    
    if (deviation > 0.30) {
      return {
        'isAnomaly': true,
        'averageAmount': avgAmount,
        'deviationPercent': (deviation * 100).round(),
        'isHigher': currentAmount > avgAmount,
      };
    }
    
    return null; // No anomaly
  }
  
  // Clear history for payee
  Future<int> clearHistoryForPayee(String payeeName) async {
    return await delete('payee_name = ?', [payeeName]);
  }
}
```

---

## 4. Repository Layer

### 4.1 Repository Interfaces (Domain Layer)

```dart
// lib/domain/repositories/bill_repository.dart

import '../entities/bill.dart';

abstract class BillRepository {
  Future<List<Bill>> getAllBills();
  Future<List<Bill>> getBillsByStatus(String status);
  Future<List<Bill>> getBillsDueWithinDays(int days);
  Future<List<Bill>> getBillsNeedingAttention();
  Future<List<Bill>> getOverdueBills();
  Future<Bill?> getBillById(int id);
  Future<int> createBill(Bill bill);
  Future<int> updateBill(Bill bill);
  Future<int> updateBillStatus(int id, String status, {String? referenceId});
  Future<int> deleteBill(int id);
  Future<int> getBillCount();
  Future<double> getTotalPendingAmount();
}
```

```dart
// lib/domain/repositories/payment_repository.dart

import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Payment?> getPaymentByBillId(int billId);
  Future<Payment?> getPaymentByReferenceId(String referenceId);
  Future<List<Payment>> getScheduledPayments();
  Future<List<Payment>> getQueuedPayments();
  Future<double> getTotalScheduledForDate(DateTime date);
  Future<int> createPayment(Payment payment);
  Future<int> updatePaymentStatus(int id, String status);
  Future<int> deletePayment(int id);
  Future<int> deletePaymentByBillId(int billId);
}
```

```dart
// lib/domain/repositories/cashflow_repository.dart

import '../entities/cashflow_input.dart';

abstract class CashflowRepository {
  Future<CashflowInput> getCashflowInputs();
  Future<int> updateCashflowInputs(CashflowInput inputs);
  Future<int> updateBalance(double newBalance);
  Future<int> updatePayday(DateTime nextPayday);
  Future<int> updateSafetyBuffer(double buffer);
}
```

```dart
// lib/domain/repositories/settings_repository.dart

import '../entities/settings.dart';

abstract class SettingsRepository {
  Future<Settings> getSettings();
  Future<int> updateSettings(Settings settings);
  Future<int> setMaintenanceMode(bool enabled);
  Future<int> setDemoMode(bool enabled);
  Future<int> setDailyPaymentCap(double cap);
  Future<bool> isMaintenanceMode();
  Future<bool> isDemoMode();
}
```

```dart
// lib/domain/repositories/audit_repository.dart

import '../entities/audit_log.dart';

abstract class AuditRepository {
  Future<List<AuditLog>> getAllLogs({int limit = 50, int offset = 0});
  Future<List<AuditLog>> getLogsByActionType(String actionType, {int limit = 50});
  Future<List<AuditLog>> getLogsByReferenceId(String referenceId);
  Future<int> log({
    required String actionType,
    String? referenceId,
    Map<String, dynamic>? details,
    String? userNote,
  });
  Future<int> clearAllLogs();
}
```

### 4.2 Repository Implementations (Data Layer)

```dart
// lib/data/repositories/bill_repository_impl.dart

import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../database/dao/bill_dao.dart';
import '../models/bill_model.dart';

class BillRepositoryImpl implements BillRepository {
  final BillDao _billDao;
  
  BillRepositoryImpl(this._billDao);
  
  @override
  Future<List<Bill>> getAllBills() async {
    final models = await _billDao.getAllBills();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<Bill>> getBillsByStatus(String status) async {
    final models = await _billDao.getBillsByStatus(status);
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<Bill>> getBillsDueWithinDays(int days) async {
    final models = await _billDao.getBillsDueWithinDays(days);
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<Bill>> getBillsNeedingAttention() async {
    final models = await _billDao.getBillsNeedingAttention();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<Bill>> getOverdueBills() async {
    final models = await _billDao.getOverdueBills();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<Bill?> getBillById(int id) async {
    final model = await _billDao.getBillById(id);
    return model?.toEntity();
  }
  
  @override
  Future<int> createBill(Bill bill) async {
    final model = BillModel.fromEntity(bill);
    return await _billDao.insertBill(model);
  }
  
  @override
  Future<int> updateBill(Bill bill) async {
    final model = BillModel.fromEntity(bill);
    return await _billDao.updateBill(model);
  }
  
  @override
  Future<int> updateBillStatus(int id, String status, {String? referenceId}) async {
    return await _billDao.updateBillStatus(id, status, referenceId: referenceId);
  }
  
  @override
  Future<int> deleteBill(int id) async {
    return await _billDao.deleteBill(id);
  }
  
  @override
  Future<int> getBillCount() async {
    return await _billDao.getBillCount();
  }
  
  @override
  Future<double> getTotalPendingAmount() async {
    return await _billDao.getTotalPendingAmount();
  }
}
```

---

## 5. Service Layer

### 5.1 Recommendation Service

Business logic for generating payment recommendations.

```dart
// lib/data/services/recommendation_service.dart

import '../../domain/entities/bill.dart';
import '../../domain/entities/cashflow_input.dart';
import '../../domain/entities/recommendation.dart';
import '../database/dao/bill_history_dao.dart';
import 'ai_service.dart';

class RecommendationService {
  final BillHistoryDao _historyDao;
  final AIService _aiService;
  
  RecommendationService(this._historyDao, this._aiService);
  
  /// Generate recommendation for a bill
  Future<Recommendation> getRecommendation({
    required Bill bill,
    required CashflowInput cashflow,
    List<Map<String, dynamic>>? upcomingPayments,
  }) async {
    // Rule-based decision logic
    final recommendationType = _calculateRecommendation(
      bill: bill,
      cashflow: cashflow,
      upcomingPayments: upcomingPayments,
    );
    
    // Get AI-generated rationale
    String rationale;
    try {
      rationale = await _aiService.generateRationale(
        payee: bill.payeeName,
        amount: bill.amount,
        dueDate: bill.dueDate.toIso8601String().split('T')[0],
        currentBalance: cashflow.currentBalance,
        nextPayday: cashflow.nextPaydayDate.toIso8601String().split('T')[0],
        safetyBuffer: cashflow.safetyBuffer,
        recommendation: recommendationType.name,
        upcomingPayments: upcomingPayments,
      );
    } catch (e) {
      rationale = _getFallbackRationale(recommendationType);
    }
    
    return Recommendation(
      type: recommendationType,
      rationale: rationale,
      suggestedDate: _getSuggestedDate(recommendationType, bill, cashflow),
      confidence: _calculateConfidence(bill, cashflow),
    );
  }
  
  RecommendationType _calculateRecommendation({
    required Bill bill,
    required CashflowInput cashflow,
    List<Map<String, dynamic>>? upcomingPayments,
  }) {
    final daysUntilDue = bill.dueDate.difference(DateTime.now()).inDays;
    final balanceAfterPayment = cashflow.currentBalance - bill.amount;
    final remainingBuffer = balanceAfterPayment - cashflow.safetyBuffer;
    
    // Rule 1: If due in less than 3 days, suggest remind later (too close)
    if (daysUntilDue < 3) {
      return RecommendationType.remindLater;
    }
    
    // Rule 2: Check if paying now is safe
    final hasUpcomingBeforeDue = upcomingPayments?.any((p) {
      final paymentDate = DateTime.parse(p['date'] as String);
      return paymentDate.isBefore(bill.dueDate) && 
             paymentDate.isAfter(DateTime.now());
    }) ?? false;
    
    if (remainingBuffer >= 500 && !hasUpcomingBeforeDue) {
      return RecommendationType.payNow;
    }
    
    // Rule 3: Check if scheduling for payday is possible
    final paydayBeforeDue = cashflow.nextPaydayDate.isBefore(bill.dueDate) ||
                            cashflow.nextPaydayDate.isAtSameMomentAs(bill.dueDate);
    
    if (paydayBeforeDue) {
      return RecommendationType.schedulePayday;
    }
    
    // Rule 4: If payday is after due date, need to pay now despite risk
    if (remainingBuffer >= 0) {
      return RecommendationType.payNow;
    }
    
    // Fallback
    return RecommendationType.remindLater;
  }
  
  DateTime? _getSuggestedDate(
    RecommendationType type,
    Bill bill,
    CashflowInput cashflow,
  ) {
    switch (type) {
      case RecommendationType.payNow:
        return DateTime.now();
      case RecommendationType.schedulePayday:
        return cashflow.nextPaydayDate;
      case RecommendationType.remindLater:
        return DateTime.now().add(const Duration(days: 2));
    }
  }
  
  double _calculateConfidence(Bill bill, CashflowInput cashflow) {
    // Simple confidence calculation based on data completeness
    double confidence = 0.5;
    
    if (cashflow.currentBalance > 0) confidence += 0.2;
    if (cashflow.safetyBuffer > 0) confidence += 0.15;
    if (bill.amount > 0) confidence += 0.15;
    
    return confidence.clamp(0.0, 1.0);
  }
  
  String _getFallbackRationale(RecommendationType type) {
    switch (type) {
      case RecommendationType.payNow:
        return 'Paying now is safe! Your balance comfortably covers this bill while maintaining your safety buffer.';
      case RecommendationType.schedulePayday:
        return 'Waiting until payday is smarter here. Paying now would leave you with less cushion for upcoming obligations.';
      case RecommendationType.remindLater:
        return 'This bill is due soon, but we need more information to give you the best recommendation. Please review manually.';
    }
  }
}

enum RecommendationType {
  payNow,
  schedulePayday,
  remindLater,
}
```

### 5.2 Safety Check Service

```dart
// lib/data/services/safety_check_service.dart

import '../../domain/entities/bill.dart';
import '../../domain/entities/cashflow_input.dart';
import '../../domain/entities/settings.dart';
import '../database/dao/bill_history_dao.dart';
import '../database/dao/payment_dao.dart';

class SafetyCheckResult {
  final bool hasInsufficientFunds;
  final bool hasAnomaly;
  final bool exceedsDailyCap;
  final String? insufficientFundsMessage;
  final String? anomalyMessage;
  final String? dailyCapMessage;
  final double? remainingBalance;
  final double? averageAmount;
  final int? de