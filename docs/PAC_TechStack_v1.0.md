# Technology Stack Documentation: Payment Assurance Copilot (PAC)

**Version:** 1.0  
**Last Updated:** February 10, 2026  
**Purpose:** Complete technology stack specification with versions, rationale, and setup instructions  
**Audience:** Developers, Hackathon Judges, Technical Reviewers

---

## 1. Stack Overview

### Architecture Pattern
- **Type:** Monolithic (Single Flutter Application)
- **Pattern:** MVVM (Model-View-ViewModel) with Provider State Management
- **Deployment:** Local-only Android APK (No cloud/backend deployment)
- **Data Persistence:** Local SQLite database (on-device)

### Architecture Rationale
For a 4-day hackathon MVP targeting Android, a monolithic Flutter application provides:
- **Rapid development:** Single codebase, no backend coordination required
- **Offline-first:** All data persists locally, demo works without network
- **Simplicity:** No cloud infrastructure to manage, deploy, or debug
- **Judge-friendly:** APK can be installed directly on any Android device

### High-Level Architecture Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                        PAC Flutter App                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Views     │ ←→ │ ViewModels  │ ←→ │   Models    │         │
│  │  (Screens)  │    │ (Providers) │    │   (Data)    │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│         ↑                  ↑                  ↑                 │
│         │                  │                  │                 │
│  ┌──────┴──────────────────┴──────────────────┴──────┐         │
│  │              Service Layer                         │         │
│  │  ┌──────────────┐  ┌──────────────┐               │         │
│  │  │ AI Service   │  │ Database Svc │               │         │
│  │  │ (LLM/Cache)  │  │ (SQLite)     │               │         │
│  │  └──────────────┘  └──────────────┘               │         │
│  └───────────────────────────────────────────────────┘         │
│         ↓                                    ↓                  │
│  ┌─────────────┐                    ┌─────────────────┐        │
│  │ Anthropic   │                    │ SQLite Database │        │
│  │ Claude API  │                    │ (sqflite)       │        │
│  │ (Optional)  │                    │                 │        │
│  └─────────────┘                    └─────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Core Framework Stack

### Flutter SDK
| Attribute | Value |
|-----------|-------|
| **Framework** | Flutter |
| **Version** | 3.38.9 (Stable) |
| **Release Date** | January 29, 2026 |
| **Dart Version** | 3.10.8 (bundled) |
| **Documentation** | https://docs.flutter.dev |
| **License** | BSD-3-Clause |

**Reason for Selection:**
- **Cross-platform potential:** While targeting Android only for hackathon, Flutter allows iOS expansion later
- **Rapid prototyping:** Hot reload enables fast UI iteration
- **Rich widget library:** Material Design components out of the box
- **Strong typing:** Dart's type system catches errors at compile time
- **Team familiarity:** Assumed prior Flutter experience

**Installation:**
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"

# Verify installation
flutter doctor

# Ensure on correct channel and version
flutter channel stable
flutter upgrade
flutter --version  # Should show 3.38.9
```

### Dart SDK
| Attribute | Value |
|-----------|-------|
| **Language** | Dart |
| **Version** | 3.10.8 |
| **Bundled With** | Flutter 3.38.9 |
| **Documentation** | https://dart.dev/guides |
| **License** | BSD-3-Clause |

**Reason for Selection:**
- Bundled with Flutter (no separate installation)
- Null safety enforced
- Strong async/await support for API calls
- Excellent IDE integration

---

## 3. State Management

### Provider
| Attribute | Value |
|-----------|-------|
| **Package** | provider |
| **Version** | 6.1.4 |
| **Pub.dev** | https://pub.dev/packages/provider |
| **Documentation** | https://pub.dev/documentation/provider/latest/ |
| **License** | MIT |

**Reason for Selection:**
- **Official recommendation:** Recommended by Flutter team for simple-to-medium complexity apps
- **Low boilerplate:** Less code than BLoC or Redux
- **Easy to learn:** Good for hackathon time constraints
- **MVVM compatible:** Works well with ChangeNotifier pattern

**Alternatives Considered:**
| Alternative | Reason Rejected |
|-------------|-----------------|
| BLoC | Too verbose for 4-day hackathon; overkill for 16 screens |
| Riverpod | Learning curve; team more familiar with Provider |
| GetX | Less predictable patterns; harder to debug |
| Redux | Too much boilerplate for MVP scope |

**Installation:**
```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.4
```

**Usage Pattern:**
```dart
// ViewModel (ChangeNotifier)
class BillsProvider extends ChangeNotifier {
  List<Bill> _bills = [];
  List<Bill> get bills => _bills;
  
