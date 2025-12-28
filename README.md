# View Ads

A production-ready Flutter app for viewing and rating ads, where users earn bonus coins and can withdraw via PayPal.

## Features

### Core Features
- **User Registration/Login**: Email-based registration or anonymous guest mode
- **Daily Ads Feed**: View video ads, image ads, and playable ads (mock data with real-time simulation)
- **Ad Viewing System**: Mandatory 10-30 second watch time before rating
- **Rating System**: 1-5 star rating with optional comments
- **Coin Rewards**: Earn 5-50 random coins per viewed and rated ad

### Wallet & Rewards
- **Coin Balance**: Real-time coin balance tracking
- **Transaction History**: Complete history of all coin transactions
- **PayPal Withdrawal**: Mock withdrawal process with pending/approved/rejected status
- **Minimum Threshold**: 5000 coins = $5 USD withdrawal minimum

### Engagement Features
- **Leaderboard**: Top earners this week/month/all time
- **Daily Bonus**: Claim daily coins with streak multiplier
- **Streak Rewards**: Up to 100% bonus for consecutive daily logins
- **Profile Stats**: Total earned, withdrawn, ads watched, current rank

### UI/UX
- **Material 3 Design**: Modern, beautiful interface with animations
- **Dark/Light Theme**: System-aware theme with manual toggle
- **Multi-language**: English, Russian, and Spanish support
- **Responsive**: Works on phones and tablets

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants
│   ├── theme/           # Material 3 theme configuration
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
├── data/
│   ├── models/          # Data models (User, Ad, Transaction, etc.)
│   ├── providers/       # State management (Provider)
│   └── repositories/    # Data repositories
├── features/
│   ├── auth/            # Login/Register screens
│   ├── home/            # Home screen with quick stats
│   ├── ads/             # Ads feed and viewer
│   ├── wallet/          # Wallet and withdrawal
│   ├── leaderboard/     # Leaderboard rankings
│   └── profile/         # Profile and settings
├── l10n/                # Localization files (.arb)
├── services/            # Storage and mock data services
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository:
```bash
git clone https://github.com/remotenode/view-ads.git
cd view-ads
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters (if needed):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## Building for Release

### Android

1. Create a keystore for signing:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=upload
storeFile=upload-keystore.jks
```

3. Build the APK:
```bash
flutter build apk --release
```

4. Build the App Bundle:
```bash
flutter build appbundle --release
```

### iOS

1. Open the project in Xcode:
```bash
open ios/Runner.xcworkspace
```

2. Configure signing in Xcode with your Apple Developer account

3. Build for release:
```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Launcher Icons

1. Add your icon images:
   - `assets/icons/app_icon.png` (1024x1024)
   - `assets/icons/app_icon_foreground.png` (for adaptive icons)

2. Generate icons:
```bash
flutter pub run flutter_launcher_icons
```

## Native Splash Screen

```bash
flutter pub run flutter_native_splash:create
```

## Localization

The app supports three languages:
- English (en) - Default
- Russian (ru)
- Spanish (es)

Localization files are in `lib/l10n/`:
- `app_en.arb` - English strings
- `app_ru.arb` - Russian strings
- `app_es.arb` - Spanish strings

To add a new language:
1. Create `lib/l10n/app_XX.arb` with translated strings
2. Add the locale to `ThemeProvider.supportedLocales`
3. Run `flutter gen-l10n`

## Configuration

### App Constants
Edit `lib/core/constants/app_constants.dart`:
- `minWatchTimeSeconds`: Minimum ad watch time (default: 10)
- `maxWatchTimeSeconds`: Maximum ad watch time (default: 30)
- `minCoinsPerAd` / `maxCoinsPerAd`: Coin reward range (5-50)
- `minWithdrawalCoins`: Minimum withdrawal threshold (5000)
- `coinsToUsdRate`: Conversion rate (0.001 = 1000 coins = $1)
- `baseDailyBonus`: Base daily bonus (50 coins)

## Architecture

The app follows clean architecture principles:
- **Presentation Layer**: Flutter widgets and screens
- **Business Logic**: Provider for state management
- **Data Layer**: Hive for local storage, mock services for demo data

## Dependencies

Key packages used:
- `provider` - State management
- `hive_flutter` - Local database
- `shared_preferences` - Settings storage
- `flutter_localizations` - Multi-language support
- `intl` - Date/number formatting
- `flutter_animate` - Animations
- `uuid` - Unique ID generation

## License

This project is licensed under the MIT License.
