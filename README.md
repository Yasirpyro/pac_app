# Payment Assurance Copilot (PAC)

> **PROCOM '26 AI in Banking Hackathon Submission**
>
> *AI-assisted payment timing + continuity for zero late fees.*

## Overview

**Payment Assurance Copilot (PAC)** is a Flutter Android prototype designed to help banking customers avoid late fees and manage cashflow. It addresses two critical pain points:
1.  **Payment Timing:** AI analyzes cashflow to recommend the safest time to pay bills (e.g., "Wait for payday").
2.  **Service Continuity:** A dedicated "Maintenance Mode" allows users to queue payment intents even when backend systems are down.

## Key Features

-   **AI Recommendations:** Context-aware suggestions ("Pay Now" vs. "Schedule") based on balance and upcoming obligations.
-   **Safety Guardrails:**
    -   Insufficient Funds Warning
    -   Anomaly Detection (e.g., "Bill is 63% higher than usual")
    -   Daily Payment Caps
-   **Maintenance Continuity:** Queue payments during downtime; transparency on system status.
-   **Offline-First:** Fully functional demo mode with local SQLite database.
-   **Audit Logging:** Transparent local log of all AI suggestions and user actions.

## Tech Stack

-   **Framework:** Flutter 3.38.9 / Dart 3.10.8
-   **State Management:** Provider 6.1.4
-   **Routing:** GoRouter 17.1.0
-   **Local Storage:** SQLite (sqflite 2.4.2)
-   **AI Integration:** Anthropic Claude API (simulated/cached for demo)

## Getting Started

### Prerequisites
-   Flutter SDK installed
-   Android Emulator or Physical Device (minSdk 24)

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-repo/pac_app.git
    cd pac_app
    ```

2.  Install dependencies:
    ```bash
    flutter pub get
    ```

3.  Run the app:
    ```bash
    flutter run
    ```

## Usage Guide (Demo Mode)

The app launches in **Demo Mode** by default, pre-loaded with synthetic data.

1.  **Home Dashboard:** View bills needing attention.
2.  **Bill Detail:** Tap a bill to see the AI recommendation and rationale.
3.  **Maintenance Mode:** Go to Settings -> Toggle "Maintenance Mode" to see the continuity features.
4.  **Reset:** Go to Settings -> "Reset Demo Data" to restore the initial state.

## Architecture

```
lib/
├── core/           # Constants, Utils
├── data/           # Repositories, DAOs, Models, Services (AI, Auth)
├── domain/         # Entities
├── presentation/   # Screens, Widgets, Providers
└── theme/          # App Theme, Colors, Typography
```

## Documentation

-   [Product Requirements (PRD)](docs/PAC_PRD_v1.0.md)
-   [Implementation Plan](docs/PAC_ImplementationPlan_v1.0.md)
-   [Demo Script](docs/DEMO_SCRIPT.md)
-   [Pitch Deck](docs/PITCH_DECK.md)

---
*Created by Team Alpha for PROCOM '26.*
