# Nirmaan - AI-Powered Business Operating System for Local Businesses

> **Operate · Predict · Grow**

Nirmaan is a modern, mobile-first business operating system designed specifically for local businesses. It unifies daily transactions, inventory management, customer engagement, predictive analytics, and AI-assisted decision support into a single cohesive platform.

---

## 🏗 System Architecture & Technology Stack

### Frontend (Mobile-First)
- **Framework**: Flutter (Dart 3.x)
- **Design System**: Material Design 3, custom Figma-derived design system
- **Target Platform**: Android-first, fully responsive mobile UI
- **State Management**: Provider / ChangeNotifier with clean architectural separation
- **Networking & Persistence**: HTTP REST client, SharedPreferences, pluggable Firebase foundation

### Backend API
- **Runtime**: Node.js (v24.x)
- **Framework**: Express.js REST API
- **Architecture**: Modular service layer with Authentication, RBAC Middleware, Audit Logging, and Structured JSON Responses
- **Security**: Helmet, CORS, Bearer Token handling, Server-side Input Validation

### Cloud, Data & Intelligence Foundation
- **Identity**: Firebase Authentication
- **Database**: Firestore (operational records)
- **Analytics & Big Data**: Google BigQuery (historical aggregation)
- **AI / Decision Support**: Google Gemini AI (decision support only per SRS FR-24)

---

## 🎨 Figma-Derived Design System Tokens

The visual language reproduces the approved Figma design specifications:

| Token Category | Token Name | Value | Usage |
| :--- | :--- | :--- | :--- |
| **Primary Navy** | `primaryNavy` | `#0F172A` | Hero headers, primary surfaces, app bars |
| **Deep Midnight** | `primaryDark` | `#0A1128` | Splash background, high-contrast containers |
| **Primary Surface**| `primarySurface` | `#1E293B` | Elevated cards on navy, dark modals |
| **Interactive Blue**| `primaryBlue` | `#0284C7` | Key links, selection pills, accents |
| **Accent Amber** | `secondaryAmber` | `#F59E0B` | Growth indicators, badges, highlights |
| **Background** | `backgroundLight` | `#F8FAFC` | Clean light canvas background |
| **Surface White** | `surfaceWhite` | `#FFFFFF` | Standard cards, input backgrounds |
| **Border Stroke** | `surfaceBorder` | `#E2E8F0` | Card borders, dividers, outlines |
| **Success** | `successGreen` | `#10B981` | Paid status, in-stock, positive trends |
| **Warning** | `warningOrange` | `#F59E0B` | Low-stock alert, pending transactions |
| **Error / Critical**| `errorRed` | `#EF4444` | Out-of-stock, churn risk, validation errors |
| **AI Purple** | `aiPurple` | `#6366F1` | AI Business Coach, Daily Brief accents |

### Shapes & Elevations
- **Standard Cards**: `16px` border radius with subtle ambient occlusion (`0 2px 8px rgba(15,23,42,0.03)`).
- **Interactive Controls**: `12px` border radius (buttons, text inputs).
- **Badges & Chips**: Fully rounded pill shapes (`999px`).
- **Typography Scale**: Built on `Inter` with 4px baseline rhythm (`Display 28px`, `PageTitle 22px`, `SectionTitle 18px`, `CardTitle 15px`, `Body 14px`, `Caption 12px`, `Badge 11px`).

---

## 👥 Role-Based Access Control (RBAC Matrix)

Per SRS Section 3.1 & 3.3 (FR-02):

| Functional Area | Business Owner | Store Manager | Sales Staff | Administrator |
| :--- | :---: | :---: | :---: | :---: |
| **Dashboard & Business Brief** | ✅ Full | ✅ Operational | ✅ Daily Summary | ✅ Full |
| **Business Health & Score** | ✅ Full Access | ❌ Restricted | ❌ Restricted | ✅ Full Access |
| **Sales Analytics & Reports** | ✅ Full | ✅ Operational | ❌ Restricted | ✅ Full |
| **Products & Inventory** | ✅ Full | ✅ Manage/Edit | ✅ Stock Update | ✅ Full |
| **Customer Directory** | ✅ Full | ✅ Manage | ✅ View & Contact | ✅ Full |
| **Order Processing** | ✅ Yes | ✅ Yes | ✅ Yes (Fast entry) | ✅ Yes |
| **AI Business Coach** | ✅ Strategic | ✅ Operational | ❌ Restricted | ✅ Full |
| **Business Twin Simulation** | ✅ Full | ❌ Restricted | ❌ Restricted | ✅ Full |
| **Governance, Audit & Backups**| ❌ Restricted | ❌ Restricted | ❌ Restricted | ✅ Full Access |

