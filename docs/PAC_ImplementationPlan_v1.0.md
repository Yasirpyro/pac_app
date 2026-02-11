# Implementation Plan: Payment Assurance Copilot (PAC)

**Version:** 1.0  
**Last Updated:** February 10, 2026  
**Purpose:** Step-by-step build sequence with testable milestones  
**Hackathon Duration:** 4 Days (Feb 10-13, 2026)  
**Audience:** Development Team, Technical Reviewers

---

## Table of Contents

1. [Implementation Overview](#1-implementation-overview)
2. [Day 1: Foundation & Core Setup](#2-day-1-foundation--core-setup)
3. [Day 2: AI Integration & Recommendations](#3-day-2-ai-integration--recommendations)
4. [Day 3: Payment Flow & Maintenance Mode](#4-day-3-payment-flow--maintenance-mode)
5. [Day 4: Polish & Demo Prep](#5-day-4-polish--demo-prep)
6. [Dependency Graph](#6-dependency-graph)
7. [Risk Mitigation](#7-risk-mitigation)
8. [Rollback Points](#8-rollback-points)

---

## 1. Implementation Overview

### 1.1 Build Philosophy

| Principle | Application |
|-----------|-------------|
| **Vertical Slices** | Build complete features end-to-end before moving on |
| **Demo-First** | Every step should produce something demonstrable |
| **Test Early** | Verify each step before proceeding |
| **Fallback Ready** | Each feature has a simpler fallback if time runs short |

### 1.2 High-Level Timeline

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         4-DAY BUILD TIMELINE                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  DAY 1 (Mon)          DAY 2 (Tue)          DAY 3 (Wed)       DAY 4 (Thu)│
│  ───────────          ───────────          ───────────       ───────────│
│  ┌─────────┐          ┌─────────┐          ┌─────────┐       ┌─────────┐│
│  │ Project │          │   AI    │          │ Payment │       │  Demo   ││
│  │  Setup  │          │ Recomm. │          │  Flow   │       │  Prep   ││
│  ├─────────┤          ├─────────┤          ├─────────┤       ├─────────┤│
│  │Database │          │ Safety  │          │  Auth   │       │  Bugs   ││
│  │ Schema  │          │ Checks  │          │  Modal  │       │  Fix    ││
│  ├─────────┤          ├─────────┤          ├─────────┤       ├─────────┤│
│  │  Bill   │          │ Recomm. │          │Maint.   │       │  Video  ││
│  │  CRUD   │          │   UI    │          │  Mode   │       │Recording││
│  ├─────────┤          ├─────────┤          ├─────────┤       ├─────────┤│
│  │  Bill   │          │  Eval   │          │Settings │       │  Pitch  ││
│  │  List   │          │  Test   │          │ Screen  │       │  Deck   ││
│  └─────────┘          └─────────┘          └─────────┘       └─────────┘│
│                                                                         │
│  Checkpoint:          Checkpoint:          Checkpoint:       SUBMIT!    │
│  Bills work           AI suggests          Full flow         ─────────  │
│                       correctly            working                      │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Definition of Done (Per Step)

Each step is complete when:
- [ ] Code compiles without errors
- [ ] Feature works on Android emulator
- [ ] Basic happy path tested manually
- [ ] Code committed to Git with descriptive message
- [ ] No known blocking bugs

### 1.4 Time Blocks

Each day is divided into focused work blocks:

| Block | Time | Focus |
|-------|------|-------|
| Morning 1 | 9:00 - 11:00 | Primary development |
| Morning 2 | 11:00 - 13:00 | Primary development |
| Lunch | 13:00 - 14:00 | Break + sync |
| Afternoon 1 | 14:00 - 16:00 | Secondary development |
| Afternoon 2 | 16:00 - 18:00 | Testing + bug fixes |
| Evening | 18:00 - 20:00 | Polish + checkpoint |

---

## 2. Day 1: Foundation & Core Setup

**Goal:** Working bill management (create, view, edit, delete bills)

**Success Criteria:**
- [ ] Flutter project runs on Android emulator
- [ ] SQLite database initialized with schema
- [ ] Can add a new bill via form
- [ ] Can view list of bills
- [ ] Can tap bill to see details
- [ ] Demo data seeds automatically

---

### Phase 1.1: Project Initialization (9:00 - 10:00)

**Duration:** 1 hour  
**Owner:** Developer  
**Dependencies:** None

#### Step 1.1.1: Create Flutter Project (15 min)

```bash
# Create project
flutter create pac_app --org com.procom26

# Navigate to project
cd pac_app

# Open in VS Code
code .
```

**Verification:**
```bash
flutter run
# Expected: Default Flutter counter app runs on emulator
```

#### Step 1.1.2: Configure pubspec.yaml (15 min)

Replace `pubspec.yaml` with dependencies from Tech Stack document.

```yaml
name: pac_app
description: Payment Assurance Copilot - PROCOM '26 Hackathon
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.10.0 <4.0.0'
  flutter: '>=3.38.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.4
  go_router: ^17.1.0
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.0
  shared_preferences: ^2.5.4
  http: ^1.6.0
  intl: ^0.20.2
  uuid: ^4.5.2
  local_auth: ^3.0.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

**Verification:**
```bash
flutter pub get
# Expected: All dependencies resolve successfully
```

#### Step 1.1.3: Create Folder Structure (15 min)

Create the directory structure:

```bash
mkdir -p lib/{core/{constants,errors,utils},data/{database/{dao,migrations},models,repositories,services},domain/{entities,repositories,usecases},presentation/{providers,screens/{home,bills,payment,maintenance,settings,auth},widgets},theme,router}
```

Create placeholder files:
- `lib/core/constants/app_constants.dart`
- `lib/core/constants/database_constants.dart`
- `lib/theme/app_colors.dart`
- `lib/theme/app_spacing.dart`
- `lib/theme/app_theme.dart`

**Verification:**
- Directory structure matches Backend Structure document
- No import errors when opening project

#### Step 1.1.4: Configure Android Settings (15 min)

Update `android/app/build.gradle`:
```groovy
android {
    namespace "com.procom26.pac_app"
    compileSdk 35

    defaultConfig {
        applicationId "com.procom26.pac_app"
        minSdk 24
        targetSdk 35
        versionCode 1
        versionName "1.0.0"
    }
    // ... rest of config
}
```

Update `android/app/src/main/kotlin/.../MainActivity.kt`:
```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity()
```

**Verification:**
```bash
flutter clean
flutter run
# Expected: App runs without Gradle errors
```

**✅ Step 1.1 Checkpoint:** Project compiles and runs on emulator

---

### Phase 1.2: Theme & Design System (10:00 - 11:00)

**Duration:** 1 hour  
**Owner:** Developer  
**Dependencies:** Step 1.1 complete

#### Step 1.2.1: Implement Color System (20 min)

Create `lib/theme/app_colors.dart` with all colors from Frontend Guidelines.

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Semantic colors
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1E88E5);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color scheduled = Color(0xFF5C6BC0);
  static const Color scheduledLight = Color(0xFFE8EAF6);
  
  // Surfaces
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE7E9EC);
  
  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Borders
  static const Color outline = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Maintenance
  static const Color maintenance = Color(0xFFFF9800);
  static const Color maintenanceLight = Color(0xFFFFF8E1);
}
```

**Verification:** File compiles without errors

#### Step 1.2.2: Implement Spacing System (15 min)

Create `lib/theme/app_spacing.dart`:

```dart
import 'package:flutter/material.dart';

class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  
  static const SizedBox verticalXS = SizedBox(height: xs);
  static const SizedBox verticalSM = SizedBox(height: sm);
  static const SizedBox verticalMD = SizedBox(height: md);
  static const SizedBox verticalLG = SizedBox(height: lg);
  
  static const SizedBox horizontalXS = SizedBox(width: xs);
  static const SizedBox horizontalSM = SizedBox(width: sm);
  static const SizedBox horizontalMD = SizedBox(width: md);
}
```

#### Step 1.2.3: Implement App Theme (25 min)

Create `lib/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.info,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.outline,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}
```

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Assurance Copilot',
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(child: Text('PAC')),
      ),
    );
  }
}
```

**Verification:**
```bash
flutter run
# Expected: App shows "PAC" text with blue theme
```

**✅ Step 1.2 Checkpoint:** Theme system working, app styled correctly

---

### Phase 1.3: Database Setup (11:00 - 13:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Step 1.2 complete

#### Step 1.3.1: Create Data Models (30 min)

Create `lib/data/models/bill_model.dart`:

```dart
class BillModel {
  final int? id;
  final String payeeName;
  final double amount;
  final DateTime dueDate;
  final String category;
  final String status;
  final String? referenceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BillModel({
    this.id,
    required this.payeeName,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.status = 'Pending',
    this.referenceId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'payee_name': payeeName,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'category': category,
      'status': status,
      'reference_id': referenceId,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      payeeName: map['payee_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      category: map['category'] as String,
      status: map['status'] as String? ?? 'Pending',
      referenceId: map['reference_id'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
    );
  }
}
```

Create similar models for:
- `lib/data/models/cashflow_input_model.dart`
- `lib/data/models/settings_model.dart`
- `lib/data/models/audit_log_model.dart`

#### Step 1.3.2: Implement Database Helper (45 min)

Create `lib/data/database/database_helper.dart` with full schema from Backend Structure document.

**Key sections:**
- Singleton pattern
- onCreate with all 6 tables
- Index creation
- Default data seeding
- Demo bill seeding

#### Step 1.3.3: Implement Bill DAO (30 min)

Create `lib/data/database/dao/bill_dao.dart` with all CRUD operations from Backend Structure document.

#### Step 1.3.4: Test Database (15 min)

Add temporary test in main.dart:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test database
  final db = await DatabaseHelper.instance.database;
  final bills = await db.query('bills');
  print('Bills in database: ${bills.length}');
  
  runApp(const MyApp());
}
```

**Verification:**
```bash
flutter run
# Expected: Console shows "Bills in database: 5" (seeded demo data)
```

**✅ Step 1.3 Checkpoint:** Database initializes, demo data exists

---

### Phase 1.4: Bill List Screen (14:00 - 16:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Step 1.3 complete

#### Step 1.4.1: Create Bill Entity (15 min)

Create `lib/domain/entities/bill.dart`:

```dart
class Bill {
  final int? id;
  final String payeeName;
  final double amount;
  final DateTime dueDate;
  final String category;
  final String status;
  final String? referenceId;

  Bill({
    this.id,
    required this.payeeName,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.status = 'Pending',
    this.referenceId,
  });

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  bool get isOverdue => daysUntilDue < 0 && status == 'Pending';
  bool get isDueSoon => daysUntilDue <= 7 && daysUntilDue >= 0;
}
```

#### Step 1.4.2: Create Bills Provider (30 min)

Create `lib/presentation/providers/bills_provider.dart`:

```dart
import 'package:flutter/material.dart';
import '../../data/database/dao/bill_dao.dart';
import '../../domain/entities/bill.dart';

class BillsProvider extends ChangeNotifier {
  final BillDao _billDao = BillDao();
  
  List<Bill> _bills = [];
  bool _isLoading = false;
  String? _error;
  
  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Bill> get pendingBills => 
      _bills.where((b) => b.status == 'Pending').toList();
  
  List<Bill> get billsNeedingAttention =>
      _bills.where((b) => b.status == 'Pending' && b.daysUntilDue <= 7).toList();

  Future<void> loadBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final models = await _billDao.getAllBills();
      _bills = models.map((m) => Bill(
        id: m.id,
        payeeName: m.payeeName,
        amount: m.amount,
        dueDate: m.dueDate,
        category: m.category,
        status: m.status,
        referenceId: m.referenceId,
      )).toList();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
```

#### Step 1.4.3: Create Status Badge Widget (20 min)

Create `lib/presentation/widgets/status_badge.dart` from Frontend Guidelines.

#### Step 1.4.4: Create Bill Card Widget (30 min)

Create `lib/presentation/widgets/bill_card.dart` from Frontend Guidelines.

#### Step 1.4.5: Create Bill List Screen (25 min)

Create `lib/presentation/screens/bills/bill_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bills_provider.dart';
import '../../widgets/bill_card.dart';
import '../../../theme/app_colors.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BillsProvider>().loadBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bills'),
      ),
      body: Consumer<BillsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.bills.isEmpty) {
            return const Center(child: Text('No bills yet'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.bills.length,
            itemBuilder: (context, index) {
              final bill = provider.bills[index];
              return BillCard(
                bill: bill,
                onTap: () {
                  // Navigate to detail (implement in 1.5)
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add bill (implement in 1.5)
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Bill'),
      ),
    );
  }
}
```

#### Step 1.4.6: Wire Up Provider (15 min)

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'presentation/providers/bills_provider.dart';
import 'presentation/screens/bills/bill_list_screen.dart';
import 'data/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Initialize DB
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BillsProvider()),
      ],
      child: MaterialApp(
        title: 'Payment Assurance Copilot',
        theme: AppTheme.lightTheme,
        home: const BillListScreen(),
      ),
    );
  }
}
```

**Verification:**
```bash
flutter run
# Expected: Bill list shows 5 demo bills with status badges
```

**✅ Step 1.4 Checkpoint:** Bill list displays correctly with cards and badges

---

### Phase 1.5: Bill CRUD Operations (16:00 - 18:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Step 1.4 complete

#### Step 1.5.1: Create Add Bill Screen (45 min)

Create `lib/presentation/screens/bills/add_bill_screen.dart`:

- Form with payee name, amount, due date, category
- Validation (required fields, amount range)
- Save button that inserts into database
- Navigation back with success toast

**Key widgets needed:**
- `AppTextField` from Frontend Guidelines
- `CurrencyInput` from Frontend Guidelines
- `DatePickerField` from Frontend Guidelines
- `AppDropdown` from Frontend Guidelines

#### Step 1.5.2: Create Bill Detail Screen (30 min)

Create `lib/presentation/screens/bills/bill_detail_screen.dart`:

- Display bill summary (payee, amount, due date, status)
- Days until due indicator
- Edit button in app bar
- "Mark as Paid" button
- Placeholder for AI recommendation (implement Day 2)

#### Step 1.5.3: Create Edit Bill Screen (20 min)

Create `lib/presentation/screens/bills/edit_bill_screen.dart`:

- Same form as Add Bill, pre-populated
- Delete button with confirmation dialog
- Save changes functionality

#### Step 1.5.4: Wire Up Navigation (25 min)

Update screens to navigate between:
- Bill List → Bill Detail (on card tap)
- Bill List → Add Bill (on FAB tap)
- Bill Detail → Edit Bill (on edit icon tap)
- Add/Edit Bill → Bill List (on save/delete)

Add methods to BillsProvider:
- `createBill(Bill bill)`
- `updateBill(Bill bill)`
- `deleteBill(int id)`
- `markAsPaid(int id)`

**Verification:**
- [ ] Can add a new bill and see it in list
- [ ] Can tap a bill and see details
- [ ] Can edit a bill's amount
- [ ] Can delete a bill
- [ ] Can mark a bill as paid

**✅ Step 1.5 Checkpoint:** Full bill CRUD working

---

### Phase 1.6: Day 1 Polish & Checkpoint (18:00 - 20:00)

**Duration:** 2 hours  
**Owner:** Both team members  
**Dependencies:** Step 1.5 complete

#### Step 1.6.1: Navigation Setup with go_router (30 min)

Create `lib/router/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';
// ... screen imports

final GoRouter appRouter = GoRouter(
  initialLocation: '/bills',
  routes: [
    GoRoute(
      path: '/bills',
      builder: (context, state) => const BillListScreen(),
    ),
    GoRoute(
      path: '/bills/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BillDetailScreen(billId: id);
      },
    ),
    GoRoute(
      path: '/add-bill',
      builder: (context, state) => const AddBillScreen(),
    ),
    GoRoute(
      path: '/edit-bill/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return EditBillScreen(billId: id);
      },
    ),
  ],
);
```

#### Step 1.6.2: Create Home Dashboard (30 min)

Create `lib/presentation/screens/home/home_screen.dart`:

- App title
- "Bills Needing Attention" card with count
- Quick stats (balance, payday, buffer) - static for now
- "View All Bills" button
- "Add Bill" button

#### Step 1.6.3: Add Bottom Navigation (30 min)

Create main scaffold with bottom nav:
- Home tab
- Bills tab
- Settings tab (placeholder)

#### Step 1.6.4: Bug Fixes & Testing (30 min)

- Test all flows on emulator
- Fix any UI issues
- Commit all code

**Day 1 Final Verification:**
```
[ ] App launches without errors
[ ] Home screen shows summary
[ ] Bill list displays all bills
[ ] Can add new bill
[ ] Can view bill details
[ ] Can edit bill
[ ] Can delete bill
[ ] Can mark bill as paid
[ ] Navigation works correctly
[ ] Bottom nav switches tabs
```

**✅ DAY 1 COMPLETE:** Bill management feature working end-to-end

---

## 3. Day 2: AI Integration & Recommendations

**Goal:** AI recommendations working with safety checks

**Success Criteria:**
- [ ] AI recommendation appears on bill detail
- [ ] Recommendation explains timing decision
- [ ] Insufficient funds warning shows when applicable
- [ ] Anomaly detection warning shows when applicable
- [ ] Daily cap enforcement works

---

### Phase 2.1: Recommendation Engine Setup (9:00 - 11:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Day 1 complete

#### Step 2.1.1: Create Recommendation Entity (15 min)

Create `lib/domain/entities/recommendation.dart`:

```dart
enum RecommendationType {
  payNow,
  schedulePayday,
  remindLater,
}

