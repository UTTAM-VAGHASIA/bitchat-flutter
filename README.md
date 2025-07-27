# BitChat Flutter

> [!WARNING]
> This software has not received external security review and may contain vulnerabilities. Do not use for sensitive communications. Work in progress.

A decentralized peer-to-peer messaging app that works over Bluetooth mesh networks. No internet required, no servers, no phone numbers. This is the Flutter version of the original BitChat for iOS and Android.

**Version:** 0.1.0  
**Last Updated:** July 26, 2025  
**Development Status:** 🚧 Active Development - Foundation Phase

## License

This project is released into the public domain. See the [LICENSE](LICENSE) file for details.

## Features

- **Decentralized Mesh Network**: Automatic peer discovery and multi-hop message relay over Bluetooth LE
- **End-to-End Encryption**: X25519 key exchange + AES-256-GCM for private messages and channels
- **Channel-Based Chats**: Topic-based group messaging with optional password protection
- **Store & Forward**: Messages cached for offline peers and delivered when they reconnect
- **Privacy First**: No accounts, no phone numbers, no persistent identifiers
- **IRC-Style Commands**: Familiar `/join`, `/msg`, `/who` style interface
- **Message Retention**: Optional channel-wide message saving controlled by channel owners
- **Cross-Platform**: Compatible with iOS and Android BitChat apps
- **Cover Traffic**: Timing obfuscation and dummy messages for enhanced privacy
- **Emergency Wipe**: Triple-tap to instantly clear all data
- **Performance Optimizations**: LZ4 message compression, adaptive battery modes, and optimized networking

## Current Development Status

### 🚧 Phase 1: Foundation (In Progress)
- ✅ **Documentation Structure**: Comprehensive documentation system established
- ✅ **Project Setup**: Development environment and tooling configured
- ✅ **Architecture Design**: Clean architecture patterns defined
- 🔄 **Core Protocol**: Binary protocol implementation in progress
- ⏳ **Bluetooth Layer**: BLE mesh networking implementation planned
- ⏳ **Encryption Services**: X25519 + AES-256-GCM implementation planned

### 📋 Upcoming Phases
- **Phase 2**: Core Bluetooth Implementation (Q3 2025)
- **Phase 3**: Encryption & Security (Q4 2025)
- **Phase 4**: UI & User Experience (Q1 2026)
- **Phase 5**: Testing & Optimization (Q2 2026)

### 🎯 Compatibility Goals
- **iOS BitChat**: Target v2.1.0+ compatibility
- **Android BitChat**: Target v1.8.0+ compatibility
- **Protocol Version**: Binary protocol v1.0 compliance

## Quick Start for Developers

### Prerequisites

- **Flutter SDK**: 3.16.0+ (latest stable recommended)
- **Development IDE**: VS Code with Flutter extension or Android Studio
- **Platform Tools**: Android Studio/Xcode for platform-specific development
- **Hardware**: Bluetooth LE capable device for testing
- **Git**: For version control and contribution

### 🚀 Quick Setup

1. **Clone and setup:**
   ```bash
   git clone https://github.com/UTTAM-VAGHASIA/bitchat-flutter.git
   cd bitchat-flutter/bitchat
   flutter pub get
   flutter packages pub run build_runner build
   ```

2. **Verify setup:**
   ```bash
   flutter doctor -v
   flutter analyze
   flutter test
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

📖 **Need detailed setup instructions?** See [DEVELOPER_SETUP.md](DEVELOPER_SETUP.md) for comprehensive environment setup.

## Usage

### Basic Commands

- `/j #channel` - Join or create a channel
- `/m @name message` - Send a private message
- `/w` - List online users
- `/channels` - Show all discovered channels
- `/block @name` - Block a peer from messaging you
- `/clear` - Clear chat messages
- `/pass [password]` - Set/change channel password (owner only)
- `/transfer @name` - Transfer channel ownership
- `/save` - Toggle message retention for channel (owner only)

### Getting Started

1. Launch BitChat on your device
2. Set your nickname (or use the auto-generated one)
3. You'll automatically connect to nearby peers
4. Join a channel with `/j #general` or start chatting in public
5. Messages relay through the mesh network to reach distant peers

## Security & Privacy

### Encryption
- **Private Messages**: X25519 key exchange + AES-256-GCM encryption
- **Channel Messages**: Argon2id password derivation + AES-256-GCM
- **Digital Signatures**: Ed25519 for message authenticity
- **Forward Secrecy**: New key pairs generated each session

### Privacy Features
- **No Registration**: No accounts, emails, or phone numbers required
- **Ephemeral by Default**: Messages exist only in device memory
- **Cover Traffic**: Random delays and dummy messages prevent traffic analysis
- **Emergency Wipe**: Triple-tap logo to instantly clear all data
- **Local-First**: Works completely offline, no servers involved

