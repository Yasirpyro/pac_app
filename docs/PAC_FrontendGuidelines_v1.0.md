# Frontend Design System: Payment Assurance Copilot (PAC)

**Version:** 1.0  
**Last Updated:** February 10, 2026  
**Purpose:** Complete visual specification for consistent UI implementation  
**Audience:** Developers, Designers, AI Code Assistants

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Spacing System](#4-spacing-system)
5. [Iconography](#5-iconography)
6. [Component Library](#6-component-library)
7. [Screen Layouts](#7-screen-layouts)
8. [Motion & Animation](#8-motion--animation)
9. [Accessibility](#9-accessibility)
10. [Code Standards](#10-code-standards)

---

## 1. Design Principles

### 1.1 Core Principles

| Principle | Description | Application |
|-----------|-------------|-------------|
| **Clarity First** | Financial information must be immediately understandable | Large amounts, clear status indicators, no ambiguous icons |
| **Trust & Safety** | Convey security without being intimidating | Blue primary color, confirmation dialogs, visible disclaimers |
| **User Agency** | User always in control; AI assists, never decides | "Recommendation" not "Instruction", always show "Cancel" option |
| **Transparency** | All actions and reasoning visible | Audit logs accessible, AI rationale displayed, no hidden operations |
| **Calm Urgency** | Communicate importance without panic | Warning = orange (not red unless critical), supportive copy |

### 1.2 Design Language

**Material Design 3 (Material You)** is the foundation:
- Modern, rounded components
- Dynamic surface tints for depth
- Accessible color contrasts
- Built-in Flutter support

### 1.3 Visual Hierarchy

```
1. AMOUNT (Largest, boldest - user needs to see money first)
2. STATUS (Color-coded badge - quick scan of situation)
3. PAYEE (Who am I paying?)
4. DATE (When is it due?)
5. ACTIONS (What can I do?)
6. DETAILS (Additional info if needed)
```

---

## 2. Color System

### 2.1 Color Palette

#### Primary Colors
```dart
// lib/theme/app_colors.dart

class AppColors {
  // Primary - Trust Blue (Banking standard)
  static const Color primary = Color(0xFF1565C0);         // Main actions, app bar
  static const Color primaryLight = Color(0xFF5E92F3);    // Hover states
  static const Color primaryDark = Color(0xFF003C8F);     // Pressed states
  static const Color onPrimary = Color(0xFFFFFFFF);       // Text on primary
  
  // Secondary - Teal Accent
  static const Color secondary = Color(0xFF00897B);       // Secondary actions
  static const Color onSecondary = Color(0xFFFFFFFF);     // Text on secondary
```

#### Semantic Colors
```dart
  // Success - Green (Paid, Completed)
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);    // Success background
  static const Color onSuccess = Color(0xFFFFFFFF);
  
  // Warning - Orange (Attention needed, due soon)
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);    // Warning background
  static const Color onWarning = Color(0xFF000000);
  
  // Error - Red (Overdue, failed, critical)
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);      // Error background
  static const Color onError = Color(0xFFFFFFFF);
  
  // Info - Blue (Informational, scheduled)
  static const Color info = Color(0xFF1E88E5);
  static const Color infoLight = Color(0xFFE3F2FD);       // Info background
  static const Color onInfo = Color(0xFFFFFFFF);
  
  // Scheduled - Indigo (Queued, upcoming)
  static const Color scheduled = Color(0xFF5C6BC0);
  static const Color scheduledLight = Color(0xFFE8EAF6);
  static const Color onScheduled = Color(0xFFFFFFFF);
```

#### Surface Colors
```dart
  // Backgrounds
  static const Color background = Color(0xFFF5F7FA);      // Main background
  static const Color surface = Color(0xFFFFFFFF);         // Cards, dialogs
  static const Color surfaceVariant = Color(0xFFE7E9EC);  // Subtle sections
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);     // Main text
  static const Color textSecondary = Color(0xFF757575);   // Secondary text
  static const Color textDisabled = Color(0xFFBDBDBD);    // Disabled text
  static const Color textHint = Color(0xFF9E9E9E);        // Placeholder text
  
  // Borders & Dividers
  static const Color outline = Color(0xFFE0E0E0);         // Input borders
  static const Color divider = Color(0xFFEEEEEE);         // List dividers
  
  // Maintenance Mode
  static const Color maintenance = Color(0xFFFF9800);     // Maintenance banner
  static const Color maintenanceLight = Color(0xFFFFF8E1);
}
```

### 2.2 Color Usage Guidelines

| Context | Color | Hex | Usage |
|---------|-------|-----|-------|
| **Primary Actions** | Trust Blue | `#1565C0` | Pay Now, Confirm, Save buttons |
| **Secondary Actions** | Teal | `#00897B` | Schedule, View Details links |
| **Cancel/Dismiss** | Text Secondary | `#757575` | Cancel buttons, dismiss links |
| **Destructive** | Error Red | `#E53935` | Delete Bill button (requires confirmation) |
| **Paid Status** | Success Green | `#43A047` | "Paid ✓" badge |
| **Due Soon** | Warning Orange | `#FFA726` | "Due in 3 days" badge |
| **Overdue** | Error Red | `#E53935` | "Overdue" badge |
| **Scheduled** | Indigo | `#5C6BC0` | "Scheduled ⏰" badge |
| **Queued** | Info Blue | `#1E88E5` | "Queued" badge (maintenance) |
| **AI Recommendation** | Light Blue BG | `#E3F2FD` | Recommendation panel background |
| **Warning Banner** | Warning Light BG | `#FFF3E0` | Insufficient funds, anomaly alerts |
| **Maintenance Banner** | Maintenance BG | `#FFF8E1` | System maintenance alert |

### 2.3 Color Scheme Implementation

```dart
// lib/theme/app_theme.dart

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
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
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
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
```

### 2.4 Dark Mode (Optional - If Time Permits)

For hackathon MVP, focus on light theme only. Dark mode is a post-hackathon enhancement.

---

## 3. Typography

### 3.1 Type Scale (Material 3)

| Name | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| `displayLarge` | 57px | 400 | 64px | Hero amounts (not used in PAC) |
| `displayMedium` | 45px | 400 | 52px | Large bill amount on detail |
| `displaySmall` | 36px | 400 | 44px | Amount on cards |
| `headlineLarge` | 32px | 400 | 40px | Screen titles |
| `headlineMedium` | 28px | 400 | 36px | Section headers |
| `headlineSmall` | 24px | 400 | 32px | Card titles |
| `titleLarge` | 22px | 500 | 28px | Payee name on detail |
| `titleMedium` | 16px | 500 | 24px | List item titles |
| `titleSmall` | 14px | 500 | 20px | Subtitle emphasis |
| `bodyLarge` | 16px | 400 | 24px | Primary body text |
| `bodyMedium` | 14px | 400 | 20px | Secondary body text |
| `bodySmall` | 12px | 400 | 16px | Captions, timestamps |
| `labelLarge` | 14px | 500 | 20px | Button text |
| `labelMedium` | 12px | 500 | 16px | Chips, badges |
| `labelSmall` | 11px | 500 | 16px | Overlines, small labels |

### 3.2 Typography Usage by Screen Element

| Element | Style | Example |
|---------|-------|---------|
| App bar title | `titleLarge` | "Payment Assurance Copilot" |
| Bill amount (large) | `displaySmall` | "$180.50" |
| Bill amount (list) | `titleLarge` | "$180.50" |
| Payee name | `titleMedium` | "ComEd Electric" |
| Due date | `bodyMedium` | "Due Feb 17, 2026" |
| Status badge | `labelMedium` | "PAID" |
| Button text | `labelLarge` | "Confirm Payment" |
| AI recommendation | `bodyLarge` | "Schedule for Feb 19 (payday)" |
| AI rationale | `bodyMedium` | "Waiting until payday keeps..." |
| Disclaimer | `bodySmall` | "This is a demo. No real funds..." |
| Section header | `titleSmall` | "UPCOMING BILLS" |
| Input label | `bodyMedium` | "Payee Name" |
| Input hint | `bodyMedium` (hint color) | "Enter payee name" |
| Error text | `bodySmall` (error color) | "Amount is required" |

### 3.3 Font Family

**Default:** Roboto (bundled with Flutter Material)

No custom fonts required for MVP. Roboto provides excellent readability for financial data.

### 3.4 Typography Implementation

```dart
// Access typography in widgets
Text(
  '\$180.50',
  style: Theme.of(context).textTheme.displaySmall?.copyWith(
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  ),
)

Text(
  'ComEd Electric',
  style: Theme.of(context).textTheme.titleMedium,
)

Text(
  'Due Feb 17, 2026',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textSecondary,
  ),
)
```

### 3.5 Currency Formatting

Always display currency with:
- Dollar sign prefix (`$`)
- Two decimal places
- Comma for thousands separator
- No space between `$` and amount

```dart
// lib/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  static final currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  static String formatCurrency(double amount) {
    return currencyFormat.format(amount);
  }
}

// Usage
Text(Formatters.formatCurrency(180.50)) // "$180.50"
Text(Formatters.formatCurrency(2800.00)) // "$2,800.00"
```

---

## 4. Spacing System

### 4.1 Spacing Scale

```dart
// lib/theme/app_spacing.dart

class AppSpacing {
  // Base unit: 4px
  static const double xxs = 2.0;   // Micro spacing
  static const double xs = 4.0;    // Tight spacing
  static const double sm = 8.0;    // Small spacing
  static const double md = 16.0;   // Medium (default)
  static const double lg = 24.0;   // Large spacing
  static const double xl = 32.0;   // Extra large
  static const double xxl = 48.0;  // Section breaks
  static const double xxxl = 64.0; // Major sections
  
  // Common EdgeInsets
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm + xs,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm + xs,
  );
  
  // SizedBox shortcuts
  static const SizedBox verticalXS = SizedBox(height: xs);
  static const SizedBox verticalSM = SizedBox(height: sm);
  static const SizedBox verticalMD = SizedBox(height: md);
  static const SizedBox verticalLG = SizedBox(height: lg);
  static const SizedBox verticalXL = SizedBox(height: xl);
  
  static const SizedBox horizontalXS = SizedBox(width: xs);
  static const SizedBox horizontalSM = SizedBox(width: sm);
  static const SizedBox horizontalMD = SizedBox(width: md);
  static const SizedBox horizontalLG = SizedBox(width: lg);
}
```

### 4.2 Spacing Usage Guidelines

| Context | Spacing | Value | Visual |
|---------|---------|-------|--------|
| Screen edge padding | `md` | 16px | `Padding(padding: AppSpacing.screenPadding)` |
| Between cards | `md` | 16px | `SizedBox(height: 16)` |
| Card internal padding | `md` | 16px | `Padding(padding: AppSpacing.cardPadding)` |
| Between list items | `sm` | 8px | Divider or SizedBox |
| Icon to text gap | `sm` | 8px | `Row` with `SizedBox(width: 8)` |
| Between form fields | `md` | 16px | `SizedBox(height: 16)` |
| Section header to content | `sm` | 8px | `SizedBox(height: 8)` |
| Between action buttons | `sm` | 8px | `Row` with `SizedBox(width: 8)` |
| Modal content padding | `lg` | 24px | `Padding(padding: EdgeInsets.all(24))` |
| Bottom nav to content | `xl` | 32px | Account for FAB overlap |

### 4.3 Border Radius

```dart
// lib/theme/app_radius.dart

class AppRadius {
  static const double xs = 4.0;   // Chips, small elements
  static const double sm = 8.0;   // Buttons, inputs
  static const double md = 12.0;  // Cards
  static const double lg = 16.0;  // Modals, bottom sheets
  static const double xl = 24.0;  // Large containers
  static const double full = 999.0; // Circular (badges)
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(full));
  static const BorderRadius modalRadius = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
}
```

---

## 5. Iconography

### 5.1 Icon Set

Use **Material Icons** (bundled with Flutter). No external icon packages needed.

### 5.2 Icon Size Scale

| Size | Value | Usage |
|------|-------|-------|
| Small | 16px | Inline with text |
| Default | 24px | List items, buttons |
| Medium | 32px | Card headers |
| Large | 48px | Empty states, success screens |
| Hero | 64px | Major states (success checkmark) |

### 5.3 Category Icons

| Category | Icon | Code |
|----------|------|------|
| Utilities | ⚡ Bolt | `Icons.bolt` |
| Insurance | 🛡️ Shield | `Icons.shield` |
| Subscriptions | 📺 Subscriptions | `Icons.subscriptions` |
| Other | 📄 Receipt | `Icons.receipt_long` |

### 5.4 Action Icons

| Action | Icon | Code |
|--------|------|------|
| Back | ← Arrow Back | `Icons.arrow_back` |
| Settings | ⚙️ Settings | `Icons.settings` |
| Edit | ✏️ Edit | `Icons.edit` |
| Delete | 🗑️ Delete | `Icons.delete` |
| Add | + Add | `Icons.add` |
| Close | ✕ Close | `Icons.close` |
| Check | ✓ Check | `Icons.check` |
| Info | ℹ️ Info | `Icons.info_outline` |
| Warning | ⚠️ Warning | `Icons.warning_amber` |
| Error | ❌ Error | `Icons.error` |
| Calendar | 📅 Calendar | `Icons.calendar_today` |
| Money | 💵 Payment | `Icons.payment` |
| Person | 👤 Person | `Icons.person` |
| Phone | 📞 Phone | `Icons.phone` |
| Location | 📍 Location | `Icons.location_on` |
| Schedule | ⏰ Schedule | `Icons.schedule` |
| Lightbulb | 💡 Tip | `Icons.lightbulb_outline` |
| Fingerprint | 👆 Biometric | `Icons.fingerprint` |
| Home | 🏠 Home | `Icons.home` |
| List | 📋 List | `Icons.receipt` |

### 5.5 Status Icons

| Status | Icon | Color | Code |
|--------|------|-------|------|
| Pending | ○ Circle | Warning | `Icons.circle_outlined` |
| Scheduled | ⏰ Schedule | Scheduled | `Icons.schedule` |
| Paid | ✓ Check Circle | Success | `Icons.check_circle` |
| Queued | ⏳ Hourglass | Info | `Icons.hourglass_empty` |
| Overdue | ⚠️ Warning | Error | `Icons.warning` |

### 5.6 Icon Implementation

```dart
// Category icon helper
Widget getCategoryIcon(String category, {double size = 24}) {
  IconData iconData;
  Color color;
  
  switch (category) {
    case 'Utilities':
      iconData = Icons.bolt;
      color = Colors.amber;
      break;
    case 'Insurance':
      iconData = Icons.shield;
      color = Colors.blue;
      break;
    case 'Subscriptions':
      iconData = Icons.subscriptions;
      color = Colors.purple;
      break;
    default:
      iconData = Icons.receipt_long;
      color = Colors.grey;
  }
  
  return Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: AppRadius.cardRadius,
    ),
    child: Icon(iconData, size: size, color: color),
  );
}
```

---

## 6. Component Library

### 6.1 Buttons

#### Primary Button
**Usage:** Main actions (Pay Now, Confirm, Save)

```dart
// lib/widgets/primary_button.dart

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    AppSpacing.horizontalSM,
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Usage
PrimaryButton(
  label: 'Confirm Payment',
  onPressed: () => handlePayment(),
)

PrimaryButton(
  label: 'Pay Now',
  icon: Icons.payment,
  onPressed: () => handlePayment(),
)

PrimaryButton(
  label: 'Saving...',
  isLoading: true,
  onPressed: null,
)
```

#### Secondary Button
**Usage:** Alternative actions (Cancel, Schedule, View Details)

```dart
// lib/widgets/secondary_button.dart

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              AppSpacing.horizontalSM,
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Usage
SecondaryButton(
  label: 'Cancel',
  onPressed: () => Navigator.pop(context),
)

SecondaryButton(
  label: 'Schedule for Feb 19',
  icon: Icons.schedule,
  onPressed: () => handleSchedule(),
)
```

#### Destructive Button
**Usage:** Dangerous actions (Delete Bill)

```dart
// lib/widgets/destructive_button.dart

class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  
  const DestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, size: 20),
            AppSpacing.horizontalSM,
            Text(label),
          ],
        ),
      ),
    );
  }
}

// Usage
DestructiveButton(
  label: 'Delete Bill',
  onPressed: () => showDeleteConfirmation(),
)
```

#### Text Button
**Usage:** Tertiary actions, links

```dart
TextButton(
  onPressed: () {},
  child: Text('View Audit Log →'),
)
```

### 6.2 Cards

#### Bill Card (List Item)
**Usage:** Bill List screen, Upcoming Bills on Home

```dart
// lib/widgets/bill_card.dart

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback onTap;
  
  const BillCard({
    super.key,
    required this.bill,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              // Category Icon
              getCategoryIcon(bill.category),
              AppSpacing.horizontalMD,
              
              // Bill Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.payeeName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalXS,
                    Text(
                      'Due ${Formatters.formatDate(bill.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Amount + Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(bill.amount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalXS,
                  StatusBadge(status: bill.status, dueDate: bill.dueDate),
                ],
              ),
              
              AppSpacing.horizontalSM,
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Info Card
**Usage:** Quick stats, summary information

```dart
// lib/widgets/info_card.dart

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  
  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: AppRadius.cardRadius,
                ),
                child: Icon(icon, color: cardColor, size: 24),
              ),
              AppSpacing.horizontalMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage
InfoCard(
  title: 'Current Balance',
  value: '\$2,800.00',
  icon: Icons.account_balance_wallet,
  color: AppColors.success,
  onTap: () => navigateToCashflow(),
)
```

### 6.3 Status Badge

```dart
// lib/widgets/status_badge.dart

class StatusBadge extends StatelessWidget {
  final String status;
  final DateTime dueDate;
  
  const StatusBadge({
    super.key,
    required this.status,
    required this.dueDate,
  });
  
  @override
  Widget build(BuildContext context) {
    final config = _getBadgeConfig();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: AppRadius.badgeRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.icon != null) ...[
            Icon(config.icon, size: 12, color: config.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            config.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: config.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  _BadgeConfig _getBadgeConfig() {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    
    // Check for overdue first
    if (status == 'Pending' && daysUntilDue < 0) {
      return _BadgeConfig(
        label: 'OVERDUE',
        backgroundColor: AppColors.errorLight,
        textColor: AppColors.error,
        icon: Icons.warning,
      );
    }
    
    switch (status) {
      case 'Paid':
        return _BadgeConfig(
          label: 'PAID',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.success,
          icon: Icons.check,
        );
      case 'Scheduled':
        return _BadgeConfig(
          label: 'SCHEDULED',
          backgroundColor: AppColors.scheduledLight,
          textColor: AppColors.scheduled,
          icon: Icons.schedule,
        );
      case 'Queued':
        return _BadgeConfig(
          label: 'QUEUED',
          backgroundColor: AppColors.infoLight,
          textColor: AppColors.info,
          icon: Icons.hourglass_empty,
        );
      case 'Pending':
        if (daysUntilDue <= 3) {
          return _BadgeConfig(
            label: 'DUE SOON',
            backgroundColor: AppColors.warningLight,
            textColor: AppColors.warning,
            icon: null,
          );
        } else if (daysUntilDue <= 7) {
          return _BadgeConfig(
            label: '$daysUntilDue DAYS',
            backgroundColor: AppColors.infoLight,
            textColor: AppColors.info,
            icon: null,
          );
        }
        return _BadgeConfig(
          label: 'PENDING',
          backgroundColor: AppColors.surfaceVariant,
          textColor: AppColors.textSecondary,
          icon: null,
        );
      default:
        return _BadgeConfig(
          label: status.toUpperCase(),
          backgroundColor: AppColors.surfaceVariant,
          textColor: AppColors.textSecondary,
          icon: null,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  
  _BadgeConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });
}
```

### 6.4 Warning Banner

```dart
// lib/widgets/warning_banner.dart

enum WarningType { warning, error, info, maintenance }

class WarningBanner extends StatelessWidget {
  final WarningType type;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  
  const WarningBanner({
    super.key,
    required this.type,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.iconColor, size: 20),
              AppSpacing.horizontalSM,
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: config.iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          if (message != null) ...[
            AppSpacing.verticalSM,
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            AppSpacing.verticalSM,
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: config.iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  _WarningConfig _getConfig() {
    switch (type) {
      case WarningType.warning:
        return _WarningConfig(
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          icon: Icons.warning_amber,
        );
      case WarningType.error:
        return _WarningConfig(
          backgroundColor: AppColors.errorLight,
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          icon: Icons.error_outline,
        );
      case WarningType.info:
        return _WarningConfig(
          backgroundColor: AppColors.infoLight,
          borderColor: AppColors.info,
          iconColor: AppColors.info,
          icon: Icons.info_outline,
        );
      case WarningType.maintenance:
        return _WarningConfig(
          backgroundColor: AppColors.maintenanceLight,
          borderColor: AppColors.maintenance,
          iconColor: AppColors.maintenance,
          icon: Icons.engineering,
        );
    }
  }
}

class _WarningConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  
  _WarningConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });
}

// Usage Examples
WarningBanner(
  type: WarningType.warning,
  title: 'Low Balance Risk',
  message: 'Paying this may leave you with less than your safety buffer (\$500).',
  actionLabel: 'Proceed Anyway',
  onAction: () => proceedWithPayment(),
  onDismiss: () => dismissWarning(),
)

WarningBanner(
  type: WarningType.info,
  title: 'Unusual Amount',
  message: 'This bill is 63% higher than usual (\$89). Please verify.',
  actionLabel: 'I Verified, Proceed',
  onAction: () => acknowledgeAnomaly(),
)

WarningBanner(
  type: WarningType.maintenance,
  title: 'Maintenance Mode Active',
  message: 'Service resumes at 6:00 AM. You can queue payments.',
  onAction: null,
)
```

### 6.5 AI Recommendation Panel

```dart
// lib/widgets/recommendation_panel.dart

class RecommendationPanel extends StatelessWidget {
  final String recommendation;
  final String rationale;
  final VoidCallback onAccept;
  final VoidCallback? onDismiss;
  
  const RecommendationPanel({
    super.key,
    required this.recommendation,
    required this.rationale,
    required this.onAccept,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.info.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              AppSpacing.horizontalSM,
              Text(
                'AI Recommendation',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.textSecondary,
                ),
            ],
          ),
          
          AppSpacing.verticalMD,
          
          // Recommendation
          Text(
            recommendation,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          AppSpacing.verticalSM,
          
          // Rationale
          Text(
            rationale,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          AppSpacing.verticalMD,
          
          // Action Button
          PrimaryButton(
            label: recommendation.contains('Schedule') 
                ? 'Schedule Payment' 
                : 'Pay Now',
            icon: recommendation.contains('Schedule') 
                ? Icons.schedule 
                : Icons.payment,
            onPressed: onAccept,
          ),
          
          AppSpacing.verticalSM,
          
          // Disclaimer
          Text(
            'This is a suggestion. You decide what\'s best for your finances.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textHint,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Usage
RecommendationPanel(
  recommendation: 'Schedule for Feb 19 (payday)',
  rationale: 'Paying now leaves only \$620 before your rent is due on Feb 16. Waiting until payday keeps a healthy \$1,420 buffer.',
  onAccept: () => schedulePayment(DateTime.parse('2026-02-19')),
  onDismiss: () => dismissRecommendation(),
)
```

### 6.6 Form Inputs

#### Text Input

```dart
// lib/widgets/app_text_field.dart

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpacing.verticalXS,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textHint,
            ),
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: AppSpacing.inputPadding,
          ),
        ),
      ],
    );
  }
}

// Usage
AppTextField(
  label: 'Payee Name',
  hint: 'Enter payee name (e.g., ComEd)',
  controller: payeeController,
  maxLength: 50,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Payee name is required';
    }
    return null;
  },
)
```

#### Currency Input

```dart
// lib/widgets/currency_input.dart

class CurrencyInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<double>? onChanged;
  
  const CurrencyInput({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: '0.00',
      controller: controller,
      errorText: errorText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefix: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Text(
          '\$',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onChanged: (value) {
        final amount = double.tryParse(value) ?? 0;
        onChanged?.call(amount);
      },
    );
  }
}

// Usage
CurrencyInput(
  label: 'Amount',
  controller: amountController,
  onChanged: (amount) => setState(() => billAmount = amount),
)
```

#### Date Picker

```dart
// lib/widgets/date_picker_field.dart

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? errorText;
  
  const DatePickerField({
    super.key,
    required this.label,
    this.selectedDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    this.errorText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpacing.verticalXS,
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: AppRadius.inputRadius,
          child: Container(
            width: double.infinity,
            padding: AppSpacing.inputPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: errorText != null ? AppColors.error : AppColors.outline,
              ),
              borderRadius: AppRadius.inputRadius,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                AppSpacing.horizontalSM,
                Text(
                  selectedDate != null
                      ? Formatters.formatDate(selectedDate!)
                      : 'Select date',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          AppSpacing.verticalXS,
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      onDateSelected(picked);
    }
  }
}

// Usage
DatePickerField(
  label: 'Due Date',
  selectedDate: dueDate,
  firstDate: DateTime.now(),
  onDateSelected: (date) => setState(() => dueDate = date),
)
```

#### Dropdown

```dart
// lib/widgets/app_dropdown.dart

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  
  const AppDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpacing.verticalXS,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.outline),
            borderRadius: AppRadius.inputRadius,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              hint: Text(
                hint ?? 'Select',
                style: TextStyle(color: AppColors.textHint),
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ),
      ],
    );
  }
}

