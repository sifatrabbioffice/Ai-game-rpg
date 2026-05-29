# iOS RPG Game - Complete Setup & Deployment Guide

## Project Structure

```
rpg-game-ios/
├── .github/
│   └── workflows/
│       └── build.yml                 # GitHub Actions CI/CD pipeline
├── RPGGame/
│   ├── RPGGameApp.swift             # App entry point
│   ├── ContentView.swift            # Main UI views
│   ├── RPGGame.swift                # Game logic & models
│   ├── AppDelegate.swift            # App configuration
│   └── Info.plist                   # App configuration
├── RPGGameTests/
│   ├── RPGGameTests.swift
│   └── PerformanceTests.swift
├── Fastfile                         # Fastlane configuration
├── Gemfile                          # Ruby dependencies
├── build-settings.conf              # Xcode build settings
├── ExportOptions.plist              # Export configuration
└── README.md
```

## Prerequisites

### System Requirements

- macOS 12.0 or later
- Xcode 15.0 or later
- CocoaPods (optional, if using dependencies)
- Fastlane
- iOS SDK 15.0+

### Developer Tools Installation

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Fastlane
sudo gem install fastlane -NV

# Install CocoaPods (optional)
sudo gem install cocoapods

# Verify installations
xcodebuild -version
fastlane --version
```

## Local Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/rpg-game-ios.git
cd rpg-game-ios
```

### 2. Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Install Fastlane plugins
fastlane install_plugins

# Install CocoaPods (if Podfile exists)
pod install
```

### 3. Open in Xcode

```bash
# Using Xcode workspace (if CocoaPods)
open RPGGame.xcworkspace

# Or using project
open RPGGame.xcodeproj
```

### 4. Configure Code Signing

- Select your development team in Xcode
- Go to: RPGGame target → Signing & Capabilities
- Set your development team
- Bundle identifier: com.yourcompany.rpggame

### 5. Build & Run Locally

```bash
# Using Xcode (Cmd + R)
# Or using Fastlane
fastlane ios build_and_test
```

## Building for Sideload

### Method 1: Using Fastlane (Recommended)

```bash
# Build IPA for sideloading
fastlane ios build_for_sideload

# Output: build/ipa/RPGGame-sideload.ipa
```

### Method 2: Manual Build with Xcode

```bash
# Create Archive
xcodebuild \
  -scheme RPGGame \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/RPGGame.xcarchive \
  archive

# Export IPA
xcodebuild \
  -exportArchive \
  -archivePath build/RPGGame.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/ipa
```

### Method 3: Command Line Build

```bash
./build.sh --release --sideload
```

## Sideload Installation Methods

### Option 1: AltStore (Recommended for Users)

**Pros:** Works on non-jailbroken devices, user-friendly, no PC needed after setup
**Cons:** Requires Wi-Fi, certificate expires after 7 days

1. Download [AltStore](https://altstore.io/) on your Mac
1. Install and open AltStore
1. Connect iPhone via USB
1. Click “Install IPA” → select RPGGame-sideload.ipa
1. Sign in with your Apple ID (free account works)
1. On iPhone: Settings → General → VPN & Device Management → Trust developer
1. Launch app from home screen

### Option 2: Sideloadly (Easiest Method)

**Pros:** Simple drag-and-drop, automatically handles resigning
**Cons:** Requires paid subscription for pro features

1. Download [Sideloadly](https://sideloadly.io/)
1. Connect iPhone via USB
1. Drag & drop RPGGame-sideload.ipa onto Sideloadly
1. Sign in with Apple ID
1. Click “Start”
1. Trust developer on device

### Option 3: Apple Configurator 2 (Mac Only)

1. Download [Apple Configurator 2](https://apps.apple.com/app/apple-configurator-2/id1037126344)
1. Connect iPhone
1. Right-click device → Add → Apps
1. Select RPGGame-sideload.ipa
1. Choose app and click Add

### Option 4: Manual resign with restorerX

```bash
# For advanced users
# 1. Install restorerX
# 2. Resign IPA with your certificate
# 3. Install using iTunes or Apple Configurator
```

## GitHub Actions CI/CD Pipeline

### Setup GitHub Secrets

In repository Settings → Secrets and variables → Actions:

```
GITHUB_TOKEN          # Auto-generated
SLACK_WEBHOOK         # Optional: For notifications
APPLE_ID              # Optional: For App Store deployment
APPLE_PASSWORD        # Optional: App Store password
MATCH_PASSWORD        # Optional: For certificate management
```

### Workflow Triggers

```yaml
# Automatic on:
- Push to main/develop branches
- Pull requests
- Manual trigger (workflow_dispatch)
```

### What the Pipeline Does

1. **Build Job**
- Checks out code
- Installs dependencies
- Builds for iOS (Debug + Release)
- Generates IPA for sideloading
- Runs unit tests
- Uploads artifacts (30-day retention)
- Creates GitHub Release (on tags)
1. **Code Analysis Job**
- Runs SwiftLint
- Generates SBOM (Software Bill of Materials)
1. **Security Job**
- Runs Semgrep security scanner
- Uploads SARIF report
1. **Performance Tests Job**
- Runs performance benchmarks
- Generates metrics

### View Workflow Results

1. Go to Actions tab in GitHub
1. Select workflow run
1. Download artifacts:
- iOS-build-artifacts (IPA file)
- sbom (dependencies)
- test reports

### Create Release with IPA

```bash
# Tag a commit
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions automatically:
# 1. Builds the app
# 2. Creates a Release
# 3. Uploads IPA file
# 4. Adds sideload instructions
```

## Testing

### Run Tests Locally

```bash
# All tests
fastlane ios test

