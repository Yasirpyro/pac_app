# Agent 2 — Database / Models / DAOs (SQLite)

## Role
You are the **data layer engineer**. You implement the full local SQLite storage, models, and DAOs exactly as specified in documentation.

## Primary Objective
Deliver a stable, seeded SQLite database with DAOs used by the app, including reset capability and basic query helpers for recommendations, safety checks, and audit logging.

## Inputs (Must Read)
- `docs/PAC_BackendStructure_v1.0.md`
- `docs/PAC_PRD_v1.0.md` (Data Model section)
- `docs/PAC_ImplementationPlan_v1.0.md`

## Scope (You Own)
### Files/Areas you MAY create/modify
- `lib/data/database/database_helper.dart`
- `lib/data/database/migrations/*` (optional placeholder)
- `lib/data/database/dao/*.dart`
- `lib/data/models/*.dart`
- `lib/core/constants/database_constants.dart` (if needed)

### Files/Areas you MUST NOT modify
- Routing/app shell (`lib/app.dart`, `lib/router/*`) — Agent 1
- Widgets — Agent 3
- Screens/providers — Agents 4/6/7
- AI logic — Agent 5

## Non-Goals
- No UI
- No Provider implementations
- No external backend/cloud sync

## Hard Requirements
1. **Tables** (must match docs):
   - `bills`
   - `payments`
   - `audit_logs`
   - `cashflow_inputs` (single row, id=1)
   - `settings` (single row, id=1)
   - `bill_history`
2. **Constraints & indexes** as documented.
3. **Seed demo data** on first create:
   - 5 demo bills (with due dates relative to today)
   - bill_history rows for at least 2 payees
   - initial audit log row: `system_init`
4. **Reset function** clears data and reseeds.
5. **Date format** stored as `YYYY-MM-DD` strings for due/scheduled dates.

## DAO Minimum API (Must Implement)
### BillDao
- insertBill, getBillById, getAllBills
- getBillsByStatus
- getBillsDueWithinDays(days)
- getBillsNeedingAttention()
- getOverdueBills()
- updateBill, updateBillStatus
- deleteBill
- getBillCount
- getTotalPendingAmount

### PaymentDao
- insertPayment
- getPaymentByBillId
- getPaymentByReferenceId
- getScheduledPayments
- getQueuedPayments
- getTotalScheduledForDate(date)

### SettingsDao
- getSettings
- setMaintenanceMode
- setDemoMode
- setDailyPaymentCap
- setNotificationsEnabled
- isMaintenanceMode
- isDemoMode

### CashflowDao
- getCashflowInputs
- updateCashflowInputs
- updateBalance / updatePayday / updateSafetyBuffer

### BillHistoryDao
- getAverageAmountForPayee
- getLastThreeAmounts
- checkForAnomaly(payeeName, currentAmount)

### AuditLogDao
- log(actionType, referenceId?, details?, userNote?)
- getAllLogs(limit/offset)

## Definition of Done (Acceptance Checklist)
- [ ] DB initializes with no errors (foreign keys enabled)
- [ ] Seed creates 5 bills + history + initial audit log
- [ ] `resetDatabase()` works and reseeds
- [ ] DAO methods return expected results
- [ ] No UI dependencies inside data layer
- [ ] Unit tests optional, but at least manual smoke verified via print/log

## Implementation Guidance
- Use singleton `DatabaseHelper.instance`.
- Ensure `PRAGMA foreign_keys = ON`.
- Use `toMap()` / `fromMap()` for each model.
- Keep DB version = 1 for hackathon unless migrations needed.
- Do not over-engineer repository pattern; DAOs are sufficient for MVP.

## Output Requirements
- Keep code deterministic and stable.
- Avoid changes outside `lib/data/**` and DB constants.
- Provide clear method names exactly as used in docs.