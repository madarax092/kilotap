# KiloTap — Flutter Mobile App Prototype

> **"Your Scrap , Their Livelihood, One Tap Away."**

KiloTap is a two-sided recyclable scrap marketplace connecting:
- 🟢 **Sellers** (Households & Small Businesses) — book scrap pickups
- 🔵 **Buyers** (Junk Collectors) — accept pickups, track earnings

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x SDK
- Firebase account
- Android Studio / VS Code with Flutter extension

### 1. Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password + Google)
3. Enable **Cloud Firestore**
4. Enable **Firebase Storage**
5. Download `google-services.json` → place in `android/app/`
6. Update `lib/firebase_options.dart` with your Firebase config

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

---

## 📱 Screens

### Authentication
| Screen | Route | Role |
|---|---|---|
| Landing / Role Selection | `/` | Both |
| Seller Registration | `/seller-auth` | Seller |
| Buyer Registration | `/buyer-auth` | Buyer |

### Seller Flow
| Screen | Route |
|---|---|
| Home Dashboard | `/seller-home` |
| Book a Pickup | `/book-pickup` |
| Booking History | `/seller-history` |
| Settings | `/seller-settings` |

### Buyer Flow
| Screen | Route |
|---|---|
| Home (Online/Offline) | `/buyer-home` |
| Earnings History | `/buyer-history` |
| Settings | `/buyer-settings` |

---

## 🎨 Brand Colors

| Token | Hex | Usage |
|---|---|---|
| Seller Green | `#1B8A5A` | All seller-facing UI |
| Buyer Blue | `#1A85C8` | All buyer-facing UI |
| App Canvas | `#F8F9FA` | Screen backgrounds |
| Pure White | `#FFFFFF` | Cards, inputs |
| Input/Inactive | `#EDF1F3` | Form fields, tabs |

---

## 🏗 Architecture

```
lib/
├── core/          # Theme, colors, constants
├── models/        # Data models (User, Pickup, MarketPrice)
├── services/      # Firebase Auth + Firestore services
├── providers/     # Riverpod state management
├── screens/       # All UI screens
│   ├── landing/   # Landing screen
│   ├── auth/      # Seller + Buyer auth
│   ├── seller/    # Seller dashboard, booking, history, settings
│   └── buyer/     # Buyer home, history, settings
├── widgets/       # Reusable UI components
└── router.dart    # GoRouter navigation
```

---

## 🔥 Firebase Collections

| Collection | Description |
|---|---|
| `users/{uid}` | User profiles (seller & buyer) |
| `pickups/{id}` | Pickup bookings |
| `market_prices/{type}` | Live scrap prices |

---

## 🛠 Tech Stack

- **Framework**: Flutter 3.x (Dart)
- **State**: flutter_riverpod
- **Navigation**: go_router
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Fonts**: Nunito Sans + Inter (via google_fonts)
- **UI Design**: StitchMCP (Google AI-generated screens)

---

## 📦 Key Dependencies

```yaml
flutter_riverpod: ^2.5.1   # State management
go_router: ^14.2.7          # Navigation
firebase_core: ^3.6.0       # Firebase
firebase_auth: ^5.3.1       # Authentication
cloud_firestore: ^5.4.4     # Database
google_sign_in: ^6.2.1      # Google OAuth
google_fonts: ^6.2.1        # Typography
url_launcher: ^6.3.0        # Terms of Service link
intl: ^0.19.0               # Date formatting
```

---

## ⚙️ Notes for Production

1. Replace `firebase_options.dart` with actual Firebase config
2. Add `google-services.json` to `android/app/`
3. Configure Google Sign-In SHA-1 fingerprint in Firebase Console
4. Set up Firestore security rules
5. Initialize market prices via `FirestoreService().seedMarketPrices()`
