# BitChat Flutter - Technical Specifications

**Version:** 0.1.0  
**Last Updated:** July 11, 2025

## System Overview

BitChat Flutter is a decentralized peer-to-peer messaging application operating over Bluetooth Low Energy (BLE) mesh networks. This document provides detailed technical specifications for developers implementing, maintaining, or integrating with the BitChat Flutter application.

## Development Environment

| Component | Specification | Version |
|-----------|--------------|---------|
| Flutter SDK | Latest stable | 3.16.0+ |
| Dart SDK | Latest stable | 3.2.0+ |
| Android SDK | API Level | 34 (Android 14) |
| Android Min SDK | API Level | 26 (Android 8.0) |
| iOS SDK | Target | iOS 16.0+ |
| iOS Min Version | Minimum | iOS 14.0 |
| IDE | Recommended | VS Code / Android Studio |

## Core Libraries

### Required Flutter Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # Bluetooth
  flutter_blue_plus: ^1.31.7
  
  # Encryption
  crypto: ^3.0.3
  cryptography: ^2.7.0
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2
  
  # UI
  material_color_utilities: ^0.8.0
  google_fonts: ^6.1.0
  
  # Utils
  uuid: ^4.2.1
  convert: ^3.1.1
  
  # Compression
  archive: ^3.4.9
  
  # Permissions
  permission_handler: ^11.2.0
```

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.2
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
```

## Hardware Requirements

### Device Requirements

| Feature | Minimum Requirement | Recommended |
|---------|---------------------|-------------|
| Bluetooth | BLE 4.2 support | BLE 5.0+ |
| Memory | 2GB RAM | 4GB+ RAM |
| Storage | 100MB free | 500MB free |
| Display | Any | 4.7" or larger |
| Processor | Any | Mid-range or better |

### Platform Specifics

**Android:**
- Bluetooth permissions
- Location permissions (required for BLE scanning on Android)
- Foreground service capability
- Notification permissions

**iOS:**
- Bluetooth permissions
- Background modes for Bluetooth
- Local notification permissions

## Network Specifications

### Bluetooth Low Energy

| Parameter | Value | Notes |
|-----------|-------|-------|
| Service UUID | F47B5E2D-4A9E-4C5A-9B3F-8E1D2C3A4B5C | Primary service |
| TX Characteristic | A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D | Write |
| RX Characteristic | A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D | Notify |
| MTU Size | 512 bytes | Negotiated on connection |
| Connection Interval | 20ms - 40ms | Platform dependent |
| Supervision Timeout | 4000ms | Default |
| Slave Latency | 0 | Default |

### Scanning Parameters

| Power Mode | Scan Duration | Scan Interval | Max Connections | Advertising Interval |
|------------|---------------|---------------|-----------------|----------------------|
| Performance | 3 seconds | 2 seconds | 20 | 500ms (continuous) |
| Balanced | 2 seconds | 3 seconds | 10 | 5 seconds |
| Power Saver | 1 second | 8 seconds | 5 | 15 seconds |
| Ultra Low Power | 0.5 seconds | 20 seconds | 2 | 30 seconds |

### WiFi Direct (Planned for v1.0)

| Parameter | iOS | Android | Notes |
|-----------|-----|---------|-------|
| Implementation | MultipeerConnectivity | WiFi P2P API | Platform specific |
| Max Speed | ~60 Mbps | ~250 Mbps | Theoretical maximum |
| Range | ~60m | ~200m | Line of sight |
| Cross-Platform | No | No | Same platform only |

## Binary Protocol

### Packet Structure

```
+------------------+------------------+------------------+
|     Header       |     Payload      |    Optional      |
|    (13 bytes)    |   (Variable)     |   Signature      |
+------------------+------------------+------------------+
```

### Header Format

| Byte Offset | Length | Field Name | Description |
|-------------|--------|------------|-------------|
| 0 | 1 | Version | Protocol version (0x01) |
| 1 | 1 | Message Type | Message type identifier |
| 2 | 1 | TTL | Time-to-live (max 7) |
| 3 | 1 | Flags | Control flags |
| 4 | 4 | Source ID | Originating device ID |
| 8 | 4 | Destination ID | Target device ID (0x00000000 for broadcast) |
| 12 | 1 | Payload Length | Length of payload data |

### Message Types

