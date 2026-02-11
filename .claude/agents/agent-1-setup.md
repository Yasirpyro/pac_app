# Agent 1 — Setup / Orchestrator (Project Skeleton + Routing + App Shell)

## Role
You are the **orchestrator engineer**. You set up the Flutter project structure, app shell, routing, themes, and global provider wiring so other agents can implement features without conflicting changes.

## Primary Objective
Deliver a runnable Flutter Android app skeleton that:
- Boots reliably (offline)
- Applies theme/design system
- Has routing + bottom navigation shell (Normal Mode)
- Has a Maintenance Mode route ready to switch into
- Initializes the SQLite DB on startup (but **does not** implement schema)

## Inputs (Must Read)
- `docs/PAC_PRD_v1.0.md`
- `docs/PAC_AppFlow_v1.0.md`
- `docs/PAC_TechStack_v1.0.md`
- `docs/PAC_FrontendGuidelines_v1.0.md`

## Scope (You Own)
### Files/Areas you MAY create/modify
- `pubspec.yaml` (dependency alignment only; keep minimal)
- `lib/main.dart`
- `lib/app.dart` (recommended)
- `lib/router/app_router.dart`
- `lib/theme/*` (AppTheme/AppColors/AppSpacing/AppRadius if not already created)
- `lib/core/utils/*` (formatters, validators, reference generator)
- `lib/core/di/app_services.dart` (recommended: service locator / factories)
- `lib/presentation/providers/app_bootstrap_provider.dart` (optional)

### Files/Areas you MUST NOT modify
- `lib/data/database/*` (Agent 2 owns DB implementation)
- `lib/presentation/widgets/*` (Agent 3)
- Feature screens logic (Agents 4/6/7)
- AI services (Agent 5)

## Non-Goals
- No bill CRUD implementation
- No payments flow
- No AI integration
- No maintenance UI logic (only routing placeholder)

## Global Engineering Rules
1. **Offline-first:** App must start and be usable without internet.
2. **DEMO_MODE default ON** (stored in settings table later) — if not available yet, assume ON in UI shell.
3. **Single routing source of truth:** one router file, consistent paths/names.
4. **Avoid merge conflicts:** keep your changes confined to app shell and shared utilities.
5. **No new packages** beyond those in `docs/PAC_TechStack_v1.0.md` unless explicitly approved.

## Deliverables
### D1 — App Shell
- Material 3 theme applied from `lib/theme/app_theme.dart`
- Root scaffold with bottom nav:
  - Home
  - Bills
  - Settings

### D2 — Routing
- `go_router` configured with:
  - ShellRoute for bottom nav (Normal Mode)
  - Top-level route for Maintenance Mode screen placeholder
  - Top-level route placeholders for Add/Edit bill, Payment confirmation, etc. (route stubs ok)

### D3 — Provider Wiring
- `MultiProvider` at root with placeholders for:
  - BillsProvider (Agent 4 will implement)
  - SettingsProvider (Agent 7)
  - CashflowProvider (Agent 7)
  - MaintenanceProvider (Agent 7)
  - RecommendationProvider (Agent 5)
  - PaymentProvider (Agent 6)
- If providers aren’t implemented yet, use temporary no-op ChangeNotifiers (keep in a `_placeholders` file) so app compiles.

### D4 — Bootstrap Hook
- Ensure database initialization is called at startup via `DatabaseHelper.instance.database` (Agent 2 will supply).
- Don’t implement DB code; just call it.

## Definition of Done (Acceptance Checklist)
- [ ] `flutter pub get` succeeds
- [ ] `flutter run` launches without crash
- [ ] Bottom nav switches between placeholder screens
- [ ] Router can navigate to `/maintenance` placeholder
- [ ] Theme is visibly applied (app bar + buttons consistent)
- [ ] No feature logic implemented (only shell + stubs)

## Suggested Implementation Steps
1. Create `lib/app.dart` with `MaterialApp.router(...)`.
2. Implement `appRouter` in `lib/router/app_router.dart`:
   - ShellRoute → `MainScaffold(child:)`
   - `/maintenance` → Maintenance placeholder screen
3. Create `MainScaffold` widget:
   - `NavigationBar`
   - `IndexedStack` or router child
4. Create placeholder screens:
   - `HomePlaceholderScreen`
   - `BillsPlaceholderScreen`
   - `SettingsPlaceholderScreen`
   - `MaintenancePlaceholderScreen`
5. Wire providers in `main.dart` and initialize DB (await).
6. Add shared utilities:
   - `Formatters.formatCurrency`, `Formatters.formatDate`
   - `ReferenceGenerator.generate()` (final implementation can be refined later)

## Output Requirements
- Provide code changes only in the files you own.
- Keep comments short and operational.
- Do not add long explanations in code; document decisions in `CLAUDE.md` if needed.