// Usage
AppDropdown<String>(
  label: 'Category',
  value: selectedCategory,
  items: const [
    DropdownMenuItem(value: 'Utilities', child: Text('Utilities')),
    DropdownMenuItem(value: 'Insurance', child: Text('Insurance')),
    DropdownMenuItem(value: 'Subscriptions', child: Text('Subscriptions')),
    DropdownMenuItem(value: 'Other', child: Text('Other')),
  ],
  onChanged: (value) => setState(() => selectedCategory = value),
)
```

### 6.7 Bottom Navigation

```dart
// lib/widgets/app_bottom_nav.dart

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black26,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Bills',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
```

### 6.8 Floating Action Button

```dart
// Usage in scaffold
Scaffold(
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => context.push('/add-bill'),
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    icon: const Icon(Icons.add),
    label: const Text('Add Bill'),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
)

// Simple FAB variant
FloatingActionButton(
  onPressed: () => context.push('/add-bill'),
  backgroundColor: AppColors.primary,
  foregroundColor: AppColors.onPrimary,
  child: const Icon(Icons.add),
)
```

### 6.9 Modal / Dialog

```dart
// lib/widgets/confirmation_dialog.dart

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;
  
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    required this.onConfirm,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelLabel,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
  
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
      ),
    );
  }
}

