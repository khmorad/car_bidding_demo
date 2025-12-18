# Car Bidding System

A full-stack Flutter application demonstrating real-time car bidding with Firebase backend. Built as part of the Pluck technical assessment.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

### Core Functionality

- **User Authentication** - Email/password login and registration
- **Car Makers Browsing** - Browse car manufacturers with search functionality
- **Car Models Catalog** - View all models for each manufacturer
- **Real-time Bidding** - Place and track bids with live updates
- **Bid History** - View all bids with timestamps and amounts
- **Highest Bid Tracking** - See current leading bid in real-time

### Technical Features

- Responsive UI with custom gradients and animations
- Real-time data synchronization via Firestore streams
- Material Design 3 with custom theming
- Optimized performance with lazy loading
- Cloud Functions for data import
- Search and filter capabilities

## Tech Stack

### Frontend

- **Flutter** (3.0+) - UI framework
- **Dart** (3.0+) - Programming language
- **flutter_bloc** (^8.1.3) - State management
- **go_router** (^14.6.2) - Declarative routing

### Backend

- **Firebase Firestore** - NoSQL database
- **Cloud Functions** - Serverless backend (Node.js)
- **Firebase Storage** - CSV file storage

### Development Tools

- **Git** - Version control
- **VS Code** / **Android Studio** - IDEs
- **Firebase CLI** - Deployment and management

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Screens, Widgets, BLoC/Cubit)         │
├─────────────────────────────────────────┤
│            Business Logic               │
│         (Services, Cubits)              │
├─────────────────────────────────────────┤
│              Data Layer                 │
│    (Models, Firestore Repository)       │
└─────────────────────────────────────────┘
```

### Design Patterns Used

- **BLoC Pattern** - For state management (authentication)
- **Repository Pattern** - For data access abstraction
- **Stream Builder Pattern** - For real-time data updates
- **Service Layer Pattern** - For business logic separation

## 📁 Project Structure

```
car_bidding_system/
├── lib/
│   ├── bloc/                    # State management
│   │   ├── auth_cubit.dart      # Authentication logic
│   │   └── auth_state.dart      # Auth states
│   ├── models/                  # Data models
│   │   ├── user.dart            # User model
│   │   ├── maker.dart           # Car maker model
│   │   ├── model.dart           # Car model
│   │   └── bid.dart             # Bid model
│   ├── screens/                 # UI screens
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── makers_screen.dart
│   │   ├── models_screen.dart
│   │   └── model_detail_screen.dart
│   ├── services/                # Business logic services
│   │   ├── auth_service.dart
│   │   ├── makers_service.dart
│   │   ├── models_service.dart
│   │   └── bid_service.dart
│   ├── widgets/                 # Reusable UI widgets
│   │   └── ...                  # Custom widget files
│   ├── router/                  # Navigation
│   │   └── app_router.dart
│   └── main.dart                # App entry point
├── functions/                   # Cloud Functions
│   ├── index.js                 # CSV import function
│   ├── package.json
│   └── .eslintrc.js
├── assets/                      # Static assets
│   └── *.png                    # Car maker logos
├── android/                     # Android config
├── ios/                         # iOS config
├── web/                         # Web config
├── test/                        # Unit & widget tests
├── firebase.json                # Firebase configuration
├── firestore.rules              # Security rules
├── firestore.indexes.json       # Composite indexes
├── pubspec.yaml                 # Dependencies
└── README.md
```

### Prerequisites

```bash
# Required
Flutter SDK 3.0+
Dart SDK 3.0+
Firebase CLI
Node.js 18+ (for Cloud Functions)
Git

# Optional
Android Studio / Xcode (for mobile development)
VS Code with Flutter extension
```

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/car_bidding_system.git
   cd car_bidding_system
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Install Cloud Functions dependencies**

   ```bash
   cd functions
   npm install
   cd ..
   ```

4. **Configure Firebase** (see [Firebase Setup](#firebase-setup))

5. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Setup

### 1. Create Firebase Project

```bash
npm install -g firebase-tools
firebase login
firebase init
```

Select these features:

- Firestore
- Functions
- Storage

### 2. Firestore Database Structure

- makers/ — Car manufacturers
- models/ — Car models
  - submodels/ — Trim/configuration variants
  - engines/ — Engine configurations per model
- bids/ — Bids placed on specific car submodels

### 3. Firestore Security Rules

See `firestore.rules` for full security rules.

- Users can read their own data and create accounts.
- Makers/models are read-only for users.
- Bids can be created by authenticated users and are immutable.

### 4. Firestore Indexes

See `firestore.indexes.json` for composite indexes (e.g., for sorting bids by model and amount).

Deploy indexes:

```bash
firebase deploy --only firestore:indexes
```

## Cloud Functions

A Cloud Function (`importCars`) imports makers and models from CSV files stored in Firebase Storage. This is used to bootstrap Firestore data for the demo.

## Navigation

Example:

```dart
context.go('/makers');
```

## Screenshots

Screenshots will be added once UI polish is complete.

## Services

Services encapsulate Firestore access (`AuthService`, `MakersService`, `ModelsService`, `BidService`) and expose stream-based APIs to support real-time UI updates.

**Widgets** are placed in the `lib/widgets/` directory and contain reusable UI components shared across screens.

## 💻 Development

### Run Tests

```bash
flutter test
flutter test integration_test/
flutter test --coverage
```

### Code Quality

```bash
flutter format lib/
flutter analyze
flutter pub outdated
```

## 🚢 Deployment

### Android

1. **Configure signing:**  
   (See Flutter docs for keystore setup)

2. **Build release APK:**  
   `flutter build apk --release`

3. **Build App Bundle:**  
   `flutter build appbundle --release`

### iOS

1. **Configure signing in Xcode**
2. **Build IPA:**  
   `flutter build ipa --release`

### Web

```bash
flutter build web --release
firebase deploy --only hosting
```

## Acknowledgments

- Pluck team for the project requirements
- Flutter and Firebase communities
- Open source contributors

## Scope & Design Decisions

This project is intentionally scoped as a technical assessment rather than a production marketplace.

- Submodel names may repeat to reflect real-world configuration data from the source CSVs.
- Engine specifications are displayed contextually and adapt to available data.
- UI components are modularized for clarity and maintainability over feature completeness.
