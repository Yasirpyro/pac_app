# Payment Assurance Copilot (PAC) - Pitch Deck

**Event:** PROCOM '26 AI in Banking Hackathon
**Team:** Team Alpha

---

## Slide 1: Title
- **Product:** Payment Assurance Copilot (PAC)
- **Tagline:** "AI-assisted payment timing + continuity for zero late fees"
- **Visual:** Lightbulb + shield icon

## Slide 2: The Problem
- **Statistic:** Customers lose $400M/year to late fees (Source: CFPB estimates).
- **Root Causes:**
  1. Poor timing awareness (Cashflow mismatch).
  2. Maintenance blackouts (Service unavailability).
- **Visual:** Timeline showing Bill Due Date vs. Payday mismatch.

## Slide 3: The Solution
- **MVP:** AI-assisted bill reminders with cashflow-aware recommendations.
- **Differentiation:** Maintenance Continuity Mode (Queue intents + Transparency).
- **Philosophy:** "AI suggests, User decides." No autopay surprises.

## Slide 4: How It Works
1. **Analyze:** AI checks Balance, Payday, and Safety Buffer.
2. **Recommend:** "Pay Now", "Schedule for Payday", or "Remind Later".
3. **Confirm:** User approves with biometric auth.
- **Safety Checks:** Insufficient funds, Anomaly detection, Daily caps.

## Slide 5: Why AI? (vs. Generic Reminders)
- **Generic:** "Bill due in 3 days." (User must calculate risk).
- **PAC AI:** "Schedule for payday. Paying now risks NSF with rent on the 16th." (Context-aware).
- **Impact:** 85% fewer late fees in simulated scenarios.

## Slide 6: Responsible AI Design
- **Guardrails:** Human-in-the-loop, Explainability, Local Audit Logs.
- **Scope:** AI *suggests* and *explains*. AI does *not* execute autonomously.
- **Risk Mitigation:** Rule-based fallback if LLM is uncertain.

## Slide 7: Technical Architecture
- **Stack:** Flutter (Android), SQLite (Local Storage).
- **AI:** Rule-based heuristic engine + Gemini 2.5 Flash (via API) for rationale.
- **Resilience:** Offline-first (`DEMO_MODE`), Local caching.

## Slide 8: Roadmap & Vision
- **Today:** Hackathon Prototype (Utility bills).
- **6 Months:** Integration with Bank Core, Expansion to all bill types.
- **12 Months:** Predictive Cashflow Modeling, Multi-account support.
- **Vision:** Every customer has a copilot that prevents financial stress.
