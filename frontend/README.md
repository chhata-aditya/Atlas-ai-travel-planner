# 🌍 Atlas — AI Travel Co-Pilot & Smart Trip Planner

<p align="center">
  <img src="web/icons/Icon-512.png" width="100" alt="Atlas Logo" />
</p>

<p align="center">
  <b>Your next-generation intelligent mobile travel companion built with Flutter.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-iOS%20|%20Android%20|%20Web-4EAA25?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License" />
</p>

---

## 📖 Overview

**Atlas** is a modern, cross-platform travel companion app designed to simplify vacation planning, discovery, and real-time trip assistance. With clean Material 3 design and rich interactive features, Atlas turns trip organization into an effortless, delightful journey.

---

## ✨ Key Features

- 🧠 **AI Smart Trip Planner**: Generate customized day-by-day itineraries tailored to your budget, travel style, and interests.
- 🗺️ **Explore & Discover**: Search top global destinations with rich media, ratings, weather info, and curated recommendations.
- 🧭 **Live Journey Co-Pilot**: Real-time trip status tracking, navigation steps, and milestone updates.
- 🛂 **Digital Passport & Stamps**: Collect interactive digital stamps, travel badges, and maintain your traveler license profile.
- 🛡️ **Safety & Emergency Hub**: Quick-access SOS triggers, local emergency contacts, and real-time safety advisories.
- 🎨 **Modern Material Design**: Fluid animations, custom theme system, and responsive mobile layout.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Channel stable, Material 3)
- **Language**: [Dart](https://dart.dev/)
- **State & Local Storage**: Flutter Stateful Architecture, `shared_preferences`
- **Design System**: Custom `AppTheme` with custom typography, color palettes, and reusable widget kit

```
lib/
├── data/          # Mock repositories and static travel datasets
├── models/        # Data models (Destination, Itinerary, Trip, UserProfile)
├── screens/       # Core app screens (Home, Explore, Planner, Journey, Safety, Auth)
├── services/      # Business logic & travel data services
├── theme/         # Color palettes, typography, theme constants
├── widgets/       # Reusable UI components (Banners, Cards, Passport Book)
└── main.dart      # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.12.0` or higher)
- Android Studio / VS Code with Flutter extension
- Connected physical device, Android Emulator, or iOS Simulator

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/chhata-aditya/Atlas-ai-travel-planner.git
   cd Atlas-ai-travel-planner
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 📱 Supported Platforms

| Android | iOS | Web | Windows / macOS |
| :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ✅ |

---

## 📄 License

This project is open source and available under the MIT License.
