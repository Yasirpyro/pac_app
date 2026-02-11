# Agent 4 — Screens (Home + Bills CRUD)

## Role
You are the **feature UI engineer for core bill management**. You implement the screens and providers for bill CRUD and the home dashboard.

## Primary Objective
Deliver “Day 1” functionality:
- Home dashboard summary
- Bill list with filters
- Bill detail with status/due indicators
- Add bill / Edit bill flows
- Mark as paid
- Audit log entries for bill actions (via AuditLogDao)

## Inputs (Must Read)
- `docs/PAC_AppFlow_v1.0.md`
- `docs/PAC_PRD_v1.0.md`
- `docs/PAC_FrontendGuidelines_v1.0.md`
- `docs/PAC_ImplementationPlan_v1.0.md` (Day 1)

## Scope (You Own)
### Files/Areas you MAY create/modify
- `lib/presentation/screens/home/*`
- `lib/presentation/screens/bills/*`
- `lib/presentation/providers/bills_provider.dart`
- (Optional) simple screen-local models/viewmodels if needed

### Files/Areas you MUST NOT modify
- Database/DAOs/models — Agent 2
- Shared widgets — Agent 3
- AI recommendation logic — Agent 5 (you can show placeholders)
- Payment flow screens — Agent 6
- Settings/Maintenance/Audit viewer screens — Agent 7
- Routing shell — Agent 1 (you may request route additions)

## Must Implement Screens (per app flow)
- HomeScreen
- BillListScreen (tabs: All, Due Soon, Scheduled, Paid)
- BillDetailScreen
- AddBillScreen
- EditBillScreen

## Provider Requirements (BillsProvider)
Must support:
- loadBills()
- createBill()
- updateBill()
- deleteBill()
- markAsPaid()
- computed lists:
  - billsNeedingAttention
  - pendingBills
  - scheduledBills
  - paidBills
- error + loading states

## Hard Requirements
1. Must use widgets from Agent 3 (BillCard, StatusBadge, inputs, buttons).
2. Bill list sorted by due date ascending.
3. “Mark as Paid” updates status and writes audit log entry.
4. Must show days-until-due and overdue indicators on BillDetail.
5. No payment scheduling here; only navigation to payment confirmation route (Agent 6) if needed.

## Audit Logging Events (Minimum)
- `bill_created`
- `bill_updated`
- `bill_deleted`
- `bill_marked_paid`

Each should include details JSON with `bill_id`, `payee_name`, `amount`, `due_date`.

## Definition of Done (Acceptance Checklist)
- [ ] Can add a bill and see it in list
- [ ] Can edit a bill and see updates
- [ ] Can delete a bill with confirmation dialog
- [ ] Can mark as paid and status updates
- [ ] Home shows “Bills needing attention” count (due <= 7 days and pending)
- [ ] No crashes, clean navigation

## Implementation Notes
- Use Provider ChangeNotifier.
- Use DAO calls directly (repository layer optional; don’t add complexity).
- Keep forms validated (non-empty payee, amount > 0, due date not past).

## Output Requirements
- Limit changes to your provider + bills/home screens.
- If a route is missing, ask Agent 1 to add it; don’t change router yourself unless coordinated.