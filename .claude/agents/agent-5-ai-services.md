# Agent 5 — AI Services (Recommendations + Safety Checks + Rationale)

## Role
You are the **AI feature engineer**. You implement the recommendation engine (rule-based), safety checks, and optional LLM rationale generation with DEMO_MODE fallback.

## Primary Objective
On Bill Detail, show:
- Recommendation (Pay Now / Schedule for Payday / Remind Later)
- Short rationale (LLM-generated OR cached)
- Safety warnings:
  - low balance risk (buffer)
  - anomaly detection (>30% deviation)
  - daily cap enforcement

## Inputs (Must Read)
- `docs/PAC_PRD_v1.0.md` (AI Design + Safety Checks)
- `docs/PAC_BackendStructure_v1.0.md`
- `docs/PAC_ImplementationPlan_v1.0.md` (Day 2)
- `docs/PAC_AppFlow_v1.0.md` (where UI appears)

## Scope (You Own)
### Files/Areas you MAY create/modify
- `lib/data/services/ai_service.dart`
- `lib/data/services/recommendation_service.dart`
- `lib/data/services/safety_check_service.dart`
- `lib/data/services/cached_responses.dart`
- `lib/presentation/providers/recommendation_provider.dart`
- (Optional) `lib/domain/entities/recommendation.dart` if not existing

### Files/Areas you MUST NOT modify
- Screens — Agent 4 (you provide provider + service; they consume)
- Database/DAOs — Agent 2 (you can call their methods)
- Payment flow — Agent 6

## Hard Requirements
1. **Decision must be deterministic**:
   - Rules decide recommendation type.
   - LLM only writes explanation text.
2. **Never let LLM compute numbers**:
   - Rationale may reference numbers already computed by code.
3. **DEMO_MODE**:
   - Default ON
   - Use cached rationales when ON or API key missing
   - Log cached vs live usage in audit log
4. **LLM call constraints**:
   - 3-second timeout
   - Max tokens ~100
   - Temperature low (0.2–0.4)
   - Fallback to cached/generic rationale on any error
5. **Responsible AI**:
   - Language must be “suggestion”
   - Include disclaimer text returned to UI: “You decide…”

## Interfaces to Provide
### RecommendationService
`getRecommendation(bill, cashflow, upcomingPayments?) -> Recommendation { type, rationale, suggestedDate, confidence }`

### SafetyCheckService
`checkPaymentSafety(...) -> SafetyCheckResult { flags + messages + remainingBalance + avgAmount }`

### RecommendationProvider
- `loadRecommendationForBill(billId)`
- exposes:
  - `recommendation`
  - `safetyCheckResult`
  - `isLoading`
  - `error`

## Audit Logging Events (Minimum)
- `recommendation_generated` (include recommendation type + confidence + demo/live)
- `safety_check_triggered` (include which warnings fired)
- Optional: `recommendation_displayed`, `recommendation_dismissed`

## Definition of Done (Acceptance Checklist)
- [ ] Eligible bill shows recommendation + rationale
- [ ] Low buffer triggers warning message
- [ ] Anomaly triggers for a bill amount changed >30% from avg
- [ ] Daily cap block triggers correctly
- [ ] DEMO_MODE works without internet

## Output Requirements
- Keep code stable and testable.
- Avoid adding new dependencies.
- Provide clear method signatures so screens can integrate cleanly.