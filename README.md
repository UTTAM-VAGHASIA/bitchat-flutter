# BitChat Flutter

> [!WARNING]
> This software has not received external security review and may contain vulnerabilities. Do not use for sensitive communications. Work in progress.

A decentralized peer-to-peer messaging app that works over Bluetooth mesh networks. No internet required, no servers, no phone numbers. This is the Flutter version of the original BitChat for iOS and Android.

**Version:** 0.1.0  
**Last Updated:** July 11, 2025

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

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio/Xcode for platform-specific development
- Bluetooth LE capable device

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/UTTAM-VAGHASIA/bitchat-flutter.git
   cd bitchat-flutter/bitchat
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate required files:**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

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

This Flutter implementation maintains 100% binary protocol compatibility with:
- [iOS BitChat](https://github.com/permissionlesstech/bitchat)
- [Android BitChat](https://github.com/permissionlesstech/bitchat-android)

Enabling seamless communication between all platforms.

## Documentation

Detailed documentation is available in the `docs/` directory:

- [Architecture](docs/ARCHITECTURE.md)
- [Protocol Specification](docs/PROTOCOL_SPEC.md)
- [Security Specification](docs/SECURITY_SPEC.md)
- [UI Requirements](docs/UI_REQUIREMENTS.md)
- [Bluetooth Implementation](docs/BLUETOOTH_IMPLEMENTATION.md)
- [Encryption Specification](docs/ENCRYPTION_SPEC.md)
- [Commands Reference](docs/COMMANDS_REFERENCE.md)
- [Platform Compatibility](docs/PLATFORM_COMPATIBILITY.md)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Support

For support and issues:
- Create an issue on GitHub
- Check compatibility with original iOS/Android versions
- Refer to the technical documentation

---

**Note**: This is a work in progress. The protocol is designed to be compatible with the original iOS and Android BitChat implementations.
