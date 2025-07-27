# BitChat Flutter - Developer Setup Guide

**Version:** 1.0  
**Last Updated:** July 26, 2025

## Overview

This guide provides comprehensive setup instructions for developing BitChat Flutter, a decentralized peer-to-peer messaging application that operates over Bluetooth Low Energy (BLE) mesh networks. Follow these steps to set up your development environment and get the project running locally.

## Prerequisites

### System Requirements

#### Minimum Requirements
- **RAM**: 8GB (16GB recommended for iOS development)
- **Storage**: 10GB free space (20GB recommended)
- **OS Versions**:
  - **Windows**: Windows 10 version 1903 or later
  - **macOS**: macOS 10.15 (Catalina) or later
  - **Linux**: Ubuntu 18.04 LTS or equivalent

#### Hardware Requirements for Testing
- **Bluetooth**: Bluetooth 4.0+ (BLE support required)
- **Mobile Devices**: 
  - iOS 14.0+ device for iOS testing
  - Android 8.0+ (API 26+) device for Android testing

### Development Tools

#### Required Software
- **Git**: Version control system
- **Code Editor**: VS Code (recommended) or Android Studio
- **Terminal**: Command line interface

#### Platform-Specific Requirements

**Windows:**
- Windows PowerShell 5.0+ or Command Prompt
- Visual Studio 2019 or later (for Windows desktop development)

**macOS:**
- Xcode 12.0+ (for iOS development)
- Command Line Tools for Xcode

**Linux:**
- GCC compiler
- GTK development libraries (for desktop development)

## Flutter SDK Setup

### Step 1: Install Flutter SDK

#### Windows Installation
```powershell
# Download Flutter SDK
# Visit https://docs.flutter.dev/get-started/install/windows
# Download the latest stable release

# Extract to C:\flutter (recommended)
# Add C:\flutter\bin to your PATH environment variable

# Verify installation
flutter doctor -v
```

#### macOS Installation
```bash
# Using Homebrew (recommended)
brew install flutter

# Or download manually from https://docs.flutter.dev/get-started/install/macos
# Extract to ~/flutter
# Add ~/flutter/bin to your PATH

# Verify installation
flutter doctor -v
```

#### Linux Installation
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz

# Extract to ~/flutter
tar xf flutter_linux_3.16.0-stable.tar.xz -C ~/

# Add to PATH in ~/.bashrc or ~/.zshrc
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter doctor -v
```

### Step 2: Configure Flutter

#### Accept Android Licenses
```bash
flutter doctor --android-licenses
```

#### Enable Platform Support
```bash
# Enable desktop support (optional)
flutter config --enable-windows-desktop  # Windows
flutter config --enable-macos-desktop    # macOS
flutter config --enable-linux-desktop    # Linux

# Enable web support (optional)
flutter config --enable-web
```#
# Platform-Specific Setup

### iOS Development Setup (macOS only)

#### Install Xcode
1. Install Xcode from the Mac App Store (Xcode 12.0+)
2. Install Xcode Command Line Tools:
   ```bash
   sudo xcode-select --install
   ```
3. Accept Xcode license:
   ```bash
   sudo xcodebuild -license accept
   ```

#### Configure iOS Simulator
```bash
# Open iOS Simulator
open -a Simulator

# Install additional simulators if needed
# Xcode > Preferences > Components
```

#### iOS Device Setup
1. Connect your iOS device via USB
2. Trust the computer on your device
3. Enable Developer Mode in Settings > Privacy & Security > Developer Mode
4. Configure code signing in Xcode with your Apple Developer account

### Android Development Setup

#### Install Android Studio
1. Download Android Studio from https://developer.android.com/studio
2. Run the installer and follow the setup wizard
3. Install the Android SDK and required components

#### Configure Android SDK
```bash
# Set ANDROID_HOME environment variable
# Windows (PowerShell)
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"

# macOS/Linux
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

#### Create Android Virtual Device (AVD)
1. Open Android Studio
2. Go to Tools > AVD Manager
3. Create a new virtual device:
   - **Device**: Pixel 4 or newer (recommended)
   - **API Level**: 26+ (Android 8.0+)
   - **Target**: Google APIs (for Google Play services)

#### Android Device Setup
1. Enable Developer Options:
   - Go to Settings > About phone
   - Tap Build number 7 times
2. Enable USB Debugging in Developer Options
3. Connect device via USB and authorize the computer##
# Desktop Development Setup

#### Windows Desktop
```powershell
# Install Visual Studio 2019 or later with C++ tools
# Or install Visual Studio Build Tools
# https://visualstudio.microsoft.com/downloads/

# Verify C++ compiler
where cl
```

