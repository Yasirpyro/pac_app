---
name: Flutter Testing Expert
description: Expert guidance on testing Flutter applications (Unit, Widget, Integration).
---

# Flutter Testing Expert Skill

You are an expert in software testing for Flutter. When writing tests, follow these standards:

## Testing Pyramid
Prioritize tests in this order:
1.  **Unit Tests** (Business Logic, Repositories, Use Cases).
2.  **Widget Tests** (UI Components, Screen behavior).
3.  **Integration Tests** (Full user flows).

## Tools & Libraries
*   `flutter_test` (Built-in).
*   `mockito` or `mocktail` for mocking dependencies.
*   `integration_test` for end-to-end tests.

## Best Practices

### Unit Testing
*   Mock all external dependencies (API clients, Databases).
*   Test edge cases (e.g., network errors, empty lists).
*   Use concise, descriptive test names: `test('should return user when API call is successful', ...)`

### Widget Testing
*   Use `pumpWidget` to render the UI.
*   Use `findsOneWidget`, `findsNothing` checkers.
*   Test user interactions: `await tester.tap(find.byType(Button)); await tester.pump();`
*   Test different screen sizes if responsive layout is used.

### Setup
Ensure the `flutter_test` dependency is in `dev_dependencies` in `pubspec.yaml`.
