# BitChat Flutter - Deployment Guide

## Introduction

This guide provides comprehensive instructions for building, deploying, and maintaining the BitChat Flutter application across all supported platforms. It covers development builds, production releases, app store submissions, and ongoing maintenance procedures.

## Platform Support Matrix

### Supported Platforms
| Platform | Minimum Version | Target Version | Distribution Method | Status |
|----------|----------------|----------------|-------------------|--------|
| **iOS** | 14.0 | 17.0+ | App Store, TestFlight | ✅ Supported |
| **Android** | API 26 (8.0) | API 34 (14.0) | Google Play, APK | ✅ Supported |
| **macOS** | 11.0 | 14.0+ | App Store, DMG | ✅ Supported |
| **Windows** | 10 (1903) | 11 | Microsoft Store, MSI | ✅ Supported |
| **Linux** | Ubuntu 20.04 | Ubuntu 22.04+ | Snap, AppImage, DEB | ✅ Supported |
| **Web** | N/A | N/A | Not Supported | ❌ No BLE Support |

## Prerequisites

### Development Environment
```yaml
Required Software:
  - Flutter SDK: 3.16.0 or later
  - Dart SDK: 3.2.0 or later
  - Git: Latest version
  - Platform-specific tools (see below)

Platform-Specific Requirements:
  iOS/macOS:
    - Xcode: 15.0 or later
    - macOS: 13.0 or later
    - Apple Developer Account (for distribution)
  
  Android:
    - Android Studio: 2023.1.1 or later
    - Android SDK: API 34
    - Java JDK: 17 or later
    - Google Play Console Account (for distribution)
  
  Windows:
    - Visual Studio 2022 with C++ workload
    - Windows 10 SDK
    - Microsoft Partner Center Account (for store)
  
  Linux:
    - GCC/Clang compiler
    - CMake: 3.15 or later
    - Ninja build system
    - GTK development libraries
```

### Code Signing Certificates
```yaml
iOS/macOS:
  - Apple Developer Certificate
  - Distribution Certificate
  - Provisioning Profiles

Android:
  - Keystore file (.jks)
  - Key alias and passwords
  - Google Play App Signing (recommended)

Windows:
  - Code Signing Certificate
  - Windows SDK signing tools

Linux:
  - GPG key for package signing (optional)
```

## Build Configuration

### Environment Setup

#### 1. Flutter Configuration
```bash
# Verify Flutter installation
flutter doctor -v

# Enable required platforms
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# Set up dependencies
cd bitchat
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Platform-Specific Setup

##### iOS Setup
```bash
# Install CocoaPods
sudo gem install cocoapods

# Setup iOS dependencies
cd ios
pod install
cd ..

# Configure signing (replace with your team ID)
flutter build ios --release --no-codesign
```

##### Android Setup
```bash
# Create keystore (production builds)
keytool -genkey -v -keystore ~/bitchat-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias bitchat-key

# Configure gradle signing
# Edit android/key.properties
```

##### Desktop Setup
```bash
# Windows (run in Developer Command Prompt)
flutter config --enable-windows-desktop

# macOS
flutter config --enable-macos-desktop

# Linux
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
flutter config --enable-linux-desktop
```

### Build Scripts

#### Universal Build Script
```bash
#!/bin/bash
# build.sh - Universal build script for BitChat Flutter

set -e

# Configuration
VERSION=$(grep 'version:' pubspec.yaml | cut -d ' ' -f 2)
BUILD_NUMBER=$(date +%Y%m%d%H%M)
BUILD_TYPE=${1:-debug}
PLATFORM=${2:-all}

echo "Building BitChat Flutter v$VERSION ($BUILD_NUMBER)"
echo "Build Type: $BUILD_TYPE"
echo "Platform: $PLATFORM"

# Clean previous builds
flutter clean
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Build function
build_platform() {
    local platform=$1
    local build_type=$2
    
    echo "Building for $platform ($build_type)..."
    
    case $platform in
        "ios")
            if [ "$build_type" = "release" ]; then
                flutter build ios --release --no-codesign
                flutter build ipa --release
            else
                flutter build ios --debug --no-codesign
            fi
            ;;
        "android")
            if [ "$build_type" = "release" ]; then
                flutter build apk --release --split-per-abi
                flutter build appbundle --release
            else
                flutter build apk --debug
            fi
            ;;
        "macos")
            flutter build macos --$build_type
            ;;
        "windows")
            flutter build windows --$build_type
            ;;
        "linux")
            flutter build linux --$build_type
            ;;
    esac
}

