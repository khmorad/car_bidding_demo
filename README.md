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
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init
```

Select these features:

- Firestore
- Functions
- Storage

### 2. Firestore Database Structure

```
users/
  {userId}/
    - email: string
    - password: string (Note: use Firebase Auth in production!)

makers/
  {makerId}/
    - id: string
    - name: string

models/
  {modelId}/
    - id: string
    - name: string
    - make_id: string
    - year: string

bids/
  {bidId}/
    - model_id: string
    - user_id: string
    - amount: number
    - created_at: timestamp
```

### 4. Firestore Security Rules

```javascript
// filepath: firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if true; // Allow signup
      allow update, delete: if request.auth.uid == userId;
    }

    // Makers collection (read-only for users)
    match /makers/{makerId} {
      allow read: if true;
      allow write: if false; // Only via Cloud Functions
    }

    // Models collection (read-only for users)
    match /models/{modelId} {
      allow read: if true;
      allow write: if false; // Only via Cloud Functions
    }

    // Bids collection
    match /bids/{bidId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.user_id == request.auth.uid
                    && request.resource.data.amount is number
                    && request.resource.data.amount > 0;
      allow update, delete: if false; // Bids are immutable
    }
  }
}
```

### 5. Firestore Indexes

```json
// filepath: firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "bids",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "model_id", "order": "ASCENDING" },
        { "fieldPath": "amount", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Deploy indexes:

```bash
firebase deploy --only firestore:indexes
```

## Cloud Functions

### Import CSV Data Function

The `importCars` function reads CSV files from Cloud Storage and populates Firestore.

**Setup:**

1. **Upload CSV files to Firebase Storage:**

   ```bash
   # Create csv folder in Storage bucket
   gsutil cp makes-sample.csv gs://your-project.appspot.com/csv/
   gsutil cp models-sample.csv gs://your-project.appspot.com/csv/
   ```

2. **Deploy the function:**

   ```bash
   firebase deploy --only functions
   ```

3. **Trigger the import:**
   ```bash
   # Get your function URL from Firebase Console
   curl https://REGION-PROJECT_ID.cloudfunctions.net/importCars
   ```

**Function Code Overview:**

## Navigation

**Navigation Examples:**

```dart
// Navigate to route
context.go('/makers');

// Navigate with path parameters
context.go('/models/$makerId?makerName=$name');

// Navigate with object
context.go('/model', extra: carModel);

// Go back
context.pop();
```

## Screenshots

still in progress

## API Reference

### AuthService

```dart
class AuthService {
  Future<User?> login(String email, String password);
  Future<User?> register(String email, String password);
}
```

### BidService

```dart
class BidService {
  // Stream real-time bids for a model
  Stream<List<BidModel>> streamBidsForModel(String modelId);

  // Place a new bid
  Future<void> placeBid({
    required String modelId,
    required String userId,
    required double amount,
  });
}
```

### MakersService

```dart
class MakersService {
  Stream<List<Maker>> getMakers();
}
```

### ModelsService

```dart
class ModelsService {
  Stream<List<CarModel>> getModelsByMaker(String makerId);
}
```

## 💻 Development

### Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests with coverage
flutter test --coverage
```

### Code Quality

```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Check for outdated dependencies
flutter pub outdated
```

### Environment Configuration

```dart
// Create lib/config/env.dart
class Environment {
  static const String apiUrl = String.fromEnvironment('API_URL');
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
```

Run with environment variables:

```bash
flutter run --dart-define=API_URL=https://api.example.com
```

## 🚢 Deployment

### Android

1. **Configure signing:**

   ```bash
   # Generate keystore
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
           -keysize 2048 -validity 10000 -alias upload
   ```

2. **Build release APK:**

   ```bash
   flutter build apk --release
   ```

3. **Build App Bundle:**
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Configure signing in Xcode**

2. **Build IPA:**
   ```bash
   flutter build ipa --release
   ```

### Web

```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## Acknowledgments

- Pluck team for the project requirements
- Flutter and Firebase communities
- Open source contributors
