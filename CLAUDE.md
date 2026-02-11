# PAC — Payment Assurance Copilot (Claude CLI Orchestrator)

## Project Overview
Flutter Android app prototype
- AI-assisted utility bill payment timing (recommendations + safety checks)
- Maintenance Mode continuity (queue payment intents + transparency)
- Offline-first demo (DEMO_MODE default ON, local SQLite)

## Specs (READ FIRST — source of truth)
All specifications are in `/docs/`:
- `PAC_PRD_v1.0.md` — Product requirements, user journeys, risks
- `PAC_AppFlow_v1.0.md` — Screens + navigation flows
- `PAC_TechStack_v1.0.md` — Exact versions + rationale
- `PAC_FrontendGuidelines_v1.0.md` — UI system + widget specs
- `PAC_BackendStructure_v1.0.md` — SQLite schema + DAOs/services
- `PAC_ImplementationPlan_v1.0.md` — Day-by-day build sequence

If something conflicts, follow priority:
1) PRD → 2) AppFlow → 3) BackendStructure → 4) FrontendGuidelines → 5) TechStack → 6) ImplementationPlan

## Tech Stack (lock these)
Flutter 3.38.9 | Dart 3.10.8  
provider 6.1.4 | go_router 17.1.0 | sqflite 2.4.2 | http 1.6.0 | intl 0.20.2 | uuid 4.5.2 | local_auth 3.0.0  
Android: minSdk 24, targetSdk 35

## Non-Negotiables (Hackathon Constraints)
- **No real customer/bank data**. Use synthetic data only.
- Avoid collecting sensitive identifiers in demo (CNIC, account numbers, etc).
- **AI suggests; user decides.** Never auto-execute payments.
- **Maintenance Mode does NOT move funds.** Only queue intents + show transparency.
- **Offline-first:** demo must work without network (cached AI responses).
- Always write audit logs for key actions.

## Repo Structure (expected)
- `docs/` → specifications (do not rewrite unless explicitly asked)
- `.claude/agents/` → sub-agent instructions (domain boundaries)
- `lib/` → Flutter app code
- `test/` → minimal unit tests (optional but preferred for recommendation logic)

## Build / Run
```bash
flutter pub get
flutter run
flutter test
flutter build apk --release