---

## 📁 Project Structure

```
NIRMAAN/
├── lib/                                # Flutter Mobile Client
│   ├── main.dart                       # App entrypoint & Provider DI
│   ├── core/
│   │   ├── constants/                  # Environment config & constants
│   │   ├── errors/                     # Failures & exceptions
│   │   ├── routing/                    # AppRoutes & AppRouter (Splash, Login, Register, ...)
│   │   └── theme/                      # AppColors, Typography, Dimensions, AppTheme
│   ├── features/
│   │   ├── ai_coach/                   # Screen 11: AI Business Coach
│   │   ├── analytics/                  # Screen 13: Business Analytics
│   │   ├── auth/                       # Screens 1-3: Splash, Login, Register, Forgot Password
│   │   │   ├── controllers/            # AuthController (Session, Register, Login, Reset)
│   │   │   └── presentation/           # SplashScreen, LoginScreen, RegisterScreen, ForgotPasswordScreen
│   │   ├── business_health/            # Screen 14: Business Health Score
│   │   ├── business_setup/             # Screen 4: Business Setup & Profile
│   │   ├── customers/                  # Screen 10: Customer Directory (Tab 4)
│   │   ├── dashboard/                  # Screen 5: Home Dashboard (Tab 1)
│   │   ├── inventory/                  # Screen 8: Inventory Management (Tab 3)
│   │   ├── main_shell/                 # 5-Tab Navigation Scaffold
│   │   ├── more/                       # Screen 16: More & Intelligence (Tab 5)
│   │   ├── notifications/              # Screen 18: Notifications & Alerts
│   │   ├── orders/                     # Screen 9: Sales & Orders (Tab 2)
│   │   ├── products/                   # Screens 6-7: Products & Add Product
│   │   ├── profile/                    # Screen 15: Business & Account Profile
│   │   ├── settings/                   # Screen 17: Settings & Governance
│   │   └── todays_business/            # Screen 12: Today's Business Brief
│   ├── models/                         # Domain entities (User, Product, Order, Customer, etc.)
│   ├── repositories/                   # Clean repository implementations (AuthRepository, etc.)
│   ├── services/                       # API client, HttpAuthService, MockAuthService, StorageService
│   └── shared/                         # Reusable cards, buttons, badges, chips, app bar, bottom nav
│
├── backend/                            # Node.js / Express REST API
│   ├── package.json
│   ├── .env.example
│   ├── .env
│   ├── src/
│   │   ├── app.js                      # Express middleware, security, routes
│   │   ├── server.js                   # Server bootstrap & graceful shutdown
│   │   ├── config/                     # Environment configuration
│   │   ├── controllers/                # AuthController
│   │   ├── middleware/                 # Auth, RBAC, Error Handler, Logger
│   │   ├── models/                     # User model with PBKDF2 hashing
│   │   ├── repositories/               # UserRepository with seeded demo accounts
│   │   ├── routes/                     # AuthRoutes, HealthRoutes
│   │   ├── services/                   # AuthService
│   │   ├── utils/                      # Response formatter & Audit logger
│   │   └── validators/                 # AuthValidators (Register, Login, ForgotPassword)
│   └── tests/
│       ├── auth.test.js                # Suite for registration, login, logout, RBAC
│       └── health.test.js              # Health & RBAC verification
│
├── test/                               # Flutter Test Suite
│   ├── auth_test.dart                  # Phase 2 unit & widget tests (Auth flow & UI)
│   ├── unit_test.dart                  # Role permissions & calculations test
│   └── widget_test.dart                # Widget rendering test
├── pubspec.yaml                        # Flutter dependencies
└── analysis_options.yaml               # Strict lint rules
```

---

## 🚀 Running the Project

### Backend
```bash
cd backend
npm install
npm test          # Runs automated test suite (Health & RBAC)
npm start         # Starts backend API on http://localhost:5001/api/v1
```

### Mobile Application (Flutter)
```bash
flutter pub get
flutter test
flutter run
```
