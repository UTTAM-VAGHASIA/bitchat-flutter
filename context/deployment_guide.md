# BitChat Flutter - Deployment Guide

**Version:** 0.1.0  
**Last Updated:** July 11, 2025

## Overview

This deployment guide outlines the processes for building, testing, and distributing BitChat Flutter across multiple platforms. The guide covers deployment to iOS, Android, and desktop platforms, with specific instructions for each target environment.

## Prerequisites

### Development Environment

Before deploying BitChat Flutter, ensure your development environment includes:

- **Flutter SDK** (latest stable version)
- **Dart SDK** (latest stable version)
- **Git** for version control
- **Android Studio** (for Android deployment)
- **Xcode** 14.0+ (for iOS/macOS deployment)
- **Visual Studio** (for Windows deployment)
- **Linux Development Tools** (for Linux deployment)

### Required Accounts and Certificates

| Platform | Requirement | Purpose |
|----------|------------|---------|
| iOS/macOS | Apple Developer Account | App signing and distribution |
| iOS/macOS | Apple Distribution Certificate | Code signing |
| iOS/macOS | Provisioning Profile | Device deployment |
| Android | Google Play Developer Account | Play Store distribution |
| Android | Keystore File | App signing |
| Windows | Microsoft Developer Account | Optional for Microsoft Store |
| Linux | GPG Key | Package signing |

## General Build Process

### 1. Environment Setup

```bash
# Update Flutter SDK
flutter upgrade

# Verify Flutter installation
flutter doctor -v

# Get project dependencies
flutter pub get

# Generate required files
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Code Quality Checks

```bash
# Run static analysis
flutter analyze

# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

### 3. Build Configuration

#### Version Management

Edit `pubspec.yaml` to set the correct version:

```yaml
version: 0.1.0+1  # Format: version_name+version_code
```

#### Environment-Specific Configuration

Create environment configuration files in the `config` directory:
- `config/dev.json` - Development environment
- `config/staging.json` - Staging/testing environment
- `config/prod.json` - Production environment

## Platform-Specific Deployment

### iOS Deployment

#### 1. iOS Configuration

Update iOS-specific settings in `ios/Runner/Info.plist`:

```xml
<!-- Required permissions -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>BitChat uses Bluetooth to communicate with nearby peers</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>BitChat uses Bluetooth to communicate with nearby peers</string>
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>bluetooth-peripheral</string>
</array>
```

#### 2. iOS Build Process

```bash
# Set up code signing
cd ios
pod install
open Runner.xcworkspace
# Configure signing in Xcode

# Build for iOS
flutter build ios --release

# Create IPA file
cd build/ios/iphoneos
mkdir Payload
cp -R Runner.app Payload
zip -r BitChat.ipa Payload
```

#### 3. iOS Distribution

**App Store Distribution:**
1. In Xcode, select Product > Archive
2. In the Archives window, click "Validate App"
3. After validation, click "Distribute App"
4. Select "App Store Connect" and follow the prompts

**Ad Hoc Distribution:**
1. Create an Ad Hoc provisioning profile in Apple Developer Portal
2. In Xcode, select Product > Archive
3. Select "Ad Hoc" distribution method
4. Follow prompts to export IPA file

### Android Deployment

#### 1. Android Configuration

Update `android/app/src/main/AndroidManifest.xml` with required permissions:

```xml
<!-- Required permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

#### 2. Android Keystore Setup

Create a keystore file if you don't already have one:

```bash
keytool -genkey -v -keystore bitchat.keystore -alias bitchat -keyalg RSA -keysize 2048 -validity 10000
```

Create `android/key.properties` file:

```
storePassword=<password>
keyPassword=<password>
keyAlias=bitchat
storeFile=../bitchat.keystore
```

Update `android/app/build.gradle` for signing:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    
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
            // ...
        }
    }
}
```

#### 3. Android Build Process

```bash
# Build APK
flutter build apk --release

# Build App Bundle (preferred for Play Store)
flutter build appbundle --release
```

#### 4. Android Distribution

**Google Play Store:**
1. Go to the Google Play Console
2. Create a new app or select existing app
3. Navigate to "Production" > "Create new release"
4. Upload the App Bundle (.aab file)
5. Fill in release details and submit for review

**Direct APK Distribution:**
1. Distribute the APK file directly
2. Users must enable "Unknown Sources" in settings
3. Consider using an app distribution service like Firebase App Distribution

