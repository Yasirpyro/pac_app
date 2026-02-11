# Agent 6 — Payment Flow (Confirmation + Mock Auth + Success + Persistence)

## Role
You are the **payments flow engineer**. You implement the simulated scheduling/queue flow with authentication UX, DB updates, and audit logging.

## Primary Objective
Deliver end-to-end flow:
Bill Detail → Payment Confirmation → Auth Modal → Success screen,
with correct behavior in:
- Normal mode: status `Scheduled`
- Maintenance mode: status `Queued` (intent only)

## Inputs (Must Read)
- `docs/PAC_AppFlow_v1.0.md` (Screens 7–9)
- `docs/PAC_PRD_v1.0.md` (Payment Flow requirements)
- `docs/PAC_BackendStructure_v1.0.md` (payments table, audit log)
- `docs/PAC_ImplementationPlan_v1.0.md` (Day 3)

## Scope (You Own)
### Files/Areas you MAY create/modify
- `lib/presentation/screens/payment/*`
- `lib/presentation/screens/auth/auth_modal.dart`
- `lib/presentation/providers/payment_provider.dart`
- `lib/data/services/auth_service.dart`
- `lib/core/utils/reference_generator.dart` (if missing; coordinate with Agent 1)
- Any payment-specific widgets if necessary (but prefer Agent 3 widgets)

### Files/Areas you MUST NOT modify
- Bill CRUD screens — Agent 4
- Settings/Maintenance screens — Agent 7 (you consume maintenance flag)
- Database implementation — Agent 2

## Hard Requirements
1. Confirmation screen must show:
   - Payee, amount, selected date
   - Impact preview: new balance (synthetic)
   - Warnings (from SafetyCheckService if available)
   - Demo disclaimer: “Simulated payment; no real funds move.”
2. Auth modal:
   - Uses `local_auth` when available
   - If device unsupported or error, **simulate success** but display “Demo auth” note
3. Persistence:
   - Insert payment row into `payments`
   - Update bill status + reference_id
   - Insert audit log entries
4. Mode logic:
   - If maintenance mode ON → queue intent (status `Queued`)
   - Else → schedule (status `Scheduled`)

## Provider API (PaymentProvider)
- `scheduleOrQueuePayment(billId, amount, date, mode) -> referenceId or error`
- `isProcessing`, `error`

## Audit Logging Events (Minimum)
- `payment_scheduled` or `payment_queued`
- `auth_completed_demo` or `auth_completed_biometric` (optional)
Details must include: bill_id, amount, scheduled_date, mode.

## Definition of Done (Acceptance Checklist)
- [ ] From BillDetail you can navigate into PaymentConfirmation
- [ ] Confirm triggers Auth modal
- [ ] Success screen shows reference ID and details
- [ ] Bill status updates accordingly
- [ ] Audit logs show payment event
- [ ] Works offline

## Output Requirements
- Confine changes to payment/auth/provider/service files.
- Do not implement maintenance mode UI here.