# Specific test
xcodebuild test -scheme RPGGame

# With coverage
xcodebuild test -scheme RPGGame -enableCodeCoverage YES
```

### Code Quality

```bash
# Run SwiftLint
fastlane ios lint

# Generate report
fastlane ios generate_report
```

## Troubleshooting

### Common Issues

**Issue: “Code signing required but no code signing identity found”**

```bash
# Solution: Allow unsigned builds
defaults write com.apple.dt.Xcode IDESourceTreeDisplayNames -dict-add SOURCE_ROOT "source_root"
```

**Issue: IPA won’t install**

- Check iOS version (minimum 15.0)
- Ensure bundle ID is correct
- Verify signing certificate
- Try re-downloading IPA

**Issue: App crashes immediately**

- Check Console in Xcode: Window → Devices and Simulators
- Review crash logs
- Verify all frameworks are linked

**Issue: GitHub Actions build fails**

- Check workflow logs: Actions tab → failed workflow
- Verify code compiles locally first
- Check Xcode version in workflow matches your environment

### Get Help

```bash
# View build logs
xcodebuild -showBuildSettings

# Check device logs
log stream --predicate 'process=="RPGGame"'

# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

## Distribution Methods

### Unofficial Distribution

- **TestFlight**: Requires App Store review
- **AltStore**: 7-day certificate cycle
- **Sideloadly**: Requires resigning
- **Jailbroken Devices**: Direct installation

### Official Distribution (Future)

To submit to App Store:

1. Enroll in Apple Developer Program ($99/year)
1. Create App ID
1. Configure certificates
1. Update build.yml for App Store distribution
1. Use `fastlane deliver` to upload

## Performance Optimization

### Build Time Optimization

```bash
# Enable parallel compilation
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks $(sysctl -n hw.ncpu)

# Use Clang modules
```

### App Size

Current: ~50-80MB

Optimization strategies:

- Strip unused symbols
- Compress assets
- Use ProGuard-like tools
- Remove debug symbols in Release

### Runtime Performance

- Monitor with Xcode Instruments
- Profile with Time Profiler
- Check memory leaks with Allocations tool

## Security Checklist

- [ ] Remove debug logging in Release build
- [ ] Enable code obfuscation
- [ ] Use HTTPS for network requests
- [ ] Sanitize user input
- [ ] Encrypt sensitive data
- [ ] Validate certificates
- [ ] Run security scanner (Semgrep)
- [ ] Update dependencies regularly

## Maintenance

### Regular Tasks

```bash
# Weekly
- Pull latest code
- Review GitHub security alerts

# Monthly
- Update Xcode
- Update dependencies: pod update
- Review analytics

# Quarterly
- Audit code with SwiftLint
- Update certificates
- Test on latest iOS device
```

### Update Instructions

```bash
# Update dependencies
bundle update
pod update

# Commit changes
git add Podfile.lock
git commit -m "Update dependencies"
```

## Contributing

1. Fork repository
1. Create feature branch
1. Make changes
1. Run tests: `fastlane ios test`
1. Run linter: `fastlane ios lint`
1. Push and create Pull Request

## License

[Your License Here]

## Support

- 📧 Email: [support@yourcompany.com](mailto:support@yourcompany.com)
- 🐛 Issues: GitHub Issues
- 💬 Discussions: GitHub Discussions

-----

**Last Updated:** 2024
**Xcode Version:** 15.0+
**iOS Target:** 15.0+
**Swift Version:** 5.9+