class Recommendation {
  final RecommendationType type;
  final String rationale;
  final DateTime? suggestedDate;
  final double confidence;

  Recommendation({
    required this.type,
    required this.rationale,
    this.suggestedDate,
    required this.confidence,
  });

  String get displayText {
    switch (type) {
      case RecommendationType.payNow:
        return 'Pay Now';
      case RecommendationType.schedulePayday:
        return 'Schedule for ${_formatDate(suggestedDate)}';
      case RecommendationType.remindLater:
        return 'Remind Me Later';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'payday';
    return '${date.month}/${date.day}';
  }
}
```

#### Step 2.1.2: Create Cashflow Provider (20 min)

Create `lib/presentation/providers/cashflow_provider.dart`:

```dart
import 'package:flutter/material.dart';
import '../../data/database/dao/cashflow_dao.dart';

class CashflowProvider extends ChangeNotifier {
  final CashflowDao _dao = CashflowDao();
  
  double _currentBalance = 0;
  DateTime _nextPayday = DateTime.now();
  double _safetyBuffer = 500;
  
  double get currentBalance => _currentBalance;
  DateTime get nextPayday => _nextPayday;
  double get safetyBuffer => _safetyBuffer;

  Future<void> loadCashflow() async {
    final inputs = await _dao.getCashflowInputs();
    _currentBalance = inputs.currentBalance;
    _nextPayday = inputs.nextPaydayDate;
    _safetyBuffer = inputs.safetyBuffer;
    notifyListeners();
  }