### macOS Deployment

#### 1. macOS Configuration

Update `macos/Runner/Info.plist` with required settings:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>BitChat uses Bluetooth to communicate with nearby peers</string>
```

Update `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.device.bluetooth</key>
<true/>
```

#### 2. macOS Build Process

```bash
# Build macOS app
flutter build macos --release
```

#### 3. macOS Notarization

1. Create an app-specific password in your Apple ID account
2. Use `xcrun altool` to upload for notarization:

```bash
cd build/macos/Build/Products/Release
xcrun altool --notarize-app \
  --primary-bundle-id "com.example.bitchat" \
  --username "your@apple.id" \
  --password "@keychain:AC_PASSWORD" \
  --file "BitChat.app"
```

3. Check notarization status:

```bash
xcrun altool --notarization-info <RequestUUID> \
  --username "your@apple.id" \
  --password "@keychain:AC_PASSWORD"
```

4. After approval, staple the ticket:

```bash
xcrun stapler staple "BitChat.app"
```

#### 4. macOS Distribution

**Mac App Store:**
1. In Xcode, archive the app
2. Use the Distribution option for Mac App Store
3. Upload to App Store Connect

**Direct Distribution:**
1. Create a DMG file from the built app
2. Consider notarizing the app for Gatekeeper
3. Distribute via website or distribution service

### Windows Deployment

#### 1. Windows Configuration

Ensure `windows/runner/Runner.rc` has proper app information:

```
// ...
VALUE "CompanyName", "BitChat"
VALUE "FileDescription", "BitChat - Decentralized Mesh Chat"
VALUE "FileVersion", VERSION_AS_STRING
VALUE "InternalName", "bitchat"
VALUE "LegalCopyright", "Copyright (C) 2025 BitChat. All rights reserved."
VALUE "OriginalFilename", "bitchat.exe"
VALUE "ProductName", "BitChat"
VALUE "ProductVersion", VERSION_AS_STRING
// ...
```

#### 2. Windows Build Process

```bash
# Build Windows executable
flutter build windows --release
```

#### 3. Windows Packaging

For MSIX packaging:

1. Add the `msix` package to `pubspec.yaml`:

```yaml
dependencies:
  msix: ^2.0.0
```

2. Configure MSIX packaging:

```bash
flutter pub run msix:create
```

#### 4. Windows Distribution

**Microsoft Store:**
1. Register as a Microsoft Store developer
2. Use the Partner Center to create a new app submission
3. Upload the MSIX package

**Direct Distribution:**
1. Distribute the Windows executable directly
2. Consider using an installer like Inno Setup
3. Create a ZIP archive with all necessary files

### Linux Deployment

#### 1. Linux Configuration

Update Linux-specific settings in `linux/my_application.cc` if needed.

#### 2. Linux Build Process

```bash
# Install Linux build dependencies
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# Build Linux application
flutter build linux --release
```

#### 3. Linux Packaging

For Debian/Ubuntu packaging:

```bash
# Install packaging tools
sudo apt-get install fakeroot

# Create debian directory structure
mkdir -p debian/DEBIAN
mkdir -p debian/usr/bin
mkdir -p debian/usr/share/applications
mkdir -p debian/usr/share/icons/hicolor/512x512/apps