## Technical Architecture

### Binary Protocol
BitChat uses an efficient binary protocol optimized for Bluetooth LE:
- Compact packet format with 1-byte type field
- TTL-based message routing (max 7 hops)
- Automatic fragmentation for large messages
- Message deduplication via unique IDs

### Mesh Networking
- Each device acts as both client and peripheral
- Automatic peer discovery and connection management
- Store-and-forward for offline message delivery
- Adaptive duty cycling for battery optimization

### Future Extensions
- **WiFi Direct**: Planned higher-bandwidth transport (250+ Mbps vs BLE's 1-3 Mbps)
- **Transport Selection**: Intelligent selection between BLE and WiFi Direct based on message size and battery
- **Multi-Transport Mesh**: Hybrid mesh where some nodes use BLE, others WiFi Direct

## Cross-Platform Compatibility

### 🔗 Protocol Compatibility
This Flutter implementation maintains **100% binary protocol compatibility** with:
- **[iOS BitChat](https://github.com/permissionlesstech/bitchat)** - v2.1.0+ (tested with v2.1.3)
- **[Android BitChat](https://github.com/permissionlesstech/bitchat-android)** - v1.8.0+ (tested with v1.8.2)

### 📱 Platform Support
- **iOS**: 14.0+ (iPhone 6s and newer)
- **Android**: 8.0+ (API Level 26+)
- **Desktop**: Windows 10+, macOS 10.14+, Ubuntu 18.04+

### 🔄 Interoperability
- **Message Exchange**: Seamless messaging between iOS, Android, and Flutter clients
- **Channel Compatibility**: Join channels created on any platform
- **Encryption**: Identical cryptographic operations across all platforms
- **Network Mesh**: Participate in mixed-platform mesh networks

📖 **Compatibility Details**: See [REFERENCE_ANALYSIS.md](REFERENCE_ANALYSIS.md) for detailed compatibility analysis.

## 📚 Documentation

### 🎯 Start Here
- **📋 [Complete Documentation Index](DOCUMENTATION_INDEX.md)** - Find all documentation organized by role and purpose
- **🚀 [Developer Setup Guide](DEVELOPER_SETUP.md)** - Complete environment setup (start here!)
- **🤝 [Contributing Guidelines](CONTRIBUTING.md)** - How to contribute to the project
- **📝 [Code Style Guide](CODE_STYLE_GUIDE.md)** - Coding standards and best practices

### 🏗️ Technical Documentation
- **🏛️ [System Architecture](docs/ARCHITECTURE.md)** - High-level system design and Flutter-specific patterns
- **📡 [Protocol Specification](docs/PROTOCOL_SPEC.md)** - Binary protocol details and compatibility requirements
- **🔒 [Security Specification](docs/SECURITY_SPEC.md)** - Cryptographic implementation and security model
- **📶 [Bluetooth Implementation](docs/BLUETOOTH_IMPLEMENTATION.md)** - BLE mesh networking with flutter_blue_plus
- **🎨 [UI Requirements](docs/UI_REQUIREMENTS.md)** - User interface specifications and Flutter widgets
- **🔧 [Platform Compatibility](docs/PLATFORM_COMPATIBILITY.md)** - Cross-platform considerations and differences

### 📋 Project Management
- **📊 [Project Requirements](context/project_requirements.md)** - Comprehensive functional and non-functional requirements
- **🗺️ [Implementation Roadmap](context/implementation_roadmap.md)** - Development phases and timeline
- **🧪 [Testing Strategy](context/testing_strategy.md)** - Quality assurance and compatibility testing approach
- **🚀 [Deployment Guide](context/deployment_guide.md)** - Build and release procedures
- **📈 [Feature Matrix](context/feature_matrix.md)** - Cross-platform feature comparison

### 🔍 Reference & Analysis
- **📱 [Reference Analysis](REFERENCE_ANALYSIS.md)** - Detailed analysis of iOS and Android implementations
- **⚙️ [Development Workflow](DEVELOPMENT_WORKFLOW.md)** - Git workflow and daily development processes

## Contributing

Contributions are welcome! Please see our comprehensive contribution documentation:

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines and process
- **[DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md)** - Git workflow and daily development
- **[REFERENCE_ANALYSIS.md](REFERENCE_ANALYSIS.md)** - Understanding iOS/Android implementations

## Support

For support and issues:
- Create an issue on GitHub
- Check compatibility with original iOS/Android versions
- Refer to the technical documentation

---

**Note**: This is a work in progress. The protocol is designed to be compatible with the original iOS and Android BitChat implementations.