  Future<void> updateBalance(double balance) async {
    await _dao.updateBalance(balance);
    _currentBalance = balance;
    notifyListeners();
  }
}
```

#### Step 2.1.3: Implement Rule-Based Recommendation Logic (45 min)

Create `lib/data/services/recommendation_service.dart`:

Implement the logic from Backend Structure document:
- Rule 1: Pay Now (if safe)
- Rule 2: Schedule for Payday (if low buffer)
- Rule 3: Remind Later (fallback)

Include confidence calculation.

#### Step 2.1.4: Create Cached Rationale Responses (20 min)

Create `lib/data/services/cached_responses.dart`:

```dart
class CachedResponses {
  static const Map<String, String> rationales = {
    'payNow_healthy': 'Paying now is safe! Your balance comfortably covers this bill while maintaining your safety buffer for other expenses.',
    'payNow_tight': 'You can pay now, but your balance will be lower than usual. Make sure no other payments are pending.',
    'schedulePayday_lowBuffer': 'Waiting until payday is smarter here. Paying now would leave you with less cushion for upcoming obligations.',
    'schedulePayday_upcoming': 'Your rent is due before this bill. Scheduling for payday ensures you have enough for both.',
    'remindLater_tooClose': 'This bill is due very soon. Please review your balance and decide manually.',
    'remindLater_noData': 'We need more information to give you the best recommendation. Please check your cashflow settings.',
  };