  Future<void> loadBills() async {
    _bills = await DatabaseService.getBills();
    notifyListeners();
  }
}

// Provide at app root
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => BillsProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ],
  child: MyApp(),
)

// Consume in widget
Consumer<BillsProvider>(
  builder: (context, billsProvider, child) {
    return ListView.builder(
      itemCount: billsProvider.bills.length,
      itemBuilder: (context, index) => BillCard(billsProvider.bills[index]),
    );
  },
)
```

---

## 4. Database & Persistence

### SQLite (sqflite)
| Attribute | Value |
|-----------|-------|
| **Package** | sqflite |
| **Version** | 2.4.2 |
| **Pub.dev** | https://pub.dev/packages/sqflite |
| **Documentation** | https://pub.dev/documentation/sqflite/latest/ |
| **License** | BSD-2-Clause |
| **Platforms** | Android, iOS, macOS |

**Reason for Selection:**
- **Local-first:** No backend required; data stays on device
- **Relational:** Supports complex queries for bill filtering, audit logs
- **Hackathon appropriate:** Simple setup, no cloud configuration
- **Production realistic:** Real banking apps use SQLite for offline caching

**Installation:**
```yaml
# pubspec.yaml
dependencies:
  sqflite: ^2.4.2
  path: ^1.9.0  # For database path construction
```

**Database Schema Implementation:**
```dart
// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'pac_database.db';
  static const int _databaseVersion = 1;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }
  
  static Future<void> _onCreate(Database db, int version) async {
    // Bills table
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payee_name TEXT NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        category TEXT CHECK(category IN ('Utilities', 'Insurance', 'Subscriptions', 'Other')),
        status TEXT CHECK(status IN ('Pending', 'Scheduled', 'Paid', 'Queued')) DEFAULT 'Pending',
        reference_id TEXT UNIQUE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_id INTEGER NOT NULL,
        reference_id TEXT NOT NULL UNIQUE,
        scheduled_date TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT CHECK(status IN ('Queued', 'Scheduled', 'Simulated')) DEFAULT 'Scheduled',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (bill_id) REFERENCES bills(id)
      )
    ''');
    
    // Audit logs table
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        action_type TEXT NOT NULL,
        reference_id TEXT,
        details TEXT,
        user_note TEXT
      )
    ''');
    
    // Cashflow inputs table (single row)
    await db.execute('''
      CREATE TABLE cashflow_inputs (
        id INTEGER PRIMARY KEY CHECK(id = 1),
        current_balance REAL NOT NULL DEFAULT 0,
        next_payday_date TEXT NOT NULL,
        safety_buffer REAL NOT NULL DEFAULT 500,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Settings table (single row)
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY CHECK(id = 1),
        daily_payment_cap REAL NOT NULL DEFAULT 2000,
        maintenance_mode INTEGER DEFAULT 0,
        demo_mode INTEGER DEFAULT 1,
        notification_enabled INTEGER DEFAULT 1
      )
    ''');
    
    // Bill history table (for anomaly detection)
    await db.execute('''
      CREATE TABLE bill_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payee_name TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL
      )
    ''');
    
    // Insert default settings and cashflow
    await db.insert('settings', {
      'id': 1,
      'daily_payment_cap': 2000.0,
      'maintenance_mode': 0,
      'demo_mode': 1,
      'notification_enabled': 1,
    });
    
    await db.insert('cashflow_inputs', {
      'id': 1,
      'current_balance': 2800.0,
      'next_payday_date': '2026-02-19',
      'safety_buffer': 500.0,
    });
  }
}
```

### Path Provider
| Attribute | Value |
|-----------|-------|
| **Package** | path_provider |
| **Version** | 2.1.5 |
| **Pub.dev** | https://pub.dev/packages/path_provider |
| **License** | BSD-3-Clause |

**Reason for Selection:**
- Required dependency for sqflite database path resolution
- Cross-platform path handling

**Installation:**
```yaml
dependencies:
  path_provider: ^2.1.5
