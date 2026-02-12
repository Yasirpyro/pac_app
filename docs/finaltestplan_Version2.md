# PAC Demo-Ready Final Implementation Plan (T-2 Hours)

**Date:** 2026-02-12  
**Goal:** Implement only the remaining demo-critical fixes without destabilizing the app.  
**Non-goals:** No refactors, no new architectures, no “nice-to-have” UI polish unless required to prevent crashes/confusion.

---

## 0) Guardrails (Do Not Break Demo Credibility)
- **Offline-first must remain functional** (DEMO_MODE safe).
- **No real payment claims:** wording must say *simulated* / *demo*.
- **No major package additions** unless already planned and required for the demo story (local notifications are allowed if already in progress).
- Every flow must end in a stable, explainable state with a clear screen the user can show on video.

---

## 1) Fix Maintenance Mode Trap + Navigation Crash

### 1.1 Symptoms to Fix
- In Maintenance Mode, user cannot return to the normal app.
- Settings button not working.
- Crash screen shows Flutter error:

`navigation_bar.dart: Failed assertion: 0 <= selectedIndex && selectedIndex < destinations.length`

This indicates **NavigationBar.selectedIndex is invalid** (often happens when you reuse the normal bottom-nav scaffold while showing a maintenance-only screen with fewer destinations or index not set).

### 1.2 Expected Behavior (for demo)
- When Maintenance Mode is ON, the app should:
  - **Show MaintenanceModeScreen** as the main screen.
  - Still allow user to open **Settings** (to turn Maintenance OFF).
  - Provide a clear **“Exit Maintenance Mode (Demo)”** action that toggles Maintenance OFF and routes back to normal Home.

### 1.3 Implementation Requirements
- **Never render the bottom NavigationBar** while in maintenance mode (or render it with a valid index and same destination count).
- Ensure Settings navigation works from MaintenanceModeScreen:
  - App bar settings icon must route to Settings.
- Fix routing so that after toggling maintenance OFF:
  - app returns to the normal shell route (Home tab) and does not crash.

### 1.4 Concrete Dev Tasks
1. **App shell / router decision point**
   - Add a single “mode gate” at app root:
     - If `settings.maintenance_mode == true` → show MaintenanceModeScreen (no bottom nav)
     - Else → show Normal ShellRoute (bottom nav)
2. **Fix NavigationBar selectedIndex crash**
   - Guarantee selectedIndex is always within `[0..destinations.length-1]`.
   - If MaintenanceModeScreen is still wrapped by MainScaffold for any reason, remove that.
3. **Settings access**
   - MaintenanceModeScreen AppBar includes settings icon → `/settings`
4. **Exit maintenance**
   - Add button/link: “Exit Maintenance Mode (Demo)”:
     - Calls `SettingsDao.setMaintenanceMode(false)`
     - Notifies providers
     - Navigates to normal Home route (replace stack)

### 1.5 Acceptance Tests (5 minutes)
- Toggle Maintenance ON in Settings → app shows MaintenanceModeScreen (no crash).
- Tap Settings icon from MaintenanceModeScreen → Settings opens.
- Tap Exit Maintenance Mode (Demo) → returns Home without crash.
- Switch tabs in normal mode → bottom nav works.

---

## 2) Show Queued Payments on Home after Maintenance Ends (Trust + Continuity)

### 2.1 Feature Definition (Developer-friendly)
When the app is back in normal mode (maintenance OFF), and there exist `payments.status == 'Queued'`:
- Home screen must show a prominent **UI box**:
  - Title: “Queued payment intents”
  - Subtitle: “You queued these during maintenance. Review and pay now (simulated) or remove.”
  - CTA: “Review queued payments”
- On CTA tap → navigate to a screen listing queued payment intents.
- From that list, user can:
  1) **Pay Now (Simulate)** → complete payment:
     - payments.status: `Queued` → `Simulated`
     - bills.status: `Queued` or `Pending` → `Paid`
  2) **Remove intent** (delete queued payment row + revert bill status):
     - delete payments row OR mark cancelled (prefer delete for speed)
     - bill.status: `Queued` → `Pending`

### 2.2 Implementation Requirements
- Add a `PaymentDao.getQueuedPayments()` query (should already exist).
- Add a small new screen OR reuse an existing screen:
  - Preferred name: **QueuedPaymentsReviewScreen**
- Ensure audit logs:
  - `queued_payment_review_opened`
  - `queued_payment_completed_simulated`
  - `queued_payment_removed`

### 2.3 UI Requirements (minimal but clear)
- Each queued item shows:
  - Payee, amount, due date, queued timestamp (if available)
  - Buttons: **Pay Now (Simulate)**, **Remove**
- Highlight urgency:
  - Overdue/due today: red/orange banner
  - Due soon: warning
  - Else: normal

