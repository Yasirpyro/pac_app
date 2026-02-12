# PAC Notification System - Manual Test Plan

## 1. Setup
- Ensure the app is installed on an Android device or emulator (Android 13+ recommended).
- Ensure "Allow Notifications" permission is granted when prompted (or via App Settings).

## 2. Test Cases

### Test 1: Immediate Notification (Debug)
**Goal:** Verify notifications can appear.
1. Go to **Settings**.
2. Tap **Test Notification**.
3. **Expected:**
   - A toast appears: "Notification scheduled for 10s".
   - Wait 10 seconds.
   - A notification "Test Notification" appears in the system tray.
   - Tapping it opens the app.

### Test 2: Create Bill (Future Due Date)
**Goal:** Verify automatic scheduling.
1. Tap **Add Bill**.
2. Enter details:
   - Payee: "Future Internet"
   - Amount: $60 (Must be >= $50 for 5-day reminder)
   - Due Date: 7 days from today.
3. Save.
4. **Expected:**
   - No immediate notification.
   - In logs (if debugging): `Scheduled notification [id] for [date]`.
   - Notification should fire in 2 days (5 days before due).

### Test 3: "Due Today" Reminder
**Goal:** Verify same-day scheduling.
1. Tap **Add Bill**.
2. Enter details:
   - Payee: "Urgent Water"
   - Amount: $30
   - Due Date: Today.
3. Save.
4. **Expected:**
   - If current time is before 9:00 AM: Notification scheduled for 9:00 AM today.
   - If current time is after 9:00 AM: No notification scheduled (as per current logic "Morning of due date").
   - *Note:* To test strictly, change device time or code logic to `DateTime.now().add(Duration(minutes: 1))` for "Morning".

### Test 4: Deep Linking
**Goal:** Verify tapping notification opens payment flow.
1. Trigger **Test Notification** or wait for a scheduled bill notification.
2. *Note:* For Test Notification, payload is 'test' (just opens app).
3. To test deep link, we need a real bill notification.
   - **Hack for testing:** Edit `NotificationService.dart`:
     - Inside `scheduleNotificationsForBill`, temporarily set `scheduledDate` to `DateTime.now().add(const Duration(seconds: 15))` for the due date reminder.
   - Create a bill "Deep Link Test".
   - Close the app (remove from background).
   - Wait for notification.
   - Tap notification.
4. **Expected:**
   - App launches.
   - Immediately navigates to **Payment Confirmation** screen for that bill.

### Test 5: Editing/Deleting
**Goal:** Verify cleanup.
1. Create a bill with due date in 7 days.
2. **Edit** the bill: Change due date to 8 days.
   - **Expected:** Old notification cancelled, new one scheduled.
3. **Delete** the bill.
   - **Expected:** All notifications for this bill cancelled.
4. **Mark as Paid**.
   - **Expected:** All notifications for this bill cancelled.

### Test 6: Demo Data Reset
**Goal:** Verify system reset.
1. Go to **Settings** -> **Reset Demo Data**.
2. **Expected:**
   - All existing notifications cancelled.
   - Default demo bills loaded.
   - New notifications scheduled for the demo bills that are pending.

## 3. Troubleshooting
- **No notification?** Check Android Settings -> Apps -> PAC -> Notifications.
- **Wrong time?** Check device timezone. App defaults to local or NY fallback.
- **Crash on start?** Check `timezone` data initialization in `main.dart`.
