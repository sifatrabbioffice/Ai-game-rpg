# 🎮 Epic RPG Quest - iOS

A fully-featured iOS RPG game built with SwiftUI, featuring character creation, dungeon exploration, turn-based combat, and persistent progression. Optimized for sideloading on iOS devices.

![Game Preview](https://img.shields.io/badge/iOS-15.0+-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange?logo=swift)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### Game Features

- 🎭 **4 Character Classes**: Warrior, Mage, Rogue, Paladin
- ⚔️ **Turn-Based Combat System**: Strategic battle mechanics
- 🗺️ **4 Explorable Locations**: Village, Forest, Dungeon, Tower
- 💾 **Save/Load System**: Persistent game state
- 📊 **Progression System**: Level up, gain experience, collect loot
- 🎨 **Dark Mode UI**: Beautiful gradient-based interface
- 💪 **Stats System**: Attack, Defense, Magic, HP management

### Technical Features

- ✅ **SwiftUI UI Framework**: Modern, reactive interface
- 📦 **MVVM Architecture**: Clean, maintainable code
- 🔒 **Code Signing Free**: No developer account required for testing
- 🚀 **GitHub Actions CI/CD**: Automated builds and testing
- 🧪 **Unit & Performance Tests**: Comprehensive test suite
- 🔐 **Security Scanning**: Automated vulnerability checks
- 📈 **Analytics & Logging**: Built-in telemetry

## 🚀 Quick Start

### Prerequisites

- macOS 12.0+
- Xcode 15.0+
- iOS 15.0+ device
- Git

### Installation (5 minutes)

```bash
# Clone the repository
git clone https://github.com/yourusername/rpg-game-ios.git
cd rpg-game-ios

# Install dependencies
bundle install
fastlane install_plugins

# Build the app
./build.sh --release --sideload

# The IPA file will be at: build/RPGGame-sideload.ipa
```

### Sideload to iPhone (Using AltStore)

1. **Install AltStore** on your Mac from <https://altstore.io/>
1. **Connect iPhone** via USB
1. **Open AltStore** → Click “Install IPA”
1. **Select** `build/RPGGame-sideload.ipa`
1. **Sign in** with your Apple ID (free account works)
1. **On your iPhone**: Settings → General → VPN & Device Management → Trust developer
1. **Launch** the app from your home screen! 🎉

**That’s it!** The app will refresh via Wi-Fi every 7 days.

## 📁 Project Structure

```
rpg-game-ios/
├── .github/
│   └── workflows/build.yml           # CI/CD Pipeline
├── RPGGame/
│   ├── RPGGameApp.swift              # App entry point
│   ├── ContentView.swift             # UI layer (6 views)
│   ├── RPGGame.swift                 # Game logic & models
│   ├── AppDelegate.swift             # Configuration
│   └── Info.plist                    # App metadata
├── RPGGameTests/
│   ├── RPGGameTests.swift            # Unit tests
│   └── PerformanceTests.swift        # Benchmarks
├── Fastfile                          # Build automation
├── build.sh                          # Quick build script
├── SETUP_AND_DEPLOYMENT_GUIDE.md     # Detailed setup
└── README.md                         # This file
```

## 🎮 Gameplay

### Character Creation

1. Enter your name
1. Choose class (Warrior/Mage/Rogue/Paladin)
1. Each class has unique stats and abilities

### Locations

- **Village**: Safe haven, Inn for healing, Shop for items
- **Forest**: Medium difficulty encounters
- **Dungeon**: High difficulty encounters
- **Tower**: Final boss battle with Ancient Dragon

### Combat

- **Attack**: Standard damage based on attack stat
- **Magic**: Spell-based damage (uses magic stat)
- **Heal**: Restore 25 HP
- **Escape**: 50% chance to flee

### Progression

- Gain experience from battles
- Level up to increase stats
- Collect loot and gold
- Unlock new items in shop

## 🏗️ Architecture

### Models

```swift
Player          // Main character with stats/inventory
Enemy           // Enemies with combat stats
Item            // Weapons, armor, potions
CharacterClass  // 4 playable classes
```

### Managers

```swift
GameManager     // Game state & logic
AnalyticsService   // Event tracking
DataStorageService // Save/load data
LoggingService     // Debug logging
```

### Views (SwiftUI)

```
ContentView
├── MainMenuView
├── VillageView
├── ForestView
├── DungeonView
├── TowerView
├── BattleView
├── GameOverView
└── VictoryView
```

## 🛠️ Building

### Build Variants

```bash
# Debug build (local testing)
./build.sh

# Release build (optimized)
./build.sh --release

# With sideload IPA
./build.sh --release --sideload

# With tests
./build.sh --release --test

# Clean and rebuild
./build.sh --release --clean --sideload
```

### Using Fastlane

```bash
# Build and test
fastlane ios build_and_test

# Build for sideload
fastlane ios build_for_sideload

# Run linter
fastlane ios lint

# Generate build report
fastlane ios generate_report
```

### Using Xcode

```bash
# Build
Cmd + B

# Run on device
Cmd + R

# Archive for distribution
Product → Archive
```

## 🔄 CI/CD Pipeline

Automated builds on every push:

1. **Build**: Compiles Debug + Release versions
1. **Tests**: Runs unit and performance tests
1. **Analysis**: SwiftLint code quality checks
1. **Security**: Semgrep vulnerability scanning
1. **Artifacts**: Uploads IPA for download

### View Results

- GitHub Actions tab → Select workflow
- Download artifacts
- View test reports

### Create Release

```bash
git tag v1.0.0
git push origin v1.0.0
# GitHub Actions automatically builds and releases IPA
```

## 🧪 Testing

### Run Tests Locally

```bash
# All tests
xcodebuild test -scheme RPGGame

# Specific test class
xcodebuild test -scheme RPGGame -only-testing RPGGameTests/GameLogicTests

# With coverage
xcodebuild test -scheme RPGGame -enableCodeCoverage YES
```

### Using Fastlane

```bash
# Run all tests
fastlane ios test

# Performance tests
fastlane ios performance_test
```

## 📊 Performance

### Metrics

- **Build Time**: ~2-3 minutes (Release)
- **App Size**: 50-80 MB
- **Launch Time**: <2 seconds
- **Memory Usage**: ~100 MB at launch

### Optimization Tips

```bash
# Parallel compilation (faster builds)
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks $(sysctl -n hw.ncpu)

# Strip debug symbols (smaller app)
# Enable in build settings: Strip Linked Product

# Use incremental compilation
# Xcode default, but can be adjusted in build settings
```

## 🔐 Security

### Features

- No external network requests (offline-capable)
- User data stored locally only
- No analytics tracking (configurable)
- Code scanning with Semgrep
- SBOM (Software Bill of Materials) generation

### Checklist

- ✅ No hardcoded secrets
- ✅ Input validation
- ✅ Safe string handling
- ✅ Memory safety (Swift)
- ✅ No debug logging in Release

## 🐛 Troubleshooting

### Common Issues

**App crashes on launch**

```swift
// Check console logs
Xcode → Window → Devices and Simulators
Select device → View Device Logs
```

**IPA won’t install**

- Ensure iOS 15.0+
- Verify bundle ID matches
- Try different sideload method

**Build fails**

```bash
# Clean and rebuild
rm -rf ~/Library/Developer/Xcode/DerivedData/*
./build.sh --clean --release
```

**Code signing issues**

```bash
# Disable code signing for testing
CODE_SIGN_IDENTITY=""
CODE_SIGNING_REQUIRED=NO
```

### Get Help

- 📖 [Setup Guide](SETUP_AND_DEPLOYMENT_GUIDE.md)
- 🐛 [GitHub Issues](../../issues)
- 💬 [GitHub Discussions](../../discussions)

## 📱 Device Compatibility

### Supported Devices

- iPhone 6s or later
- iPad (3rd generation) or later
- iOS 15.0 or higher

### Tested On

- iPhone 14 Pro (iOS 17.x)
- iPhone 13 Mini (iOS 16.x)
- iPhone 12 (iOS 15.x)

## 📚 Documentation

- [Setup & Deployment Guide](SETUP_AND_DEPLOYMENT_GUIDE.md) - Comprehensive guide
- [GitHub Actions Workflow](.github/workflows/build.yml) - CI/CD details
- [Code Documentation](RPGGame/RPGGame.swift) - Inline code docs

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
1. Create a feature branch: `git checkout -b feature/amazing-feature`
1. Make your changes
1. Run tests: `fastlane ios test`
1. Run linter: `fastlane ios lint`
1. Commit: `git commit -m 'Add amazing feature'`
1. Push: `git push origin feature/amazing-feature`
1. Open Pull Request

## 📄 License

MIT License - see LICENSE file for details

## 🎯 Roadmap

### v1.1 (Planned)

- [ ] Multiplayer battles
- [ ] More character classes
- [ ] Equipment system
- [ ] Skill tree
- [ ] Achievements

### v1.2 (Future)

- [ ] Story/quest system
- [ ] NPC dialogue
- [ ] Procedural dungeons
- [ ] Guilds
- [ ] Cloud save sync

### v2.0 (Long term)

- [ ] 3D graphics
- [ ] Online multiplayer
- [ ] Social features
- [ ] Tournaments
- [ ] Cosmetics/cosmetics shop

## 🙏 Credits

- Built with **SwiftUI**
- CI/CD by **GitHub Actions**
- Automated with **Fastlane**
- Code quality by **SwiftLint**
- Security scanning by **Semgrep**

## 📞 Contact

- 📧 Email: [dev@yourcompany.com](mailto:dev@yourcompany.com)
- 🐦 Twitter: [@yourusername](https://twitter.com/yourusername)
- 💼 LinkedIn: [Your Profile](https://linkedin.com)

## ⭐ Show Your Support

If you enjoy this game, please star the repository! ⭐

-----

**Made with ❤️ for iOS developers**

Last updated: 2024 | Version: 1.0.0 | Swift 5.9+ | iOS 15.0+