  static String getRationale(String key) {
    return rationales[key] ?? rationales['remindLater_noData']!;
  }
}
```

#### Step 2.1.5: Unit Test Recommendation Logic (20 min)

Create `test/services/recommendation_service_test.dart`:

```dart
void main() {
  group('RecommendationService', () {
    test('recommends payNow when buffer is healthy', () {
      // Test case
    });
    
    test('recommends schedulePayday when buffer is low', () {
      // Test case
    });
    
    test('recommends remindLater when due in less than 3 days', () {
      // Test case
    });
  });
}
```

**Verification:**
```bash
flutter test test/services/recommendation_service_test.dart
# Expected: All tests pass
```

**✅ Step 2.1 Checkpoint:** Recommendation logic works correctly

---

### Phase 2.2: AI API Integration (11:00 - 13:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Step 2.1 complete

#### Step 2.2.1: Create AI Service (45 min)

Create `lib/data/services/ai_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5';
  static const int _timeoutSeconds = 3;
  
  final String? apiKey;
  final bool demoMode;
  
  AIService({this.apiKey, this.demoMode = true});

  Future<String> generateRationale({
    required String payee,
    required double amount,
    required String dueDate,
    required double currentBalance,
    required String nextPayday,
    required double safetyBuffer,
    required String recommendation,
  }) async {
    // If demo mode or no API key, use cached response
    if (demoMode || apiKey == null || apiKey!.isEmpty) {
      return _getCachedRationale(recommendation, currentBalance, amount, safetyBuffer);
    }
    
    try {
      final prompt = _buildPrompt(
        payee: payee,
        amount: amount,
        dueDate: dueDate,
        currentBalance: currentBalance,
        nextPayday: nextPayday,
        safetyBuffer: safetyBuffer,
        recommendation: recommendation,
      );
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey!,
          'anthropic-version': '2024-01-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 100,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      ).timeout(Duration(seconds: _timeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'];
      }
    } catch (e) {
      // Fall back to cached response on error
    }
    
    return _getCachedRationale(recommendation, currentBalance, amount, safetyBuffer);
  }

  String _buildPrompt({...}) {
    return '''
You are a helpful financial assistant. Generate a brief explanation (max 50 words) for this payment recommendation.

Bill: $payee \$$amount due $dueDate
Balance: \$$currentBalance
Next payday: $nextPayday
Safety buffer: \$$safetyBuffer

Recommendation: $recommendation

Explain why this timing is best. Be friendly and specific.
''';
  }

  String _getCachedRationale(String recommendation, double balance, double amount, double buffer) {
    final remaining = balance - amount - buffer;
    
    if (recommendation.contains('payNow')) {
      if (remaining > 500) {
        return 'Paying now is safe! Your balance comfortably covers this bill while maintaining your \$${buffer.toInt()} safety buffer.';
      } else {
        return 'You can pay now, but your buffer will be tight. Consider if any other payments are pending.';
      }
    } else if (recommendation.contains('schedule')) {
      return 'Waiting until payday is smarter here. Paying now would reduce your buffer below \$${buffer.toInt()}.';
    } else {
      return 'This bill needs your attention soon. Please review your finances and decide.';
    }
  }
}
```

#### Step 2.2.2: Create Settings DAO & Provider (30 min)

Implement settings to check demo_mode flag.

Create `lib/presentation/providers/settings_provider.dart`.

#### Step 2.2.3: Test API Integration (20 min)

Test with demo mode (no API key):
```dart
final aiService = AIService(demoMode: true);
final rationale = await aiService.generateRationale(...);
print(rationale); // Should return cached response
```

#### Step 2.2.4: Handle API Errors Gracefully (25 min)

Ensure all API failures fall back to cached responses:
- Network timeout (3 seconds)
- API errors (4xx, 5xx)
- JSON parse errors
- Empty responses

**Verification:**
- [ ] Demo mode returns cached responses instantly
- [ ] Timeout after 3 seconds falls back to cache
- [ ] Error responses fall back to cache

**✅ Step 2.2 Checkpoint:** AI service works with fallback

---

### Phase 2.3: Safety Checks (14:00 - 16:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Step 2.2 complete

#### Step 2.3.1: Create Safety Check Service (45 min)

Create `lib/data/services/safety_check_service.dart`:

```dart
class SafetyCheckResult {
  final bool hasWarnings;
  final bool hasInsufficientFunds;
  final bool hasAnomaly;
  final bool exceedsDailyCap;
  final String? insufficientFundsMessage;
  final String? anomalyMessage;
  final String? dailyCapMessage;