# Build platforms
if [ "$PLATFORM" = "all" ]; then
    build_platform "android" $BUILD_TYPE
    build_platform "ios" $BUILD_TYPE
    build_platform "macos" $BUILD_TYPE
    build_platform "windows" $BUILD_TYPE
    build_platform "linux" $BUILD_TYPE
else
    build_platform $PLATFORM $BUILD_TYPE
fi

echo "Build completed successfully!"
```

#### Platform-Specific Build Scripts

##### iOS Build Script
```bash
#!/bin/bash
# build_ios.sh - iOS specific build script

set -e

BUILD_TYPE=${1:-release}
EXPORT_METHOD=${2:-app-store}

echo "Building iOS app ($BUILD_TYPE, $EXPORT_METHOD)..."

# Clean and prepare
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build
if [ "$BUILD_TYPE" = "release" ]; then
    flutter build ios --release
    
    # Create IPA
    xcodebuild -workspace ios/Runner.xcworkspace \
               -scheme Runner \
               -configuration Release \
               -destination generic/platform=iOS \
               -archivePath build/ios/Runner.xcarchive \
               archive
    
    # Export IPA
    xcodebuild -exportArchive \
               -archivePath build/ios/Runner.xcarchive \
               -exportPath build/ios/ipa \
               -exportOptionsPlist ios/ExportOptions.plist
else
    flutter build ios --debug --no-codesign
fi

echo "iOS build completed!"
```

##### Android Build Script
```bash
#!/bin/bash
# build_android.sh - Android specific build script

set -e

BUILD_TYPE=${1:-release}
OUTPUT_TYPE=${2:-apk}

echo "Building Android app ($BUILD_TYPE, $OUTPUT_TYPE)..."

# Clean and prepare
flutter clean
flutter pub get

# Build
if [ "$BUILD_TYPE" = "release" ]; then
    if [ "$OUTPUT_TYPE" = "appbundle" ]; then
        flutter build appbundle --release
    else
        flutter build apk --release --split-per-abi
    fi
else
    flutter build apk --debug
fi

echo "Android build completed!"
```

## Development Builds

### Debug Builds
```bash
# Quick debug build for testing
flutter run --debug

# Debug build with specific device
flutter run --debug -d <device-id>

# Debug build with hot reload
flutter run --debug --hot
```

### Profile Builds
```bash
# Profile build for performance testing
flutter run --profile

# Profile build with specific optimizations
flutter build apk --profile --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### Development Testing
```bash
# Run on iOS simulator
flutter run -d "iPhone 15 Pro"

# Run on Android emulator
flutter run -d "Pixel_7_API_34"

# Run on physical device
flutter devices
flutter run -d <device-id>
```

## Production Builds

### Release Configuration

#### Version Management
```yaml
# pubspec.yaml version configuration
version: 1.0.0+1

# Version format: MAJOR.MINOR.PATCH+BUILD_NUMBER
# Example: 1.2.3+20240115001
```

#### Build Variants
```yaml
# Flutter build variants
Development:
  - Debug symbols included
  - Logging enabled
  - Test endpoints

Staging:
  - Optimized build
  - Limited logging
  - Staging endpoints

Production:
  - Fully optimized
  - Minimal logging
  - Production endpoints
  - Obfuscation enabled
```

### iOS Production Build

#### 1. Prepare iOS Build
```bash
# Update version and build number
flutter pub run cider version 1.0.0
flutter pub run cider bump build

# Clean and prepare
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

#### 2. Configure Signing
```bash
# Automatic signing (recommended)
# Configure in Xcode: Runner -> Signing & Capabilities
# - Enable "Automatically manage signing"
# - Select your development team
# - Choose provisioning profile

# Manual signing
# Create provisioning profiles in Apple Developer Portal
# Download and install profiles
# Configure in Xcode signing settings
```

#### 3. Build and Archive
```bash
# Build iOS release
flutter build ios --release

# Create archive using Xcode
xcodebuild -workspace ios/Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -destination generic/platform=iOS \
           -archivePath build/ios/BitChat.xcarchive \
           archive

# Export for App Store
xcodebuild -exportArchive \
           -archivePath build/ios/BitChat.xcarchive \
           -exportPath build/ios/export \
           -exportOptionsPlist ios/ExportOptions.plist