#### macOS Desktop
```bash
# Xcode Command Line Tools (already installed for iOS)
xcode-select --install
```

#### Linux Desktop
```bash
# Install required development packages
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

# For other distributions, install equivalent packages
```

## BitChat Project Setup

### Step 1: Clone Repository
```bash
# Clone the repository
git clone https://github.com/your-org/bitchat-flutter.git
cd bitchat-flutter
```

### Step 2: Project Structure Verification
```bash
# Verify project structure
ls -la
# Should see: bitchat/, docs/, context/, assets/, etc.

# Navigate to Flutter app
cd bitchat
ls -la
# Should see: lib/, pubspec.yaml, android/, ios/, etc.
```

### Step 3: Install Dependencies
```bash
# Install Flutter dependencies
flutter pub get

# Generate code (if using build_runner)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Configure Project Settings

#### Update pubspec.yaml (if needed)
```yaml
name: bitchat
description: Decentralized peer-to-peer messaging over Bluetooth mesh

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_blue_plus: ^1.14.0
  crypto: ^3.0.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  provider: ^6.0.5
  permission_handler: ^11.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
```#
### Configure Platform Permissions

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- For Android 12+ -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation" />
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>BitChat uses Bluetooth to create mesh networks for decentralized messaging</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>BitChat uses Bluetooth to communicate with nearby devices</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>BitChat needs location permission for Bluetooth scanning on iOS</string>
```

## Development Environment Configuration

### VS Code Setup (Recommended)

#### Install Extensions
```bash
# Install Flutter extension (includes Dart)
# Open VS Code and install:
# - Flutter (by Dart Code)
# - Dart (by Dart Code)
# - GitLens (optional, for Git integration)
# - Bracket Pair Colorizer (optional)
```

#### Configure VS Code Settings
Create `.vscode/settings.json`:
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "dart.insertArgumentPlaceholders": false,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.rulers": [80],
  "editor.formatOnSave": true,
  "files.associations": {
    "*.dart": "dart"
  }
}
```

#### Configure Launch Configuration
Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Debug)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--debug"]
    },
    {
      "name": "Flutter (Profile)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--profile"]
    },
    {
      "name": "Flutter (Release)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--release"]
    }
  ]
}
```### Androi
d Studio Setup (Alternative)

#### Install Flutter Plugin
1. Open Android Studio
2. Go to File > Settings > Plugins
3. Search for "Flutter" and install
4. Restart Android Studio

#### Configure Flutter SDK Path
1. Go to File > Settings > Languages & Frameworks > Flutter
2. Set Flutter SDK path to your Flutter installation directory

## Verification Steps

### Step 1: Flutter Doctor Check
```bash
flutter doctor -v
```

Expected output should show:
- ✅ Flutter (Channel stable, version 3.16.0+)
- ✅ Android toolchain
- ✅ Xcode (macOS only)
- ✅ VS Code or Android Studio
- ✅ Connected device

### Step 2: Build Test
```bash
# Navigate to Flutter app directory
cd bitchat

# Test debug build for each platform
flutter build apk --debug              # Android
flutter build ios --debug --no-codesign # iOS (macOS only)
flutter build windows --debug          # Windows
flutter build macos --debug            # macOS
flutter build linux --debug            # Linux
```

### Step 3: Run Application
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run with hot reload (development)
flutter run --hot

# Run in debug mode
flutter run --debug
```

### Step 4: Test Core Functionality
```bash
# Run unit tests
flutter test

# Run integration tests (if available)
flutter test integration_test

# Run static analysis
flutter analyze

# Check code formatting
dart format --set-exit-if-changed .
```

## Development Commands Reference

### Essential Commands
```bash
# Development
flutter run --hot          # Hot reload development
flutter run --debug        # Debug mode
flutter run --profile      # Profile mode
flutter run --release      # Release mode

# Building
flutter build apk --debug     # Android debug build
flutter build apk --release   # Android release build
flutter build ios --debug --no-codesign  # iOS debug build
flutter build windows --debug # Windows debug build

# Testing
flutter test              # Run unit tests
flutter test --coverage  # Run tests with coverage
flutter analyze          # Static code analysis
dart format .             # Code formatting

# Dependencies
flutter pub get           # Install dependencies
flutter pub upgrade       # Upgrade dependencies
flutter pub deps          # Show dependency tree