  SafetyCheckResult({
    required this.hasInsufficientFunds,
    required this.hasAnomaly,
    required this.exceedsDailyCap,
    this.insufficientFundsMessage,
    this.anomalyMessage,
    this.dailyCapMessage,
  }) : hasWarnings = hasInsufficientFunds || hasAnomaly || exceedsDailyCap;
}

class SafetyCheckService {
  final BillHistoryDao _historyDao;
  final PaymentDao _paymentDao;
  final SettingsDao _settingsDao;
  
  SafetyCheckService(this._historyDao, this._paymentDao, this._settingsDao);
  
  Future<SafetyCheckResult> checkPaymentSafety({
    required double billAmount,
    required String payeeName,
    required double currentBalance,
    required double safetyBuffer,
    required DateTime scheduledDate,
  }) async {
    // Check 1: Insufficient funds
    final insufficientFunds = await _checkInsufficientFunds(
      billAmount, currentBalance, safetyBuffer,
    );
    
    // Check 2: Anomaly detection
    final anomaly = await _checkAnomaly(payeeName, billAmount);
    
    // Check 3: Daily cap
    final dailyCap = await _checkDailyCap(billAmount, scheduledDate);
    
    return SafetyCheckResult(
      hasInsufficientFunds: insufficientFunds != null,
      hasAnomaly: anomaly != null,
      exceedsDailyCap: dailyCap != null,
      insufficientFundsMessage: insufficientFunds,
      anomalyMessage: anomaly,
      dailyCapMessage: dailyCap,
    );
  }
  
  Future<String?> _checkInsufficientFunds(
    double amount, double balance, double buffer,
  ) async {
    if ((balance - amount) < buffer) {
      return 'Paying this may leave you with less than your safety buffer (\$${buffer.toStringAsFixed(0)}).';
    }
    return null;
  }
  
  Future<String?> _checkAnomaly(String payeeName, double amount) async {
    final avgAmount = await _historyDao.getAverageAmountForPayee(payeeName);
    if (avgAmount == null || avgAmount == 0) return null;
    
    final deviation = ((amount - avgAmount) / avgAmount).abs();
    if (deviation > 0.30) {
      final percent = (deviation * 100).round();
      final direction = amount > avgAmount ? 'higher' : 'lower';
      return 'This bill is $percent% $direction than usual (\$${avgAmount.toStringAsFixed(2)}).';
    }
    return null;
  }
  
