# AirShield Mobile 🌬️

> **Air Quality Monitoring & Smart Home Control** - A comprehensive Flutter mobile application for monitoring air quality and controlling smart home devices.

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📱 Features

### Core Features ✅
- **Real-time AQI Monitoring** - Track air quality index with detailed pollutant breakdowns
- **Smart Device Control** - Manage air purifiers and other smart home devices
- **Automation Rules** - Create intelligent rules based on AQI thresholds and time
- **Push Notifications** - Receive alerts for air quality changes and device status
- **Interactive Maps** - Visualize AQI data on maps with location-based information
- **Historical Data & Charts** - View AQI trends with beautiful fl_chart visualizations
- **AI Chatbot 🤖** - Gemini-powered assistant for AQI queries and device control

### User Management ✅
- **Profile Management** - Edit profile with avatar upload (camera/gallery)
- **Health Preferences** - Set health conditions and AQI sensitivity levels
- **Saved Locations** - Manage favorite locations for quick AQI checks
- **Settings** - Customize theme (Light/Dark/System) and language (EN/VI)

### UI/UX ✅
- **Modern Design** - Beautiful, intuitive interface with smooth animations
- **Dark/Light Theme** - Full theme support with system preference sync
- **Bilingual Support** - Complete English and Vietnamese translations
- **Responsive Layout** - Optimized for various screen sizes

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.10+ installed ([Download here](https://flutter.dev/docs/get-started/install))
- Dart 3.0+
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/airshield.git
   cd airshield/airshield_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Check available devices**
   ```bash
   flutter devices
   ```

4. **Run the app**
   ```bash
   # Run on Chrome (for development)
   flutter run -d chrome
   
   # Run on Android emulator
   flutter run -d android
   
   # Run on iOS simulator (macOS only)
   flutter run -d ios
   ```

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.10+
- **Language**: Dart 3.0+
- **State Management**: flutter_bloc (BLoC pattern)
- **Navigation**: go_router
- **UI Components**: Google Fonts, Material Design 3

### Data & Storage
- **Local Storage**: shared_preferences, flutter_secure_storage
- **Models**: Equatable, freezed (code generation)

### Features
- **Charts**: fl_chart
- **Maps**: flutter_map, latlong2
- **Notifications**: firebase_messaging, flutter_local_notifications
- **Image Picker**: image_picker
- **Networking**: dio

### Code Generation
- **build_runner**, **freezed**, **json_serializable**

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── api/              # API client (Dio)
│   ├── l10n/             # Localization (EN/VI)
│   ├── theme/            # Theme management
│   └── utils/            # Utility functions
│
├── features/
│   ├── auth/            # Authentication & Authorization
│   ├── dashboard/       # Main dashboard
│   ├── chatbot/         # AI Assistant 🤖
│   ├── smart_home/      # Device management
│   ├── automation/      # Automation rules
│   ├── notifications/   # Push & local notifications
│   ├── profile/         # User profile management
│   └── map/             # Map with AQI overlay
│
└── main.dart            # App entry point
```

Each feature follows **Clean Architecture** with:
- `data/` - Models, repositories
- `presentation/` - UI, BLoC, widgets

---

## 🎨 Screenshots

> _Screenshots coming soon_

---

## 🌍 Localization

AirShield supports multiple languages:
- 🇺🇸 **English**
- 🇻🇳 **Vietnamese (Tiếng Việt)**

To switch language: `Profile → Settings → Language`

---

## 🔧 Configuration

### Android Permissions

Permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- Camera access (for avatar photos)
- Photo library access
- Internet access
- Location access (for maps)

### iOS Permissions

Permissions are configured in `ios/Runner/Info.plist`:
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSLocationWhenInUseUsageDescription`

---

## 📦 Build & Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

### iOS IPA (macOS only)
```bash
flutter build ios --release
```

---

## 🧪 Testing

**Current Status**: Manual testing completed

```bash
# Run unit tests (when available)
flutter test

# Run integration tests (when available)
flutter test integration_test
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Your Name** - _Initial work_

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community packages creators
- Design inspiration from modern air quality apps

---

## 📞 Support

For issues, questions, or suggestions:
- 📧 Email: support@airshield.app
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/airshield/issues)

---

**Made with ❤️ using Flutter**
