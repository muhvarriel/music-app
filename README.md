# 🎵 Music App

A modern Flutter music application that integrates with Spotify Web API to provide music discovery, audio previews, and artist exploration features with a sleek, responsive design.

## ✨ Features

### 🎧 Core Functionality
- **Real-time Music Search** - Search tracks and artists with debounced input for optimal performance
- **Audio Preview** - Play 30-second previews of tracks using Spotify's preview URLs
- **Artist Discovery** - Explore popular artists with detailed information and follower counts
- **Favorite Artists** - Save and manage your favorite artists with persistent storage
- **Global Audio Player** - Persistent mini-player with playback controls across the app

### 📱 User Experience
- **Responsive Design** - Adaptive layout for mobile and desktop/web platforms
- **Modern UI** - Clean Material Design with custom themes and animations
- **Hero Animations** - Smooth transitions between screens
- **Backdrop Blur Effects** - Beautiful visual effects on artist cards
- **Dark/Light Theme** - Automatic theme switching based on system preferences

### 🔧 Technical Features
- **Spotify API Integration** - OAuth 2.0 client credentials flow for secure API access
- **Smart Caching** - Efficient image caching with `cached_network_image`
- **State Management** - Provider pattern for audio state and GetX for navigation
- **Error Handling** - Robust error handling with automatic token refresh
- **Performance Optimized** - Lazy loading, debounced search, and efficient rendering

## 🏗️ Architecture

```
lib/
├── configuration/          # App configuration and environment variables
├── model/                 # Data models (Artist, Track, Album, etc.)
├── repository/            # Data access layer with API integration
├── services/              # Network services and utilities
├── ui/                    # User interface components
│   ├── screens/          # Main application screens
│   └── widgets/          # Reusable UI components
└── utils/                # Utilities, constants, and helpers
```

### 🎯 Design Patterns
- **Repository Pattern** - Clean separation between data access and business logic
- **Provider Pattern** - Reactive state management for audio player
- **Singleton Pattern** - Centralized API service management
- **Factory Pattern** - Model creation from JSON responses

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Spotify Developer Account
- Android Studio / VS Code with Flutter extensions

### 🔑 Spotify API Setup

1. Create a Spotify Developer account at [developer.spotify.com](https://developer.spotify.com)
2. Create a new app in your Spotify Dashboard
3. Copy your `Client ID` and `Client Secret`
4. Update `lib/configuration/app_environment.dart`:

```dart
class AppEnvironment {
  static const String spotifyClientId = 'your_client_id_here';
  static const String spotifyClientSecret = 'your_client_secret_here';
}
```

### 📦 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/muhvarriel/music-app.git
   cd music-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Spotify credentials**
   - Update `lib/configuration/app_environment.dart` with your API credentials

4. **Run the application**
   ```bash
   flutter run
   ```

## 📚 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.5+1
  get: ^4.7.2

  # Network & API
  dio: ^5.9.0

  # Audio Playback
  audioplayers: ^6.5.1

  # UI & Design
  google_fonts: ^6.3.2
  cached_network_image: ^3.4.1
  like_button: ^2.1.0
  cupertino_icons: ^1.0.8

  # Storage & Utils
  shared_preferences: ^2.5.3
  intl: ^0.20.2

dev_dependencies:
  flutter_lints: ^6.0.0
```

## 🎨 Screenshots

### Mobile Interface
- Clean, modern design optimized for mobile devices
- Intuitive navigation with bottom player
- Smooth animations and transitions

### Desktop Interface
- Responsive layout with sidebar navigation
- Multi-panel view for enhanced productivity
- Optimized for larger screens

## 🔧 Technical Implementation

### Audio System
The app uses a sophisticated audio management system:

```dart
class MusicProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(Tracks track) async {
    final previewUrl = await MusicRepo.getSpotifyPreviewUrl(track.id ?? "");
    if (previewUrl?.isNotEmpty ?? false) {
      await _player.play(UrlSource(previewUrl!));
    }
  }
}
```

### API Integration
Robust Spotify API integration with automatic token management:

```dart
static Future<void> generateToken() async {
  final response = await dio.post("token", data: {
    "grant_type": "client_credentials",
    "client_id": AppEnvironment.spotifyClientId,
    "client_secret": AppEnvironment.spotifyClientSecret,
  });

  await setSharedString("spotifyToken", response.data['access_token']);
}
```

## 🛠️ Development

### Project Structure
- **Models** - Type-safe data structures for API responses
- **Repositories** - Data access layer with error handling
- **Services** - Network configuration and API clients
- **Providers** - State management for reactive UI updates
- **Widgets** - Reusable UI components with consistent styling

### Code Quality
- Consistent naming conventions
- Proper error handling with try-catch blocks
- Separation of concerns between UI and business logic
- Type-safe JSON serialization

## 🚧 Roadmap

### Upcoming Features
- [ ] Playlist creation and management
- [ ] User authentication with Spotify login
- [ ] Enhanced search filters (genre, year, etc.)
- [ ] Offline favorites storage
- [ ] Social sharing features
- [ ] Advanced audio controls (EQ, crossfade)

### Technical Improvements
- [ ] Unit and integration tests
- [ ] Performance monitoring
- [ ] Advanced error tracking
- [ ] Accessibility improvements
- [ ] Multi-language support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Spotify Web API** - For providing comprehensive music data
- **Flutter Team** - For the amazing cross-platform framework
- **Community Contributors** - For the excellent packages and libraries used

## 📞 Contact

**Developer**: Varriel Muhammad  
**GitHub**: [@muhvarriel](https://github.com/muhvarriel)  
**Project Link**: [https://github.com/muhvarriel/music-app](https://github.com/muhvarriel/music-app)

---

⭐ **Star this repository if you found it helpful!**
