# PAC Day 3 Test Plan: Payment Flow & Maintenance Mode

**Objective:** Verify the end-to-end functionality of payment scheduling, safety checks, audit logging, and maintenance mode.

## 1. Normal Payment Flow
- [ ] **Pre-condition:** App has at least one "Pending" bill.
- [ ] **Action:** Tap on a Pending bill from Home or Bill List.
- [ ] **Verify:** Bill Detail screen opens. AI Recommendation panel is visible (if eligible).
- [ ] **Action:** Tap "Pay Now" or "Schedule Payment" button.
- [ ] **Verify:** Payment Confirmation screen opens.
  - Payment amount matches.
  - Balance impact is calculated correctly.
  - Safety warnings appear if balance < buffer.
- [ ] **Action:** Tap "Authenticate & Pay".
- [ ] **Verify:**
  - Biometric/Auth modal appears (or simulated delay).
  - Success screen appears with a Reference ID (e.g., `PAC-20260211-001`).
- [ ] **Action:** Tap "Done".
- [ ] **Verify:**
  - Bill status changes to "Scheduled" or "Paid" (Simulated).
  - Home screen dashboard updates (if "Pay Now", balance should decrease).

## 2. Audit Logging
- [ ] **Action:** Navigate to Settings > View Audit Log.
- [ ] **Verify:**
  - Entry exists for "Payment Scheduled" or "Payment Paid".
  - Timestamp is correct.
  - Details expand to show bill ID and amount.

## 3. Maintenance Mode
- [ ] **Action:** Navigate to Settings > Toggle "Maintenance Mode" ON.
- [ ] **Verify:**
  - Toast confirms "Maintenance mode enabled".
  - Home screen shows "Maintenance Mode" banner.
- [ ] **Action:** Try to Pay a bill (Pay Now).
- [ ] **Verify:**
  - User is redirected to Queue Payment flow OR prevented with a message.
  - (Based on implementation: logic handles Pay Now in maintenance by queueing).
- [ ] **Action:** Go to Maintenance Screen (via banner or Settings).
- [ ] **Action:** Tap "Queue Payment" (if available) or use Bill List > Pay.
- [ ] **Verify:**
  - "Queued" status is assigned instead of "Scheduled".
  - Success screen mentions "Payment Queued".
- [ ] **Action:** Navigate to Settings > Toggle "Maintenance Mode" OFF.
- [ ] **Verify:** App returns to normal state.

## 4. Settings & Data
- [ ] **Action:** Settings > Cashflow Settings.
- [ ] **Action:** Change "Safety Buffer" to $1000.
- [ ] **Verify:** Value is saved.
- [ ] **Action:** Settings > Reset Demo Data.
- [ ] **Verify:** All bills/payments are reset to initial demo state.
