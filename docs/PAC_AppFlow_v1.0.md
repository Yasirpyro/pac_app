# App Flow Document: Payment Assurance Copilot (PAC)

**Version:** 1.0  
**Date:** February 10, 2026  
**Purpose:** Complete navigation, interaction, and screen flow specification  
**Audience:** Developers, Designers, QA

---

## Table of Contents

1. [Screen Inventory](#1-screen-inventory)
2. [Navigation Architecture](#2-navigation-architecture)
3. [Screen-by-Screen Specifications](#3-screen-by-screen-specifications)
4. [User Journey Flows](#4-user-journey-flows)
5. [State Transitions](#5-state-transitions)
6. [Edge Cases & Error Handling](#6-edge-cases--error-handling)
7. [Navigation Patterns](#7-navigation-patterns)

---

## 1. Screen Inventory

### 1.1 Complete Screen List

| # | Screen Name | Type | Access Method | Parent Screen |
|---|-------------|------|---------------|---------------|
| 1 | Home Dashboard | Primary | App launch | - |
| 2 | Bill List | Primary | Bottom nav / Home tap | - |
| 3 | Bill Detail | Secondary | Bill List item tap | Bill List |
| 4 | Add Bill | Secondary | FAB / Home button | Bill List, Home |
| 5 | Edit Bill | Secondary | Bill Detail edit icon | Bill Detail |
| 6 | Payment Recommendation | Overlay | Bill Detail auto-show | Bill Detail |
| 7 | Payment Confirmation | Secondary | Select payment action | Bill Detail |
| 8 | Authentication Modal | Modal | Confirm payment tap | Payment Confirmation |
| 9 | Payment Success | Secondary | Auth success | Authentication Modal |
| 10 | Maintenance Mode Home | Primary (alt) | System state change | - |
| 11 | Queue Payment Confirmation | Secondary | Maintenance pay action | Maintenance Home |
| 12 | Emergency Options | Tab | Maintenance mode tab | Maintenance Home |
| 13 | Settings | Primary | Bottom nav / Home button | - |
| 14 | Cashflow Inputs | Secondary | Settings tap | Settings |
| 15 | Audit Log Viewer | Secondary | Settings tap | Settings |
| 16 | About / Help | Secondary | Settings tap | Settings |

**Total Screens:** 16  
**Primary Screens:** 4 (Home, Bill List, Maintenance Home, Settings)  
**Secondary Screens:** 10  
**Modals/Overlays:** 2

---

## 2. Navigation Architecture

### 2.1 Navigation Hierarchy

```
App Root
├── Bottom Navigation Bar (Normal Mode)
│   ├── [Home] Home Dashboard (Screen 1)
│   ├── [Bills] Bill List (Screen 2)
│   └── [Settings] Settings (Screen 13)
│
├── Maintenance Mode (Conditional - replaces normal nav)
│   └── Maintenance Mode Home (Screen 10)
│       ├── [Tab: Queued] Queued Payments View
│       └── [Tab: Help] Emergency Options (Screen 12)
│
└── Modal/Overlay Layer
    ├── Authentication Modal (Screen 8)
    └── Confirmation Dialogs (Delete, etc.)
```

### 2.2 Navigation Methods

| Method | Trigger | Behavior | Example |
|--------|---------|----------|---------|
| **Bottom Nav** | Tap nav icon | Navigate to primary screen, clear back stack | Home → Bills → Settings |
| **Card/List Tap** | Tap list item | Push to detail screen, add to back stack | Bill List → Bill Detail |
| **FAB (Floating Action Button)** | Tap + button | Open add/create screen | Add Bill |
| **Back Button** | Device back / App bar back | Pop from stack, return to previous | Edit Bill → Bill Detail |
| **Modal** | Trigger action | Overlay current screen, dismissible | Authentication Modal |
| **Deep Link** | Notification tap | Navigate to specific screen | Notification → Bill Detail |
| **State Change** | System event | Replace entire nav structure | Maintenance Mode ON → Maintenance Home |

### 2.3 Back Stack Behavior

**Normal Flow Example:**
```
Home Dashboard → Bill List → Bill Detail → Payment Confirmation → Auth Modal
[Back from Auth] → Payment Confirmation
[Back] → Bill Detail
[Back] → Bill List
[Back] → Home Dashboard
```

**Modal Behavior:**
```
Payment Confirmation → [Auth Modal appears]
[Back/Cancel on Modal] → Payment Confirmation (modal dismissed, no navigation)
[Auth Success on Modal] → Payment Success (modal dismissed, navigate forward)
```

**Bottom Nav Behavior:**
```
Home → Bill Detail → [Tap Settings Nav]
Result: Navigate to Settings, clear Bill Detail from stack
Next Back: Exit app (on Home/Bills/Settings root screens)
```

---

## 3. Screen-by-Screen Specifications

### Screen 1: Home Dashboard

**Purpose:** Landing screen, overview of payment status and quick actions

#### Layout Components
1. **App Bar**
   - Title: "Payment Assurance Copilot"
   - Right icon: Settings gear (→ Screen 13)
   - No back button

2. **Maintenance Banner** (Conditional)
   - Visible when: `settings.maintenance_mode = 1`
   - Text: "⚠️ Maintenance Mode Active (Est. end: [time])"
   - Tap: Navigate to Maintenance Mode Home (Screen 10)
   - Color: Orange warning background

3. **Demo Mode Badge** (Conditional)
   - Visible when: `settings.demo_mode = 1`
   - Text: "🎭 Demo Mode"
   - Position: Top right corner
   - Non-interactive

4. **Alert Card: Bills Needing Attention**
   - Visible when: Any bill has reminder date ≤ today AND status = Pending
   - Text: "[X] Bill(s) Need Attention"
   - Icon: Alert triangle
   - Tap: Navigate to Bill List filtered to "Needs Attention"

5. **Quick Stats Panel**
   - **Current Balance:** "$[amount]" (from cashflow_inputs table)
   - **Next Payday:** "[Date]" (from cashflow_inputs table)
   - **Safety Buffer:** "$[amount]" (from cashflow_inputs table)
   - Tap whole panel: Navigate to Cashflow Inputs (Screen 14)

6. **Upcoming Bills Summary**
   - Shows next 3 bills chronologically
   - Each row: Payee name, Amount, Due date, Status badge
   - Tap row: Navigate to Bill Detail (Screen 3) for that bill
   - "View All →" link at bottom: Navigate to Bill List (Screen 2)

7. **Primary Action Buttons**
   - Button: "Add New Bill"
     - Tap: Navigate to Add Bill (Screen 4)
   - Button: "View All Bills"
     - Tap: Navigate to Bill List (Screen 2)

8. **Bottom Navigation Bar**
   - [Home icon] - Active/highlighted
   - [Bills icon] - Tap → Bill List (Screen 2)
   - [Settings icon] - Tap → Settings (Screen 13)

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Settings gear icon | Tap | Navigate to Settings (Screen 13) |
| Maintenance banner | Tap | Navigate to Maintenance Home (Screen 10) |
| Alert card | Tap | Navigate to Bill List (Screen 2), filter="Needs Attention" |
| Quick stats panel | Tap | Navigate to Cashflow Inputs (Screen 14) |
| Upcoming bill row | Tap | Navigate to Bill Detail (Screen 3), pass bill_id |
| "View All →" link | Tap | Navigate to Bill List (Screen 2) |
| "Add New Bill" button | Tap | Navigate to Add Bill (Screen 4) |
| "View All Bills" button | Tap | Navigate to Bill List (Screen 2) |
| Bottom nav: Bills | Tap | Navigate to Bill List (Screen 2) |
| Bottom nav: Settings | Tap | Navigate to Settings (Screen 13) |
| Device Back button | Press | Exit app (confirm dialog: "Exit PAC?") |

#### Data Dependencies
- `cashflow_inputs` table (balance, payday, buffer)
- `bills` table (upcoming bills count, next 3 bills)
- `settings` table (maintenance_mode, demo_mode)

#### Screen States
- **Normal:** All features available
- **Maintenance Mode:** Banner visible, limited functionality messaging
- **No Bills:** Show empty state: "No bills yet. Add your first bill to get started."

---

### Screen 2: Bill List

**Purpose:** View and manage all bills

#### Layout Components

1. **App Bar**
   - Title: "My Bills"
   - Left icon: Back (→ Home if from Home, otherwise pop stack)
   - Right icon: Settings gear (→ Screen 13)

2. **Filter Tabs**
   - Tab 1: "All" (default)
   - Tab 2: "Due Soon" (due within 7 days)
   - Tab 3: "Scheduled" (status = Scheduled)
   - Tab 4: "Paid" (status = Paid)
   - Selection: Underline indicator, filters list below

3. **Search Bar** (Optional - if time)
   - Placeholder: "Search bills..."
   - Search on: Payee name
   - Real-time filter as user types

4. **Bill List (Scrollable)**
   - Sort: Due date ascending (closest first)
   - Each list item:
     - **Payee icon:** Category-based (⚡ Utilities, 🏠 Insurance, etc.)
     - **Payee name:** Bold, max 1 line (ellipsis if overflow)
     - **Amount:** "$[amount]" in large font
     - **Due date:** "[Month] [Day]" below payee
     - **Status badge:** Color-coded pill
       - Yellow: Due within 7 days
       - Red: Overdue (due_date < today)
       - Green: Paid ✓
       - Blue: Scheduled ⏰
     - **Right chevron:** ">"
   - Tap row: Navigate to Bill Detail (Screen 3)

5. **Empty State** (When no bills match filter)
   - Icon: Empty folder
   - Text: "No bills found"
   - Button: "Add Bill" → Navigate to Add Bill (Screen 4)

6. **Floating Action Button (FAB)**
   - Icon: "+" (Plus sign)
   - Position: Bottom right corner
   - Tap: Navigate to Add Bill (Screen 4)

7. **Bottom Navigation Bar**
   - [Home icon] - Tap → Home (Screen 1)
   - [Bills icon] - Active/highlighted
   - [Settings icon] - Tap → Settings (Screen 13)

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Navigate back (pop stack) |
| Settings gear | Tap | Navigate to Settings (Screen 13) |
| Filter tab | Tap | Update list filter, animate tab indicator |
| Search bar | Type | Filter list in real-time |
| Bill list item | Tap | Navigate to Bill Detail (Screen 3), pass bill_id |
| FAB (+) | Tap | Navigate to Add Bill (Screen 4) |
| Empty state "Add Bill" | Tap | Navigate to Add Bill (Screen 4) |
| Bottom nav: Home | Tap | Navigate to Home (Screen 1) |
| Bottom nav: Settings | Tap | Navigate to Settings (Screen 13) |
| Device Back | Press | Navigate back or exit if on root |

#### Data Dependencies
- `bills` table (all records, filtered by tab selection)

#### Screen States
- **Loading:** Show skeleton list items while querying database
- **Empty:** No bills in database, show empty state
- **Filtered Empty:** Bills exist but none match filter, show "No bills found"
- **Normal:** Display list of bills

---

### Screen 3: Bill Detail

**Purpose:** View bill details, get AI recommendation, take payment action

#### Layout Components

1. **App Bar**
   - Title: "[Payee Name]" (dynamic)
   - Left icon: Back (→ Bill List or previous screen)
   - Right icon: Edit (→ Edit Bill Screen 5)

2. **Bill Summary Card**
   - **Payee icon:** Large, category-based
   - **Payee name:** Bold, 20pt
   - **Amount:** "$[amount]" in very large font (32pt)
   - **Due date:** "[Weekday], [Month] [Day], [Year]"
   - **Category tag:** Small pill (e.g., "Utilities")
   - **Status badge:** Current status (Pending/Scheduled/Paid/Queued)

3. **Days Until Due Indicator**
   - Format: "[X] days until due" or "Due today!" or "Overdue by [X] days"
   - Color: Green (>7 days), Yellow (3-7 days), Red (<3 days or overdue)

4. **AI Recommendation Panel** (Conditional)
   - Visible when: 
     - Bill status = Pending
     - Due date within 5-7 days
     - Amount ≥ $50
     - Cashflow data available
   - **Icon:** 💡 Lightbulb
   - **Header:** "AI Recommendation"
   - **Recommendation text:** Large, bold
     - "Pay Now" (Green button)
     - "Schedule for [Date]" (Blue button)
     - "Remind Me in 2 Days" (Gray button)
   - **Rationale text:** 2-3 sentences explaining why
     - Example: "Paying now leaves only $620 before your rent is due on Feb 16. Waiting until payday on Feb 19 keeps a healthy $1,420 buffer."
   - **Disclaimer:** Small text: "This is a suggestion. You decide what's best."
   - **Tap recommendation button:** Navigate to Payment Confirmation (Screen 7), pre-fill with selected option

5. **Warning Banners** (Conditional, stacked)
   - **Insufficient Funds Warning**
     - Visible when: current_balance - amount < safety_buffer
     - Text: "⚠️ Low Balance Risk: Paying this may leave you with less than your safety buffer ($[amount])."
     - Button: "Proceed Anyway" or "Update Balance"
   - **Anomaly Detection Warning**
     - Visible when: |amount - avg_amount| / avg_amount > 0.30
     - Text: "⚠️ Unusual Amount: This bill is [X]% [higher/lower] than usual ($[avg]). Please verify before paying."
     - Button: "I Verified, Pay Anyway" or "Edit Amount"

6. **Historical Data Section** (If available)
   - Header: "Payment History"
   - Table:
     - Previous amounts: "$[amount1]", "$[amount2]", "$[amount3]"
     - Average: "$[avg]"
     - Last paid: "[Date]"

7. **Action Buttons** (If no AI recommendation shown)
   - Button: "Pay Now"
     - Tap: Navigate to Payment Confirmation (Screen 7), date = today
   - Button: "Schedule Payment"
     - Tap: Navigate to Payment Confirmation (Screen 7), show date picker
   - Button: "Mark as Paid"
     - Tap: Show confirmation dialog → Update status to Paid → Return to Bill List

8. **Secondary Actions**
   - Link: "View Audit Log for This Bill"
     - Tap: Navigate to Audit Log Viewer (Screen 15), filter by bill_id

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Pop to previous screen (Bill List) |
| Edit icon | Tap | Navigate to Edit Bill (Screen 5), pass bill_id |
| AI recommendation button | Tap | Navigate to Payment Confirmation (Screen 7), pass recommendation + date |
| "Proceed Anyway" (warning) | Tap | Dismiss warning, allow payment action |
| "Update Balance" (warning) | Tap | Navigate to Cashflow Inputs (Screen 14) |
| "I Verified, Pay Anyway" | Tap | Dismiss anomaly warning |
| "Edit Amount" | Tap | Navigate to Edit Bill (Screen 5), focus on amount field |
| "Pay Now" button | Tap | Navigate to Payment Confirmation (Screen 7), date=today |
| "Schedule Payment" button | Tap | Navigate to Payment Confirmation (Screen 7), show date picker |
| "Mark as Paid" button | Tap | Confirmation dialog → Update DB → Return to Bill List |
| "View Audit Log" link | Tap | Navigate to Audit Log (Screen 15), filter by bill_id |
| Device Back | Press | Pop to previous screen |

#### Data Dependencies
- `bills` table (bill details)
- `cashflow_inputs` table (for AI recommendation)
- `bill_history` table (for historical data, anomaly detection)
- `settings` table (safety_buffer, daily_cap)

#### Screen States
- **Normal:** Bill pending, no recommendation shown yet
- **Recommendation Active:** AI recommendation panel visible
- **Warning State:** One or more warning banners shown
- **Scheduled:** Bill already scheduled, show "Scheduled for [date]" and "Edit Schedule" button
- **Paid:** Bill paid, show "Paid on [date]" and no action buttons
- **Maintenance Mode:** Show maintenance banner, disable pay actions, show queue option

---

### Screen 4: Add Bill

**Purpose:** Create new bill entry

#### Layout Components

1. **App Bar**
   - Title: "Add New Bill"
   - Left icon: Back (→ previous screen)
   - Right icon: None

2. **Form Fields** (Scrollable)
   - **Payee Name**
     - Type: Text input
     - Placeholder: "Enter payee name (e.g., ComEd)"
     - Max length: 50 characters
     - Required: Yes
     - Validation: Not empty
   
   - **Amount**
     - Type: Number input (decimal)
     - Placeholder: "$0.00"
     - Prefix: "$" (non-editable)
     - Min: $0.01
     - Max: $9,999.99
     - Required: Yes
     - Validation: > 0, ≤ 9999.99
   
   - **Due Date**
     - Type: Date picker
     - Default: Today + 7 days
     - Required: Yes
     - Validation: Must be future date or today
   
   - **Category**
     - Type: Dropdown
     - Options: Utilities, Insurance, Subscriptions, Other
     - Default: Utilities
     - Required: Yes

3. **Auto-Populate Suggestion** (Optional - if time)
   - Below Payee Name field
   - Text: "Recently used: [Payee1], [Payee2]" (from bill_history)
   - Tap payee name: Auto-fill name and average amount

4. **Action Buttons**
   - Button: "Save Bill" (Primary, enabled when form valid)
     - Tap: Validate → Insert into DB → Navigate back to Bill List with success toast
   - Button: "Cancel" (Secondary)
     - Tap: Confirmation dialog "Discard changes?" → Yes: Navigate back, No: Stay

5. **Validation Feedback**
   - Show inline errors below fields:
     - "Payee name is required"
     - "Amount must be between $0.01 and $9,999.99"
     - "Due date cannot be in the past"

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Confirmation if fields dirty → Navigate back |
| Payee name input | Type | Update field value, clear error if valid |
| Amount input | Type | Update field value, format to 2 decimals on blur |
| Due date picker | Select date | Update field value |
| Category dropdown | Select option | Update field value |
| Recently used payee | Tap | Auto-fill payee name and last amount |
| "Save Bill" button | Tap | Validate → Insert DB → Back to Bill List + Toast |
| "Cancel" button | Tap | Confirm discard → Navigate back |
| Device Back | Press | Same as Cancel button |

#### Data Dependencies
- `bills` table (insert new record)
- `bill_history` table (optional, for auto-populate suggestions)
- `audit_logs` table (log "bill_created" action)

#### Screen States
- **Empty Form:** All fields blank/default, Save disabled
- **Partial Form:** Some fields filled, Save disabled if invalid
- **Valid Form:** All fields valid, Save enabled
- **Saving:** Show loading spinner during DB write
- **Error:** Show error toast if DB write fails

---

### Screen 5: Edit Bill

**Purpose:** Modify existing bill details

#### Layout Components
Same as Add Bill (Screen 4), with the following differences:

1. **App Bar**
   - Title: "Edit Bill"

2. **Form Fields**
   - Pre-populated with existing bill data

3. **Action Buttons**
   - Button: "Save Changes" (Primary)
     - Tap: Validate → Update DB → Navigate back to Bill Detail
   - Button: "Delete Bill" (Destructive, Red)
     - Tap: Confirmation dialog "Delete this bill? This cannot be undone." → Yes: Delete from DB → Navigate to Bill List
   - Button: "Cancel" (Secondary)
     - Tap: Confirmation if dirty → Navigate back

4. **Constraints**
   - Cannot edit if bill status = Paid
   - Cannot edit if bill status = Scheduled (must cancel schedule first)

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Confirm if dirty → Navigate back to Bill Detail |
| [All form fields] | Type/Select | Same as Add Bill (Screen 4) |
| "Save Changes" button | Tap | Validate → Update DB → Back to Bill Detail + Toast |
| "Delete Bill" button | Tap | Confirm dialog → Delete DB → Back to Bill List |
| "Cancel" button | Tap | Confirm discard → Navigate back |
| Device Back | Press | Same as Cancel button |

#### Data Dependencies
- `bills` table (update record)
- `audit_logs` table (log "bill_updated" or "bill_deleted")

#### Screen States
- **Loaded:** Form pre-filled with bill data
- **Editing:** User modifying fields
- **Locked:** Status = Paid or Scheduled, show message "Cannot edit [status] bills"
- **Saving:** Loading spinner during DB update
- **Error:** Error toast if update fails

---

### Screen 6: Payment Recommendation (Overlay)

**Note:** This is not a separate screen but a panel within Bill Detail (Screen 3). Documented here for clarity.

**Trigger:** Auto-display when opening Bill Detail if conditions met (see Screen 3)

**Behavior:**
- Appears as a card within Bill Detail scroll view
- Not a modal (user can scroll past it)
- Dismissible: "X" icon in corner → Hides panel, logs "recommendation_dismissed" in audit

**Alternative Implementation (if time):**
- Could be a bottom sheet that slides up from bottom
- Allows user to swipe down to dismiss

---

### Screen 7: Payment Confirmation

**Purpose:** Review and confirm payment details before scheduling

#### Layout Components

1. **App Bar**
   - Title: "Confirm Payment"
   - Left icon: Back (→ Bill Detail)
   - Right icon: None

2. **Payment Summary Card**
   - **Header:** "Review Payment Details"
   - **Table:**
     - Payee: [Name]
     - Amount: $[amount] (large, bold)
     - Payment Date: [Selected date or "Today"]
     - Account: Checking ...1234 (mock)
   - **Divider line**

3. **Impact Preview**
   - Text: "After payment, your balance will be:"
   - Amount: "$[current_balance - payment_amount]" (large)
   - Color: Green if ≥ safety_buffer, Orange if < safety_buffer

4. **Safety Check Warnings** (Conditional, same as Bill Detail)
   - Insufficient funds warning
   - Anomaly detection warning
   - Daily cap warning (if applicable)

5. **Date Selector** (If "Schedule Payment" selected)
   - Default: Recommendation date or today
   - Type: Date picker button
   - Tap: Opens date picker modal
   - Constraint: Date must be ≥ today, ≤ due_date

6. **Demo Disclaimer**
   - Text: "⚠️ This is a simulated payment for demo purposes only. No actual funds will be transferred."
   - Color: Gray background
   - Position: Above action buttons

7. **Action Buttons**
   - Button: "Confirm Payment" (Primary, Green)
     - Tap: Navigate to Authentication Modal (Screen 8)
   - Button: "Change Date" (Secondary, if scheduled)
     - Tap: Open date picker
   - Button: "Cancel" (Secondary)
     - Tap: Navigate back to Bill Detail

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Navigate back to Bill Detail (no changes saved) |
| Date picker button | Tap | Open date picker modal → Select date → Update display |
| "Confirm Payment" button | Tap | Navigate to Authentication Modal (Screen 8) |
| "Change Date" button | Tap | Open date picker modal |
| "Cancel" button | Tap | Navigate back to Bill Detail |
| Device Back | Press | Navigate back to Bill Detail |

#### Data Dependencies
- `bills` table (read for summary)
- `cashflow_inputs` table (read for impact preview)
- `settings` table (read for daily_cap, safety_buffer)

#### Screen States
- **Normal:** All details displayed, Confirm enabled
- **Warning Active:** Warning banner shown, Confirm enabled but requires acknowledgment
- **Cap Exceeded:** Daily cap reached, Confirm disabled, message "Daily limit reached"
- **Loading Date Picker:** Date picker modal open

---

### Screen 8: Authentication Modal

**Purpose:** Mock biometric/PIN authentication before payment

#### Layout Components

1. **Modal Overlay**
   - Background: Semi-transparent black (60% opacity)
   - Position: Centered on screen
   - Dismissible: Back button or tap outside (returns to Payment Confirmation)

2. **Modal Content Card**
   - **Icon:** Fingerprint or lock icon (large)
   - **Title:** "Authenticate to Schedule Payment"
   - **Subtitle:** "Confirm it's you before proceeding"
   - **Payment Summary:** (Small text)
     - Payee: [Name]
     - Amount: $[amount]
     - Date: [date]

3. **Authentication Button**
   - Button: "Touch ID" or "Use PIN" (Primary)
     - Tap: Simulate auth (0.5s delay) → Success animation → Navigate to Payment Success (Screen 9)
   - Alternative: "Cancel"
     - Tap: Dismiss modal → Return to Payment Confirmation

4. **Demo Note**
   - Text: "(Demo: Tap button to simulate authentication)"
   - Color: Gray, small font

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| "Touch ID" / "Use PIN" button | Tap | 0.5s delay → Success animation → Navigate to Payment Success (Screen 9) |
| "Cancel" button | Tap | Dismiss modal → Return to Payment Confirmation (Screen 7) |
| Tap outside modal | Tap | Dismiss modal → Return to Payment Confirmation (Screen 7) |
| Device Back | Press | Dismiss modal → Return to Payment Confirmation (Screen 7) |

#### Data Dependencies
- None (purely UI simulation)

#### Screen States
- **Idle:** Button ready to tap
- **Authenticating:** Button shows spinner (0.5s)
- **Success:** Checkmark animation (0.3s) → Navigate to Success screen
- **Error:** (Not implemented in MVP - always succeeds)

---

### Screen 9: Payment Success

**Purpose:** Confirm successful payment scheduling

#### Layout Components

1. **App Bar**
   - Title: "Payment Scheduled"
   - Left icon: None (force forward navigation)
   - Right icon: Close "X" (→ Home Dashboard)

2. **Success Animation**
   - Icon: Large green checkmark with scale-in animation
   - Duration: 0.5s on screen entry

3. **Confirmation Message**
   - **Header:** "✓ Payment Scheduled Successfully"
   - **Subheader:** "Your payment has been queued"

4. **Payment Details Card**
   - Payee: [Name]
   - Amount: $[amount]
   - Scheduled for: [Date] at [Time]
   - Reference ID: PAC-YYYYMMDD-NNN (copyable)

5. **Next Steps Section**
   - Text: "What happens next:"
   - Bullet list:
     - "We'll remind you 1 day before the payment processes"
     - "You can cancel or reschedule anytime in Bill Details"
     - "Payment will be queued on [date] at 8:00 AM"

6. **Action Buttons**
   - Button: "Done" (Primary)
     - Tap: Navigate to Home Dashboard (Screen 1)
   - Link: "View Bill Details"
     - Tap: Navigate to Bill Detail (Screen 3) for this bill
   - Link: "Schedule Another Payment"
     - Tap: Navigate to Bill List (Screen 2)

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Close "X" icon | Tap | Navigate to Home Dashboard (Screen 1) |
| Reference ID | Long press | Copy to clipboard + Toast "Copied!" |
| "Done" button | Tap | Navigate to Home Dashboard (Screen 1) |
| "View Bill Details" link | Tap | Navigate to Bill Detail (Screen 3) |
| "Schedule Another Payment" link | Tap | Navigate to Bill List (Screen 2) |
| Device Back | Press | Navigate to Home Dashboard (Screen 1) |

#### Data Dependencies
- `bills` table (updated status to Scheduled)
- `payments` table (new record inserted)
- `audit_logs` table (log "payment_scheduled" action)

#### Screen States
- **Success:** Animation played, details shown
- **No Animation:** (If returning from Home) Show static success state

#### Side Effects
- Insert record into `payments` table
- Update `bills.status` to "Scheduled"
- Update `bills.reference_id` with PAC-YYYYMMDD-NNN
- Insert audit log entry
- Show toast notification: "Payment scheduled for [date]"

---

### Screen 10: Maintenance Mode Home

**Purpose:** Limited functionality during system maintenance

#### Layout Components

1. **App Bar**
   - Title: "Payment Assurance Copilot"
   - Right icon: Settings gear (→ Settings, but limited)
   - No back button (this is root screen in maintenance mode)

2. **Maintenance Banner** (Prominent)
   - Background: Orange gradient
   - Icon: ⚠️ Warning
   - **Title:** "Maintenance Mode Active"
   - **Subtitle:** "Limited service - Payments cannot be processed"
   - **Estimated end:** "Service resumes at [time]"

3. **Balance Snapshot Card**
   - **Label:** "Last Known Balance"
   - **Amount:** "$[amount]" (large, grayed out)
   - **Timestamp:** "*As of [date] [time]" (italic, small)
   - **Disclaimer:** "May not reflect recent activity"
   - Non-interactive

4. **Tab Navigation**
   - Tab 1: "Queued Payments" (default)
   - Tab 2: "Emergency Options"
   - Selection: Underline indicator

5. **Queued Payments Tab Content** (Tab 1)
   - **Section header:** "Bills Due During Maintenance"
   - **List of bills:**
     - Each item:
       - Payee name
       - Amount
       - Due date
       - Status badge: "Queued for [time]" or "Not Yet Queued"
     - Tap item: Navigate to Bill Detail (limited actions)
   - **Empty state:** "No bills due during maintenance period"

6. **Action Buttons (Queued Tab)**
   - Button: "Queue Payment" (for bills with status "Not Yet Queued")
     - Tap: Navigate to Queue Payment Confirmation (Screen 11)

7. **Emergency Options Tab Content** (Tab 2)
   - **Header:** "Need Help Right Now?"
   - **Cards (static info):**
     - **Call Us:**
       - Text: "1-800-BANK-HELP (24/7)"
       - Button: "Call Now" → Opens phone dialer
     - **ATM Locator:**
       - Text: "Find nearby ATMs for cash withdrawals"
       - Button: "Open Map" → Opens Google Maps (demo: toast "Map would open")
     - **Branch Hours:**
       - Text: "Monday-Friday: 9 AM - 5 PM, Saturday: 9 AM - 1 PM"
       - Address: "123 Main St, Demo City, ST 12345"
     - **Online Help:**
       - Text: "Visit our help center for FAQs"
       - Link: "help.demobank.com"

8. **Info Callout** (Bottom of Queued tab)
   - Icon: ℹ️ Info
   - Text: "Queued payments are INTENTS only. They will process automatically when service resumes. You will receive a confirmation when complete."

9. **Exit Maintenance Mode** (If demo toggle)
   - Link: "Exit Maintenance Mode (Demo Only)"
     - Tap: Confirmation dialog → Deactivate maintenance mode → Navigate to Home (Screen 1)

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Settings gear | Tap | Navigate to Settings (Screen 13), limited options |
| Tab: Queued Payments | Tap | Switch to Queued tab view |
| Tab: Emergency Options | Tap | Switch to Emergency tab view (Screen 12) |
| Queued bill item | Tap | Navigate to Bill Detail (Screen 3), limited actions |
| "Queue Payment" button | Tap | Navigate to Queue Payment Confirmation (Screen 11) |
| "Call Now" button | Tap | Open device phone dialer with number |
| "Open Map" button | Tap | Open Google Maps (demo: show toast) |
| "Exit Maintenance Mode" link | Tap | Confirm → Deactivate maintenance → Navigate to Home |
| Device Back | Press | Exit app confirmation dialog |

#### Data Dependencies
- `settings` table (maintenance_mode flag)
- `cashflow_inputs` table (last known balance snapshot)
- `bills` table (bills due during maintenance window)
- `payments` table (queued payments)

#### Screen States
- **Active Maintenance:** Full maintenance UI shown
- **No Bills Due:** Empty state in Queued tab
- **Has Queued Payments:** List populated with queued items
- **Emergency Tab Active:** Emergency options displayed

---

### Screen 11: Queue Payment Confirmation

**Purpose:** Queue payment intent during maintenance

#### Layout Components

1. **App Bar**
   - Title: "Queue Payment"
   - Left icon: Back (→ Maintenance Home)

2. **Informational Banner**
   - Background: Blue info background
   - Icon: ℹ️
   - **Title:** "Payment Intent Only"
   - **Text:** "System maintenance is in progress. This payment will be QUEUED (not processed immediately) and will execute automatically when service resumes at approximately [time]."

3. **Payment Summary** (Same as Screen 7)
   - Payee, Amount, Queued for date/time

4. **Balance Disclaimer**
   - Text: "Your balance shown ($[amount]) is a snapshot from [timestamp]. Actual balance may differ when payment processes."
   - Color: Gray background

5. **Confirmation Checkbox**
   - Label: "☐ I understand this is a payment INTENT and will process later"
   - Required: Must be checked to enable Confirm button

6. **Action Buttons**
   - Button: "Confirm Queue" (Primary, enabled when checkbox checked)
     - Tap: Navigate to Authentication Modal (Screen 8, but modified success flow)
   - Button: "Cancel"
     - Tap: Navigate back to Maintenance Home

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Navigate to Maintenance Home (Screen 10) |
| Confirmation checkbox | Tap | Toggle checkbox, enable/disable Confirm button |
| "Confirm Queue" button | Tap | Navigate to Authentication Modal → Success → Return to Maintenance Home with queued status updated |
| "Cancel" button | Tap | Navigate to Maintenance Home (Screen 10) |
| Device Back | Press | Navigate to Maintenance Home (Screen 10) |

#### Data Dependencies
- `bills` table (read for summary)
- `cashflow_inputs` table (balance snapshot)
- `payments` table (insert queued payment)

#### Screen States
- **Checkbox Unchecked:** Confirm button disabled
- **Checkbox Checked:** Confirm button enabled
- **Queueing:** Loading state during DB write

#### Side Effects
- Insert record into `payments` table with status "QUEUED"
- Update `bills.status` to "Queued"
- Insert audit log: "payment_queued_during_maintenance"
- No balance change (snapshot only)

---

### Screen 12: Emergency Options

**Note:** This is Tab 2 of Maintenance Mode Home (Screen 10). Documented here for reference but implemented as a tab, not separate screen.

See Screen 10, Tab 2 content.

---

### Screen 13: Settings

**Purpose:** Configure app preferences and access system features

#### Layout Components

1. **App Bar**
   - Title: "Settings"
   - Left icon: Back (→ previous screen)
   - Right icon: None

2. **Settings Sections** (Scrollable list)

   **Section 1: Cashflow Settings**
   - Item: "Current Balance"
     - Value: "$[amount]"
     - Tap: Navigate to Cashflow Inputs (Screen 14)
   - Item: "Next Payday"
     - Value: "[Date]"
     - Tap: Navigate to Cashflow Inputs (Screen 14)
   - Item: "Safety Buffer"
     - Value: "$[amount]"
     - Tap: Navigate to Cashflow Inputs (Screen 14)

   **Section 2: Payment Limits**
   - Item: "Daily Payment Cap"
     - Value: "$[amount]"
     - Tap: Open inline editor → Number input → Save

   **Section 3: System Settings**
   - Item: "Maintenance Mode" (Demo)
     - Type: Toggle switch
     - Value: ON/OFF
     - Tap: Toggle maintenance mode → Show confirmation dialog → Update DB → Reload app state
   - Item: "Demo Mode"
     - Type: Toggle switch
     - Value: ON/OFF (default ON for hackathon)
     - Tap: Toggle demo mode → Update DB
   - Item: "Notifications"
     - Type: Toggle switch
     - Value: ON/OFF
     - Tap: Toggle notification preference (mock)

   **Section 4: Data & Privacy**
   - Item: "View Audit Log"
     - Icon: Right chevron
     - Tap: Navigate to Audit Log Viewer (Screen 15)
   - Item: "Reset Demo Data"
     - Icon: ⚠️ Warning
     - Tap: Confirmation dialog "Delete all bills and logs? This cannot be undone." → Yes: Clear DB tables → Navigate to Home with success toast

   **Section 5: Help & About**
   - Item: "How to Use PAC"
     - Tap: Navigate to About/Help (Screen 16)
   - Item: "About This App"
     - Tap: Navigate to About/Help (Screen 16)
   - Item: "App Version"
     - Value: "1.0.0 (Demo)"
     - Non-interactive

3. **Bottom Navigation Bar**
   - [Home icon] - Tap → Home (Screen 1)
   - [Bills icon] - Tap → Bill List (Screen 2)
   - [Settings icon] - Active/highlighted

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Navigate to previous screen |
| "Current Balance" row | Tap | Navigate to Cashflow Inputs (Screen 14) |
| "Next Payday" row | Tap | Navigate to Cashflow Inputs (Screen 14) |
| "Safety Buffer" row | Tap | Navigate to Cashflow Inputs (Screen 14) |
| "Daily Payment Cap" row | Tap | Open inline number input → Update DB → Refresh display |
| Maintenance Mode toggle | Tap | Confirm → Toggle setting → Update DB → App state change |
| Demo Mode toggle | Tap | Toggle setting → Update DB |
| Notifications toggle | Tap | Toggle setting → Update DB (mock) |
| "View Audit Log" row | Tap | Navigate to Audit Log Viewer (Screen 15) |
| "Reset Demo Data" row | Tap | Confirm dialog → Clear DB → Navigate to Home + Toast |
| "How to Use PAC" row | Tap | Navigate to About/Help (Screen 16) |
| "About This App" row | Tap | Navigate to About/Help (Screen 16) |
| Bottom nav: Home | Tap | Navigate to Home (Screen 1) |
| Bottom nav: Bills | Tap | Navigate to Bill List (Screen 2) |
| Device Back | Press | Navigate to previous screen or Home |

#### Data Dependencies
- `cashflow_inputs` table (read/write)
- `settings` table (read/write for all toggles and caps)

#### Screen States
- **Normal:** All settings displayed and interactive
- **Maintenance Mode ON:** Indicator shown, app state changed
- **Demo Mode OFF:** AI uses live API instead of cache (if available)

---

### Screen 14: Cashflow Inputs

**Purpose:** Edit synthetic cashflow data for AI recommendations

#### Layout Components

1. **App Bar**
   - Title: "Cashflow Settings"
   - Left icon: Back (→ Settings)

2. **Instructions**
   - Text: "Provide your cashflow information to help PAC make better recommendations."
   - Icon: 💡 Lightbulb

3. **Form Fields**
   - **Current Balance**
     - Type: Number input (currency)
     - Placeholder: "$0.00"
     - Prefix: "$"
     - Min: $0
     - Max: $999,999.99
     - Helper text: "Enter your checking account balance"
   
   - **Next Payday Date**
     - Type: Date picker
     - Default: [Current + 14 days]
     - Helper text: "When do you next get paid?"
   
   - **Safety Buffer**
     - Type: Number input (currency)
     - Placeholder: "$500.00"
     - Min: $100
     - Max: $2,000
     - Helper text: "Minimum balance you want to maintain"

4. **Action Buttons**
   - Button: "Save Changes" (Primary)
     - Tap: Validate → Update DB → Navigate back to Settings + Toast "Cashflow updated"
   - Button: "Cancel"
     - Tap: Discard changes → Navigate back to Settings

5. **Demo Note**
   - Text: "⚠️ For demo purposes only. Production app would sync with real account data."
   - Color: Gray background

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Confirm if dirty → Navigate to Settings |
| Current Balance input | Type | Update value, format on blur |
| Next Payday picker | Select date | Update value |
| Safety Buffer input | Type | Update value, format on blur |
| "Save Changes" button | Tap | Validate → Update DB → Back to Settings + Toast |
| "Cancel" button | Tap | Discard → Back to Settings |
| Device Back | Press | Same as Cancel |

#### Data Dependencies
- `cashflow_inputs` table (update single row, id=1)
- `audit_logs` table (log "cashflow_updated")

#### Screen States
- **Loaded:** Form pre-filled with current values
- **Editing:** User modifying fields
- **Invalid:** Show validation errors if amount out of range
- **Saving:** Loading spinner during DB update

---

### Screen 15: Audit Log Viewer

**Purpose:** View all user actions and system events

#### Layout Components

1. **App Bar**
   - Title: "Audit Log"
   - Left icon: Back (→ Settings or previous screen)
   - Right icon: Filter icon (optional)

2. **Filter Bar** (Optional - if time)
   - Dropdown: "All Actions" / "Payments" / "Recommendations" / "Settings Changes"
   - Date range picker

3. **Log Entries List** (Scrollable, reverse chronological)
   - Each entry card:
     - **Timestamp:** "[Date] [Time]" (gray, small)
     - **Action Type Icon:**
       - 💵 Payment scheduled/queued/cancelled
       - 💡 Recommendation shown/accepted/rejected
       - ⚙️ Setting changed
       - 📝 Bill created/edited/deleted
       - ⚠️ Warning triggered
     - **Action Description:** "[Action] [Details]"
       - Example: "Payment scheduled: ComEd Electric $180 for Feb 19"
       - Example: "AI recommended: Schedule for payday (User accepted)"
       - Example: "Warning triggered: Insufficient funds risk"
     - **Reference ID:** (if applicable)
       - Example: "Ref: PAC-20260212-001"
     - **Details JSON:** (Collapsed by default)
       - Tap: Expand to show raw JSON data

4. **Empty State** (No logs)
   - Text: "No audit logs yet. Actions will appear here as you use the app."

5. **Export Button** (If time permits)
   - Button: "Export to CSV"
     - Tap: Generate CSV → Share sheet to save/send file

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Navigate to previous screen |
| Filter dropdown | Select | Update list to show filtered entries |
| Date range picker | Select dates | Update list to show date range |
| Log entry | Tap | Expand/collapse details JSON |
| "Export to CSV" button | Tap | Generate CSV → Share sheet |
| Device Back | Press | Navigate to previous screen |

#### Data Dependencies
- `audit_logs` table (read all or filtered)

#### Screen States
- **Loading:** Skeleton list while querying DB
- **Empty:** No logs in database
- **Normal:** List of logs displayed
- **Filtered:** Subset of logs shown based on filter

---

### Screen 16: About / Help

**Purpose:** App information and user guide

#### Layout Components

1. **App Bar**
   - Title: "About PAC"
   - Left icon: Back (→ Settings)

2. **Sections** (Scrollable)

   **Section 1: About This App**
   - Text: "Payment Assurance Copilot (PAC) is a demo application for PROCOM '26 AI in Banking hackathon."
   - Text: "This app is NOT a real banking service. All data is synthetic and for demonstration purposes only."

   **Section 2: How It Works**
   - **Card: Smart Reminders**
     - Icon: 💡
     - Text: "PAC analyzes your cashflow and recommends the best time to pay bills."
   - **Card: Safety Checks**
     - Icon: 🛡️
     - Text: "Warnings appear if paying a bill might leave you with insufficient funds or if amounts look unusual."
   - **Card: Maintenance Mode**
     - Icon: ⚠️
     - Text: "During system maintenance, queue payments to process automatically when service resumes."

   **Section 3: Responsible AI**
   - **Card: You're in Control**
     - Text: "AI suggests, you decide. Every payment requires your explicit confirmation."
   - **Card: Transparency**
     - Text: "All recommendations include explanations. View the audit log anytime."
   - **Card: Limitations**
     - Text: "AI cannot access real bank data or execute payments. This is a demonstration only."

   **Section 4: Demo Notes**
   - Text: "This demo uses:"
   - Bullet list:
     - Synthetic cashflow data (you enter manually)
     - Simulated payments (no real money moves)
     - Mock authentication (no real security)
     - Local storage only (no cloud sync)

   **Section 5: Team**
   - Text: "Built by [Team Names] for PROCOM '26"
   - Link: "GitHub Repository" → Opens browser (demo: toast)

   **Section 6: Version**
   - Text: "Version 1.0.0 (Demo Build)"
   - Text: "February 2026"

3. **Action Buttons**
   - Button: "Back to Settings"
     - Tap: Navigate to Settings (Screen 13)

#### Interaction Map

| Element | Interaction | Result |
|---------|-------------|--------|
| Back button | Tap | Navigate to Settings (Screen 13) |
| GitHub link | Tap | Open browser to repo (demo: toast "Link would open") |
| "Back to Settings" button | Tap | Navigate to Settings (Screen 13) |
| Device Back | Press | Navigate to Settings (Screen 13) |

#### Data Dependencies
- None (static content)

---

## 4. User Journey Flows

### 4.1 Journey A: New Bill Entry → AI Recommendation → Payment Scheduling

**Entry Point:** Home Dashboard  
**Goal:** Add a bill, get recommendation, schedule payment  
**Duration:** ~90 seconds

```
┌─────────────────────────────────────────────────────────────────┐
│ HOME DASHBOARD (Screen 1)                                       │
│ • User sees "Add New Bill" button                               │
│ └─→ Tap "Add New Bill"                                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ ADD BILL (Screen 4)                                             │
│ • User enters:                                                  │
│   - Payee: "ComEd Electric"                                     │
│   - Amount: $180                                                │
│   - Due Date: Feb 17, 2026                                      │
│   - Category: Utilities                                         │
│ └─→ Tap "Save Bill"                                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ BILL LIST (Screen 2)                                            │
│ • Success toast: "Bill added"                                   │
│ • New bill appears in list with "Due in 5 days" badge           │
│ └─→ Tap bill row                                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ BILL DETAIL (Screen 3)                                          │
│ • AI Recommendation panel appears:                              │
│   "💡 Recommendation: Schedule for Feb 19 (payday)"             │
│   Rationale: "Paying now leaves only $2,620..."                 │
│ └─→ Tap "Schedule for Feb 19" button                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ PAYMENT CONFIRMATION (Screen 7)                                 │
│ • Shows: Payee, Amount, Date (Feb 19), Impact preview           │
│ • Demo disclaimer visible                                       │
│ └─→ Tap "Confirm Payment"                                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ AUTHENTICATION MODAL (Screen 8)                                 │
│ • Modal appears: "Authenticate to Schedule Payment"             │
│ • Shows: Touch ID icon, payment summary                         │
│ └─→ Tap "Touch ID" button                                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    [0.5s auth simulation]
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ PAYMENT SUCCESS (Screen 9)                                      │
│ • Green checkmark animation                                     │
│ • Shows: "Payment Scheduled Successfully"                       │
│ • Reference ID: PAC-20260212-001                                │
│ └─→ Tap "Done"                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ HOME DASHBOARD (Screen 1)                                       │
│ • Returns to home                                               │
│ • Bill now shows "Scheduled ✓" in upcoming bills                │
│ END                                                             │
└─────────────────────────────────────────────────────────────────┘
```

**Back Stack at Success Screen:** [Home → Bill List → Bill Detail → Payment Confirmation → Success]

---

### 4.2 Journey B: Maintenance Mode → Queue Payment Intent

**Entry Point:** Home Dashboard (Maintenance Mode ON)  
**Goal:** Queue a payment during system downtime  
**Duration:** ~60 seconds

```
┌─────────────────────────────────────────────────────────────────┐
│ HOME DASHBOARD (Screen 1)                                       │
│ • Maintenance banner visible: "⚠️ Maintenance Mode Active"      │
│ └─→ Tap banner                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ MAINTENANCE MODE HOME (Screen 10)                               │
│ • Tab: "Queued Payments" (active)                               │
│ • Shows balance snapshot: "$1,450 *as of Feb 12 11 PM"          │
│ • List shows: "Internet Bill - $89 (Due Today) - Not Queued"    │
│ └─→ Tap "Queue Payment" button                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ QUEUE PAYMENT CONFIRMATION (Screen 11)                          │
│ • Info banner: "Payment INTENT only"                            │
│ • Shows: Payee, Amount, Queue time (6 AM)                       │
│ • Checkbox: "☐ I understand this is a payment INTENT"           │
│ └─→ Check checkbox                                              │
│ └─→ Tap "Confirm Queue" (now enabled)                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ AUTHENTICATION MODAL (Screen 8)                                 │
│ • Modal appears with payment summary                            │
│ └─→ Tap "Touch ID"                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    [0.5s auth simulation]
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ MAINTENANCE MODE HOME (Screen 10)                               │
│ • Returns to maintenance home                                   │
│ • Bill now shows: "Queued for 6:00 AM ✓"                        │
│ • Toast: "Payment queued successfully"                          │
│ └─→ Tap "Emergency Options" tab                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ EMERGENCY OPTIONS (Screen 12)                                   │
│ • Shows: Call button, ATM locator, branch hours                 │
│ • User reviews options                                          │
│ END                                                             │
└─────────────────────────────────────────────────────────────────┘
```

**Back Stack at End:** [Maintenance Home (Queued tab)]

---

### 4.3 Journey C: Anomaly Detection → Verify → Pay Anyway

**Entry Point:** Bill List  
**Goal:** Handle unusually high bill amount  
**Duration:** ~60 seconds

```
┌─────────────────────────────────────────────────────────────────┐
│ BILL LIST (Screen 2)                                            │
│ • User sees bill: "Comcast Internet - $145" (usually $89)       │
│ └─→ Tap bill row                                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ BILL DETAIL (Screen 3)                                          │
│ • Warning banner appears:                                       │
│   "⚠️ Unusual Amount: This bill is 63% higher than usual ($89)" │
│ • AI Recommendation: "Pay Now" (below warning)                  │
│ • User mentally verifies: "Oh right, modem upgrade charge"      │
│ └─→ Tap "I Verified, Pay Anyway"                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    [Warning dismissed]
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ BILL DETAIL (Screen 3)                                          │
│ • Warning banner removed                                        │
│ • AI Recommendation still visible                               │
│ └─→ Tap "Pay Now" button                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ PAYMENT CONFIRMATION (Screen 7)                                 │
│ • Shows: Comcast, $145, Today                                   │
│ └─→ Tap "Confirm Payment"                                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ AUTHENTICATION MODAL (Screen 8)                                 │
│ └─→ Tap "Touch ID"                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ PAYMENT SUCCESS (Screen 9)                                      │
│ • Payment scheduled/processed                                   │
│ • Audit log records: "User proceeded despite anomaly warning"   │
│ END                                                             │
└─────────────────────────────────────────────────────────────────┘
```

---

### 4.4 Journey D: View Audit Log

**Entry Point:** Settings  
**Goal:** Review app activity history  
**Duration:** ~30 seconds

```
┌─────────────────────────────────────────────────────────────────┐
│ SETTINGS (Screen 13)                                            │
│ • User scrolls to "Data & Privacy" section                      │
│ └─→ Tap "View Audit Log"                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ AUDIT LOG VIEWER (Screen 15)                                    │
│ • Shows chronological list (newest first):                      │
│   1. "2026-02-12 10:34 - Payment scheduled (PAC-001)"           │
│   2. "2026-02-12 10:33 - AI recommended: Schedule for payday"   │
│   3. "2026-02-12 10:30 - Bill created: ComEd Electric"          │
│   4. "2026-02-12 09:15 - Cashflow updated"                      │
│ • User taps entry #2 to expand                                  │
│ └─→ Tap log entry                                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ AUDIT LOG VIEWER (Screen 15)                                    │
│ • Entry #2 expands to show JSON details:                        │
│   {                                                             │
│     "bill_id": 1,                                               │
│     "recommendation": "schedule_payday",                        │
│     "rationale": "Paying now leaves only $2,620...",            │
│     "user_choice": "accepted"                                   │
│   }                                                             │
│ • User reviews data                                             │
│ └─→ Tap Back button                                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ SETTINGS (Screen 13)                                            │
│ • Returns to settings                                           │
│ END                                                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. State Transitions

### 5.1 Bill Status State Machine

```
┌─────────┐
│ PENDING │ ← Initial state when bill created
└────┬────┘
     │
     ├──→ [User taps "Schedule Payment"] ──→ ┌───────────┐
     │                                        │ SCHEDULED │
     │                                        └─────┬─────┘
     │                                              │
     │                                              ├──→ [Scheduled date reached - Demo only]
     │                                              │     ┌──────────┐
     │                                              └───→ │ SIMULATED│ (Demo final state)
     │                                                    └──────────┘
     │
     ├──→ [User taps "Mark as Paid"] ──────→ ┌──────┐
     │                                        │ PAID │ (Final state)
     │                                        └──────┘
     │
     └──→ [Maintenance Mode + Queue] ──────→ ┌────────┐
                                              │ QUEUED │
                                              └────┬───┘
                                                   │
                                                   └──→ [Maintenance ends - Demo only]
                                                         ┌───────────┐
                                                         │ SCHEDULED │
                                                         └───────────┘
```

**State Definitions:**
- **PENDING:** Bill exists, no action taken
- **SCHEDULED:** Payment scheduled for future date
- **QUEUED:** Payment queued during maintenance (special)
- **PAID:** User manually marked as paid
- **SIMULATED:** Payment processed in demo (not real)

**State Constraints:**
- Cannot edit PAID bills
- Cannot delete SCHEDULED bills without confirmation
- QUEUED bills can only be created during maintenance mode
- Bills overdue (due_date < today) remain PENDING but display red warning

---

### 5.2 App Mode State Machine

```
┌──────────────┐
│ NORMAL MODE  │ ← Default state
└──────┬───────┘
       │
       ├──→ [User toggles Maintenance Mode ON in Settings]
       │     OR [Scheduled maintenance starts - not in demo]
       │
       ↓
┌──────────────────┐
│ MAINTENANCE MODE │
└──────┬───────────┘
       │
       ├──→ Navigation structure changes:
       │     • Bottom nav hidden
       │     • Maintenance Home replaces normal Home
       │     • Payment actions disabled (Queue only)
       │     • Balance shows snapshot with disclaimer
       │
       ├──→ [User toggles Maintenance Mode OFF in Settings]
       │     OR [Maintenance window ends]
       │
       ↓
┌──────────────┐
│ NORMAL MODE  │ ← Returns to normal
└──────────────┘
```

**Mode Behaviors:**

| Feature | Normal Mode | Maintenance Mode |
|---------|-------------|------------------|
| Navigation | Bottom nav (Home, Bills, Settings) | Single screen (Maintenance Home) with tabs |
| Payment Actions | Pay Now, Schedule Payment | Queue Payment (intent only) |
| Balance Display | Current (editable in settings) | Snapshot with timestamp |
| Bill Detail | Full access, edit/delete allowed | Read-only, queue option only |
| Add Bill | Allowed | Allowed |
| AI Recommendations | Active | Active (but suggests Queue instead) |

---

### 5.3 Authentication Modal Flow

```
┌────────────────────────┐
│ Payment Confirmation   │
│ (Screen 7 or 11)       │
└───────────┬────────────┘
            │
            └──→ [User taps "Confirm Payment" or "Confirm Queue"]
                 
                 ┌──────────────────────┐
                 │ Authentication Modal │ ← Modal appears
                 │ (Screen 8)           │
                 └──────┬───────────────┘
                        │
                        ├──→ [User taps "Touch ID" / "Use PIN"]
                        │     
                        │    [0.5s simulated delay]
                        │     
                        │    [Success animation: 0.3s]
                        │     
                        ↓
                 ┌──────────────────────┐
                 │ Payment Success      │ ← Modal dismissed, navigate forward
                 │ (Screen 9)           │
                 └──────────────────────┘
                        
                        ├──→ [User taps "Cancel" or Back]
                        │     
                        ↓
                 ┌──────────────────────┐
                 │ Payment Confirmation │ ← Modal dismissed, return to previous
                 │ (Screen 7 or 11)     │
                 └──────────────────────┘
```

**Modal Behavior:**
- Modal overlays current screen (does not replace in navigation stack)
- Tapping outside modal dismisses it (returns to Payment Confirmation)
- Device back button dismisses modal
- Success path navigates forward (adds Payment Success to stack)
- Cancel path returns to previous screen without navigation change

---

## 6. Edge Cases & Error Handling

### 6.1 Data Validation Errors

| Scenario | Trigger | UI Response | User Action Required |
|----------|---------|-------------|---------------------|
| **Empty payee name** | Save bill with blank name | Inline error below field: "Payee name is required" | Enter name |
| **Amount = $0** | Save bill with $0 amount | Inline error: "Amount must be greater than $0" | Enter valid amount |
| **Amount > $9,999.99** | Enter amount > limit | Inline error: "Amount cannot exceed $9,999.99" | Reduce amount |
| **Due date in past** | Select past date | Inline error: "Due date cannot be in the past" | Select future date |
| **Daily cap exceeded** | Attempt payment when cap reached | Dialog: "Daily limit reached ($2,000). Try again tomorrow or adjust limit in Settings." + [Go to Settings] [Cancel] | Wait or change cap |
| **Invalid date format** | Manual date entry (if allowed) | Auto-format or show error: "Invalid date format" | Use date picker |

---

### 6.2 System Errors

| Scenario | Trigger | UI Response | Recovery Action |
|----------|---------|-------------|----------------|
| **Database write failure** | Save bill/payment fails | Toast: "Error saving data. Please try again." + Log to audit | Retry button |
| **Database read failure** | Query fails on screen load | Empty state with error icon: "Error loading data" + [Retry] button | Tap Retry |
| **AI API timeout** | LLM call takes >3s | Fall back to cached response + Show "Demo Mode" badge + Toast: "Using offline recommendation" | Continue normally |
| **AI API error** | LLM returns error/gibberish | Fall back to "Review Manually" recommendation + Show disclaimer | User decides manually |
| **App crash** | Unexpected error | (Handled by OS) App restarts, data in SQLite persists | Reopen app |
| **Low storage** | Device storage full | Toast: "Low storage. Some features may not work." | User frees space |

---

### 6.3 Navigation Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| **Back from root screen (Home/Bills/Settings)** | Show exit confirmation dialog: "Exit PAC?" [Yes] [No] |
| **Back from Payment Success** | Navigate to Home (not Payment Confirmation, to avoid confusion) |
| **Deep link to deleted bill** | Show toast "Bill not found" + Navigate to Bill List |
| **Switch to maintenance mode while viewing Bill Detail** | Show banner at top: "Maintenance mode active. Payment actions limited." + Disable "Pay Now", show "Queue Payment" |
| **Network loss during AI call** | Fall back to demo mode (cached responses) + Show badge |
| **Rapidly tap navigation** | Debounce taps (ignore if navigation in progress) |

---

### 6.4 User Input Edge Cases

| Scenario | Handling |
|----------|----------|
| **Paste $1,234.56 into amount field** | Strip "$" and "," automatically, parse as 1234.56 |
| **Enter amount with >2 decimals (e.g., $10.999)** | Round to 2 decimals on blur: $11.00 |
| **Enter very long payee name (>50 chars)** | Truncate to 50 chars, show counter: "50/50" |
| **Schedule payment for due date + 1 year** | Allow (no constraint in MVP), but show warning: "This date is far in the future" |
| **Create duplicate bill (same payee, amount, date)** | Allow (no uniqueness check in MVP), but show info: "Similar bill already exists" |

---

## 7. Navigation Patterns

### 7.1 Bottom Navigation Behavior

**Persistent Tabs:** Home, Bills, Settings  
**Visibility:** Always visible except in Maintenance Mode  

**Tap Behavior:**
- **Tap current tab:** No action (or scroll to top if already on that screen)
- **Tap different tab:** Navigate to that tab's root screen, clear back stack
- **Badge indicators:** Show count on Bills tab if bills need attention

**Back Stack Management:**
- Bottom nav resets back stack to root of selected tab
- Example: If on `Bill List → Bill Detail → Payment Confirmation`, tapping Home nav will navigate to Home and clear the Bills back stack

---

### 7.2 Modal Dismissal

**Methods to dismiss modal:**
1. Tap "Cancel" button (if present)
2. Tap outside modal area (if configured as dismissible)
3. Press device Back button
4. Swipe down (if modal is bottom sheet style)

**Dismissal behavior:**
- Returns to previous screen without adding to back stack
- No data changes saved (unless modal explicitly saved before dismiss)

---

### 7.3 Deep Linking (If implemented)

**Supported deep links:**
- `pac://bill/{bill_id}` → Navigate to Bill Detail for specific bill
- `pac://settings` → Navigate to Settings
- `pac://maintenance` → Navigate to Maintenance Home (if active)

**Invalid link handling:**
- Show toast "Invalid link" + Navigate to Home

---

### 7.4 Notification Navigation (Future)

**Notification scenarios:**
- "Bill due in 1 day: [Payee] $[amount]"
  - Tap: Navigate to Bill Detail for that bill

**Back stack from notification:**
- Deep link directly to Bill Detail
- Back button returns to Home (not to notification shade)

---

## 8. Summary: Navigation Flow Diagram

```
┌───────────────────────────────────────────────────────────────────────┐
│                         APP NAVIGATION MAP                            │
└───────────────────────────────────────────────────────────────────────┘

NORMAL MODE:
────────────
                    ┌─────────────────┐
                    │   HOME (1)      │ ← App Entry Point
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ↓              ↓              ↓
      ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
      │  BILLS (2)   │ │  [MODALS]    │ │ SETTINGS(13) │
      └──────┬───────┘ └──────────────┘ └──────┬───────┘
             │                                  │
             ↓                                  ↓
      ┌──────────────┐                  ┌──────────────┐
      │ BILL DETAIL  │                  │ CASHFLOW(14) │
      │    (3)       │                  │ AUDIT LOG(15)│
      └──────┬───────┘                  │  ABOUT (16)  │
             │                          └──────────────┘
             ↓
      ┌──────────────┐
      │ ADD/EDIT     │
      │ BILL (4,5)   │
      └──────┬───────┘
             │
             ↓
      ┌──────────────┐
      │ PAYMENT      │
      │ CONFIRM (7)  │
      └──────┬───────┘
             │
             ↓
      ┌──────────────┐
      │ AUTH MODAL   │
      │    (8)       │
      └──────┬───────┘
             │
             ↓
      ┌──────────────┐
      │ SUCCESS (9)  │
      └──────────────┘

MAINTENANCE MODE:
─────────────────
                    ┌─────────────────┐
                    │ MAINTENANCE     │ ← Replaces normal nav
                    │   HOME (10)     │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ↓                             ↓
      ┌──────────────┐              ┌──────────────┐
      │ QUEUED TAB   │              │ EMERGENCY(12)│
      │              │              │   TAB        │
      └──────┬───────┘              └──────────────┘
             │
             ↓
      ┌──────────────┐
      │ QUEUE        │
      │ CONFIRM (11) │
      └──────┬───────┘
             │
             ↓
      ┌──────────────┐
      │ AUTH MODAL   │
      │    (8)       │
      └──────────────┘
```

---

## 9. Quick Reference: Screen Transition Table

| From Screen | User Action | To Screen | Back Destination |
|-------------|-------------|-----------|------------------|
| 1 - Home | Tap "Add Bill" | 4 - Add Bill | 1 - Home |
| 1 - Home | Tap "View All Bills" | 2 - Bill List | 1 - Home |
| 1 - Home | Tap upcoming bill row | 3 - Bill Detail | 1 - Home |
| 1 - Home | Tap Settings icon | 13 - Settings | 1 - Home |
| 1 - Home | Tap maintenance banner | 10 - Maintenance Home | 1 - Home |
| 2 - Bill List | Tap bill row | 3 - Bill Detail | 2 - Bill List |
| 2 - Bill List | Tap FAB (+) | 4 - Add Bill | 2 - Bill List |
| 2 - Bill List | Tap Home nav | 1 - Home | Exit |
| 3 - Bill Detail | Tap Edit icon | 5 - Edit Bill | 3 - Bill Detail |
| 3 - Bill Detail | Tap AI recommendation | 7 - Payment Confirmation | 3 - Bill Detail |
| 3 - Bill Detail | Tap "Pay Now" | 7 - Payment Confirmation | 3 - Bill Detail |
| 4 - Add Bill | Tap "Save" | 2 - Bill List (+ toast) | - |
| 5 - Edit Bill | Tap "Save" | 3 - Bill Detail | - |
| 5 - Edit Bill | Tap "Delete" | 2 - Bill List | - |
| 7 - Payment Confirmation | Tap "Confirm" | 8 - Auth Modal | 7 - Payment Confirmation |
| 8 - Auth Modal | Tap "Touch ID" (success) | 9 - Payment Success | - |
| 8 - Auth Modal | Tap "Cancel" | 7 - Payment Confirmation | - |
| 9 - Payment Success | Tap "Done" | 1 - Home | Exit |
| 10 - Maintenance Home | Tap "Queue Payment" | 11 - Queue Confirmation | 10 - Maintenance Home |
| 10 - Maintenance Home | Tap Emergency tab | 12 - Emergency (same screen) | 10 - Maintenance Home |
| 11 - Queue Confirmation | Tap "Confirm" | 8 - Auth Modal → 10 - Maintenance Home | - |
| 13 - Settings | Tap "View Audit Log" | 15 - Audit Log | 13 - Settings |
| 13 - Settings | Tap cashflow row | 14 - Cashflow Inputs | 13 - Settings |
| 13 - Settings | Tap "About" | 16 - About | 13 - Settings |

---

**END OF APP FLOW DOCUMENT**

This document provides complete navigation, interaction, and flow specifications for all 16 screens in the Payment Assurance Copilot app. Use this as the single source of truth for implementing user journeys, screen transitions, and interaction behaviors.