  Future<String?> _checkDailyCap(double amount, DateTime date) async {
    final settings = await _settingsDao.getSettings();
    final dailyCap = settings.dailyPaymentCap;
    
    final totalForDay = await _paymentDao.getTotalScheduledForDate(date);
    if ((totalForDay + amount) > dailyCap) {
      return 'Daily payment limit (\$${dailyCap.toStringAsFixed(0)}) would be exceeded.';
    }
    return null;
  }
}
```

#### Step 2.3.2: Implement Bill History DAO (30 min)

Create `lib/data/database/dao/bill_history_dao.dart` from Backend Structure document.

#### Step 2.3.3: Create Warning Banner Widget (25 min)

Create `lib/presentation/widgets/warning_banner.dart` from Frontend Guidelines.

Support types: warning, error, info, maintenance.

#### Step 2.3.4: Test Safety Checks (20 min)

Test scenarios:
1. Bill amount > (balance - buffer) → Insufficient funds warning
2. Bill amount 50% higher than average → Anomaly warning
3. Total for day > $2000 → Daily cap warning

**Verification:**
- [ ] Insufficient funds warning appears correctly
- [ ] Anomaly warning appears for unusual amounts
- [ ] Daily cap prevents excessive scheduling

**✅ Step 2.3 Checkpoint:** Safety checks working

---

### Phase 2.4: Recommendation UI (16:00 - 18:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Step 2.3 complete

#### Step 2.4.1: Create Recommendation Panel Widget (45 min)

Create `lib/presentation/widgets/recommendation_panel.dart` from Frontend Guidelines.

- Icon and "AI Recommendation" header
- Recommendation text (bold)
- Rationale text
- Action button ("Pay Now" or "Schedule for...")
- Disclaimer text

#### Step 2.4.2: Integrate Recommendation into Bill Detail (30 min)

Update `lib/presentation/screens/bills/bill_detail_screen.dart`:

- Load recommendation when screen opens
- Show recommendation panel if:
  - Bill status is Pending
  - Due within 7 days
  - Amount >= $50
- Show warning banners above recommendation

#### Step 2.4.3: Create Recommendation Provider (25 min)

Create `lib/presentation/providers/recommendation_provider.dart`:

```dart
class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _recommendationService;
  final SafetyCheckService _safetyCheckService;
  
  Recommendation? _recommendation;
  SafetyCheckResult? _safetyCheck;
  bool _isLoading = false;
  
  Recommendation? get recommendation => _recommendation;
  SafetyCheckResult? get safetyCheck => _safetyCheck;
  bool get isLoading => _isLoading;

  Future<void> getRecommendation(Bill bill, CashflowInput cashflow) async {
    _isLoading = true;
    notifyListeners();
    
    _recommendation = await _recommendationService.getRecommendation(
      bill: bill,
      cashflow: cashflow,
    );
    
    _safetyCheck = await _safetyCheckService.checkPaymentSafety(
      billAmount: bill.amount,
      payeeName: bill.payeeName,
      currentBalance: cashflow.currentBalance,
      safetyBuffer: cashflow.safetyBuffer,
      scheduledDate: DateTime.now(),
    );
    
    _isLoading = false;
    notifyListeners();
  }
}
```

#### Step 2.4.4: Visual Polish & Testing (20 min)

- Verify recommendation appears correctly
- Verify warnings appear above recommendation
- Test dismiss functionality
- Test accept recommendation flow

**Verification:**
- [ ] Recommendation panel appears on eligible bills
- [ ] Rationale text displays correctly
- [ ] Warning banners appear when applicable
- [ ] Tapping recommendation button works

**✅ Step 2.4 Checkpoint:** Recommendation UI complete

---

### Phase 2.5: Day 2 Evaluation & Polish (18:00 - 20:00)

**Duration:** 2 hours  
**Owner:** Both team members  
**Dependencies:** Step 2.4 complete

#### Step 2.5.1: Run 20-Scenario Evaluation (60 min)

Test all 20 scenarios from PRD:

| # | Scenario | Expected | Actual | Pass? |
|---|----------|----------|--------|-------|
| 1 | Healthy buffer, 5 days to due | Pay Now | | |
| 2 | Low buffer, payday before due | Schedule | | |
| 3 | Low buffer, payday after due | Pay Now (warning) | | |
| ... | ... | ... | | |

Document any failures and fix.

#### Step 2.5.2: Fix Evaluation Failures (30 min)

Address any recommendation logic issues found in evaluation.

#### Step 2.5.3: Commit & Document (30 min)

- Commit all Day 2 code
- Update any documentation
- Note known issues for Day 3

**Day 2 Final Verification:**
```
[ ] Recommendation appears on eligible bills
[ ] Recommendation logic matches rules (85%+ accuracy)
[ ] Rationale text is clear and helpful
[ ] Insufficient funds warning works
[ ] Anomaly detection warning works
[ ] Daily cap enforcement works
[ ] Demo mode works without API key
```

**✅ DAY 2 COMPLETE:** AI recommendations working with safety checks

---

## 4. Day 3: Payment Flow & Maintenance Mode

**Goal:** Complete payment scheduling flow and maintenance mode

**Success Criteria:**
- [ ] Can confirm and schedule payment
- [ ] Mock authentication works
- [ ] Success screen shows with reference ID
- [ ] Audit log records all actions
- [ ] Maintenance mode UI works
- [ ] Can queue payments during maintenance
- [ ] Settings screen functional

---

### Phase 3.1: Payment Confirmation Flow (9:00 - 11:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Day 2 complete

#### Step 3.1.1: Create Payment Entity & Model (20 min)

Create `lib/domain/entities/payment.dart` and `lib/data/models/payment_model.dart`.

#### Step 3.1.2: Create Payment DAO (25 min)

Create `lib/data/database/dao/payment_dao.dart` from Backend Structure document.

#### Step 3.1.3: Create Reference ID Generator (15 min)

Create `lib/core/utils/reference_generator.dart`:

```dart
class ReferenceGenerator {
  static int _dailyCounter = 0;
  static String? _currentDate;
  
