# Product Requirements Document: Payment Assurance Copilot (PAC)

**Version:** 1.0  
**Owner:** Hackathon Team Alpha  
**Date:** February 10, 2026  
**Target Event:** PROCOM '26 AI in Banking Hackathon  
**Classification:** Prototype/Demo Only - Not Production

---

## 1. Executive Summary

**Payment Assurance Copilot (PAC)** is a Flutter Android prototype that addresses the dual problem of payment timing failures and service continuity gaps in consumer banking. The app uses AI-assisted decision support to help customers avoid missed utility payments through personalized reminders and cashflow-aware recommendations, while providing transparency and limited self-service during planned maintenance windows.

**Core value proposition:** Reduce late fees and service disruptions by proactively guiding payment timing decisions and maintaining visibility during system downtime.

**Non-goals:**
- ❌ Autonomous payment execution without user confirmation
- ❌ Real-time fund movement during maintenance periods
- ❌ Integration with actual bank core systems
- ❌ Production-grade ML model training or deployment
- ❌ Handling real customer data or PII
- ❌ Multi-bank account aggregation
- ❌ Credit/loan product integration

---

## 2. Problem Statement

**Root Problem:**  
Customers experience financial harm and frustration due to (a) forgetting payment deadlines and lacking cashflow awareness, and (b) inability to access banking services during planned maintenance, resulting in late fees, service cutoffs, and negative brand perception.

### Pain Scenarios

**Scenario 1: The Cashflow Blind Spot**  
Sarah has $2,800 in her account. Her electricity bill ($180) is due Friday, rent ($1,200) is due Monday, and she gets paid next Wednesday. She pays the electric bill Thursday night without checking her upcoming obligations. On Monday, her rent payment bounces, triggering a $35 NSF fee and a $75 late fee from her landlord.

**Scenario 2: The Maintenance Collision**  
Marcus knows his internet bill ($89) is due Sunday. He plans to pay it Saturday night. The bank's scheduled maintenance runs Saturday 11 PM - Sunday 6 AM. Marcus attempts to pay at 11:30 PM and gets a generic "service unavailable" error. He forgets to retry Sunday morning. His internet is suspended Monday, and he misses a critical work video call, plus incurs a $25 late fee and $50 reconnection fee.

**Scenario 3: The Forgotten Utility**  
Aisha set up autopay for most bills but manually pays her water bill quarterly. She doesn't use paper statements. The $142 water bill due date passes unnoticed because it's not in her calendar. She receives a shutoff notice 45 days later with $65 in late fees and a mandatory $150 deposit to restore service.

---

## 3. Target Users & Persona

### Primary User Segments
1. **Salaried professionals** (ages 25-45) managing 8-12 monthly bills with variable due dates
2. **Students** (ages 18-24) new to independent bill management, limited cashflow buffers
3. **Small business owners** (side hustles/freelancers) with irregular income and complex payment schedules

### Primary Persona: "Busy Salaried Customer"

**Name:** Jordan Chen  
**Age:** 32  
**Occupation:** Marketing Manager  
**Income:** $75,000/year, paid biweekly  
**Banking relationship:** Checking + savings, mobile-first user  

**Behaviors:**
- Manages 10 recurring bills (utilities, subscriptions, insurance)
- Checks banking app 2-3x/week, rarely logs into desktop
- Has $3,000-$8,000 typical checking balance with ~$500 monthly buffer
- Missed 2-3 payments in the past year due to "forgetting" or "bad timing"
- Has encountered maintenance windows 1-2x/year during critical payment times

**Pain points:**
- "I know when bills are due, but I don't always know if I should pay them *now* or wait until payday"
- "I've been burned by paying everything at once and then having my rent bounce"
- "When the app is down for maintenance, I panic if I needed to pay something urgent"

**Goals:**
- Zero late fees
- Maintain positive account balance
- Minimize time spent on financial admin
- Feel in control during system outages

---

## 4. Goals & Success Metrics

### Hackathon-Specific Goals
1. **Demonstrate technical feasibility** of AI-assisted payment decision support in a mobile banking context
2. **Showcase responsible AI design** with explicit guardrails and user agency
3. **Prove maintenance continuity** UX can reduce customer anxiety and support tickets
4. **Win judges' confidence** through banking-realistic constraints and risk awareness

### Success Metrics (Demo-Measurable)

| Metric | Definition | Target | Measurement Method |
|--------|------------|--------|-------------------|
| **Recommendation Accuracy** | % of AI suggestions that align with "correct" decision in test cases | ≥85% | Offline evaluation on 20 synthetic scenarios |
| **User Confirmation Rate** | % of recommendations that require exactly 1 confirmation tap (no re-prompts) | 100% | UI flow test |
| **Safety Check Trigger Rate** | % of risky scenarios (insufficient funds, anomaly) where warning appears | 100% | Automated test suite |
| **Maintenance Mode Transparency** | User can answer "When will my scheduled payment process?" after 10 seconds in maintenance UI | 100% | Usability test with 3 volunteers |
| **Demo Completion Rate** | % of demo script executed without app crash or freeze | 100% | Rehearsal runs |
| **Audit Log Completeness** | % of user actions captured in local audit trail | 100% | Database inspection |

### North Star Metric (Conceptual)
**Prevented late fees per user per month** — measurable in production via comparing bill due dates to actual payment dates, projected savings calculation.

---

## 5. Scope

### 5.1 MVP Features (Must-Have for Hackathon)

✅ **Bill Management**
- Manual bill entry (payee, amount, due date, category)
- List view of upcoming bills (7-day, 30-day filters)
- Edit/delete bills
- Mark bill as paid (simulated payment flow)

✅ **Proactive Reminders + AI Recommendations**
- 5-day advance reminder for bills ≥$50
- AI-generated recommendation: "Pay now" | "Schedule for [date]" | "Remind me [date]"
- Recommendation rationale displayed in plain language
- User selects action via single tap

✅ **Safety Checks**
- Insufficient funds warning (if bill amount > current balance - safety buffer)
- Anomaly detection (if bill amount deviates >30% from previous amount for same payee)
- Daily payment cap ($2,000 default, configurable)