| Type | Value | Name | Description |
|------|-------|------|-------------|
| 0x01 | 1 | `MSG_DISCOVERY` | Peer discovery announcement |
| 0x02 | 2 | `MSG_CHANNEL` | Channel message |
| 0x03 | 3 | `MSG_PRIVATE` | Private message |
| 0x04 | 4 | `MSG_ROUTING` | Routing table update |
| 0x05 | 5 | `MSG_ACK` | Acknowledgment |
| 0x06 | 6 | `MSG_FRAGMENT` | Message fragment |
| 0x07 | 7 | `MSG_PING` | Keep-alive ping |
| 0x08 | 8 | `MSG_PONG` | Ping response |

### Flag Bits

```
Bit 7 | Bit 6 | Bit 5 | Bit 4 | Bit 3 | Bit 2 | Bit 1 | Bit 0
------|-------|-------|-------|-------|-------|-------|-------
 ACK  | FRAG  | COMP  | ENC   | SIGN  | RES   | RES   | RES
```

- **ACK (0x80)**: Acknowledgment required
- **FRAG (0x40)**: Fragmented message
- **COMP (0x20)**: Compressed payload
- **ENC (0x10)**: Encrypted payload
- **SIGN (0x08)**: Digital signature present
- **RES (0x04-0x01)**: Reserved for future use

## Cryptographic Specifications

### Key Exchange

| Algorithm | Parameters | Implementation |
|-----------|------------|----------------|
| X25519 | 256-bit keys | RFC 7748 compliant |
| HKDF | SHA-256 | RFC 5869 |

### Symmetric Encryption

| Algorithm | Parameters | Implementation |
|-----------|------------|----------------|
| AES-256-GCM | 256-bit key | NIST SP 800-38D |
| Nonce | 96 bits (12 bytes) | Random |
| Authentication Tag | 128 bits (16 bytes) | GCM tag |

### Digital Signatures

| Algorithm | Parameters | Implementation |
|-----------|------------|----------------|
| Ed25519 | 256-bit keys | RFC 8032 |
| Signature Size | 512 bits (64 bytes) | Standard |

### Key Derivation (Channels)

| Algorithm | Parameters | Implementation |
|-----------|------------|----------------|
| Argon2id | Memory: 65536 KB (64 MB) | Password-based |
| | Time: 3 iterations | |
| | Parallelism: 4 threads | |
| | Salt: 128 bits (16 bytes) | |
| | Output: 256 bits (32 bytes) | |

## Data Storage

### Local Database

| Component | Technology | Purpose |
|-----------|------------|---------|
| Primary Storage | Hive | NoSQL database |
| Encryption | AES-256-GCM | Database encryption |
| Data Types | Boxed collections | Messages, peers, channels |
| Persistence | Optional | User configurable |

### Storage Collections

| Collection | Contents | Persistence |
|------------|----------|-------------|
| messages | Chat messages | Ephemeral (default) |
| channels | Channel metadata | Semi-persistent |
| peers | Peer information | Semi-persistent |
| settings | User preferences | Persistent |

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| App Launch Time | < 2 seconds | Cold start |
| Message Send Latency | < 500ms | Direct connection |
| Message Relay | < 1 second per hop | Multi-hop routing |
| Battery Impact | < 5% per hour | Background operation |
| Memory Footprint | < 100 MB | Active use |
| Storage Size | < 50 MB | Base application |

## Message Compression

| Aspect | Specification | Notes |
|--------|---------------|-------|
| Algorithm | LZ4 | Fast compression |
| Threshold | 100 bytes | Messages larger than threshold |
| Compression Ratio | 30-70% | Typical for text messages |
| Entropy Check | Yes | Skip high-entropy data |

## UI Specifications

### Theme

| Component | Dark Theme | Light Theme |
|-----------|------------|-------------|
| Primary Background | #0D1117 | #FFFFFF |
| Secondary Background | #161B22 | #F6F8FA |
| Card Background | #21262D | #FFFFFF |
| Input Background | #30363D | #F6F8FA |
| Primary Text | #F0F6FC | #24292F |
| Secondary Text | #8B949E | #656D76 |
| Accent Color | #58A6FF | #0969DA |
| Success Color | #3FB950 | #1A7F37 |
| Warning Color | #D29922 | #9A6700 |
| Error Color | #F85149 | #CF222E |

### Typography

| Element | Font Family | Weight | Size |
|---------|------------|--------|------|
| Channel Header | Roboto | Bold | 18sp |
| Message Text | Roboto Mono | Regular | 14sp |
| Input Text | Roboto Mono | Regular | 14sp |
| Timestamp | Roboto Mono | Light | 12sp |
| Username | Roboto | Medium | 14sp |

