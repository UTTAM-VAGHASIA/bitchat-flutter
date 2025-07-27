# BitChat Flutter - Product Overview

BitChat Flutter is a decentralized peer-to-peer messaging application that operates over Bluetooth Low Energy (BLE) mesh networks without requiring internet access or centralized servers.

## Core Features

- **Decentralized Mesh Network**: Automatic peer discovery and multi-hop message relay over Bluetooth LE
- **End-to-End Encryption**: X25519 key exchange + AES-256-GCM for private messages and channels
- **Channel-Based Chats**: Topic-based group messaging with optional password protection
- **Store & Forward**: Messages cached for offline peers and delivered when they reconnect
- **Privacy First**: No accounts, no phone numbers, no persistent identifiers
- **IRC-Style Commands**: Familiar `/join`, `/msg`, `/who` style interface
- **Cross-Platform**: Compatible with iOS and Android BitChat apps

## Key Requirements

- **Protocol Compatibility**: Must maintain 100% binary protocol compatibility with iOS BitChat v2.1.0+ and Android BitChat v1.8.0+
- **Security**: All messages encrypted, forward secrecy, cover traffic for privacy
- **Performance**: Optimized for battery life, efficient mesh routing (max 7 hops)
- **User Experience**: Simple, IRC-like interface with Material Design 3

## Development Status

Currently in **Phase 1: Foundation** - establishing documentation, architecture, and core protocol implementation. The project follows a structured roadmap through Q2 2026 for full feature completion.

## Target Platforms

- iOS 14.0+ (iPhone 6s and newer)
- Android 8.0+ (API Level 26+)
- Desktop: Windows 10+, macOS 10.14+, Ubuntu 18.04+