  static String generate() {
    final today = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
    
    if (_currentDate != today) {
      _currentDate = today;
      _dailyCounter = 0;
    }
    
    _dailyCounter++;
    return 'PAC-$today-${_dailyCounter.toString().padLeft(3, '0')}';
  }
}
```

#### Step 3.1.4: Create Payment Confirmation Screen (45 min)

Create `lib/presentation/screens/payment/payment_confirmation_screen.dart`:

- Payment summary card (payee, amount, date)
- Balance impact preview
- Warning banners (if any)
- Demo disclaimer
- Confirm Payment button
- Cancel button

#### Step 3.1.5: Add Navigation & Integration (15 min)

Wire up navigation from Bill Detail → Payment Confirmation.

Pass bill ID and scheduled date as parameters.

**Verification:**
- [ ] Payment confirmation screen displays correctly
- [ ] Balance impact calculated correctly
- [ ] Warnings appear if applicable

**✅ Step 3.1 Checkpoint:** Payment confirmation screen working

---

### Phase 3.2: Authentication & Success (11:00 - 13:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Step 3.1 complete

#### Step 3.2.1: Create Auth Service (30 min)

Create `lib/data/services/auth_service.dart`:

```dart
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  
  Future<bool> authenticate({String reason = 'Authenticate to confirm payment'}) async {
    try {
      final canAuthenticate = await _auth.canCheckBiometrics || 
                              await _auth.isDeviceSupported();
      
      if (!canAuthenticate) {
        // Simulate success on devices without biometrics
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      }
      
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      // Simulate success on error for demo
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
  }
}
```

#### Step 3.2.2: Create Auth Modal (30 min)

Create `lib/presentation/screens/auth/auth_modal.dart`:

- Modal overlay with fingerprint icon
- "Authenticate to Schedule Payment" title
- Payment summary (small text)
- "Touch ID" / "Use PIN" button
- Cancel button
- Loading state during authentication

#### Step 3.2.3: Create Payment Success Screen (30 min)

Create `lib/presentation/screens/payment/payment_success_screen.dart`:

- Large green checkmark animation
- "Payment Scheduled Successfully" header
- Payment details card
- Reference ID (copyable)
- "Next Steps" section
- "Done" button → Home
- "View Bill Details" link

#### Step 3.2.4: Implement Payment Processing (30 min)

Create `lib/presentation/providers/payment_provider.dart`:

```dart
class PaymentProvider extends ChangeNotifier {
  final PaymentDao _paymentDao;
  final BillDao _billDao;
  final AuditLogDao _auditDao;
  final AuthService _authService;
  
  bool _isProcessing = false;
  String? _error;
  
  Future<String?> schedulePayment({
    required int billId,
    required double amount,
    required DateTime scheduledDate,
  }) async {
    _isProcessing = true;
    notifyListeners();
    
    try {
      // Authenticate
      final authenticated = await _authService.authenticate();
      if (!authenticated) {
        _error = 'Authentication failed';
        return null;
      }
      
      // Generate reference ID
      final referenceId = ReferenceGenerator.generate();
      
      // Create payment record
      await _paymentDao.insertPayment(PaymentModel(
        billId: billId,
        referenceId: referenceId,
        scheduledDate: scheduledDate,
        amount: amount,
        status: 'Scheduled',
      ));
      
      // Update bill status
      await _billDao.updateBillStatus(billId, 'Scheduled', referenceId: referenceId);
      
      // Log to audit
      await _auditDao.log(
        actionType: 'payment_scheduled',
        referenceId: referenceId,
        details: {
          'bill_id': billId,
          'amount': amount,
          'scheduled_date': scheduledDate.toIso8601String(),
        },
        userNote: 'User scheduled payment',
      );
      
      _isProcessing = false;
      notifyListeners();
      return referenceId;
      
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }
}
```

**Verification:**
- [ ] Auth modal appears on confirm tap
- [ ] Simulated auth completes successfully
- [ ] Success screen shows with reference ID
- [ ] Bill status updates to "Scheduled"
- [ ] Payment record created in database

**✅ Step 3.2 Checkpoint:** Full payment flow working

---

### Phase 3.3: Audit Logging (14:00 - 15:00)

**Duration:** 1 hour  
**Owner:** Developer  
**Dependencies:** Step 3.2 complete

#### Step 3.3.1: Create Audit Log DAO (20 min)

Create `lib/data/database/dao/audit_log_dao.dart` from Backend Structure document.

#### Step 3.3.2: Integrate Logging Throughout App (30 min)

Add audit logging for:
- Bill created
- Bill updated
- Bill deleted
- Bill marked as paid
- Recommendation shown
- Recommendation accepted/rejected
- Payment scheduled
- Payment queued
- Safety check triggered
- Settings changed

#### Step 3.3.3: Create Audit Log Viewer Screen (10 min)

Create `lib/presentation/screens/settings/audit_log_screen.dart`:

- Chronological list of log entries
- Each entry shows: timestamp, action, reference
- Expandable details (JSON)

**Verification:**
- [ ] All actions create audit log entries
- [ ] Audit log viewer shows entries
- [ ] Entries display correctly

**✅ Step 3.3 Checkpoint:** Audit logging complete

---

### Phase 3.4: Maintenance Mode (15:00 - 17:00)

**Duration:** 2 hours  
**Owner:** Developer  
**Dependencies:** Step 3.3 complete

#### Step 3.4.1: Create Maintenance Mode Provider (20 min)

Create `lib/presentation/providers/maintenance_provider.dart`:

```dart
class MaintenanceProvider extends ChangeNotifier {
  final SettingsDao _settingsDao;
  
  bool _isMaintenanceMode = false;
  DateTime? _estimatedEndTime;
  double? _balanceSnapshot;
  DateTime? _snapshotTime;
  
  bool get isMaintenanceMode => _isMaintenanceMode;
  