```

#### 4. App Store Submission
```bash
# Upload using Xcode
# Open Xcode -> Window -> Organizer
# Select archive and click "Distribute App"

# Upload using command line
xcrun altool --upload-app \
             --type ios \
             --file build/ios/export/BitChat.ipa \
             --username "your-apple-id@example.com" \
             --password "app-specific-password"

# Upload using Transporter app
# Download from Mac App Store
# Drag and drop IPA file
```

### Android Production Build

#### 1. Prepare Android Build
```bash
# Update version
flutter pub run cider version 1.0.0
flutter pub run cider bump build

# Clean and prepare
flutter clean
flutter pub get
```

#### 2. Configure Signing
```properties
# android/key.properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=bitchat-key
storeFile=../bitchat-release-key.jks
```

```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 3. Build Release
```bash
# Build APK (for direct distribution)
flutter build apk --release --split-per-abi

# Build App Bundle (for Google Play)
flutter build appbundle --release

# Verify signing
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

#### 4. Google Play Submission
```bash
# Upload using Google Play Console web interface
# 1. Go to Google Play Console
# 2. Select your app
# 3. Go to Release -> Production
# 4. Create new release
# 5. Upload AAB file
# 6. Fill release notes
# 7. Review and rollout

# Upload using command line (requires setup)
# Install bundletool
# Generate APKs from bundle
bundletool build-apks --bundle=app-release.aab --output=app-release.apks

# Upload using fastlane (optional)
fastlane supply --aab build/app/outputs/bundle/release/app-release.aab
```

### Desktop Production Builds

#### macOS Build
```bash
# Build macOS app
flutter build macos --release

# Create DMG installer
create-dmg \
  --volname "BitChat Installer" \
  --volicon "assets/icons/app_icon.icns" \
  --window-pos 200 120 \
  --window-size 600 300 \
  --icon-size 100 \
  --icon "BitChat.app" 175 120 \
  --hide-extension "BitChat.app" \
  --app-drop-link 425 120 \
  "BitChat-1.0.0.dmg" \
  "build/macos/Build/Products/Release/"

# Notarize for distribution (requires Apple Developer account)
xcrun notarytool submit BitChat-1.0.0.dmg \
  --apple-id "your-apple-id@example.com" \
  --password "app-specific-password" \
  --team-id "YOUR_TEAM_ID" \
  --wait

# Staple notarization
xcrun stapler staple BitChat-1.0.0.dmg
```

#### Windows Build
```bash
# Build Windows app
flutter build windows --release

# Create MSI installer using WiX Toolset
# 1. Install WiX Toolset
# 2. Create installer configuration
# 3. Build MSI package

# Example WiX configuration (BitChat.wxs)
candle BitChat.wxs
light BitChat.wixobj -o BitChat-1.0.0.msi

# Sign the installer
signtool sign /f "certificate.pfx" /p "password" /t "http://timestamp.digicert.com" BitChat-1.0.0.msi
```

#### Linux Build
```bash
# Build Linux app
flutter build linux --release

# Create AppImage
# 1. Install appimagetool
# 2. Create AppDir structure
# 3. Generate AppImage

# Create Snap package
snapcraft

# Create DEB package
# 1. Create debian directory structure
# 2. Configure control files
# 3. Build package
dpkg-buildpackage -us -uc
```

## CI/CD Pipeline

### GitHub Actions Workflow

#### Main Workflow
```yaml
# .github/workflows/build-and-deploy.yml
name: Build and Deploy BitChat Flutter

on:
  push:
    branches: [ main, develop ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]