```

### Shared Preferences
| Attribute | Value |
|-----------|-------|
| **Package** | shared_preferences |
| **Version** | 2.5.4 |
| **Pub.dev** | https://pub.dev/packages/shared_preferences |
| **License** | BSD-3-Clause |

**Reason for Selection:**
- Simple key-value storage for non-critical preferences
- Faster than SQLite for simple flags (e.g., onboarding completed)

**Installation:**
```yaml
dependencies:
  shared_preferences: ^2.5.4
```

---

## 5. Navigation

### Go Router
| Attribute | Value |
|-----------|-------|
| **Package** | go_router |
| **Version** | 17.1.0 |
| **Pub.dev** | https://pub.dev/packages/go_router |
| **Documentation** | https://pub.dev/documentation/go_router/latest/ |
| **License** | BSD-3-Clause |

**Reason for Selection:**
- **Declarative routing:** Cleaner than Navigator 1.0 imperative approach
- **Deep linking support:** Future-proofs for notification navigation
- **Bottom navigation support:** Built-in patterns for our 3-tab layout
- **Official package:** Maintained by Flutter team

**Alternatives Considered:**
| Alternative | Reason Rejected |
|-------------|-----------------|
| Navigator 2.0 (raw) | Too verbose; go_router abstracts complexity |
| Auto Route | Code generation adds complexity |
| Beamer | Less active community support |

**Installation:**
```yaml
dependencies:
  go_router: ^17.1.0
