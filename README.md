# MoodMelody v2

## Summary

MoodMelody is an iOS app that provides personalized music recommendations based on your current mood. The app integrates with Apple Music to search for and play track previews that match four distinct emotional states: Happy, Sad, Angry, and Frustrated. Users can discover new music, like tracks, and build personalized playlists for different moods.

### Key Features

- **Mood-Based Discovery**: Select from four mood categories to get tailored music recommendations
- **Apple Music Integration**: Seamless integration with Apple Music for track search and preview playback
- **Smart Caching**: 24-hour intelligent caching system to improve performance and reduce API calls
- **Like System**: Save favorite tracks for each mood category
- **Preview Playback**: 30-second track previews with playback controls
- **Onboarding Flow**: Guided setup with Apple Music authorization

---

## Technical Overview

### Architecture

MoodMelody v2 follows a modular Swift Package Manager architecture with clear separation of concerns:

```
MoodMelody v2/
├── moodmelodyv2/           # Main iOS app target
├── MoodCore/               # Core business logic and models
├── AppleMusicClient/       # Apple Music API integration
└── UIComponents/           # Reusable UI components
```

### Swift Packages

#### 1. **MoodCore** 
Core business logic and shared models used across the application.

**Key Components:**
- `Track.swift` - Core track model with metadata and like functionality
- `MoodType.swift` - Enum defining the four mood categories with search terms and visual styling
- `MoodCache.swift` - Persistent caching layer using UserDefaults with 24-hour expiration

#### 2. **AppleMusicClient**
Handles all Apple Music API interactions and audio playback.

**Key Components:**
- `AppleMusicSearch.swift` - Manages MusicKit catalog search requests
- `AppleMusicPlayback.swift` - AVFoundation-based preview playback system
- `AppleMusicAuth.swift` - Apple Music authorization management

#### 3. **UIComponents**
Reusable SwiftUI components for consistent UI across the app.

**Key Components:**
- `TrackCard.swift` - Individual track display with playback and like controls
- `MoodButton.swift` - Mood selection buttons with emoji and color theming
- `PlaybackBar.swift` - Mini-player showing current track with basic controls

### Core Features Deep Dive

#### Mood System
The app centers around four predefined moods, each with:
- **Visual Identity**: Unique emoji and color scheme
- **Search Strategy**: Tailored Apple Music search terms
- **Persistent State**: Separate like lists and cache storage

```swift
public enum MoodType: String, CaseIterable {
    case happy = "Happy"        // 😊 Yellow
    case sad = "Sad"           // 😢 Blue  
    case angry = "Angry"       // 😡 Red
    case frustrated = "Frustrated" // 😤 Orange
}
```

#### Smart Caching Strategy
- **24-Hour Expiration**: Balances fresh content with performance
- **Mood-Specific Storage**: Separate cache buckets for each mood
- **Like State Persistence**: User preferences survive app restarts
- **Graceful Fallback**: Falls back to live search when cache expires

#### Apple Music Integration
- **MusicKit Framework**: Official Apple Music API integration
- **Catalog Search**: Searches Apple Music's full catalog based on mood
- **Preview Playback**: 30-second track previews via AVFoundation
- **Authorization Flow**: Handles Music app permissions and restrictions

### App Flow

1. **Launch**: Check onboarding completion status
2. **Onboarding**: Request Apple Music authorization if needed
3. **Mood Selection**: Present four mood options in a grid layout
4. **Track Discovery**: Search Apple Music catalog (cached or live)
5. **Playback**: Preview tracks with playback controls
6. **Personalization**: Like tracks to build mood-specific collections

### Technical Requirements

- **iOS 15.0+**: Minimum deployment target
- **Swift 5.9+**: Swift tools version
- **MusicKit**: Apple Music integration
- **AVFoundation**: Audio playback capabilities
- **Apple Music Subscription**: Required for full functionality

### Project Configuration

#### Info.plist Permissions
```xml
<key>NSAppleMusicUsageDescription</key>
<string>MoodMelody needs access to Apple Music to provide personalized music recommendations based on your mood.</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

#### Entitlements
- `com.apple.developer.musickitidentifiers`: Apple Music catalog access
- `com.apple.developer.playable-content`: Background audio playback

### State Management

The app uses a combination of:
- **@StateObject/@ObservableObject**: For reactive UI updates
- **@AppStorage**: For simple persistent settings (onboarding status)
- **UserDefaults**: For complex cached data (tracks, likes)
- **Singleton Pattern**: For shared services (search, playback, cache)

### Testing Structure

- **Unit Tests**: `moodmelodyv2Tests/` - Business logic testing
- **UI Tests**: `moodmelodyv2UITests/` - End-to-end user interaction testing
- **XCTest Framework**: Standard iOS testing with XCTAssert functions

### Key Dependencies

- **MusicKit**: Apple's official framework for Apple Music integration
- **AVFoundation**: Audio session management and playback
- **SwiftUI**: Modern declarative UI framework
- **Foundation**: Core Swift framework for data handling

### Performance Considerations

- **Lazy Loading**: Track lists use LazyVStack for efficient memory usage
- **Image Caching**: AsyncImage handles artwork loading and caching
- **Search Debouncing**: Prevents excessive API calls during user interaction
- **Background Audio**: Continues playback when app is backgrounded

### Future Enhancement Opportunities

- **Machine Learning**: Improve mood-based recommendations over time
- **Social Features**: Share mood playlists with friends
- **Custom Moods**: Allow users to create custom mood categories
- **Analytics**: Track user preferences for better recommendations
- **Offline Mode**: Download tracks for offline listening
- **Cross-Platform**: Expand to macOS, watchOS, or tvOS

---

## Getting Started

### Prerequisites
1. Xcode 16.1 or later
2. iOS 15.0+ deployment target
3. Apple Developer account for device testing
4. Apple Music subscription (recommended for full experience)

### Setup
1. Clone the repository
2. Open `moodmelodyv2.xcodeproj` in Xcode
3. Ensure all Swift Package dependencies are resolved
4. Configure your development team in project settings
5. Build and run on device or simulator

### Development Notes
- The app requires Apple Music authorization to function fully
- Preview playback works in simulator but device testing recommended
- Cache data persists between app launches for testing convenience