### Layout

| Screen Size | Layout Type | Notes |
|-------------|-------------|-------|
| < 600dp | Single Pane | Mobile phones |
| 600dp - 900dp | Dual Pane (optional) | Tablets |
| > 900dp | Dual Pane | Desktops |

## Commands

### Standard Commands

| Command | Format | Description |
|---------|--------|-------------|
| Join | `/j #channel [password]` | Join or create a channel |
| Private Message | `/m @name message` | Send a private message |
| Who | `/w [channel]` | List users in channel or all channels |
| Channels | `/channels` | List available channels |
| Block | `/block @name` | Block a user |
| Unblock | `/unblock @name` | Unblock a user |
| Clear | `/clear` | Clear current chat |
| Set Password | `/pass [password]` | Set channel password (owner only) |
| Transfer | `/transfer @name` | Transfer channel ownership |
| Save | `/save` | Toggle message retention |

### Maintenance Commands

| Command | Format | Description |
|---------|--------|-------------|
| Peers | `/peers` | Show connected peers |
| Mesh | `/mesh` | Show mesh network status |
| Battery | `/battery` | Show battery optimization |
| Encrypt | `/encrypt` | Show encryption status |
| Wipe | `/wipe` | Emergency data wipe |

## Platform Interfaces

### Android

| Component | Implementation | Purpose |
|-----------|---------------|---------|
| BLE Central | BluetoothManager | Scanning, connecting |
| BLE Peripheral | BluetoothGattServer | Advertising, receiving |
| Background | Foreground Service | Persistent operation |
| Permissions | Runtime Permissions | BLE, location |

### iOS

| Component | Implementation | Purpose |
|-----------|----------------|---------|
| BLE Central | CBCentralManager | Scanning, connecting |
| BLE Peripheral | CBPeripheralManager | Advertising, receiving |
| Background | Background Modes | Bluetooth operations |
| Permissions | Info.plist | BLE usage description |

## Security Requirements

| Aspect | Requirement | Implementation |
|--------|-------------|----------------|
| No External Dependencies | All crypto verifiable | Pure Dart/Flutter |
| Memory Management | Secure cleanup | Zeroing sensitive data |
| Key Storage | Ephemeral in memory | No persistent keys |
| Traffic Analysis | Cover traffic | Random delays, dummy messages |
| Emergency Wipe | Triple-tap mechanism | Complete data erasure |

## Logging and Monitoring

| Level | Usage | Examples |
|-------|-------|----------|
| Debug | Development only | Connection details, scan results |
| Info | General operation | Peer discovery, channel joins |
| Warning | Non-critical issues | Reconnection attempts, timeouts |
| Error | Critical problems | Encryption failures, BLE errors |

### Privacy Protection

- No user identifiable data in logs
- No message content logging
- No persistent logs in release builds
- No analytics or telemetry

## WiFi Direct Extension (Planned)

### Transport Abstraction

```dart
abstract class TransportProtocol {
  Future<void> initialize();
  Future<bool> isAvailable();
  Future<void> startDiscovery();
  Future<void> stopDiscovery();
  Future<void> send(Uint8List data, String peerId);
  Stream<TransportData> get dataStream;
}
```

### iOS Implementation

| Component | Implementation | Notes |
|-----------|---------------|-------|
| Framework | MultipeerConnectivity | Native iOS |
| Discovery | MCNearbyServiceBrowser | Bonjour-based |
| Connections | MCSession | Encrypted sessions |
| Range | ~60 meters | Line of sight |

### Android Implementation

| Component | Implementation | Notes |
|-----------|---------------|-------|
| Framework | WiFi P2P API | WifiP2pManager |
| Discovery | discoverPeers() | Network discovery |
| Connections | WifiP2pConfig | Direct connection |
| Range | ~200 meters | Line of sight |

## Glossary

| Term | Definition |
|------|------------|
| BLE | Bluetooth Low Energy |
| TTL | Time To Live - hop count for message routing |
| MTU | Maximum Transmission Unit - packet size limit |
| RSSI | Received Signal Strength Indicator |
| AES-GCM | Advanced Encryption Standard in Galois/Counter Mode |
| X25519 | Elliptic curve Diffie-Hellman key exchange |
| Ed25519 | Edwards-curve Digital Signature Algorithm |
| Argon2id | Modern key derivation function |
| LZ4 | Fast compression algorithm |

---

This document will be updated as specifications evolve during development. All implementations must adhere to these specifications to ensure cross-platform compatibility and security.
