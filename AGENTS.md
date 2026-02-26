# Anser Project Documentation

## Project Overview

**Anser** is a universal Apple platform application built with SwiftUI. It is designed to be a multi-platform app targeting iOS, macOS, and visionOS (Apple Vision Pro). 

Based on the product requirements document (`iOS版《抓大鹅》产品需求文档（PRD）.docx`), this app appears to be a game titled "Catch the Big Goose" (抓大鹅) - an iOS game project.

- **Bundle Identifier**: `com.alvin.Anser`
- **Version**: 1.0
- **Created**: February 26, 2026
- **Author**: 牛慧升 (Niu Huisheng)

## Technology Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Development Environment**: Xcode 26.2
- **Minimum Deployment Targets**:
  - iOS 26.2
  - macOS 26.2
  - visionOS (xros) 26.2

## Project Structure

```
Anser/
├── AnserApp.swift          # App entry point (@main)
├── ContentView.swift       # Main view implementation
└── Assets.xcassets/        # Asset catalog
    ├── Contents.json
    ├── AccentColor.colorset/    # Global accent color
    └── AppIcon.appiconset/      # App icons (iOS, macOS)

Anser.xcodeproj/            # Xcode project configuration
├── project.pbxproj         # Project build settings
├── project.xcworkspace/    # Workspace configuration
└── xcuserdata/             # User-specific settings
```

## Key Source Files

### AnserApp.swift
The application entry point using the `@main` attribute. It sets up the main window group with `ContentView` as the root view.

### ContentView.swift
The primary view of the application. Currently contains a basic SwiftUI template with a "Hello, world!" text and a globe icon.

## Build Configuration

### Supported Platforms
- iPhone (device and simulator)
- iPad
- Mac (macOS)
- Apple Vision Pro (visionOS)

### Build Settings
- **Code Signing**: Automatic (`CODE_SIGN_STYLE = Automatic`)
- **App Sandbox**: Enabled
- **User Selected Files**: Read-only access
- **Swift Concurrency**: Approachable concurrency enabled
- **Default Actor Isolation**: MainActor

### Build Commands

Build the project using Xcode or command line tools:

```bash
# Build for iOS Simulator
xcodebuild -project Anser.xcodeproj -scheme Anser -sdk iphonesimulator

# Build for macOS
xcodebuild -project Anser.xcodeproj -scheme Anser -sdk macosx

# Build for iOS Device
xcodebuild -project Anser.xcodeproj -scheme Anser -sdk iphoneos
```

## Development Guidelines

### Code Style
- Follow standard Swift naming conventions
- Use SwiftUI's declarative syntax patterns
- File headers include creation date and author

### Swift Features Enabled
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES` - Upcoming Swift features
- `SWIFT_APPROACHABLE_CONCURRENCY = YES` - Modern concurrency model
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` - UI updates on main actor

### Asset Management
- App icons support multiple platforms (iOS, macOS)
- iOS icons support light, dark, and tinted modes
- Accent color is defined but uses system default

## Testing

Currently, the project does not include any test targets. To add tests:
1. Create a Unit Test target in Xcode
2. Create a UI Test target for UI automation

## Localization

- Base localization is configured
- String catalogs are enabled (`STRING_CATALOG_GENERATE_SYMBOLS = YES`)
- Development region is set to English (`en`)

## Security Considerations

- App Sandbox is enabled (`ENABLE_APP_SANDBOX = YES`)
- User script sandboxing is enabled
- File access is restricted to read-only for user-selected files

## Notes for AI Agents

- This is a newly created project (February 2026) with minimal implementation
- The project uses Xcode's new file system synchronization feature (`PBXFileSystemSynchronizedRootGroup`)
- The app targets very recent OS versions (26.2), requiring latest development tools
- The project is intended to be a game based on the PRD document present in the repository
