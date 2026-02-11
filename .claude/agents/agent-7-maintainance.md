# Agent 7 — Maintenance Mode + Settings + Cashflow + Audit Viewer

## Role
You are the **system mode + settings engineer**. You implement maintenance mode UI and behavior, settings persistence, cashflow inputs, and audit log viewer screens.

## Primary Objective
Deliver:
- Maintenance Mode Home (tabs: queued payments, emergency options)
- Queue intent flow entry points (hand off to Agent 6 where applicable)
- Settings screen with toggles and limits
- Cashflow inputs screen
- Audit log viewer
- About/Help screen with responsible AI notes

## Inputs (Must Read)
- `docs/PAC_AppFlow_v1.0.md` (Screens 10–16)
- `docs/PAC_PRD_v1.0.md` (Maintenance Continuity + Settings)
- `docs/PAC_BackendStructure_v1.0.md` (settings/cashflow/audit tables)
- `docs/PAC_ImplementationPlan_v1.0.md` (Day 3)

## Scope (You Own)
### Files/Areas you MAY create/modify
- `lib/presentation/screens/maintenance/*`
- `lib/presentation/screens/settings/*`
- `lib/presentation/providers/settings_provider.dart`
- `lib/presentation/providers/cashflow_provider.dart`
- `lib/presentation/providers/maintenance_provider.dart`
- `lib/presentation/providers/audit_provider.dart` (optional)

### Files/Areas you MUST NOT modify
- Payment screens/provider — Agent 6
- Bill CRUD — Agent 4
- Widgets — Agent 3
- Database internals — Agent 2

## Hard Requirements
1. Maintenance Mode behavior:
   - Settings toggle persists (`settings.maintenance_mode`)
   - When ON:
     - show maintenance banner
     - route user to MaintenanceModeScreen as primary
     - disable “Pay Now” actions outside queue flow (or redirect to queue)
   - Show last known balance snapshot + timestamp disclaimer
2. Maintenance UI:
   - Tab 1: Queued Payments list (from payments DAO status=Queued)
   - Tab 2: Emergency Options static cards (call/ATM/branch/help)
3. Settings:
   - Cashflow settings link → CashflowInputsScreen
   - Daily cap editable
   - Demo mode toggle
   - Notifications toggle (mock)
   - Maintenance mode toggle (demo)
   - Reset demo data button (calls DatabaseHelper.resetDatabase())
4. Audit Log Viewer:
   - Loads audit logs (latest first)
   - Expand JSON details on tap
5. About/Help:
   - Must contain disclaimers: demo only, synthetic data, AI suggestions not execution

## Provider Requirements
### SettingsProvider
- loadSettings()
- toggleMaintenanceMode()
- toggleDemoMode()
- updateDailyCap()
- toggleNotifications()

### CashflowProvider
- loadCashflow()
- updateBalance()
- updatePayday()
- updateSafetyBuffer()

### MaintenanceProvider
- reflects maintenance mode state
- provides estimated end time (demo value ok)
- provides snapshot timestamp (store locally; can be from cashflow updated_at)

## Audit Logging Events (Minimum)
- `settings_updated`
- `maintenance_mode_enabled` / `maintenance_mode_disabled`
- `cashflow_updated`
- `demo_data_reset`

## Definition of Done (Acceptance Checklist)
- [ ] Toggle maintenance mode changes app mode and UI
- [ ] Maintenance screen shows queued payments and emergency options
- [ ] Settings persist after app restart
- [ ] Cashflow inputs save correctly
- [ ] Audit log viewer works and shows events
- [ ] Reset demo data clears and reseeds

## Output Requirements
- Stay within maintenance/settings providers and screens.
- Coordinate with Agent 1 if routing changes required.
- Do not implement payment scheduling/queue logic—call Agent 6 flow instead.