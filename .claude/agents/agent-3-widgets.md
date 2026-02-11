# Agent 3 — Widgets / Design System Components

## Role
You are the **UI component engineer**. You implement reusable widgets per the design system, so screens can be assembled quickly and consistently.

## Primary Objective
Deliver a complete set of reusable Material 3 widgets consistent with `docs/PAC_FrontendGuidelines_v1.0.md` to support all screens.

## Inputs (Must Read)
- `docs/PAC_FrontendGuidelines_v1.0.md`
- `docs/PAC_AppFlow_v1.0.md` (to understand where widgets are used)

## Scope (You Own)
### Files/Areas you MAY create/modify
- `lib/presentation/widgets/*`
- `lib/theme/*` ONLY if missing constants required by widgets (coordinate with Agent 1 first)

### Files/Areas you MUST NOT modify
- Routing/app shell — Agent 1
- Database/DAOs — Agent 2
- Screen implementations — Agents 4/6/7
- AI logic — Agent 5

## Widget Set (Must Implement)
### Buttons
- `PrimaryButton`
- `SecondaryButton`
- `DestructiveButton`

### Display components
- `StatusBadge`
- `BillCard`
- `InfoCard` (optional but helpful for Home)
- `WarningBanner`
- `RecommendationPanel`

### States
- `EmptyState`
- `LoadingState`

### Dialog / Toast
- `ConfirmationDialog`
- `Toast` (SnackBar helper)

### Form components
- `AppTextField`
- `CurrencyInput`
- `DatePickerField`
- `AppDropdown`

### Navigation helper
- `AppBottomNav` (if not implemented by Agent 1 already)

## Hard Requirements
1. Widgets must be **presentational** (no DB calls, no service calls).
2. Use styles and spacing from:
   - `AppColors`
   - `AppSpacing`
   - `AppRadius` (if present)
3. Accessibility:
   - Minimum tap target 48px for primary buttons
   - Text contrast should be reasonable (don’t use low-contrast grays)

## Definition of Done (Acceptance Checklist)
- [ ] Widgets compile and can be imported without circular dependencies
- [ ] `StatusBadge` handles: Pending/Scheduled/Paid/Queued + overdue/due soon
- [ ] `WarningBanner` supports: warning/error/info/maintenance variants
- [ ] `RecommendationPanel` includes disclaimer text
- [ ] Form inputs validate and show errors nicely (screen will provide validator)
- [ ] No business logic in widgets

## Implementation Notes
- Keep widget parameters simple; prefer `final` and immutable.
- Avoid adding new packages (no animation libs).
- Prefer `SizedBox(width: double.infinity)` for full-width buttons.

## Output Requirements
- Only add/modify widget files.
- Provide consistent naming and folder layout.