```

**Route Configuration:**
```dart
// lib/router/app_router.dart
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route for bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/bills',
          name: 'bills',
          builder: (context, state) => const BillListScreen(),
          routes: [
            GoRoute(
              path: ':billId',
              name: 'billDetail',
              builder: (context, state) {
                final billId = int.parse(state.pathParameters['billId']!);
                return BillDetailScreen(billId: billId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Non-shell routes (full screen)
    GoRoute(
      path: '/add-bill',
      name: 'addBill',
      builder: (context, state) => const AddBillScreen(),
    ),
    GoRoute(
      path: '/edit-bill/:billId',
      name: 'editBill',
      builder: (context, state) {
        final billId = int.parse(state.pathParameters['billId']!);
        return EditBillScreen(billId: billId);
      },
    ),
    GoRoute(
      path: '/payment-confirmation/:billId',
      name: 'paymentConfirmation',
      builder: (context, state) {
        final billId = int.parse(state.pathParameters['billId']!);
        final scheduledDate = state.uri.queryParameters['date'];
        return PaymentConfirmationScreen(
          billId: billId,
          scheduledDate: scheduledDate,
        );
      },
    ),
    GoRoute(
      path: '/payment-success/:referenceId',
      name: 'paymentSuccess',
      builder: (context, state) {
        final referenceId = state.pathParameters['referenceId']!;
        return PaymentSuccessScreen(referenceId: referenceId);
      },
    ),
    GoRoute(
      path: '/maintenance',
      name: 'maintenance',
      builder: (context, state) => const MaintenanceModeScreen(),
    ),
    GoRoute(
      path: '/cashflow-inputs',
      name: 'cashflowInputs',
      builder: (context, state) => const CashflowInputsScreen(),
    ),
    GoRoute(
      path: '/audit-log',
      name: 'auditLog',
      builder: (context, state) => const AuditLogScreen(),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
```

---

## 6. AI / LLM Integration

### Anthropic Claude API
| Attribute | Value |
|-----------|-------|
| **Provider** | Anthropic |
| **Model** | claude-haiku-4-5 |
| **Model ID (versioned)** | claude-haiku-4-5-20251001 |
| **API Documentation** | https://docs.anthropic.com/claude/reference |
| **Pricing** | ~$0.25/1M input tokens, ~$1.25/1M output tokens |
| **License** | Commercial (API Terms of Service) |

**Reason for Selection:**
- **Speed:** Haiku is optimized for low-latency responses (<1s typical)
- **Cost:** Most affordable Claude model for hackathon budget
- **Quality:** Sufficient for generating 50-word rationale text
- **Safety:** Built-in content filtering; aligns with responsible AI goals

**Alternatives Considered:**
| Alternative | Reason Rejected |
|-------------|-----------------|
| GPT-4o-mini | Similar capability, but team prefers Anthropic API |
| Claude Sonnet | Overkill for simple rationale generation; higher cost |
| Local LLM (Llama) | Too slow on mobile; requires significant setup |
| Gemini | Less familiar API; limited hackathon time for learning |

**HTTP Client for API Calls:**
| Attribute | Value |
|-----------|-------|
| **Package** | http |
| **Version** | 1.6.0 |
| **Pub.dev** | https://pub.dev/packages/http |
| **License** | BSD-3-Clause |

**Installation:**
```yaml
dependencies:
  http: ^1.6.0
```

**AI Service Implementation:**
```dart
// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5';
  static const int _timeoutSeconds = 3;
  
  // API key should be stored securely - for demo, using environment variable
  static String? _apiKey;
  
  static void initialize(String apiKey) {
    _apiKey = apiKey;
  }
  
  static Future<String> generateRationale({
    required String payee,
    required double amount,
    required String dueDate,
    required double currentBalance,
    required String nextPayday,
    required double safetyBuffer,
    required String recommendation,
    List<Map<String, dynamic>>? upcomingPayments,
  }) async {
    // If no API key or demo mode, use cached response
    if (_apiKey == null || _apiKey!.isEmpty) {
      return _getCachedRationale(recommendation);
    }
    
    final prompt = '''
You are a helpful financial assistant for a banking app. Generate a brief, friendly explanation (max 50 words) for why we recommend this payment timing.

Context:
- Bill: $payee \$${amount.toStringAsFixed(2)} due $dueDate
- Current balance: \$${currentBalance.toStringAsFixed(2)}
- Next payday: $nextPayday
- Safety buffer: \$${safetyBuffer.toStringAsFixed(2)}
- Known upcoming: ${upcomingPayments?.map((p) => '${p['name']} \$${p['amount']}').join(', ') ?? 'None'}

Recommendation: $recommendation

Generate explanation focusing on the main factor (buffer, timing, upcoming obligations). Use simple language. Start with "Why?" or directly explain.
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey!,
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
        return data['content'][0]['text'] ?? _getCachedRationale(recommendation);
      } else {
        return _getCachedRationale(recommendation);
      }
    } catch (e) {
      // Timeout or network error - fall back to cache
      return _getCachedRationale(recommendation);
    }
  }
  
  static String _getCachedRationale(String recommendation) {
    // Cached responses for demo mode
    final Map<String, String> cachedRationales = {
      'pay_now': 'Paying now is safe! Your balance comfortably covers this bill while maintaining your safety buffer for other expenses.',
      'schedule_payday': 'Waiting until payday is smarter here. Paying now would leave you with less cushion for upcoming obligations.',
      'remind_later': 'This bill is due soon, but we need more information to give you the best recommendation. Please review manually.',
    };
    
    return cachedRationales[recommendation] ?? 
      'This timing helps maintain your safety buffer and avoids conflicts with other payments.';
  }
}
```

### Demo Mode / Caching Strategy
For hackathon reliability, the app operates in "Demo Mode" by default:
- **10 pre-generated rationale responses** cover common scenarios
- **3-second timeout** on API calls; falls back to cache on failure
- **Visual indicator** shows "🎭 Demo Mode" badge when using cached responses
- **Audit logging** records whether AI response was live or cached

**Cached Scenario Coverage:**
1. Pay now - healthy buffer
2. Schedule for payday - low buffer
3. Insufficient funds warning triggered
4. Anomaly detected - high amount
5. Anomaly detected - low amount
6. Multiple bills same day
7. Payday is after due date (edge case)
8. Remind later - <3 days to due
9. Bill already paid today
10. First bill for new payee (no history)

---

## 7. UI & Styling

### Material Design 3
| Attribute | Value |
|-----------|-------|
| **Design System** | Material Design 3 (Material You) |
| **Flutter Component Set** | Built-in Material widgets |
| **Documentation** | https://m3.material.io |

**Reason for Selection:**
- **Native Android feel:** Material Design is standard for Android apps
- **Built-in components:** No additional packages needed for buttons, cards, inputs
- **Theming:** Dynamic color support for modern Android look
- **Accessibility:** Material components include accessibility features

**Theme Configuration:**
```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E88E5), // Primary blue
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
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
      ),
    );
  }
  
  // Custom colors for status indicators
  static const Color warningColor = Color(0xFFFFA726);  // Orange
  static const Color errorColor = Color(0xFFE53935);    // Red
  static const Color successColor = Color(0xFF43A047);  // Green
  static const Color infoColor = Color(0xFF1E88E5);     // Blue
  static const Color scheduledColor = Color(0xFF5C6BC0); // Indigo
}
```

### Intl (Internationalization & Formatting)
| Attribute | Value |
|-----------|-------|
| **Package** | intl |
| **Version** | 0.20.2 |
| **Pub.dev** | https://pub.dev/packages/intl |
| **License** | BSD-3-Clause |

**Reason for Selection:**
- **Date formatting:** Required for displaying dates like "Feb 17, 2026"
- **Currency formatting:** Required for "$180.50" display
- **Number formatting:** Percentage display for anomaly warnings

**Installation:**
```yaml
dependencies:
  intl: ^0.20.2
```

**Usage:**
```dart
import 'package:intl/intl.dart';

// Currency formatting
final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
String formatted = currencyFormat.format(180.50); // "$180.50"

// Date formatting
final dateFormat = DateFormat('MMM d, y'); // "Feb 17, 2026"
final dateTimeFormat = DateFormat('MMM d, y h:mm a'); // "Feb 12, 2026 10:34 AM"
String formattedDate = dateFormat.format(DateTime.parse('2026-02-17'));

// Relative days
int daysUntilDue = DateTime.parse('2026-02-17').difference(DateTime.now()).inDays;
String dueText = daysUntilDue == 0 ? 'Due today!' 
  : daysUntilDue < 0 ? 'Overdue by ${-daysUntilDue} days'
  : '$daysUntilDue days until due';
```

---

## 8. Utility Packages

### UUID
| Attribute | Value |
|-----------|-------|
| **Package** | uuid |
| **Version** | 4.5.2 |
| **Pub.dev** | https://pub.dev/packages/uuid |
| **License** | MIT |

**Reason for Selection:**
- **Reference ID generation:** Required for PAC-YYYYMMDD-NNN format
- **Uniqueness:** Cryptographically strong random generation
- **Lightweight:** No heavy dependencies

**Installation:**
```yaml
dependencies:
  uuid: ^4.5.2
```

**Usage:**
```dart
import 'package:uuid/uuid.dart';

class ReferenceIdGenerator {
  static const _uuid = Uuid();
  static int _dailyCounter = 0;
  static String? _currentDate;
  
  static String generate() {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    
    // Reset counter if new day
    if (_currentDate != today) {
      _currentDate = today;
      _dailyCounter = 0;
    }
    
    _dailyCounter++;
    return 'PAC-$today-${_dailyCounter.toString().padLeft(3, '0')}';
    // Example: PAC-20260212-001
  }
}
```

### Local Auth (Mock Biometric)
| Attribute | Value |
|-----------|-------|
| **Package** | local_auth |
| **Version** | 3.0.0 |
| **Pub.dev** | https://pub.dev/packages/local_auth |
| **License** | BSD-3-Clause |
| **Platforms** | Android, iOS, macOS, Windows |

**Reason for Selection:**
- **Realistic UX:** Provides real biometric prompt on devices that support it
- **Fallback:** Gracefully handles devices without biometrics
- **Demo-friendly:** Can simulate success for demo purposes

**Installation:**
```yaml
dependencies:
  local_auth: ^3.0.0
```

**Android Configuration:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    
    <application
        android:label="Payment Assurance Copilot"
        ...>
        <!-- Ensure MainActivity extends FlutterFragmentActivity -->
    </application>
</manifest>
```

**MainActivity Update:**
```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    // FlutterFragmentActivity required for local_auth
}
```

**Usage:**
```dart
import 'package:local_auth/local_auth.dart';

class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();
  
  static Future<bool> authenticate({String reason = 'Authenticate to confirm payment'}) async {
    try {
      // Check if device supports authentication
      final bool canAuthenticate = await _auth.canCheckBiometrics || 
                                   await _auth.isDeviceSupported();
      
      if (!canAuthenticate) {
        // For demo: simulate success on devices without biometrics
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      }
      
      // Attempt authentication
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern fallback
        ),
      );
      
      return didAuthenticate;
    } catch (e) {
      // For demo: simulate success on error
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
  }
}
```

### Flutter Local Notifications (Optional)
| Attribute | Value |
|-----------|-------|
| **Package** | flutter_local_notifications |
| **Version** | 19.1.0 |
| **Pub.dev** | https://pub.dev/packages/flutter_local_notifications |
| **License** | BSD-3-Clause |
| **Priority** | Low (Add-on feature if time permits) |

**Reason for Selection:**
- **Reminders:** Could trigger reminder notifications for bills due soon
- **No push required:** Local-only, no backend server needed

**Note:** This is an optional add-on feature. Core MVP can function without notifications by relying on the in-app alert cards.

---

## 9. Android Configuration

### Target SDK Configuration
| Attribute | Value |
|-----------|-------|
| **minSdkVersion** | 24 (Android 7.0 Nougat) |
| **targetSdkVersion** | 35 (Android 15) |
| **compileSdkVersion** | 35 |

**Reason for minSdkVersion 24:**
- Covers 97%+ of active Android devices
- Required by local_auth package
- Ensures modern security features available

**Reason for targetSdkVersion 35:**
- Required by Google Play Store for new apps (as of Aug 2025)
- Ensures latest Android security and privacy behaviors

### Android Gradle Configuration
```groovy
// android/app/build.gradle
android {
    namespace "com.example.pac"
    compileSdk 35

    defaultConfig {
        applicationId "com.example.pac"
        minSdk 24
        targetSdk 35
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }
}
```

### Gradle Wrapper Version
| Attribute | Value |
|-----------|-------|
| **Gradle Version** | 8.5 |
| **Android Gradle Plugin** | 8.2.2 |

```properties
# android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-all.zip
```

```groovy
// android/build.gradle
buildscript {
    ext.kotlin_version = '1.9.22'
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

### Required Permissions
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Biometric authentication -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    
    <!-- Internet for AI API calls (optional in demo mode) -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- No other permissions needed for MVP -->
</manifest>
```

---

## 10. Development Tools

### IDE: Visual Studio Code
| Attribute | Value |
|-----------|-------|
| **Editor** | Visual Studio Code |
| **Version** | 1.96+ (Latest stable) |
| **Download** | https://code.visualstudio.com |

**Required Extensions:**
| Extension | ID | Version | Purpose |
|-----------|-----|---------|---------|
| Flutter | Dart-Code.flutter | 3.129.x | Flutter SDK integration, hot reload, debugging |
| Dart | Dart-Code.dart-code | (Auto-installed) | Dart language support |
| Material Icon Theme | PKief.material-icon-theme | Latest | Better file icons |
| Error Lens | usernamehw.errorlens | Latest | Inline error display |

**VS Code Settings (Recommended):**
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit",
    "source.organizeImports": "explicit"
  },
  "dart.flutterSdkPath": "<PATH_TO_FLUTTER_SDK>",
  "dart.lineLength": 100,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.tabSize": 2
  }
}
```

**Launch Configuration:**
```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "PAC Debug",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "flutterMode": "debug"
    },
    {
      "name": "PAC Profile",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "flutterMode": "profile"
    },
    {
      "name": "PAC Release",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "flutterMode": "release"
    }
  ]
}
```

### Alternative IDE: Android Studio
| Attribute | Value |
|-----------|-------|
| **IDE** | Android Studio |
| **Version** | Ladybug (2024.2.x) or later |
| **Download** | https://developer.android.com/studio |

**Required Plugins:**
- Flutter plugin
- Dart plugin

---

## 11. Version Control & Collaboration

### Git Configuration
| Attribute | Value |
|-----------|-------|
| **VCS** | Git |
| **Version** | 2.43+ |
| **Platform** | GitHub |

**Branch Strategy (Simplified for Hackathon):**
```
main          <- Final demo-ready code
  └── dev     <- Active development (default branch during hackathon)
       ├── feature/bills-ui
       ├── feature/ai-integration
       └── feature/maintenance-mode
```

**Git Ignore Configuration:**
```gitignore
# .gitignore
# Flutter/Dart
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies

# Android
android/.gradle/
android/app/debug/
android/app/release/
android/local.properties
*.apk
*.aab

# IDE
.idea/
*.iml
.vscode/
*.swp

# Environment
.env
.env.local
*.env

# Misc
.DS_Store
Thumbs.db
```

**Commit Message Convention:**
```
feat: Add bill list screen with filtering
fix: Correct currency formatting for amounts > $1000
docs: Update tech stack documentation
refactor: Extract AI service to separate class
style: Format code with dart fix
test: Add unit tests for recommendation engine
```

---

## 12. Project Structure

```
pac_app/
├── android/                    # Android-specific configuration
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/.../MainActivity.kt
│   └── build.gradle
├── lib/
│   ├── main.dart               # App entry point
│   ├── models/                 # Data models
│   │   ├── bill.dart
│   │   ├── payment.dart
│   │   ├── audit_log.dart
│   │   ├── cashflow_input.dart
│   │   └── settings.dart
│   ├── providers/              # State management (ViewModels)
│   │   ├── bills_provider.dart
│   │   ├── settings_provider.dart
│   │   ├── cashflow_provider.dart
│   │   └── maintenance_provider.dart
│   ├── screens/                # UI screens
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── bills/
│   │   │   ├── bill_list_screen.dart
│   │   │   ├── bill_detail_screen.dart
│   │   │   ├── add_bill_screen.dart
│   │   │   └── edit_bill_screen.dart
│   │   ├── payment/
│   │   │   ├── payment_confirmation_screen.dart
│   │   │   └── payment_success_screen.dart
│   │   ├── maintenance/
│   │   │   └── maintenance_mode_screen.dart
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   ├── cashflow_inputs_screen.dart
│   │   │   ├── audit_log_screen.dart
│   │   │   └── about_screen.dart
│   │   └── auth/
│   │       └── auth_modal.dart
│   ├── services/               # Business logic services
│   │   ├── database_service.dart
│   │   ├── ai_service.dart
│   │   ├── recommendation_service.dart
│   │   ├── auth_service.dart
│   │   └── audit_service.dart
│   ├── widgets/                # Reusable widgets
│   │   ├── bill_card.dart
│   │   ├── recommendation_panel.dart
│   │   ├── warning_banner.dart
│   │   ├── status_badge.dart
│   │   └── maintenance_banner.dart
│   ├── router/                 # Navigation configuration
│   │   └── app_router.dart
│   ├── theme/                  # Theme configuration
│   │   └── app_theme.dart
│   └── utils/                  # Utility functions
│       ├── formatters.dart
│       ├── validators.dart
│       └── reference_generator.dart
├── test/                       # Unit and widget tests
│   ├── services/
│   │   └── recommendation_service_test.dart
│   └── widgets/
│       └── bill_card_test.dart
├── pubspec.yaml                # Dependencies
├── pubspec.lock                # Locked dependencies
├── analysis_options.yaml       # Linting rules
└── README.md                   # Project documentation
```

---

## 13. Complete pubspec.yaml

```yaml
# pubspec.yaml
name: pac_app
description: Payment Assurance Copilot - AI-assisted bill payment timing for PROCOM '26 Hackathon
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.10.0 <4.0.0'
  flutter: '>=3.38.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.4

  # Navigation
  go_router: ^17.1.0

  # Database & Persistence
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.0
  shared_preferences: ^2.5.4

  # Networking (for AI API)
  http: ^1.6.0

  # UI & Formatting
  intl: ^0.20.2

  # Utilities
  uuid: ^4.5.2

  # Authentication (mock biometric)
  local_auth: ^3.0.0

  # Material Icons (included with Flutter)
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/cached_responses/
```

---

## 14. Security Considerations

### API Key Management
| Risk | Mitigation |
|------|------------|
| API key exposure in code | Store in environment variable, not committed to Git |
| API key in APK | For demo: acceptable risk; Production: use backend proxy |
| Unauthorized API usage | Rate limiting via Anthropic dashboard |

**Environment Variable Setup:**
```bash
# .env (DO NOT COMMIT)
ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxxxxxxx

# Load in app (using flutter_dotenv or compile-time config)
```

**For Hackathon Demo:**
- Demo mode uses cached responses by default
- Live API calls are optional "bonus" feature
- API key can be hardcoded for demo ONLY (not production)

### Data Security
| Area | Implementation |
|------|---------------|
| Local database | Stored in app's private directory; inaccessible to other apps |
| Sensitive data | No real PII stored; all data is synthetic |
| Authentication | Simulated for demo; uses platform biometrics if available |
| Network | HTTPS only for API calls |

### Audit Trail
All user actions logged locally:
- Bill operations (create, edit, delete)
- Payment scheduling
- AI recommendations shown and user decisions
- Settings changes
- Safety check triggers

Logs are stored in SQLite `audit_logs` table, viewable in Settings.

---

## 15. Setup Instructions

### Prerequisites
1. **Operating System:** Windows 10/11, macOS 12+, or Linux (Ubuntu 20.04+)
2. **Disk Space:** 10GB free for Flutter SDK + Android SDK
3. **RAM:** 8GB minimum (16GB recommended)
4. **Android Device or Emulator:** Android 7.0+ (API 24+)

### Step-by-Step Setup

**1. Install Flutter SDK:**
```bash
# Clone Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add to ~/.bashrc, ~/.zshrc, or Windows PATH)
export PATH="$PATH:$HOME/flutter/bin"

# Run Flutter doctor
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses
```

**2. Install Android Studio (for Android SDK):**
- Download from https://developer.android.com/studio
- Install Android SDK via SDK Manager
- Install Android SDK Command-line Tools
- Install Android Emulator

**3. Clone Project:**
```bash
git clone https://github.com/<team>/pac-app.git
cd pac-app
```

**4. Install Dependencies:**
```bash
flutter pub get
```

**5. Create Environment File (Optional - for live AI):**
```bash
# Create .env file in project root
echo "ANTHROPIC_API_KEY=your-api-key-here" > .env
```

**6. Run App:**
```bash
# List available devices
flutter devices

# Run on connected device or emulator
flutter run

# Or specify device
flutter run -d <device_id>
```

**7. Build Release APK:**
```bash
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| `flutter doctor` shows Android license issues | Run `flutter doctor --android-licenses` and accept all |
| Gradle build fails | Ensure Gradle 8.5 and AGP 8.2.2 in android/build.gradle |
| Emulator too slow | Use hardware acceleration (HAXM on Intel, Hyper-V on AMD) |
| Hot reload not working | Ensure device is connected, run `flutter clean` then `flutter run` |
| local_auth crashes | Ensure MainActivity extends FlutterFragmentActivity |

---

## 16. Update & Upgrade Policy

### During Hackathon (Feb 10-13, 2026)
- **DO NOT update any dependencies** during the hackathon
- All versions locked in `pubspec.lock`
- Focus on feature development, not dependency management

### Post-Hackathon (If Continuing Development)
1. **Check for updates weekly:**
   ```bash
   flutter pub outdated
   ```

2. **Update Flutter SDK:**
   ```bash
   flutter upgrade
   ```

3. **Update dependencies:**
   ```bash
   flutter pub upgrade --major-versions  # Review changes before committing
   ```

4. **Test thoroughly** after any update before merging to main

### Version Pinning Strategy
- **Caret syntax (^)** used for minor/patch updates within major version
- **Lock file committed** to ensure reproducible builds
- **Major version updates** require explicit review and testing

---

## 17. Compatibility Matrix

| Component | Minimum | Tested | Maximum |
|-----------|---------|--------|---------|
| Flutter SDK | 3.38.0 | 3.38.9 | 3.x |
| Dart SDK | 3.10.0 | 3.10.8 | 3.x |
| Android SDK (min) | 24 | 24 | - |
| Android SDK (target) | 35 | 35 | 35 |
| Java/JDK | 17 | 17 | 21 |
| Gradle | 8.0 | 8.5 | 8.x |
| Android Gradle Plugin | 8.0 | 8.2.2 | 8.x |

---

## 18. Summary: Key Technology Decisions

| Category | Choice | Version | Primary Reason |
|----------|--------|---------|----------------|
| **Framework** | Flutter | 3.38.9 | Rapid prototyping, hot reload, Material Design |
| **Language** | Dart | 3.10.8 | Bundled with Flutter, null safety |
| **State Management** | Provider | 6.1.4 | Simple, low boilerplate, team familiarity |
| **Navigation** | go_router | 17.1.0 | Declarative, deep linking support |
| **Database** | sqflite (SQLite) | 2.4.2 | Local-first, no backend required |
| **AI Model** | Claude Haiku 4.5 | claude-haiku-4-5 | Fast, cost-effective, safe |
| **HTTP Client** | http | 1.6.0 | Lightweight, sufficient for demo |
| **Authentication** | local_auth | 3.0.0 | Platform biometrics, graceful fallback |
| **Formatting** | intl | 0.20.2 | Currency and date formatting |
| **UUID** | uuid | 4.5.2 | Reference ID generation |
| **Target Platform** | Android | API 24-35 | Hackathon requirement |
| **IDE** | VS Code | 1.96+ | Lightweight, excellent Flutter support |

---

**END OF TECHNOLOGY STACK DOCUMENT**

This document provides a complete, version-locked technology stack for the Payment Assurance Copilot MVP. All versions are specified exactly as researched for February 2026, with installation instructions and rationale for each choice.