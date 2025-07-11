# BitChat Feature Matrix

**Version:** 0.1.0  
**Last Updated:** July 11, 2025

## Overview

This document provides a comprehensive comparison of features across the BitChat implementations for iOS, Android, and Flutter. This matrix helps ensure feature parity and highlights platform-specific capabilities.

## Core Features

| Feature | iOS | Android | Flutter | Notes |
|---------|-----|---------|---------|-------|
| **Mesh Networking** |||||
| BLE Peer Discovery | ✓ | ✓ | ✓ | Identical scanning methodology |
| Multi-hop Message Relay | ✓ | ✓ | ✓ | TTL-based, max 7 hops |
| Store & Forward | ✓ | ✓ | ✓ | 24-hour retention |
| Maximum Network Size | 1,024 peers | 1,024 peers | 1,024 peers | Theoretical limit |
| **Encryption** |||||
| X25519 Key Exchange | ✓ | ✓ | ✓ | RFC 7748 compliant |
| AES-256-GCM | ✓ | ✓ | ✓ | NIST SP 800-38D |
| Ed25519 Signatures | ✓ | ✓ | ✓ | RFC 8032 |
| Argon2id (Channels) | ✓ | ✓ | ✓ | Memory: 64MB, Iterations: 3, Parallelism: 4 |
| Forward Secrecy | ✓ | ✓ | ✓ | New keys each session |
| Emergency Wipe | ✓ | ✓ | ✓ | Triple-tap to clear all data |
| **Messaging** |||||
| Channel-Based Messaging | ✓ | ✓ | ✓ | Unlimited channels |
| Private Messaging | ✓ | ✓ | ✓ | End-to-end encrypted |
| IRC-Style Commands | ✓ | ✓ | ✓ | Complete command set |
| Message Retention Control | ✓ | ✓ | ✓ | Owner-controlled |
| Channel Password | ✓ | ✓ | ✓ | Argon2id derived |
| @Mentions | ✓ | ✓ | ✓ | With autocomplete |
| **Performance** |||||
| LZ4 Compression | ✓ | ✓ | ✓ | For messages >100 bytes |
| Adaptive Power Modes | ✓ | ✓ | ✓ | 4 power modes |
| Bloom Filters | ✓ | ✓ | ✓ | For duplicate detection |
| Message Aggregation | ✓ | ✓ | ✓ | Batch small messages |
| **Privacy** |||||
| No Registration | ✓ | ✓ | ✓ | No accounts or phone numbers |
| Ephemeral Messages | ✓ | ✓ | ✓ | Default behavior |
| Cover Traffic | ✓ | ✓ | ✓ | Random delays and dummy messages |
| Timing Obfuscation | ✓ | ✓ | ✓ | 50-500ms random delays |

## Transport Features

| Feature | iOS | Android | Flutter | Notes |
|---------|-----|---------|---------|-------|
| **Bluetooth LE** |||||
| Central Role | ✓ | ✓ | ✓ | Scanning and connecting |
| Peripheral Role | ✓ | ✓ | ✓ | Advertising and accepting connections |
| Maximum MTU | 512 bytes | 512 bytes | 512 bytes | Negotiated at connection |
| Packet Fragmentation | ✓ | ✓ | ✓ | 491-byte fragments |
| **WiFi Direct** |||||
| Basic Implementation | ✓ | ✓ | Planned (v1.0) | High bandwidth alternative |
| iOS MultipeerConnectivity | ✓ | N/A | Planned (v1.0) | iOS/macOS specific |
| Android WiFi P2P | N/A | ✓ | Planned (v1.0) | Android specific |
| Cross-Platform Support | ✓* | ✓* | Planned (v1.0) | *Limited to same platform |
| Transport Selection | ✓ | ✓ | Planned (v1.0) | Based on battery/message size |

## Battery Optimization

| Feature | iOS | Android | Flutter | Notes |
|---------|-----|---------|---------|-------|
| **Power Modes** |||||
| Performance Mode | ✓ | ✓ | ✓ | >60% battery or charging |
| Balanced Mode | ✓ | ✓ | ✓ | 30-60% battery |
| Power Saver Mode | ✓ | ✓ | ✓ | 10-30% battery |
| Ultra Low Power Mode | ✓ | ✓ | ✓ | <10% battery |
| **Scan Parameters** |||||
| Performance | 3s scan, 2s pause | 3s scan, 2s pause | 3s scan, 2s pause | 20 connections max |
| Balanced | 2s scan, 3s pause | 2s scan, 3s pause | 2s scan, 3s pause | 10 connections max |
| Power Saver | 1s scan, 8s pause | 1s scan, 8s pause | 1s scan, 8s pause | 5 connections max |
| Ultra Low Power | 0.5s scan, 20s pause | 0.5s scan, 20s pause | 0.5s scan, 20s pause | 2 connections max |

## UI Features