// Usage
ConfirmationDialog.show(
  context: context,
  title: 'Delete Bill?',
  message: 'This action cannot be undone. Are you sure you want to delete this bill?',
  confirmLabel: 'Delete',
  cancelLabel: 'Keep',
  isDestructive: true,
  onConfirm: () => deleteBill(),
)
```

### 6.10 Empty State

```dart
// lib/widgets/empty_state.dart

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textDisabled,
            ),
            AppSpacing.verticalMD,
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              AppSpacing.verticalSM,
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.verticalLG,
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Usage
EmptyState(
  icon: Icons.receipt_long,
  title: 'No bills yet',
  message: 'Add your first bill to get started with payment reminders.',
  actionLabel: 'Add Bill',
  onAction: () => context.push('/add-bill'),
)
```

### 6.11 Loading State

```dart
// lib/widgets/loading_state.dart

class LoadingState extends StatelessWidget {
  final String? message;
  
  const LoadingState({super.key, this.message});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          if (message != null) ...[
            AppSpacing.verticalMD,
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Usage
LoadingState(message: 'Loading bills...')
```

### 6.12 Toast / Snackbar

```dart
// lib/utils/toast.dart

class Toast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(config.icon, color: Colors.white, size: 20),
            AppSpacing.horizontalSM,
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: config.color,