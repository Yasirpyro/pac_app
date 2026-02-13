# Payment Assurance Copilot (PAC)

**JS Bank Presents PROCOM ’26 Hackathon — AI in Banking**  
**Track:** Open Innovation (AI-powered banking solution)  
**Team:** Hackathon Team HYRX  
**Status:** Working prototype (Demo-ready)  
**Platform:** Flutter (Android)

---

## 1) What is PAC?

**Payment Assurance Copilot (PAC)** is an Android prototype that helps bank customers avoid missed/late utility payments and stay informed during **planned banking maintenance windows**.

PAC combines:
- **AI-assisted payment timing recommendations** (Pay now / Schedule / Remind me)
- **Safety checks** (low balance risk, anomaly detection, daily cap)
- **Maintenance continuity mode** (queue intents + transparent status)
- **Local notifications** to bring users back at the right time for **one-tap pay**

> **Prototype / Demo only.** No real banking integration and **no real funds move**.

---

## 2) Why this matters to banking (Hackathon fit)

The PROCOM ’26 hackathon asks for an AI-powered solution that meaningfully connects to banking. PAC does that by targeting two real banking pain points:

### A) Payment timing failures (late fees + customer frustration)
Customers forget due dates or pay at the wrong time (cashflow blind spots), causing:
- NSF fees
- late fees from billers/landlords
- service interruptions
- reduced trust in the bank

### B) Maintenance collisions (service continuity gap)
During planned maintenance, customers attempting critical payments often hit generic errors and fail to retry later.

PAC addresses both with:
- **AI timing suggestions** + plain-language rationale
- **Continuity UX during downtime** (queue intents and clear messaging)

---

## 3) Demo highlights (what judges should look for)

### ✅ AI recommendations (assistive, not autonomous)
For eligible bills, PAC produces:
- **Pay now**
- **Schedule for [date]**
- **Remind me on [date]**

AI output includes a brief rationale and always keeps the user in control.

### ✅ Maintenance mode continuity
When maintenance mode is enabled (simulated):
- payments cannot be executed
- users can **queue payment intents**
- after maintenance ends, PAC surfaces queued items for review:
  - **Pay now (simulate)**
  - **Remove intent**

### ✅ Notifications + one-tap pay (real device)
PAC schedules **local notifications** (Android 15 supported) so reminders appear even when the app is closed. Tapping a notification deep-links the user to an urgent list or bill detail for a fast pay flow (simulated).

### ✅ Audit log (transparency)
Key actions are logged locally, including:
- recommendations shown
- reminders set
- payment scheduled/queued/completed (simulated)
- safety warnings triggered

---

## 4) Core features implemented

### 4.1 Bill management
- Manual bill entry: payee, amount, due date, category  
- Edit / delete bills  
- Bills list sorted by due date with status cues:
  - overdue (red)
  - due soon (yellow)
  - pending/scheduled/paid

### 4.2 Cashflow inputs (synthetic)
- Current balance
- Next payday date
- Safety buffer
- Daily payment cap

> These are **synthetic inputs** for demo reliability and to avoid real account data.

### 4.3 AI recommendations (hybrid approach)
- **Rule-based decision logic** ensures predictable outcomes
- Optional LLM-generated rationale (or cached/fallback text in demo mode)
- Guardrails:
  - AI cannot execute payments
  - user confirmation required

### 4.4 Safety checks
- Low balance risk warning vs safety buffer
- Anomaly detection vs historical average for payee (demo history)
- Daily payment cap enforcement
- Safety events logged to audit trail

### 4.5 Payment flows (simulated)
- **Pay Now (Simulated)** → completes payment and marks bill **Paid**
- **Schedule Payment** → moves into Scheduled list
- **Complete Scheduled (Simulated)** → marks paid
- Reference IDs generated for demo realism

### 4.6 Reminders for non-urgent bills
- For bills due in **more than 7 days**, user can set a reminder date
- App shows recommended reminder date + “Set Reminder”
- Reminder date stored and shown in Scheduled/Reminders section:
  - shows **original due date + reminder date**

### 4.7 Urgent screen (prioritized list)
- A dedicated urgent list for due-today/overdue items with urgency highlighting
- Drives the “tap notification → review → pay” demo flow

