# 🎬 Loopz - Short Video Platform

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Provider-663399?style=for-the-badge&logo=provider&logoColor=white" alt="Provider" />
  <img src="https://img.shields.io/badge/REST_API-02569B?style=for-the-badge&logo=google-cloud&logoColor=white" alt="REST API" />
</p>

Loopz is a modern, TikTok-inspired short video sharing application built with Flutter. It features a seamless vertical scrolling feed, real-time video playback, content creation tools, and a robust administration dashboard.

## ✨ Features

- **📱 Dynamic Video Feed**: High-performance vertical scrolling feed with auto-playing videos and smooth transitions.
- **🔐 Secure Authentication**: Full user lifecycle management including registration, login, and session persistence.
- **📤 Content Creation**: Integrated video picker and uploader with support for custom captions.
- **💬 Social Interaction**: 
  - Real-time commenting system.
  - Video liking and sharing functionality.
  - Creator profiles with video galleries.
- **🛡️ Admin Dashboard**: Dedicated administrative interface for:
  - Global platform analytics.
  - User management.
  - Video moderation (Approve/Reject content).
- **🎨 Premium UI/UX**: Sleek dark-mode aesthetic with custom gradients and micro-animations.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (v3.10.8+)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Networking**: [HTTP](https://pub.dev/packages/http) with a centralized `ApiClient` architecture.
- **Video Handling**: [Video Player](https://pub.dev/packages/video_player) & [Cached Network Image](https://pub.dev/packages/cached_network_image)
- **Local Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences) for session management.
- **Utilities**: `uuid`, `share_plus`, `timeago`, `intl`.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) / [Xcode](https://developer.apple.com/xcode/)
- A running instance of the [Loopz Backend](https://github.com/arcthaneaidelta/TikTok_App_Backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/arcthaneaidelta/TIK.git
   cd TIK/mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint**
   The application is configured to use a production backend by default. To use a local backend, update `lib/services/api_config.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_LOCAL_IP:5000';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── models/         # Data models (User, Video, Comment)
├── providers/      # State management logic
├── screens/        # UI Layers (Auth, Feed, Profile, Upload, Admin)
├── services/       # API clients and business logic
├── widgets/        # Reusable UI components
└── main.dart       # Application entry point
```

## 🔧 Configuration

The project uses a centralized configuration in `lib/services/api_config.dart` for endpoint management. Ensure your backend is reachable from your mobile device/emulator.

---
<p align="center">Made with ❤️ for the Loopz Community</p>
