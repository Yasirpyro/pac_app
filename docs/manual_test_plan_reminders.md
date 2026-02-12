# Manual Test Plan: Set Reminder Feature

## 1. Prerequisites
- App installed on Android Emulator or Device.
- Demo mode enabled (default).

## 2. Test Cases

### Case 1: Set Reminder for a Far-Future Bill (> 7 days)
1. **Navigate**: Go to "Bills" tab.
2. **Select**: Tap on "State Farm Insurance" (Due in ~10 days).
3. **Verify UI**:
   - "Set Reminder" button should be **Primary** (Filled/Blue).
   - "Pay Now" button should be **Secondary** (Outlined).
4. **Action**: Tap "Set Reminder".
5. **Interaction**:
   - Date picker appears.
   - Select a date (e.g., 2 days before due date).
   - Tap "OK".
6. **Verify Result**:
   - Toast appears: "Reminder set for [Date]".
   - Screen updates to show a blue info box: "Reminder set for [Date]".
   - **Home Screen**: "Reminders" count increases by 1.

### Case 2: Set Reminder for an Imminent Bill (< 7 days)
1. **Navigate**: Go to "Bills" tab.
2. **Select**: Tap on "ComEd Electric" (Due in ~3 days).
3. **Verify UI**:
   - "Pay Now" button should be **Primary**.
   - "Set Reminder" button should be **Secondary**.
4. **Action**: Tap "Set Reminder".
5. **Interaction**:
   - Select tomorrow's date.
   - Tap "OK".
6. **Verify Result**:
   - Reminder is set and displayed.

### Case 3: Remove a Reminder
1. **Navigate**: Go to a bill with an active reminder.
2. **Action**: Tap the "X" (Close icon) on the blue reminder info box.
3. **Verify Result**:
   - Info box disappears.
   - Toast/Feedback might not appear (silent removal is current behavior, check provider logic).
   - **Home Screen**: "Reminders" count decreases by 1.

### Case 4: Edit a Reminder
1. **Navigate**: Go to a bill with an active reminder.
2. **Action**: Tap "Set Reminder" again.
3. **Interaction**: Pick a different date.
4. **Verify Result**:
   - The blue info box updates to the new date.
   - Verify only one reminder exists for this bill (no duplicate notifications).

### Case 5: Maintenance Mode Behavior
1. **Action**: Enable Maintenance Mode in Settings.
2. **Navigate**: Go to a Bill Detail screen.
3. **Action**: Try to set a reminder.
4. **Verify Result**:
   - Should work normally (Reminders are local and don't require network/API).

## 3. Technical Verification (Optional)
- **Database**:
  - Inspect `pac_app.db` using App Inspection.
  - Verify `reminders` table has rows with correct `bill_id` and `reminder_date`.
- **Notifications**:
  - Requires waiting for the triggered time or using a simulated clock.
  - Notification title should be: "Reminder: [Payee Name]".
