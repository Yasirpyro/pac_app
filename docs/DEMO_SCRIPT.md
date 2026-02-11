# PAC Hackathon Demo Script

**Target Duration:** 3-4 minutes
**Theme:** "Resilience in Banking" - How PAC ensures payment continuity even during outages.

## 📱 Phase 1: The "Happy Path" (Normal Operation)
**Goal:** Show AI assisting with financial decisions.

1.  **Launch App**: Open PAC App. Dashboard loads.
2.  **Cashflow Insight**: Point out the "Safe to Spend" indicator.
    *   *Script:* "PAC doesn't just show balance; it calculates what's actually safe to spend after bills."
3.  **Bill Payment**:
    *   Tap a "Pending" bill (e.g., ComEd Electric).
    *   **AI Recommendation**: Show the "Pay Now" vs "Schedule" suggestion.
    *   *Action:* Select "Pay Now".
    *   *Result:* Biometric simulated (FaceID icon), Payment Success screen.

## 🛠️ Phase 2: The "Chaos" (Maintenance Mode)
**Goal:** Demonstrate the core hackathon value proposition—reliability.

1.  **Trigger Outage**:
    *   Go to **Settings**.
    *   Toggle **Maintenance Mode** ON.
    *   *Visual:* App theme changes (Orange banner appears), navigation restricted.
2.  **Attempt Action**:
    *   Try to navigate to "Bills".
    *   *Result:* Redirected back to Maintenance Dashboard.
    *   *Script:* "During a bank outage, standard apps crash or block you. PAC enters a resilient 'Read-Only' state."

## 🚀 Phase 3: The "Deep Link" (The Wow Moment)
**Goal:** Show how PAC captures intent from external triggers (SMS/Email) even when the system is down.

1.  **Scenario**: "Imagine the user receives an urgent SMS from a utility provider saying a bill is overdue."
2.  **Action**:
    *   Run `scripts/simulate_sms.bat` on your laptop.
    *   *Or manually via ADB:* `adb shell am start -W -a android.intent.action.VIEW -d "pac://procom26/maintenance/queue/1" com.procom26.pac_app`
3.  **Result**:
    *   App opens directly to the **Queue Payment** screen (bypassing the restriction).
    *   *Visual:* "Payment Intent Only" warning banner.
4.  **Queue It**:
    *   Tap "Queue This Payment".
    *   *Result:* Success toast.
5.  **Verify**:
    *   Show "Queued Payments" tab in Maintenance Dashboard.
    *   *Script:* "The payment isn't lost. It's securely queued locally and will auto-execute when the bank comes back online."

## 🏁 Phase 4: Audit & Wrap-up
1.  **Transparency**:
    *   Go to Settings -> Audit Log.
    *   Show the "Payment Queued" entry.
2.  **Closing**: "PAC turns a 'Service Unavailable' error into a 'Payment Assurance' promise."