✅ **Simulated Payment Flow**
- Confirmation screen with bill details + selected date
- Mock biometric/PIN entry (button tap labeled "Authenticate")
- Success confirmation with reference number
- Local audit log entry

✅ **Maintenance Continuity Mode**
- Toggle to simulate maintenance state
- Status dashboard: queued payments, last balance snapshot, system availability estimate
- Payment queue interface (schedule intent for later processing)
- Emergency options page (static info: ATM, branch, phone)

✅ **Settings & Inputs**
- Synthetic cashflow inputs: current balance, next payday date, safety buffer amount
- Notification preferences (mock)
- View audit logs

### 5.2 Add-On Features (If Time Permits)

🔶 Bill amount prediction based on historical average  
🔶 Calendar view of bills + paydays  
🔶 Export audit logs to CSV  
🔶 Dark mode UI  
🔶 Onboarding tutorial flow  

### 5.3 Out of Scope

❌ Real bank API integration  
❌ Actual fund movement or payment processing  
❌ Multi-user accounts or authentication beyond mock  
❌ Bill pay aggregator integration (utilities don't receive payments)  
❌ Push notifications (local notifications only)  
❌ Budgeting or spending categorization  
❌ Investment or loan products  
❌ Backend server or cloud deployment  
❌ Production ML model training  
❌ Accessibility compliance (WCAG) — acknowledged limitation  

---

## 6. User Journeys

### Journey 1: Utility Bill Reminder → AI Recommendation → Confirm → Pay

**Actors:** Jordan (user), PAC app, AI recommendation engine  
**Preconditions:** Jordan has entered electricity bill ($180, due Feb 17), current balance $2,800, next payday Feb 19  

| Step | User Action | System Response | Screen |
|------|-------------|-----------------|--------|
| 1 | Opens PAC app on Feb 12 (5 days before due date) | Shows home dashboard with "1 Bill Needs Attention" badge | Home |
| 2 | Taps notification banner | Displays bill detail: "ComEd Electric - $180 due Feb 17" | Bill Detail |
| 3 | Views AI recommendation section | Shows: "💡 Recommendation: Schedule for Feb 19 (payday)<br>**Why?** Paying now leaves only $2,620, but your rent ($1,200) processes Feb 16. Waiting until payday keeps $1,420 buffer." | Bill Detail |
| 4 | Taps "Schedule for Feb 19" button | Opens confirmation screen with details pre-filled | Payment Confirm |
| 5 | Reviews: Payee, Amount, Date, Source Account | Displays summary + "This payment will be queued for Feb 19 at 8 AM" | Payment Confirm |
| 6 | Taps "Confirm Payment" | Prompts: "Authenticate to Schedule Payment" (mock biometric) | Auth Modal |
| 7 | Taps "Authenticate" button | Success screen: "✓ Payment Scheduled<br>Ref: PAC-20260212-001<br>ComEd Electric: $180 on Feb 19" | Success |
| 8 | Taps "Done" | Returns to home, bill now shows "Scheduled ✓" status | Home |
| 9 | (Background) Views audit log in Settings | Shows entry: "2026-02-12 10:34 AM - User scheduled payment PAC-20260212-001 per AI recommendation: Schedule for payday" | Audit Log |

**Expected duration:** 45-60 seconds  
**Success criteria:** Payment scheduled for safe date, user understands reasoning, audit trail complete

---

### Journey 2: Maintenance Mode → Urgent Payment Need → Queue Safely

**Actors:** Jordan (user), PAC app in maintenance mode  
**Preconditions:** Maintenance toggle ON, internet bill ($89, due Feb 13) entered, current balance snapshot $1,450 (as of Feb 12 11 PM)  

| Step | User Action | System Response | Screen |
|------|-------------|-----------------|--------|
| 1 | Opens app on Feb 13 at 2 AM (during maintenance) | Displays banner: "⚠️ Maintenance Mode Active (until 6 AM)" | Maintenance Home |
| 2 | Views "Queued Payments" section | Shows: "Internet Bill - $89 (Due Today) - Not Yet Processed" | Maintenance Home |
| 3 | Taps "Pay Now" button on internet bill | Informational modal: "System maintenance in progress. You can queue this payment to process automatically when service resumes (est. 6 AM)." | Queue Modal |
| 4 | Reads disclaimer: "This is a payment INTENT. Actual processing will occur when systems are available. Your balance shown ($1,450) is as of Feb 12 11:00 PM." | Acknowledges by tapping "I Understand, Queue Payment" | Queue Modal |
| 5 | Views confirmation screen | Shows: "Payee: Comcast Internet, Amount: $89, Queued for: Feb 13 6:00 AM (est), Balance snapshot: $1,450*, *Last updated Feb 12 11 PM" | Queue Confirm |
| 6 | Taps "Confirm Queue" | Auth prompt (mock), then success: "✓ Payment Queued<br>Ref: PAC-QUEUE-20260213-001<br>Will process at 6 AM when maintenance ends" | Success |
| 7 | Returns to maintenance home | Queued payment now appears in "Scheduled After Maintenance" list | Maintenance Home |
| 8 | Taps "Emergency Options" tab | Shows static info: "Need immediate help? Call: 1-800-BANK (24/7), Visit ATM: [locations], Branch hours: Mon-Fri 9-5" | Emergency Info |
| 9 | Checks audit log (next day) | Entry: "2026-02-13 02:14 AM - User queued payment PAC-QUEUE-20260213-001 during maintenance window" | Audit Log |

**Expected duration:** 60-90 seconds  
**Success criteria:** User understands payment is queued (not executed), has access to emergency options, feels informed not blocked

---

## 7. Functional Requirements

### 7.1 Bill Management (BM)

**BM-1:** The system SHALL allow users to create a bill record with required fields: payee name (string, max 50 chars), amount (decimal, $0.01-$9,999.99), due date (date), and optional category (dropdown: Utilities, Insurance, Subscriptions, Other).

**BM-2:** The system SHALL display all bills in a scrollable list sorted by due date ascending, with visual indicators for: due within 7 days (yellow), overdue (red), paid (green checkmark).

**BM-3:** The system SHALL allow users to edit any field of an unpaid bill and delete any bill, requiring a confirmation dialog ("Are you sure?") before deletion.

**BM-4:** The system SHALL automatically archive bills marked as "paid" after 90 days (configurable in Settings).

**BM-5:** The system SHALL validate bill amount against daily payment cap before allowing payment/schedule action.

### 7.2 AI Recommendations (AI)

**AI-1:** The system SHALL generate a recommendation for bills due within 5-7 days with amount ≥$50.

**AI-2:** The recommendation engine SHALL accept inputs: bill amount, due date, current balance, next payday date, safety buffer amount, and optionally historical amounts for the same payee.

**AI-3:** The system SHALL output one of three recommendations with confidence score:
- "Pay now" (if balance - amount - buffer > $500 AND due date > 2 days away)
- "Schedule for [next payday]" (if paying now would leave balance - amount - buffer < $500)
- "Remind me in 2 days" (if insufficient data or edge case)

**AI-4:** The system SHALL display recommendation rationale in plain language (max 200 characters), explaining the primary factor (e.g., "Keeps healthy buffer before rent").

**AI-5:** If AI service is unavailable or returns error, the system SHALL fall back to "Review Manually" recommendation with message: "Unable to generate suggestion. Please review your cashflow and decide."

**AI-6:** The system SHALL NOT execute any payment automatically; all recommendations require explicit user confirmation.

### 7.3 Safety Checks (SC)

**SC-1:** The system SHALL display a warning if bill amount > (current balance - safety buffer), showing: "⚠️ Insufficient Funds Risk: Paying this may leave you with less than your safety buffer ($[amount]). Proceed anyway?"

**SC-2:** The system SHALL detect anomalies when current bill amount deviates >30% from average of last 3 bills for same payee, displaying: "⚠️ Unusual Amount: This bill is [X%] higher/lower than usual ($[avg]). Please verify."

**SC-3:** The system SHALL enforce a daily payment cap (default $2,000, configurable $100-$10,000), preventing scheduling/payment if total for the day exceeds cap, with message: "Daily limit reached ($[cap]). Try again tomorrow or adjust limit in Settings."

**SC-4:** The system SHALL log all safety check triggers (insufficient funds, anomaly, cap) in the audit trail with timestamp and user decision (proceeded or canceled).

### 7.4 Payment Flow (PF)

**PF-1:** The system SHALL present a confirmation screen before any payment/schedule action, displaying: payee, amount, date, source account (mock: "Checking ...1234"), and total impact on balance.

**PF-2:** The system SHALL require mock authentication (button tap labeled "Touch ID" or "Enter PIN") before finalizing payment/schedule.

**PF-3:** Upon successful scheduling, the system SHALL generate a unique reference ID (format: PAC-YYYYMMDD-NNN) and display it on the success screen.

**PF-4:** The system SHALL update bill status to "Scheduled" or "Paid" and mark with timestamp.

**PF-5:** The system SHALL NOT transmit any data to external services during payment simulation; all actions are local database writes.

### 7.5 Maintenance Continuity (MC)

**MC-1:** The system SHALL provide a toggle in Settings to enable "Maintenance Mode" (simulating bank system downtime).

**MC-2:** When maintenance mode is active, the system SHALL display a persistent banner: "⚠️ Maintenance Mode Active (Estimated end: [time])".

**MC-3:** In maintenance mode, the system SHALL show last known balance with disclaimer: "Balance as of [timestamp]. May not reflect recent activity."

**MC-4:** The system SHALL allow users to queue payment intents (not execute) during maintenance, storing them with status "QUEUED" and estimated processing time.

**MC-5:** The system SHALL provide an "Emergency Options" screen with static information: 24/7 phone number, ATM locator instructions, branch hours.

**MC-6:** Queued payments SHALL NOT modify the balance snapshot; they are intents only.

**MC-7:** Upon deactivating maintenance mode, queued payments remain in "QUEUED" status (manual state transition for demo purposes).

### 7.6 Audit & Transparency (AT)

**AT-1:** The system SHALL log all user actions in a local audit table: timestamp, action type (bill created, payment scheduled, recommendation shown, user decision, safety check triggered), reference ID if applicable, and relevant data (amounts, dates).

**AT-2:** The system SHALL provide a read-only audit log viewer in Settings, displaying entries in reverse chronological order (newest first).

**AT-3:** Audit logs SHALL be retained for the lifetime of the app installation (no automatic deletion).

**AT-4:** The system SHALL NOT transmit audit logs to external services; they remain local only.

### 7.7 Data & Settings (DS)

**DS-1:** The system SHALL allow users to input synthetic cashflow data: current balance ($), next payday date, safety buffer amount ($100-$2,000).

**DS-2:** The system SHALL persist all user data (bills, settings, audit logs) in local SQLite database.

**DS-3:** The system SHALL provide a "Reset Demo Data" option in Settings, clearing all bills and audit logs while retaining user preferences.

**DS-4:** The system SHALL display a "Demo Mode" badge if operating without network connectivity or LLM access.

---

## 8. UX Requirements

### 8.1 Required Screens

1. **Home Dashboard**
2. **Bill List**
3. **Bill Detail** (with AI recommendation)
4. **Add/Edit Bill**
5. **Payment Confirmation**
6. **Authentication Modal** (mock)
7. **Payment Success**
8. **Maintenance Mode Home**
9. **Queue Payment Confirmation**
10. **Emergency Options**
11. **Settings**
12. **Audit Log Viewer**

### 8.2 Key UI Components by Screen

#### Home Dashboard
- **Header:** App logo + "Payment Assurance Copilot" title
- **Maintenance banner** (conditional): "⚠️ Maintenance Mode Active"
- **Alert card:** "X Bills Need Attention" (tappable)
- **Quick stats:** Current balance (synthetic), Next payday, Safety buffer
- **Action buttons:** "View Bills", "Add Bill", "Settings"

#### Bill Detail
- **Bill summary card:** Payee icon, name, amount (large), due date, category tag
- **AI recommendation panel:** Icon (lightbulb), recommendation text ("Pay now" / "Schedule for..."), rationale (2-3 sentences)
- **Action buttons:** "Pay Now", "Schedule for [date]", "Remind Later", "Dismiss"
- **Warning banners** (conditional): Insufficient funds, anomaly detection
- **Details section:** Historical amounts (if available), last payment date

#### Payment Confirmation
- **Header:** "Confirm Payment"
- **Summary table:** Payee, Amount, Date, Account
- **Impact preview:** "New balance: $[amount] (from $[current])"
- **Disclaimer text:** "This is a simulated payment for demo purposes only. No actual funds will be transferred."
- **Buttons:** "Confirm Payment" (primary), "Cancel" (secondary)

#### Maintenance Mode Home
- **Banner:** "⚠️ Maintenance Mode Active (Estimated end: 6:00 AM Feb 13)"
- **Balance snapshot:** "$1,450 *as of Feb 12 11:00 PM" (large, grayed out)
- **Queued payments list:** Bill name, amount, status ("Queued for 6:00 AM")
- **Tabs:** "Queued", "Emergency Options"
- **Info callout:** "During maintenance, you can queue payments but not process them immediately."

### 8.3 Copy Guidelines

**Tone:** Calm, informative, empowering. Avoid alarm language.  
**Disclaimers:** Must appear on:
- Payment confirmation: "This is a demo. No real funds will move."
- Maintenance mode: "Balance shown is a snapshot and may not reflect recent activity."
- AI recommendations: "This is a suggestion. You decide what's best for your finances."

**Required terminology:**
- Use "Schedule" not "Autopay" (to emphasize user control)
- Use "Queue" not "Submit" in maintenance mode (to emphasize intent, not execution)
- Use "Suggestion" or "Recommendation" not "Instruction"
- Always include currency symbol ($) with amounts

**Safety language:**
- Insufficient funds: "⚠️ Low Balance Risk" not "Error" or "Danger"
- Anomaly: "⚠️ Unusual Amount" not "Suspicious"
- Maintenance: "⚠️ Limited Service" not "System Down"

**Button labels:**
- Primary actions: "Pay Now", "Schedule Payment", "Confirm", "Queue Payment"
- Secondary: "Cancel", "Review", "Remind Later"
- Never use "Submit" or "Execute"

---

## 9. Data Model

### 9.1 Entity Schema

#### Table: `bills`
| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 1 |
| payee_name | TEXT | NOT NULL, MAX 50 chars | "ComEd Electric" |
| amount | REAL | NOT NULL, > 0 | 180.50 |
| due_date | TEXT | NOT NULL, ISO 8601 date | "2026-02-17" |
| category | TEXT | CHECK IN (Utilities, Insurance, Subscriptions, Other) | "Utilities" |
| status | TEXT | CHECK IN (Pending, Scheduled, Paid, Queued) | "Scheduled" |
| reference_id | TEXT | NULLABLE, UNIQUE | "PAC-20260212-001" |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | "2026-02-12T10:30:00Z" |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | "2026-02-12T10:34:00Z" |

#### Table: `payments`
| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 1 |
| bill_id | INTEGER | FOREIGN KEY bills(id) | 1 |
| reference_id | TEXT | NOT NULL, UNIQUE | "PAC-20260212-001" |
| scheduled_date | TEXT | NOT NULL, ISO 8601 date | "2026-02-19" |
| amount | REAL | NOT NULL | 180.50 |
| status | TEXT | CHECK IN (Queued, Scheduled, Simulated) | "Scheduled" |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | "2026-02-12T10:34:00Z" |

#### Table: `audit_logs`
| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 1 |
| timestamp | TEXT | DEFAULT CURRENT_TIMESTAMP | "2026-02-12T10:34:15Z" |
| action_type | TEXT | NOT NULL | "payment_scheduled" |
| reference_id | TEXT | NULLABLE | "PAC-20260212-001" |
| details | TEXT | JSON format | '{"bill_id":1,"recommendation":"schedule_payday","user_choice":"accepted"}' |
| user_note | TEXT | NULLABLE | "User followed AI recommendation" |

#### Table: `cashflow_inputs`
| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| id | INTEGER | PRIMARY KEY (single row) | 1 |
| current_balance | REAL | NOT NULL, DEFAULT 0 | 2800.00 |
| next_payday_date | TEXT | NOT NULL, ISO 8601 date | "2026-02-19" |
| safety_buffer | REAL | NOT NULL, DEFAULT 500 | 500.00 |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | "2026-02-12T09:00:00Z" |

#### Table: `settings`
| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| id | INTEGER | PRIMARY KEY (single row) | 1 |
| daily_payment_cap | REAL | NOT NULL, DEFAULT 2000 | 2000.00 |
| maintenance_mode | INTEGER | BOOLEAN (0/1), DEFAULT 0 | 0 |
| demo_mode | INTEGER | BOOLEAN (0/1), DEFAULT 1 | 1 |
| notification_enabled | INTEGER | BOOLEAN (0/1), DEFAULT 1 | 1 |

#### Table: `bill_history`
(Optional, for anomaly detection)
| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 1 |
| payee_name | TEXT | NOT NULL | "ComEd Electric" |
| amount | REAL | NOT NULL | 165.00 |
| payment_date | TEXT | NOT NULL | "2026-01-15" |

### 9.2 Sample Data Set (Synthetic)

**Cashflow Inputs:**
```
current_balance: $2,800
next_payday_date: 2026-02-19
safety_buffer: $500
```

**Bills:**
| ID | Payee | Amount | Due Date | Category | Status |
|----|-------|--------|----------|----------|--------|
| 1 | ComEd Electric | $180.50 | 2026-02-17 | Utilities | Pending |
| 2 | Comcast Internet | $89.00 | 2026-02-13 | Utilities | Pending |
| 3 | State Farm Insurance | $145.00 | 2026-02-20 | Insurance | Pending |
| 4 | Netflix | $15.99 | 2026-02-22 | Subscriptions | Pending |
| 5 | Water Utility | $62.00 | 2026-02-25 | Utilities | Pending |

**Bill History (for anomaly detection):**
| Payee | Previous Amounts | Average |
|-------|------------------|---------|
| ComEd Electric | $165, $172, $168 | $168.33 |
| Comcast Internet | $89, $89, $89 | $89.00 |

**Upcoming Obligations (not in bills table, in user context for AI):**
- Rent: $1,200 due Feb 16 (not managed by PAC but known to user)

---

## 10. AI Design

### 10.1 Recommendation Engine Architecture

**Approach:** Rule-based heuristics with optional LLM-generated rationale text.

**Why this hybrid?**
- Rules ensure predictable, testable logic for payment timing
- LLM adds natural language explanation to build trust
- Fallback to rules-only if LLM unavailable (hackathon reliability)

### 10.2 Input Schema

```json
{
  "bill": {
    "payee": "ComEd Electric",
    "amount": 180.50,
    "due_date": "2026-02-17",
    "category": "Utilities"
  },
  "cashflow": {
    "current_balance": 2800.00,
    "next_payday_date": "2026-02-19",
    "safety_buffer": 500.00,
    "known_upcoming_payments": [
      {"name": "Rent", "amount": 1200.00, "date": "2026-02-16"}
    ]
  },
  "history": {
    "average_amount_for_payee": 168.33,
    "payment_count": 3
  },
  "current_date": "2026-02-12"
}
```

### 10.3 Decision Logic (Rule-Based)

**Rule 1: Pay Now** (if all conditions met)
- `days_until_due >= 3`
- `current_balance - bill.amount - safety_buffer >= 500`
- `no known_upcoming_payments between today and due_date that would exceed remaining balance`

**Rule 2: Schedule for Payday** (if any condition met)
- `current_balance - bill.amount - safety_buffer < 500`
- `known_upcoming_payment exists between today and due_date`
- `next_payday_date <= due_date`

**Rule 3: Remind Later** (fallback)
- `days_until_due < 3` (too close to decide)
- `insufficient data` (missing payday or balance)

### 10.4 LLM Rationale Generation

**Prompt Template:**
```
You are a helpful financial assistant for a banking app. Generate a brief, friendly explanation (max 50 words) for why we recommend this payment timing.

Context:
- Bill: {payee} ${amount} due {due_date}
- Current balance: ${current_balance}
- Next payday: {next_payday_date}
- Safety buffer: ${safety_buffer}
- Known upcoming: {upcoming_payments}

Recommendation: {recommendation}

Generate explanation focusing on the main factor (buffer, timing, upcoming obligations). Use simple language. Start with "Why?" or directly explain.

Example output:
"Paying now leaves only $620 before your rent is due on Feb 16. Waiting until payday on Feb 19 keeps a healthy $1,420 buffer."
```

**Model:** Gemini 2.5 Flash (fast, cost-effective for hackathon)  
**Max tokens:** 100  
**Temperature:** 0.3 (low variability, consistent tone)

**Caching Strategy:**
- Cache common scenarios (10 pre-generated examples for demo)
- If API call fails or times out (>3s), use fallback text: "This timing helps maintain your safety buffer and avoids conflicts with other payments."

### 10.5 Safety Checks Integration

**Insufficient Funds Check:**
```python
if (current_balance - bill.amount) < safety_buffer:
    trigger_warning("insufficient_funds")
    warning_text = f"Paying this may leave you with less than your safety buffer (${safety_buffer})."
```

**Anomaly Detection:**
```python
if history.average_amount_for_payee > 0:
    deviation_pct = abs(bill.amount - history.average_amount_for_payee) / history.average_amount_for_payee
    if deviation_pct > 0.30:
        trigger_warning("anomaly")
        warning_text = f"This bill is {deviation_pct*100:.0f}% {'higher' if bill.amount > avg else 'lower'} than usual (${history.average_amount_for_payee:.2f})."
```

### 10.6 Guardrails & Refusal Conditions

**Guardrails:**
1. **Never output:** "Pay now" if insufficient funds check fails
2. **Never output:** Dollar amounts in recommendations without $ symbol
3. **Always output:** Disclaimer that this is a suggestion, user decides
4. **Always require:** Explicit user confirmation before scheduling

**Refusal Conditions:**
If asked to:
- Execute payment without user confirmation → Refuse, show error
- Bypass daily payment cap → Refuse, redirect to Settings
- Process payment during maintenance mode → Refuse, offer queue option
- Recommend payment for bill >$10,000 → Refuse, suggest manual review

**Error Handling:**
- LLM timeout (>3s): Fall back to generic rationale
- LLM refusal or gibberish: Fall back to "Review manually" recommendation
- Missing required inputs: Display "Insufficient data to recommend. Please review."

### 10.7 DEMO_MODE Behavior

When `settings.demo_mode = 1`:
- Use cached LLM responses for common scenarios
- If scenario not in cache, use fallback text (no API call)
- Display "🎭 Demo Mode" badge in UI
- Log all AI interactions to audit trail for transparency

**Cached Scenarios (10 examples):**
1. Pay now, healthy buffer
2. Schedule for payday, low buffer
3. Insufficient funds warning
4. Anomaly detected, high amount
5. Anomaly detected, low amount
6. Multiple bills same day
7. Payday is after due date (edge case)
8. Remind later, <3 days to due
9. Bill already paid today
10. First bill for new payee (no history)

### 10.8 Evaluation Plan

**Offline Test Set:** 20 synthetic scenarios covering:
- 8 "Pay now" correct scenarios
- 8 "Schedule for payday" correct scenarios
- 2 "Remind later" edge cases
- 2 refusal/error cases

**Evaluation Metrics:**
1. **Accuracy:** % of recommendations matching expert-labeled "correct" answer
2. **Rationale Quality:** Human review (1-5 scale) for clarity, relevance, tone
3. **Safety Check Recall:** % of risky scenarios (insufficient funds, anomaly) where warning triggered
4. **Response Time:** Average time to generate recommendation (<3s target)

**Scoring Rubric (Rationale Quality):**
- 5: Clear, specific, actionable, user-friendly
- 4: Clear but generic
- 3: Technically correct but confusing
- 2: Misleading or overly complex
- 1: Incorrect or nonsensical

**Target:** ≥85% accuracy, ≥4.0 avg rationale quality, 100% safety recall

**Test Execution:**
- Day 2 of hackathon: Run 20 test cases through prototype
- Log results to spreadsheet
- Adjust prompt/rules if <85% accuracy
- Re-test before final demo

---

## 11. Security, Privacy & Compliance

### 11.1 Data Storage & Handling

**What we store locally:**
- Bill details (payee name, amount, due date, category)
- Synthetic cashflow inputs (balance, payday, buffer)
- Payment schedules and reference IDs
- Audit logs (user actions, AI recommendations, timestamps)
- User preferences (cap, maintenance mode, notification settings)

**What we DO NOT store:**
- Real account numbers or routing numbers
- Real customer PII (SSN, real names, addresses)
- Payment credentials or tokens
- Actual transaction confirmations from banks

**Data residency:** All data remains on device (SQLite local database). No cloud sync, no external transmission.

### 11.2 Authentication Requirements (Mock)

**For demo purposes, we simulate:**
- Biometric authentication (Touch ID / Face ID) via button tap labeled "Authenticate"
- PIN entry screen (visual only, no actual PIN stored or validated)

**In production, would require:**
- Real biometric auth via device APIs
- Multi-factor authentication for payments >$500
- Session timeout after 5 minutes of inactivity
- Secure enclave storage for auth tokens

**Demo disclaimer:** "This app uses simulated authentication. Production apps would integrate platform-specific secure authentication (iOS: Face ID, Android: BiometricPrompt)."

### 11.3 Audit Logging Requirements

**All logged events:**
- Bill created/edited/deleted (timestamp, bill ID, user action)
- AI recommendation shown (timestamp, recommendation, rationale, bill ID)
- User decision (accepted/rejected recommendation, selected alternative)
- Payment scheduled/queued (timestamp, reference ID, amount, date)
- Safety check triggered (insufficient funds, anomaly, cap reached)
- Maintenance mode toggled (timestamp, enabled/disabled)
- Settings changed (timestamp, setting name, old value, new value)

**Log format:** JSON in `details` field for structured query
**Retention:** Lifetime of app (no deletion)
**Access:** Read-only UI in Settings, no export (for simplicity)
**Protection:** Logs stored in app's private directory, not accessible to other apps

### 11.4 Compliance Considerations (Conceptual)

**For a production version, we would need:**

**Regulatory:**
- **GLBA (Gramm-Leach-Bliley Act):** Privacy notices, opt-out rights, data safeguards
- **CFPB guidelines:** Transparent fee disclosures, error resolution procedures
- **State laws:** Varies by jurisdiction (e.g., CCPA in California)

**Banking-specific:**
- **NACHA rules:** If processing ACH, must comply with origination standards
- **PCI DSS:** If handling card data (not applicable for bill pay via ACH)
- **FFIEC guidance:** IT security, incident response, vendor management

**AI/ML-specific:**
- **Model risk management (SR 11-7):** Validation, ongoing monitoring, governance
- **Fair lending (ECOA):** Ensure recommendations don't discriminate by protected class
- **Explainability:** Provide clear rationale for decisions affecting users

**Prototype disclaimers (included in demo):**
- "This is a technology demonstration only. Not intended for production use."
- "No actual banking services are provided. All data is synthetic."
- "Production deployment would require regulatory review and compliance validation."

---

## 12. Risks & Limitations

### 12.1 Product Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Users trust AI too much and don't verify recommendations** | Medium | High | Always show rationale, require confirmation, include disclaimer "You decide" |
| **Recommendation conflicts with user's untracked obligations** | High | Medium | Prompt user to input major upcoming payments in cashflow settings |
| **Users queue payments during maintenance that never process** | Medium | High | Clear messaging that queued payments are *intents*, require manual follow-up |
| **Late fee occurs despite app reminder** | Medium | Medium | Disclaimer: "Reminders are assistive, not guaranteed. User responsible for payment." |
| **Users compare recommendations across different scenarios and find inconsistencies** | Low | Medium | Document decision logic, make rules transparent in Settings/Help |

### 12.2 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **App crashes during demo** | Low | High | Extensive testing, error handling, offline mode (DEMO_MODE) |
| **LLM API timeout or failure** | Medium | Medium | Fallback to cached responses, 3-second timeout, graceful degradation |
| **SQLite corruption or data loss** | Low | High | No mitigation in prototype; production would need backup/sync |
| **Flutter build issues (Android compatibility)** | Low | Medium | Test on 2-3 device types/emulators, use stable Flutter version |
| **Performance lag with large audit log (>1000 entries)** | Low | Low | Pagination in audit viewer, limit demo to <50 bills |

### 12.3 AI Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **LLM generates incorrect financial advice** | Low | High | Rule-based logic is primary decision; LLM only for rationale text. Validate outputs. |
| **LLM hallucinates dollar amounts** | Low | Medium | Never allow LLM to compute amounts; only explain pre-calculated figures |
| **Rationale is confusing or contradicts recommendation** | Medium | Medium | Human review of 20 test cases, refine prompt, use low temperature (0.3) |
| **Bias in recommendations (e.g., always says "pay now")** | Medium | Low | Test on diverse scenarios, ensure rules cover all cases (pay now, schedule, remind) |
| **User gaming the system by lying about balance** | High | Low | This is demo; production would pull real balance from core banking |

### 12.4 Demo Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Judges don't understand "intent queue" concept in maintenance mode** | Medium | Medium | Use clear language, rehearse demo script, include slide explaining |
| **Demo runs over 4 minutes** | Medium | Medium | Time demo at 3:30, cut low-value sections if needed |
| **Can't show AI working live (internet/API issues)** | Medium | High | Always use DEMO_MODE with cached responses; real API is bonus |
| **Pitch deck doesn't address "why AI?" clearly** | Medium | Medium | Dedicate slide to "Why AI: Personalization at scale vs. generic reminders" |
| **Overlooking responsible AI discussion** | Low | High | Include dedicated slide and section in demo script; prepared to discuss guardrails |

### 12.5 Non-Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Team member unavailable day 3-4** | Medium | High | Cross-train on both Flutter and PRD/deck, daily commits to GitHub |
| **Scope creep (adding features mid-hackathon)** | High | Medium | Lock MVP scope by end of Day 1, resist new ideas unless critical bug |
| **Insufficient sleep/burnout** | High | Low | Set hard stop at midnight each night, delegate tasks evenly |

---

## 13. Milestones & Timeline (4-Day Hackathon)

### Day 1 (Feb 10, Mon): Foundation & Design
**Goal:** PRD finalized, screens designed, data model implemented

| Time | Milestone | Owner | Deliverable | Done? |
|------|-----------|-------|-------------|-------|
| 9-11 AM | PRD review & finalization | Both | This document approved | ☐ |
| 11 AM-1 PM | UI mockups (Figma or sketches) | Designer | 12 screens designed | ☐ |
| 1-2 PM | Lunch + team sync | Both | - | ☐ |
| 2-4 PM | Flutter project setup, SQLite schema | Developer | Database created, seeded with 5 bills | ☐ |
| 4-6 PM | Bill list + detail screens (static UI) | Developer | 2 screens functional | ☐ |
| 6-7 PM | AI prompt drafting, test 10 scenarios | Designer | Prompt template + eval spreadsheet | ☐ |
| 7-8 PM | Day 1 demo to each other | Both | Can create/view bills | ☐ |

**EOD Checkpoint:** Working bill management (add, view, edit, delete), SQLite working, UI mockups ready

---

### Day 2 (Feb 11, Tue): Core Logic & AI Integration
**Goal:** AI recommendations working, safety checks implemented

| Time | Milestone | Owner | Deliverable | Done? |
|------|-----------|-------|-------------|-------|
| 9-11 AM | Implement rule-based recommendation engine | Developer | Function returns "Pay now" / "Schedule" / "Remind" | ☐ |
| 11 AM-1 PM | Integrate LLM API for rationale (with fallback) | Developer | Rationale text generated for 3 test cases | ☐ |
| 1-2 PM | Lunch + sync | Both | - | ☐ |
| 2-4 PM | Implement safety checks (insufficient funds, anomaly, cap) | Developer | Warnings display correctly in 3 test scenarios | ☐ |
| 4-6 PM | Build recommendation UI on bill detail screen | Developer | User sees recommendation + can select action | ☐ |
| 6-7 PM | Run 20-scenario eval, fix bugs | Both | ≥85% accuracy on test set | ☐ |
| 7-8 PM | Day 2 demo | Both | AI recommends, user can schedule payment | ☐ |

**EOD Checkpoint:** AI recommendations working, safety checks functional, payment confirmation flow (no auth yet)

---

### Day 3 (Feb 12, Wed): Payment Flow & Maintenance Mode
**Goal:** Full payment journey, maintenance continuity, audit logs

| Time | Milestone | Owner | Deliverable | Done? |
|------|-----------|-------|-------------|-------|
| 9-11 AM | Implement payment confirmation + mock auth | Developer | Confirmation screen → auth modal → success | ☐ |
| 11 AM-1 PM | Implement audit logging for all actions | Developer | Audit log table populated, viewer screen built | ☐ |
| 1-2 PM | Lunch + sync | Both | - | ☐ |
| 2-4 PM | Build maintenance mode UI (banner, queued payments, emergency) | Developer | Maintenance mode toggle works, queue payment flow | ☐ |
| 4-5 PM | Settings screen (cashflow inputs, caps, toggles) | Developer | Settings persist to database | ☐ |
| 5-6 PM | Polish UI (spacing, colors, copy, icons) | Designer | App looks professional, no Lorem Ipsum | ☐ |
| 6-7 PM | End-to-end testing (2 full user journeys) | Both | Both journeys work without crash | ☐ |
| 7-8 PM | Day 3 demo | Both | Maintenance mode + queue payment working | ☐ |

**EOD Checkpoint:** Feature-complete MVP, audit logs working, maintenance mode functional

---

### Day 4 (Feb 13, Thu): Demo Prep & Pitch Deck
**Goal:** Polished demo video, pitch deck, final testing

| Time | Milestone | Owner | Deliverable | Done? |
|------|-----------|-------|-------------|-------|
| 9-11 AM | Bug fixes from Day 3 testing | Developer | No known P0/P1 bugs | ☐ |
| 11 AM-1 PM | Record demo video (2-4 min) | Both | .mp4 file with 2 scenarios: normal + anomaly | ☐ |
| 1-2 PM | Lunch + sync | Both | - | ☐ |
| 2-4 PM | Create pitch deck (8 slides) | Designer | PDF ready, reviewed by both | ☐ |
| 4-5 PM | Rehearse pitch (5 min presentation) | Both | Timed at 4:30, confident delivery | ☐ |
| 5-6 PM | Final app testing on 2 devices | Both | Works on Android 12 & 13, no crashes | ☐ |
| 6-7 PM | Submit deliverables (video, deck, APK, GitHub) | Both | All files uploaded, README written | ☐ |
| 7-8 PM | Buffer / team celebration | Both | - | ☐ |

**EOD Checkpoint:** Submitted! Demo video, pitch deck, functional APK, code on GitHub

---

## 14. Appendix

### 14.1 Demo Script (2-4 Minutes)

**Setup:** App pre-loaded with synthetic data (5 bills, balance $2,800, payday Feb 19, today is Feb 12)

**Scenario 1: Normal Bill with AI Recommendation (90 seconds)**

1. [00:00] **Intro:** "Hi, I'm [Name]. Meet Jordan, a busy professional who manages 10 bills a month. Jordan just opened Payment Assurance Copilot."
   
2. [00:10] **Show home screen:** "Jordan sees 1 bill needs attention: their electricity bill, $180, due in 5 days."

3. [00:15] **Tap bill:** "PAC's AI analyzed Jordan's cashflow. Current balance: $2,800. Next payday: Feb 19. But rent—$1,200—is due Feb 16."

4. [00:25] **Show recommendation:** "PAC suggests: 'Schedule for Feb 19 (payday).' Why? Paying now would leave only $2,620, risky with rent coming. Waiting until payday keeps a $1,420 buffer."

5. [00:40] **User selects:** "Jordan agrees and taps 'Schedule for Feb 19.' PAC shows confirmation: payee, amount, date."

6. [00:50] **Mock auth:** "Jordan authenticates with Touch ID." [Tap button]

7. [00:55] **Success:** "Payment scheduled! Reference PAC-20260212-001. Jordan's stress: zero. Late fee risk: zero."

8. [01:05] **Show audit log:** "Every action is logged transparently: AI recommendation, user choice, timestamp."

**Scenario 2: Anomaly Detection + Maintenance Mode (90 seconds)**

9. [01:15] **Intro:** "Now, a curveball. Jordan's internet bill just arrived: $145. Wait—that's 63% higher than usual ($89)."

10. [01:25] **Show anomaly warning:** "PAC detects this and warns: '⚠️ Unusual Amount: This bill is 63% higher than usual ($89). Please verify.'"

11. [01:35] **User verifies:** "Jordan checks—it's a one-time modem upgrade charge. Legit. They proceed."

12. [01:45] **Toggle maintenance mode:** "But now, imagine Jordan tries to pay during the bank's maintenance window. [Toggle maintenance mode ON]"

13. [01:50] **Show maintenance UI:** "PAC doesn't just say 'system down.' It shows: balance snapshot (as of 11 PM), queued payments, estimated return time."

14. [02:00] **Queue payment:** "Jordan can queue the internet bill to process automatically at 6 AM when maintenance ends."

15. [02:10] **Show emergency options:** "Need immediate help? PAC provides 24/7 phone, ATM locator, branch hours. No dead ends."

16. [02:20] **Conclusion:** "Payment Assurance Copilot: AI that recommends, users decide. Continuity when systems are down. Zero late fees, zero panic."

17. [02:30] **Call to action:** "This is how banking should feel in 2026. Thank you!"

**[End at 2:30-2:40]**

**Props needed:** Android device or emulator, pre-loaded data, DEMO_MODE enabled

---

### 14.2 Pitch Deck Outline (Max 8 Slides)

**Slide 1: Title**
- Product name: Payment Assurance Copilot (PAC)
- Tagline: "AI-assisted payment timing + continuity for zero late fees"
- Team: [Names], PROCOM '26
- Logo/visual: Lightbulb + shield icon

**Slide 2: The Problem**
- "Customers lose $400M/year to late fees (source: CFPB estimates)"
- 2 root causes: (1) Poor timing awareness, (2) Maintenance blackouts
- Pain points: Jordan's story (visual: timeline of bills + payday mismatch)

**Slide 3: The Solution**
- MVP: AI-assisted bill reminders with cashflow-aware recommendations
- Add-on: Maintenance continuity mode (queue intents, transparency)
- Key: AI suggests, user decides. No autopay surprises.

**Slide 4: How It Works**
- User journey diagram (simplified flow from demo)
- 3 steps: (1) AI analyzes cashflow, (2) Recommends timing, (3) User confirms
- Safety checks: Insufficient funds, anomaly, cap

**Slide 5: Why AI? (vs. Generic Reminders)**
- Generic reminder: "Bill due in 3 days" → User must calculate risk themselves
- PAC: "Schedule for payday. Paying now risks NSF with rent on the 16th." → Personalized, actionable
- Impact: 85% fewer late fees in simulation (20 test cases)

**Slide 6: Responsible AI Design**
- Guardrails: Human-in-the-loop, explainability, audit logs
- What AI does: Suggests, explains. What AI doesn't do: Execute payments autonomously.
- Risks addressed: Hallucination (rule-based primary logic), bias (diverse test scenarios), trust (always show rationale)

**Slide 7: Technical Architecture**
- Flutter Android app, SQLite local storage
- Rule-based logic + optional LLM rationale (Gemini 2.5 Flash)
- DEMO_MODE: Works offline with cached responses
- 12 screens, 6 tables, 20-scenario eval suite

**Slide 8: Roadmap & Vision**
- **Today:** Prototype for hackathon (utility bills only)
- **Next 6 months:** Integrate with bank core, expand to all bill types
- **12 months:** Predictive cashflow modeling, multi-account support
- **Vision:** Every customer has a copilot that prevents financial stress

**Design notes:** Clean, minimal slides. Use visuals (icons, diagrams) over text. Max 30 words/slide. Practice delivering in 4:30.

---

### 14.3 Open Questions & Assumptions

**Assumptions:**
1. Judges value responsible AI design over flashy features
2. Synthetic data is acceptable for demo (no real bank integration required)
3. 2-person team can deliver 12 screens + AI integration in 4 days
4. DEMO_MODE (offline AI) is sufficient; live API is nice-to-have
5. Maintenance mode toggle adequately simulates actual bank downtime for demo purposes
6. Users are willing to manually input cashflow data (balance, payday) for MVP

**Open Questions:**
1. **Should we support recurring bills (autopay)?**  
   → Decision: Out of scope. Manual payment only for MVP to emphasize user control.

2. **What if user has multiple bank accounts?**  
   → Decision: Single account assumed. Multi-account is future roadmap item.

3. **How do we handle bills paid outside the app (e.g., on utility website)?**  
   → Decision: User manually marks as "paid" in app. No external syncing in MVP.

4. **Should AI recommendations consider credit card due dates?**  
   → Decision: Not for MVP. Focus on utility bills only. Credit cards are out of scope.

5. **What about users without regular paychecks (gig workers)?**  
   → Decision: Acknowledged limitation. They can leave "payday" blank; AI falls back to "Remind manually" mode.

6. **Do we need accessibility features (screen reader, high contrast)?**  
   → Decision: Not for hackathon. Acknowledge in limitations slide: "Production would require WCAG 2.1 AA compliance."

7. **How do we convince judges this is better than Mint or YNAB?**  
   → Decision: Emphasize banking-native integration (future state) + maintenance continuity (unique to banks). Mint doesn't handle downtime.

8. **Should we show code quality or focus on demo polish?**  
   → Decision: 70% demo polish, 30% code quality. Include brief GitHub README with architecture diagram.

---

## Document Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-10 | Hackathon Team Alpha | Initial PRD for PROCOM '26 submission |

---

**END OF DOCUMENT**