  Future<void> checkMaintenanceStatus() async {
    final settings = await _settingsDao.getSettings();
    _isMaintenanceMode = settings.maintenanceMode;
    
    if (_isMaintenanceMode) {
      // Set estimated end time (demo: 4 hours from now)
      _estimatedEndTime = DateTime.now().add(const Duration(hours: 4));
      // Capture balance snapshot
      // ...
    }
    
    notifyListeners();
  }
  
  Future<void> toggleMaintenanceMode() async {
    await _settingsDao.setMaintenanceMode(!_isMaintenanceMode);
    await checkMaintenanceStatus();
  }
}
```

#### Step 3.4.2: Create Maintenance Mode Home Screen (40 min)

Create `lib/presentation/screens/maintenance/maintenance_mode_screen.dart`:

- Prominent maintenance banner
- Balance snapshot with timestamp disclaimer
- Tab: Queued Payments (list)
- Tab: Emergency Options (static info)
- Queue Payment button
- Exit Maintenance Mode link (demo)

#### Step 3.4.3: Create Queue Payment Confirmation (30 min)

Create `lib/presentation/screens/maintenance/queue_payment_screen.dart`:

- Info banner explaining "intent only"
- Payment summary
- Balance disclaimer
- Checkbox: "I understand this is a payment INTENT"
- Confirm Queue button (enabled when checked)
- Cancel button

Modify payment flow to create "Queued" status instead of "Scheduled".

#### Step 3.4.4: Create Emergency Options Tab (15 min)

Static content:
- Call Us: 1-800-BANK-HELP
- ATM Locator button
- Branch Hours
- Online Help link

#### Step 3.4.5: Integrate Maintenance Mode (15 min)

- Check maintenance status on app launch
- Show maintenance banner on Home if active
- Redirect to Maintenance Home when in maintenance mode
- Disable normal payment flow (offer queue instead)

**Verification:**
- [ ] Toggle maintenance mode in settings
- [ ] App switches to maintenance UI
- [ ] Can queue payment during maintenance
- [ ] Emergency options display correctly
- [ ] Can exit maintenance mode

**✅ Step 3.4 Checkpoint:** Maintenance mode working

---

### Phase 3.5: Settings Screen (17:00 - 18:30)

**Duration:** 1.5 hours  
**Owner:** Developer  
**Dependencies:** Step 3.4 complete

#### Step 3.5.1: Create Settings Screen (45 min)

Create `lib/presentation/screens/settings/settings_screen.dart`:

Sections:
- **Cashflow Settings**
  - Current Balance (tap → Cashflow Inputs)
  - Next Payday
  - Safety Buffer
  
- **Payment Limits**
  - Daily Payment Cap (editable)
  
- **System Settings**
  - Maintenance Mode toggle
  - Demo Mode toggle
  - Notifications toggle
  
- **Data & Privacy**
  - View Audit Log
  - Reset Demo Data
  
- **Help & About**
  - How to Use PAC
  - About This App
  - App Version

#### Step 3.5.2: Create Cashflow Inputs Screen (30 min)

Create `lib/presentation/screens/settings/cashflow_inputs_screen.dart`:

- Current Balance input (currency)
- Next Payday date picker
- Safety Buffer input (range: $100-$2000)
- Save Changes button
- Cancel button

#### Step 3.5.3: Wire Up Settings (15 min)

- Connect all settings to database
- Implement Reset Demo Data functionality
- Add navigation to About screen

**Verification:**
- [ ] All settings display current values
- [ ] Can update cashflow inputs
- [ ] Toggles work correctly
- [ ] Reset Demo Data clears and reseeds

**✅ Step 3.5 Checkpoint:** Settings screen complete

---

### Phase 3.6: Day 3 Testing & Polish (18:30 - 20:00)

**Duration:** 1.5 hours  
**Owner:** Both team members  
**Dependencies:** Step 3.5 complete

#### Step 3.6.1: End-to-End Testing (45 min)

Test complete user journeys:

**Journey A: Normal Payment Flow**
1. Open app → Home shows bills needing attention
2. Tap bill → See AI recommendation
3. Accept recommendation → Payment confirmation
4. Confirm → Auth modal → Success
5. Verify bill status is "Scheduled"
6. Check audit log shows entries

**Journey B: Maintenance Mode Flow**
1. Enable maintenance mode in settings
2. App switches to maintenance UI
3. Attempt to queue payment
4. Confirm queue with checkbox
5. Verify payment is "Queued"
6. Disable maintenance mode
7. App returns to normal

#### Step 3.6.2: Bug Fixes (30 min)

Fix any issues found during testing.

#### Step 3.6.3: Commit & Prepare for Day 4 (15 min)

- Commit all code
- List known issues
- Prioritize Day 4 work

**Day 3 Final Verification:**
```
[ ] Payment confirmation screen works
[ ] Auth modal appears and authenticates
[ ] Success screen shows reference ID
[ ] Bill status updates correctly
[ ] Audit log captures all actions
[ ] Maintenance mode toggle works
[ ] Maintenance UI displays correctly
[ ] Can queue payments in maintenance
[ ] Emergency options show
[ ] Settings screen functional
[ ] Cashflow inputs save correctly
[ ] Reset demo data works
```

**✅ DAY 3 COMPLETE:** Full app flow working

---

## 5. Day 4: Polish & Demo Prep

**Goal:** Polished app ready for demo, video recorded, pitch deck complete

**Success Criteria:**
- [ ] No blocking bugs
- [ ] Demo video recorded (2-4 min)
- [ ] Pitch deck complete (8 slides)
- [ ] Rehearsal completed
- [ ] All deliverables submitted

---

### Phase 4.1: Bug Fixes