# Maintenance
flutter clean             # Clean build artifacts
flutter doctor -v         # Environment verification
flutter --version         # Show Flutter version
```### D
ebugging Commands
```bash
# Debug information
flutter logs              # Show device logs
flutter screenshot        # Take screenshot
flutter symbolize         # Symbolize stack traces

# Performance
flutter run --profile     # Profile mode for performance testing
flutter run --trace-startup  # Trace app startup performance
```

## Troubleshooting

### Common Issues

#### Flutter Doctor Issues

**Issue**: Android licenses not accepted
```bash
# Solution
flutter doctor --android-licenses
# Accept all licenses by typing 'y'
```

**Issue**: Xcode not found (macOS)
```bash
# Solution
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

**Issue**: VS Code not detected
```bash
# Solution
# Install Flutter extension in VS Code
# Restart VS Code and run flutter doctor again
```

#### Build Issues

**Issue**: Gradle build fails (Android)
```bash
# Solution 1: Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug

# Solution 2: Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version 7.6.1
```

**Issue**: CocoaPods issues (iOS)
```bash
# Solution
cd ios
rm Podfile.lock
rm -rf Pods
pod install --repo-update
cd ..
flutter clean
flutter build ios --debug --no-codesign
```

**Issue**: Permission denied errors
```bash
# Solution (macOS/Linux)
sudo chown -R $(whoami) ~/.pub-cache
sudo chown -R $(whoami) ~/.flutter
```

#### Runtime Issues

**Issue**: Bluetooth permissions not working
- **Android**: Ensure all Bluetooth permissions are declared in AndroidManifest.xml
- **iOS**: Ensure usage descriptions are added to Info.plist
- **Both**: Request permissions at runtime using permission_handler

**Issue**: Hot reload not working
```bash
# Solution
flutter clean
flutter pub get
flutter run --hot
```

**Issue**: Device not detected
```bash
# Solution
flutter devices
# If no devices shown:
# - Check USB debugging is enabled (Android)
# - Check device is trusted (iOS)
# - Try different USB cable/port
```### Platform
-Specific Issues

#### Windows
- **Issue**: Visual Studio not found
  - Install Visual Studio 2019+ with C++ tools
  - Or install Visual Studio Build Tools

#### macOS
- **Issue**: Command Line Tools missing
  ```bash
  xcode-select --install
  ```

#### Linux
- **Issue**: Missing development libraries
  ```bash
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
  ```

### Performance Issues

**Issue**: Slow build times
```bash
# Solutions
flutter clean                    # Clean build cache
flutter pub deps                 # Check for unnecessary dependencies
flutter build --verbose         # Identify bottlenecks
```

**Issue**: Large app size
```bash
# Solutions
flutter build apk --split-per-abi  # Split APKs by architecture
flutter build appbundle           # Use Android App Bundle
flutter build ios --split-debug-info  # Split debug info (iOS)
```

## Getting Help

### Documentation Resources
- **Flutter Documentation**: https://docs.flutter.dev/
- **Dart Documentation**: https://dart.dev/guides
- **BitChat Technical Docs**: `docs/` folder in this repository
- **API Documentation Standards**: `API_DOCUMENTATION_STANDARDS.md`

### Community Support
- **Flutter Community**: https://flutter.dev/community
- **Stack Overflow**: Tag questions with `flutter` and `dart`
- **GitHub Issues**: Report bugs and feature requests

### Project-Specific Support
- **Issues**: Create GitHub issues for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Contributing**: See `CONTRIBUTING.md` for contribution guidelines

## Next Steps

After completing the setup:

1. **Read the Documentation**: Familiarize yourself with the project structure and technical specifications in the `docs/` folder
2. **Review Code Style**: Read `CODE_STYLE_GUIDE.md` for coding standards
3. **Understand the Workflow**: Review `DEVELOPMENT_WORKFLOW.md` for development processes
4. **Start Contributing**: Follow `CONTRIBUTING.md` for contribution guidelines
5. **Join Development**: Check the project roadmap in `context/implementation_roadmap.md`

## Security Considerations

### Development Security
- **Never commit**: Private keys, certificates, or sensitive configuration
- **Use secure networks**: Avoid public WiFi for development
- **Keep tools updated**: Regularly update Flutter SDK and dependencies
- **Review dependencies**: Audit third-party packages for security issues

### Testing Security
- **Use test keys**: Never use production keys in development
- **Isolate test networks**: Use separate Bluetooth networks for testing
- **Clean test data**: Remove test data from devices after testing

---

**Welcome to BitChat Flutter development!** 🚀

If you encounter any issues not covered in this guide, please create an issue or refer to the troubleshooting section above.