# Copy application
cp -r build/linux/x64/release/bundle/* debian/usr/bin/

# Create control file
cat > debian/DEBIAN/control << EOF
Package: bitchat
Version: 0.1.0
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, liblzma5
Maintainer: BitChat Team <support@bitchat.example.com>
Description: Decentralized mesh chat application
 BitChat is a secure messaging app that works over Bluetooth mesh networks
 without requiring internet access or centralized servers.
EOF

# Build package
fakeroot dpkg-deb --build debian bitchat_0.1.0_amd64.deb
```

#### 4. Linux Distribution

**Linux Package Repositories:**
1. Set up a PPA (Personal Package Archive) for Ubuntu
2. Create repository metadata
3. Publish package to the repository

**Direct Distribution:**
1. Provide DEB/RPM packages for download
2. Consider AppImage or Flatpak formats
3. Include installation instructions

## Continuous Integration and Deployment

### GitHub Actions Workflow

Create `.github/workflows/build.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  release:
    types: [published]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter analyze

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test

  build-android:
    runs-on: ubuntu-latest
    needs: [analyze, test]
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-release
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    runs-on: macos-latest
    needs: [analyze, test]
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release --no-codesign
      # Add steps for code signing and archiving
```

### Firebase App Distribution

For beta distribution, use Firebase App Distribution:

1. Set up Firebase project
2. Install Firebase CLI
3. Add Firebase configuration
4. Deploy to Firebase App Distribution:

```bash
# Deploy Android build
firebase appdistribution:distribute path/to/app-release.apk \
  --app FIREBASE_APP_ID \
  --release-notes "Release notes" \
  --groups "testers"

# Deploy iOS build
firebase appdistribution:distribute path/to/BitChat.ipa \
  --app FIREBASE_APP_ID \
  --release-notes "Release notes" \
  --groups "testers"
```

## Version Management

### Versioning Strategy

BitChat follows Semantic Versioning (SemVer):

- **Major Version**: Breaking changes (e.g., 1.0.0)
- **Minor Version**: New features, backwards compatible (e.g., 1.1.0)
- **Patch Version**: Bug fixes, backwards compatible (e.g., 1.1.1)
- **Build Number**: Incremental value for app stores (e.g., +42)

### Release Channels

| Channel | Purpose | Update Frequency |
|---------|---------|-----------------|
| Alpha | Internal testing | As needed |
| Beta | External testing | Weekly |
| Production | Public release | Monthly |

### Release Checklist

Before deploying any release:

1. [ ] Run all unit and integration tests
2. [ ] Perform cross-platform compatibility testing
3. [ ] Verify binary protocol compatibility with iOS/Android versions
4. [ ] Check performance on low-end devices
5. [ ] Validate battery optimization features
6. [ ] Ensure accessibility compliance
7. [ ] Update documentation and release notes
8. [ ] Tag the release in Git repository

## Troubleshooting

### Common iOS Issues

| Issue | Solution |
|-------|----------|
| Signing certificate errors | Refresh certificates in Xcode Account settings |
| Provisioning profile issues | Regenerate profiles in Apple Developer Portal |
| Bluetooth permissions | Verify Info.plist has proper usage descriptions |
| App Store rejection | Check App Store Review Guidelines for compliance |

### Common Android Issues

| Issue | Solution |
|-------|----------|
| Keystore problems | Ensure key.properties file is properly configured |
| Permission issues | Verify all required permissions in AndroidManifest.xml |
| Google Play rejection | Review Google Play policies and content guidelines |
| Background service | Implement proper foreground service notification |

### Common Desktop Issues

| Issue | Solution |
|-------|----------|
| Missing Bluetooth drivers | Provide instructions for installing BLE drivers |
| Package dependencies | List required system libraries for each platform |
| Installation permissions | Guide for handling installation permissions |
| Display scaling issues | Set proper Flutter window size configurations |

## Post-Deployment

### Monitoring

1. **Crash Reporting**: Set up crash reporting without compromising privacy
2. **Performance Monitoring**: Implement battery and performance tracking
3. **User Feedback**: Provide in-app feedback mechanism

### Updates

1. **Security Updates**: Prioritize security patch deployment
2. **Feature Releases**: Schedule regular feature updates
3. **Compatibility Testing**: Test updates with older versions

## Appendix

### Platform-Specific Resources

| Platform | Resources |
|----------|-----------|
| iOS | [Apple Developer Documentation](https://developer.apple.com/documentation/) |
| Android | [Android Developer Documentation](https://developer.android.com/docs) |
| macOS | [macOS Developer Documentation](https://developer.apple.com/documentation/) |
| Windows | [Windows Developer Documentation](https://docs.microsoft.com/en-us/windows/apps/) |
| Linux | [Linux Packaging Guide](https://www.debian.org/doc/manuals/maint-guide/) |

### Useful Commands

```bash
# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade

# Check for outdated dependencies
flutter pub outdated

# Run with specific environment
flutter run --dart-define=ENVIRONMENT=dev

# Generate deployment scripts
flutter create . --platforms=windows,macos,linux
```

### Contact Information

For deployment assistance, contact:

- **Technical Support**: tech@bitchat.example.com
- **Developer Community**: Join our [Discord Server](https://discord.gg/bitchat)
- **GitHub Repository**: [github.com/permissionlesstech/bitchat-flutter](https://github.com/permissionlesstech/bitchat-flutter)

---

This deployment guide is a living document that will be updated as deployment processes evolve. Always refer to the most current version when deploying BitChat Flutter.