env:
  FLUTTER_VERSION: '3.16.0'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/bitchat-release-key.jks
      
      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.ANDROID_STORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=bitchat-release-key.jks" >> android/key.properties
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release --split-per-abi
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: android-builds
          path: |
            build/app/outputs/flutter-apk/*.apk
            build/app/outputs/bundle/release/*.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Setup iOS dependencies
        run: cd ios && pod install
      
      - name: Import certificates
        uses: apple-actions/import-codesign-certs@v1
        with:
          p12-file-base64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          p12-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
      
      - name: Download provisioning profiles
        uses: apple-actions/download-provisioning-profiles@v1
        with:
          bundle-id: com.bitchat.flutter
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Build IPA
        run: flutter build ipa --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ios-builds
          path: build/ios/ipa/*.ipa

  build-desktop:
    needs: test
    strategy:
      matrix:
        os: [macos-latest, windows-latest, ubuntu-latest]
    runs-on: ${{ matrix.os }}
    if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Install Linux dependencies
        if: runner.os == 'Linux'
        run: |
          sudo apt-get update
          sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build macOS
        if: runner.os == 'macOS'
        run: flutter build macos --release
      
      - name: Build Windows
        if: runner.os == 'Windows'
        run: flutter build windows --release
      
      - name: Build Linux
        if: runner.os == 'Linux'
        run: flutter build linux --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: desktop-builds-${{ runner.os }}
          path: |
            build/macos/Build/Products/Release/
            build/windows/runner/Release/
            build/linux/x64/release/bundle/

  deploy:
    needs: [build-android, build-ios, build-desktop]
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')
    
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v3
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            android-builds/*.apk
            android-builds/*.aab
            ios-builds/*.ipa
            desktop-builds-*/**/*
          draft: true
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Automated Testing in CI/CD
```yaml
# .github/workflows/test.yml
name: Automated Testing

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test --coverage --reporter=github
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  integration-tests:
    runs-on: macos-latest
    strategy:
      matrix:
        device: ['iPhone 15 Pro', 'Pixel 7 API 34']
    
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      
      - name: Setup Android emulator
        if: contains(matrix.device, 'Pixel')
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          target: google_apis
          arch: x86_64
          script: flutter test integration_test/
      
      - name: Setup iOS simulator
        if: contains(matrix.device, 'iPhone')
        run: |
          xcrun simctl create test-device com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro
          xcrun simctl boot test-device
          flutter test integration_test/ -d test-device

  security-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run security tests
        run: flutter test test/security/
      
      - name: Static security analysis
        run: |
          dart pub global activate security_analysis
          security_analysis analyze
```

## App Store Deployment

### iOS App Store

#### 1. App Store Connect Setup
```yaml
App Information:
  - App Name: BitChat
  - Bundle ID: com.bitchat.flutter
  - SKU: bitchat-flutter-001
  - Primary Language: English (U.S.)

App Store Information:
  - Category: Social Networking
  - Content Rights: Does Not Use Third-Party Content
  - Age Rating: 4+ (appropriate for all ages)

Pricing and Availability:
  - Price: Free
  - Availability: All territories
  - App Store Distribution: Available
```

#### 2. App Review Information
```yaml
Contact Information:
  - First Name: [Your Name]
  - Last Name: [Your Last Name]
  - Phone Number: [Your Phone]
  - Email: [Your Email]

Demo Account:
  - Username: demo@bitchat.example.com
  - Password: DemoPassword123!

Notes:
  - BitChat is a decentralized messaging app using Bluetooth LE
  - No server infrastructure required
  - Works offline and in areas with no internet
  - Fully encrypted peer-to-peer communication
```

#### 3. Submission Process
```bash
# 1. Upload build via Xcode or Transporter
# 2. Complete app information in App Store Connect
# 3. Add screenshots and metadata
# 4. Submit for review
# 5. Monitor review status
# 6. Release when approved
```

### Google Play Store

#### 1. Play Console Setup
```yaml
App Details:
  - App Name: BitChat
  - Short Description: Secure decentralized messaging via Bluetooth
  - Full Description: [Detailed app description]
  - Category: Communication
  - Content Rating: Everyone

Store Listing:
  - Screenshots: Required for all form factors
  - Feature Graphic: 1024 x 500 pixels
  - App Icon: 512 x 512 pixels
  - Privacy Policy: Required URL

Pricing & Distribution:
  - Free app
  - Available in all countries
  - Content guidelines compliance
```

#### 2. Release Management
```yaml
Release Types:
  - Internal Testing: Team members only
  - Closed Testing: Limited user group
  - Open Testing: Public beta
  - Production: Full release

Release Tracks:
  - Alpha: Internal builds
  - Beta: Pre-release testing
  - Production: Live release
```

#### 3. Submission Process
```bash
# 1. Upload AAB file to Play Console
# 2. Complete store listing information
# 3. Set up release notes
# 4. Configure rollout percentage
# 5. Submit for review
# 6. Monitor release status
```

### Desktop App Stores

#### Microsoft Store (Windows)
```yaml
App Identity:
  - Package Name: BitChat
  - Publisher: [Your Publisher Name]
  - Version: 1.0.0.0

Store Listing:
  - Description: Secure decentralized messaging
  - Screenshots: Windows 10/11 screenshots
  - System Requirements: Windows 10 version 1903+

Pricing:
  - Free app
  - Available worldwide
```

#### Mac App Store
```yaml
App Information:
  - Bundle ID: com.bitchat.flutter.macos
  - Category: Social Networking
  - Minimum System Version: macOS 11.0

Entitlements:
  - Bluetooth access
  - Network access
  - Keychain access
  - Hardened Runtime
```

## Monitoring and Maintenance

### Application Monitoring

#### Crash Reporting
```dart
// Crash reporting setup
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize crash reporting
  await Firebase.initializeApp();
  
  // Set up crash reporting
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(BitChatApp());
}
```

#### Performance Monitoring
```dart
// Performance monitoring
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceMonitor {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  
  static Future<void> trackMessageSend() async {
    final trace = _performance.newTrace('message_send');
    await trace.start();
    
    try {
      // Message sending logic
      await sendMessage();
    } finally {
      await trace.stop();
    }
  }
  
  static void trackNetworkRequest(String url) {
    final metric = _performance.newHttpMetric(url, HttpMethod.Post);
    // Track network performance
  }
}
```

#### Analytics
```dart
// Analytics setup
import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logMessageSent() async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'platform': Platform.operatingSystem,
        'app_version': await getAppVersion(),
      },
    );
  }
  
  static Future<void> logChannelJoined(String channelId) async {
    await _analytics.logEvent(
      name: 'channel_joined',
      parameters: {
        'channel_id': channelId,
      },
    );
  }
}
```

### Update Management

#### Over-the-Air Updates
```dart
// Update checker
class UpdateChecker {
  static const String UPDATE_CHECK_URL = 'https://api.bitchat.example.com/version';
  
  static Future<UpdateInfo?> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(UPDATE_CHECK_URL));
      final data = jsonDecode(response.body);
      
      final latestVersion = data['latest_version'];
      final currentVersion = await getAppVersion();
      
      if (isNewerVersion(latestVersion, currentVersion)) {
        return UpdateInfo(
          version: latestVersion,
          downloadUrl: data['download_url'],
          releaseNotes: data['release_notes'],
          isRequired: data['is_required'] ?? false,
        );
      }
    } catch (e) {
      print('Update check failed: $e');
    }
    
    return null;
  }
  
  static bool isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();
    
    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    
    return false;
  }
}
```

#### Automatic Updates
```yaml
# Update strategies by platform
iOS:
  - App Store automatic updates
  - TestFlight beta updates
  - Enterprise distribution updates

Android:
  - Google Play automatic updates
  - In-app update API
  - APK sideloading updates

Desktop:
  - Platform store updates
  - Self-updating mechanisms
  - Manual download updates
```

### Maintenance Procedures

#### Regular Maintenance Tasks
```yaml
Daily:
  - Monitor crash reports
  - Check performance metrics
  - Review user feedback
  - Monitor app store ratings

Weekly:
  - Analyze usage analytics
  - Review security alerts
  - Update dependencies
  - Test critical user flows

Monthly:
  - Security audit
  - Performance optimization
  - User experience review
  - Competitive analysis

Quarterly:
  - Major version planning
  - Platform updates
  - Feature roadmap review
  - Technical debt assessment
```

#### Emergency Response
```yaml
Critical Issues:
  - Security vulnerabilities
  - Data loss bugs
  - Crash loops
  - Performance degradation

Response Process:
  1. Assess severity and impact
  2. Implement hotfix
  3. Test fix thoroughly
  4. Deploy emergency update
  5. Monitor deployment
  6. Post-mortem analysis

Communication:
  - Internal team notification
  - User communication (if needed)
  - App store update notes
  - Documentation updates
```

### Rollback Procedures

#### App Store Rollback
```yaml
iOS App Store:
  - Cannot rollback published versions
  - Submit new version with fixes
  - Use TestFlight for quick testing
  - Communicate with users via app description

Google Play:
  - Use staged rollout to limit impact
  - Halt rollout if issues detected
  - Release previous version as new update
  - Use Play Console to manage releases

Desktop Stores:
  - Similar to mobile app stores
  - May have different rollback policies
  - Maintain previous version packages
```

#### Self-Hosted Rollback
```bash
#!/bin/bash
# rollback.sh - Emergency rollback script

PREVIOUS_VERSION=${1:-"1.0.0"}
PLATFORM=${2:-"all"}

echo "Rolling back to version $PREVIOUS_VERSION"

# Update download links
update_download_links() {
    local version=$1
    # Update CDN or server to serve previous version
    echo "Updating download links to version $version"
}

# Notify users
notify_users() {
    local version=$1
    # Send push notification or email about rollback
    echo "Notifying users about rollback to version $version"
}

# Execute rollback
update_download_links $PREVIOUS_VERSION
notify_users $PREVIOUS_VERSION

echo "Rollback completed successfully"
```

## Security Considerations

### Code Signing
```yaml
iOS:
  - Use Apple Developer certificates
  - Enable automatic signing in Xcode
  - Verify provisioning profiles
  - Test on multiple devices

Android:
  - Use strong keystore passwords
  - Store keystore securely
  - Enable Google Play App Signing
  - Verify APK signatures

Desktop:
  - Use code signing certificates
  - Sign all executables and installers
  - Verify signatures before distribution
  - Use timestamping for long-term validity
```

### Distribution Security
```yaml
Secure Distribution:
  - Use HTTPS for all downloads
  - Verify checksums and signatures
  - Implement certificate pinning
  - Monitor for unauthorized copies

App Store Security:
  - Follow platform security guidelines
  - Implement app transport security
  - Use secure coding practices
  - Regular security audits
```

### Privacy Compliance
```yaml
Data Protection:
  - GDPR compliance for EU users
  - CCPA compliance for California users
  - Privacy policy updates
  - User consent management

Data Handling:
  - Minimal data collection
  - Local data processing
  - Secure data transmission
  - User data deletion
```

## Troubleshooting

### Common Build Issues

#### Flutter Issues
```bash
# Clean build cache
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Fix dependency conflicts
flutter pub deps
flutter pub upgrade

# Reset Flutter installation
flutter channel stable
flutter upgrade
flutter doctor -v
```

#### iOS Build Issues
```bash
# Clean iOS build
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# Fix signing issues
# Open ios/Runner.xcworkspace in Xcode
# Check signing settings
# Verify provisioning profiles

# Fix simulator issues
xcrun simctl erase all
xcrun simctl boot "iPhone 15 Pro"
```

#### Android Build Issues
```bash
# Clean Android build
cd android
./gradlew clean
cd ..

# Fix Gradle issues
cd android
./gradlew --refresh-dependencies
cd ..

# Fix SDK issues
flutter doctor --android-licenses
```

### Deployment Issues

#### App Store Rejection
```yaml
Common Rejection Reasons:
  - Missing privacy policy
  - Incomplete app information
  - Crashes during review
  - Guideline violations
  - Missing functionality

Resolution Steps:
  1. Read rejection message carefully
  2. Fix identified issues
  3. Test thoroughly
  4. Resubmit with resolution notes
  5. Respond to reviewer feedback
```

#### Performance Issues
```yaml
Performance Problems:
  - Slow app startup
  - High memory usage
  - Battery drain
  - Network timeouts

Debugging Steps:
  1. Use Flutter DevTools
  2. Profile memory usage
  3. Analyze network requests
  4. Test on various devices
  5. Optimize critical paths
```

## Conclusion

This deployment guide provides comprehensive instructions for building, deploying, and maintaining BitChat Flutter across all supported platforms. Following these procedures ensures consistent, secure, and reliable deployments while maintaining high quality standards.

### Key Success Factors

1. **Automated CI/CD**: Reduces manual errors and ensures consistent builds
2. **Platform-Specific Optimization**: Leverages each platform's strengths
3. **Security First**: Implements proper code signing and security measures
4. **Monitoring and Analytics**: Provides visibility into app performance and usage
5. **Maintenance Procedures**: Ensures long-term app health and user satisfaction

### Best Practices

- Always test builds on real devices before release
- Maintain separate environments for development, staging, and production
- Use semantic versioning for clear version management
- Implement proper error handling and crash reporting
- Keep dependencies up to date and secure
- Monitor app performance and user feedback continuously
- Have rollback procedures ready for emergency situations

The deployment process should be treated as a critical part of the development lifecycle, with proper planning, testing, and monitoring to ensure successful releases and positive user experiences.