### 2.4 Acceptance Tests (10 minutes)
- Create queued payment during maintenance.
- Turn maintenance OFF.
- Home shows queued payments box.
- Review screen lists queued items.
- Pay one → it disappears from queue and bill becomes Paid.
- Remove one → it disappears and bill becomes Pending.

---

## 3) Notification-Driven “Last Day / Urgent” Flow + One-Tap Pay Journey (Demo Story)

### 3.1 Demo Scenario (what must work on video)
**Today = Feb 12.** User has bills due today and/or overdue/pending.
User is outside the app and receives a notification:
- “Today is the last day for pending bills. Tap to review and pay (simulated) in one tap.”

User taps notification:
- App opens to a list of **urgent pending bills**, sorted and color-highlighted.
- User taps a bill:
  - sees AI summary/rationale + safety warnings
  - confirms pay now
  - biometric auth
  - success screen includes:
    - “View other pending payments”
    - “View balance” (synthetic cashflow)

### 3.2 Implementation Requirements
#### A) Scheduling the urgent notification
- Implement local notification scheduling for “due today / urgent” bills:
  - When a bill is due today and status is Pending/Scheduled/Queued (not Paid),
    schedule a notification for **immediate test** and for **9:00 AM** (production-like).
- For a demo in 2 hours, add a **Debug button** in Settings:
  - “Send demo urgent notification in 10 seconds”
  - This must schedule a notification containing payload `{route: '/urgent', type:'urgent_due_today'}`
  - This avoids waiting for 9:00 AM.

#### B) Notification tap routing
- On tap, route to: **UrgentBillsScreen**
  - `/urgent` route (new)
- The route must work when:
  - app is in background
  - app is terminated and launched via tap

#### C) UrgentBillsScreen behavior
- It lists bills that are:
  - status in `Pending`, `Scheduled`, `Queued`
  - and `due_date <= today`
  - OR due within 1 day (optional)
- Sorting:
  1) Overdue first
  2) Due today next
  3) Due soon next
- Visual urgency:
  - Overdue: red
  - Due today: orange
  - Due soon: yellow/info
- Each item tap → opens Bill Detail OR directly Payment Confirmation with action=payNow.
  - For demo clarity, prefer: Urgent list → Bill Detail (shows AI summary) → Pay Now.

#### D) “Pay Now” should actually mark Paid (Simulated)
- Ensure earlier fix exists:
  - Pay Now action -> bills.status = `Paid`
  - payments.status = `Simulated`
  - Not “Scheduled”.

#### E) Success screen CTAs
- Add two buttons:
  - “View other pending payments” → back to UrgentBillsScreen
  - “View balance” → CashflowInputsScreen or a simple balance dialog

### 3.3 Acceptance Tests (15 minutes)
- Create at least 2 bills due today/overdue.
- Use Settings debug button to schedule urgent notification in 10 seconds.
- Close app (swipe away).
- Notification appears.
- Tap notification → UrgentBillsScreen opens.
- Tap first urgent bill → confirm pay now → biometric → success.
- Tap “View other pending payments” → returns to urgent list with remaining items.
- Ensure audit logs contain the key actions.

---

## 4) Time-Boxed Execution Order (2 Hours)
### Phase 1 (0:00–0:25) — Stop the crash + fix maintenance navigation
- Implement mode gate at app shell/router
- Remove bottom nav from maintenance mode
- Ensure Settings accessible and Exit Maintenance works

### Phase 2 (0:25–0:55) — Queued payments surfaced post-maintenance
- Implement Home queued-intents card
- Implement QueuedPaymentsReviewScreen
- Implement Pay/Remove actions + audit logs

### Phase 3 (0:55–1:35) — Urgent notification + urgent list + one-tap path
- Add debug “send urgent notification in 10 seconds”
- Add `/urgent` route + UrgentBillsScreen
- Ensure notification tap deep links to `/urgent`

### Phase 4 (1:35–2:00) — Final polishing + rehearsal checklist
- Verify copy says “simulated”
- Run full demo script once end-to-end
- Build release APK if needed

---

## 5) Final Demo Rehearsal Checklist (Must Pass)
### Maintenance segment
- [ ] Toggle maintenance ON → maintenance screen shows (no crash)
- [ ] Queue a payment intent during maintenance
- [ ] Exit maintenance (demo) → returns home
- [ ] Home shows “Queued payment intents” box
- [ ] Review queued → pay one, remove one

### Notification segment
- [ ] Trigger urgent notification in 10 seconds
- [ ] Close app fully
- [ ] Notification appears
- [ ] Tap opens urgent list
- [ ] Urgent list highlights overdue vs due today
- [ ] Tap bill → see AI summary + safety warning (if any)
- [ ] Pay Now → biometric → success
- [ ] Success has “View other pending payments” + “View balance”

### Credibility / Responsible AI
- [ ] All screens show disclaimers where needed (simulated, demo)
- [ ] No screen implies real bank processing during maintenance
- [ ] Audit log has entries for: queued, payment completed, notification tap

---
END