### 4.8 Maintenance mode (simulated)
- Toggle maintenance mode in settings
- During maintenance:
  - queue intent instead of executing
  - show balance snapshot disclaimer
- After maintenance ends:
  - queued intents appear on Home for review

---

## 5) Responsible AI & privacy (prototype constraints)

### Data handling
- **No real customer/bank data**
- **No PII required** for demo
- All data stored **locally on device** (SQLite)
- No backend server, no cloud sync

### AI responsibility
- AI suggestions are **assistive**, not mandatory
- Clear disclaimers: “AI suggests, user decides”
- Rule-based logic is primary (LLM used for rationale only where enabled)
- Audit logs provide transparency into system behavior

### Limitations (prototype)
- No real bank core integration
- Notifications are local (not bank push)
- Cashflow inputs are manual/synthetic
- Accessibility not fully WCAG validated (hackathon scope)

---

## 6) Tech stack

- **Flutter** (Android)
- **SQLite** (local persistence)
- State management: **Provider**
- Navigation: (project standard)
- Local notifications: `flutter_local_notifications`
- Optional HTTP/LLM integration (demo-safe fallback)

---

## 7) Repository structure (high level)

> Names may vary slightly depending on your folder layout.

- `lib/`
  - `screens/` — Home, Bills, Bill Detail, Maintenance, Settings, Urgent, etc.
  - `providers/` — BillsProvider, PaymentsProvider, SettingsProvider, etc.
  - `data/`
    - `dao/` — SQLite DAOs
    - `models/` — Bill, Payment, AuditLog, etc.
    - `services/` — AI service, NotificationService
- `android/` — Android build + manifest
- `docs/` — PRD and design docs (source of truth)

---

## 8) Setup & run (Android device)

### Prerequisites
- Flutter SDK installed and on PATH
- Android Studio installed (Android SDK + platform-tools)
- JDK 17
- USB debugging enabled on your Android phone

Verify:
```bash
flutter doctor
flutter devices
```

### Install deps
```bash
flutter pub get
```

### Run on device
```bash
flutter run
```

### Build APK (for submission)
```bash
flutter build apk --release
```
APK output:
- `build/app/outputs/flutter-apk/app-release.apk`

---

## 9) How to demo in 2–4 minutes (recommended script)

### Scene 1: AI recommendation → schedule / pay (normal mode)
1. Open Home: show balance, payday, attention badge
2. Open a bill due soon
3. Show AI recommendation + rationale
4. Tap Schedule or Pay Now → confirm → authenticate → success
5. Quickly show audit log entry

### Scene 2: Maintenance mode continuity
1. Toggle maintenance mode ON
2. Try to pay a bill → queue intent (not executed)
3. Exit maintenance mode
4. Home shows queued intents card
5. Review queued → pay one / remove one

### Scene 3: Notification → urgent list → one-tap pay
1. Trigger demo urgent notification (debug button) OR use due-today schedule
2. Close app / swipe away
3. Notification arrives
4. Tap notification → urgent list opens
5. Tap a bill → confirm → biometric → success
6. “View other pending payments”

---

## 10) Risks & mitigations (for judges)

| Risk | Why it matters | Mitigation in PAC |
|------|----------------|------------------|
| Users over-trust AI | Could lead to poor decisions | Clear disclaimers + rationale + user confirmation |
| Missing external obligations | AI can’t see everything | User cashflow inputs + conservative rules + “Review manually” fallback |
| Downtime confusion | Bank brand trust risk | Maintenance continuity UX + queue intents + emergency options |
| LLM failures | Demo reliability | Rule-first logic + cached/fallback rationale |

---

## 11) Hackathon deliverables checklist

- [x] Working prototype (Android app)
- [x] 2–4 minute demo video flow supported
- [ ] Pitch deck (max 8 slides) — add `/docs/pitch_deck.pdf` if included
- [x] Repository documentation (this README + PRD in docs/)
- [x] No real customer data; synthetic demo data only

---

## 12) Credits
Built by **Hackathon Team Hyrx ** for **PROCOM ’26 AI in Banking Hackathon**.

---