| Feature | iOS | Android | Flutter | Notes |
|---------|-----|---------|---------|-------|
| Terminal-Style Interface | ✓ | ✓ | ✓ | IRC-like appearance |
| Dark Mode | ✓ | ✓ | ✓ | Default theme |
| Light Mode | ✓ | ✓ | ✓ | Optional |
| Adaptive Layout | ✓ | ✓ | ✓ | Responsive to screen sizes |
| Haptic Feedback | ✓ | ✓ | ✓ | For interactions |
| RSSI Indicators | ✓ | ✓ | ✓ | Signal strength visualization |
| Accessibility Support | ✓ | ✓ | ✓ | Screen readers, contrast |

## Platform-Specific Features

| Feature | iOS | Android | Flutter | Notes |
|---------|-----|---------|---------|-------|
| **iOS Specific** |||||
| Native SwiftUI | ✓ | N/A | N/A | iOS UI framework |
| Background Modes | ✓ | N/A | ✓ | iOS specific |
| Keychain Integration | ✓ | N/A | ✓ | Secure storage |
| **Android Specific** |||||
| Jetpack Compose UI | N/A | ✓ | N/A | Android UI framework |
| Foreground Service | N/A | ✓ | ✓ | For persistent connections |
| Material Design 3 | N/A | ✓ | ✓ | Android design language |
| **Flutter Cross-Platform** |||||
| Single Codebase | N/A | N/A | ✓ | Unified development |
| Platform Channels | N/A | N/A | ✓ | Native code bridging |
| Adaptive UI | N/A | N/A | ✓ | Platform-specific adaptations |

## Command Support

| Command | iOS | Android | Flutter | Description |
|---------|-----|---------|---------|-------------|
| /j, /join | ✓ | ✓ | ✓ | Join a channel |
| /m, /msg | ✓ | ✓ | ✓ | Send a private message |
| /w, /who | ✓ | ✓ | ✓ | List users |
| /channels | ✓ | ✓ | ✓ | List available channels |
| /block | ✓ | ✓ | ✓ | Block a peer |
| /unblock | ✓ | ✓ | ✓ | Unblock a peer |
| /clear | ✓ | ✓ | ✓ | Clear chat messages |
| /pass | ✓ | ✓ | ✓ | Set/change channel password |
| /transfer | ✓ | ✓ | ✓ | Transfer channel ownership |
| /save | ✓ | ✓ | ✓ | Toggle message retention |
| /peers | ✓ | ✓ | ✓ | Show connected peers |
| /mesh | ✓ | ✓ | ✓ | Show mesh network status |
| /battery | ✓ | ✓ | ✓ | Show battery optimization status |
| /encrypt | ✓ | ✓ | ✓ | Show encryption status |
| /wipe | ✓ | ✓ | ✓ | Emergency data wipe |

## Planned Features

| Feature | iOS | Android | Flutter | Target Release |
|---------|-----|---------|---------|---------------|
| WiFi Direct Integration | Implemented | Implemented | v1.0 | November 2025 |
| Multi-Transport Mesh | Implemented | Implemented | v1.0 | November 2025 |
| Advanced Message Threading | Planned | Planned | v1.1 | Q1 2026 |
| File Sharing | Implemented | Implemented | v1.1 | Q1 2026 |
| Voice Messages | Planned | Planned | v1.2 | Q2 2026 |
| Ultrasonic Transport | Research | Research | v1.5 | 2026 |
| LoRa Integration | Research | Research | v2.0 | 2027 |

## Compatibility Matrix

This section details the cross-compatibility between different BitChat implementations:

| From ↓ / To → | iOS BitChat | Android BitChat | Flutter iOS | Flutter Android |
|---------------|-------------|-----------------|-------------|-----------------|
| iOS BitChat | ✓ | ✓ | ✓ | ✓ |
| Android BitChat | ✓ | ✓ | ✓ | ✓ |
| Flutter iOS | ✓ | ✓ | ✓ | ✓ |
| Flutter Android | ✓ | ✓ | ✓ | ✓ |

## Platform Requirements

| Platform | Minimum Version | Target Version | BLE Support | WiFi Direct Support |
|----------|----------------|----------------|-------------|---------------------|
| iOS | iOS 14.0 | iOS 16.0+ | Required | Via MultipeerConnectivity |
| macOS | macOS 11.0 | macOS 13.0+ | Required | Via MultipeerConnectivity |
| Android | API 26 (8.0) | API 34 (14) | Required | Via WiFi P2P API |
| Windows (Flutter) | Windows 10 | Windows 11 | Required | Limited |
| Linux (Flutter) | Ubuntu 20.04 | Ubuntu 22.04 | Required | Limited |

## Summary

The BitChat Flutter implementation aims for 100% feature parity with the original iOS and Android versions, ensuring seamless cross-platform compatibility. Any deviations or platform-specific implementations are clearly documented in this matrix.

The core functionality of mesh networking, end-to-end encryption, and IRC-style messaging is identical across all implementations, with only UI frameworks and platform-specific optimizations differing between versions.
