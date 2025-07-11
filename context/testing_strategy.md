# BitChat Flutter - Testing Strategy

**Version:** 0.1.0  
**Last Updated:** July 11, 2025

## Overview

This document outlines the comprehensive testing strategy for BitChat Flutter, with special emphasis on ensuring cross-platform compatibility with the original iOS and Android implementations.

## Testing Goals

1. **Ensure Protocol Compatibility**: Validate 100% binary protocol compatibility with iOS and Android implementations
2. **Verify Encryption Compatibility**: Test cryptographic operations across platforms
3. **Validate Mesh Network**: Test multi-hop message routing across different device types
4. **Measure Performance**: Benchmark battery usage and network efficiency
5. **Verify UI/UX**: Ensure consistent user experience across platforms

## Testing Layers

### Unit Tests

| Category | Description | Coverage Target |
|----------|-------------|-----------------|
| Protocol | Binary packet encoding/decoding | 100% |
| Encryption | Key generation, encryption/decryption | 100% |
| Commands | Command parsing and execution | 100% |
| Mesh | Routing algorithms and peer management | 90% |
| Battery | Power mode transitions | 95% |

#### Protocol Testing

```dart
void main() {
  group('Binary Protocol', () {
    test('should encode message with identical format to iOS/Android', () {
      final message = Message(
        type: MessageType.channelMessage,
        content: 'Test message',
        senderId: '12345678',
        channelId: 'general',
      );
      
      final packet = BinaryProtocol.encodeMessage(message);
      
      // Byte-by-byte comparison with reference iOS output
      expect(packet.bytes, equals(iosReferenceBytes));
      // Byte-by-byte comparison with reference Android output
      expect(packet.bytes, equals(androidReferenceBytes));
    });
    
    test('should decode iOS messages correctly', () {
      final decoded = BinaryProtocol.decodePacket(iosReferenceBytes);
      expect(decoded.type, equals(MessageType.channelMessage));
      expect(decoded.content, equals('Test message'));
      expect(decoded.senderId, equals('12345678'));
    });
    
    test('should handle edge cases identically to reference implementations', () {
      // Test empty messages
      // Test max-size messages
      // Test messages with special characters
      // Test fragmented messages
    });
  });
}
```

#### Encryption Testing

```dart
void main() {
  group('Encryption Compatibility', () {
    test('X25519 key exchange produces identical shared secrets', () async {
      final aliceKeyPair = await generateKeyPair(seed: fixedSeed1);
      final bobKeyPair = await generateKeyPair(seed: fixedSeed2);
      
      final sharedSecret1 = await computeSharedSecret(
        aliceKeyPair.privateKey, 
        bobKeyPair.publicKey,
      );
      
      // Compare with reference implementations
      expect(sharedSecret1, equals(iosReferenceSharedSecret));
      expect(sharedSecret1, equals(androidReferenceSharedSecret));
    });
    
    test('AES-256-GCM encryption produces identical ciphertext', () async {
      final plaintext = 'Test message for encryption';
      final key = Uint8List.fromList(List.generate(32, (i) => i));
      final nonce = Uint8List.fromList(List.generate(12, (i) => i));
      
      final ciphertext = await encryptAesGcm(plaintext, key, nonce);
      
      // Compare with reference implementations
      expect(ciphertext, equals(iosReferenceCiphertext));
      expect(ciphertext, equals(androidReferenceCiphertext));
    });
  });
}
```

### Integration Tests

| Category | Description | Test Devices |
|----------|-------------|-------------|
| Bluetooth Mesh | Multi-device message relay | Min. 5 devices |
| Multi-platform | iOS ↔ Flutter ↔ Android | Min. 1 each |
| Battery Tests | Power consumption in different modes | All supported devices |
| Background | Background operation and message caching | All supported platforms |

#### Mesh Network Testing

```dart
void main() {
  group('Mesh Network Integration', () {
    testWidgets('Messages relay through multiple hops', (tester) async {
      // Setup 3+ test devices in a chain formation where direct communication
      // is only possible between adjacent devices
      
      // Send a message from first device to last device
      await firstDevice.sendMessage(message, lastDevice.id);
      
      // Verify message arrives at last device
      await expectLater(lastDevice.messages, emits(message));
      
      // Verify message passed through intermediate devices
      expect(middleDevice.relayedMessages, contains(message.id));
    });
  });
}
```

### Cross-Platform Tests

#### Test Matrix

| Test Case | iOS | Android | Flutter iOS | Flutter Android | Mixed |
|-----------|-----|---------|-------------|----------------|-------|
| Join Channel | ✓ | ✓ | ✓ | ✓ | ✓ |
| Private Message | ✓ | ✓ | ✓ | ✓ | ✓ |
| Channel Password | ✓ | ✓ | ✓ | ✓ | ✓ |
| Message Fragmentation | ✓ | ✓ | ✓ | ✓ | ✓ |
| Multi-hop Relay | ✓ | ✓ | ✓ | ✓ | ✓ |
| Store & Forward | ✓ | ✓ | ✓ | ✓ | ✓ |
| Battery Optimization | ✓ | ✓ | ✓ | ✓ | N/A |

#### Platform Compatibility Test Scenarios

1. **Basic Communication**
   - iOS BitChat ↔ Flutter iOS
   - Android BitChat ↔ Flutter Android
   - iOS BitChat ↔ Flutter Android
   - Android BitChat ↔ Flutter iOS

2. **Mixed Group Chat**
   - Create a channel with iOS, Android, Flutter iOS, and Flutter Android devices
   - Each device sends and receives messages
   - Verify all messages are received by all devices

3. **Binary Protocol Edge Cases**
   - Max-length messages
   - Messages with Unicode characters
   - Messages requiring fragmentation
   - Messages with attachments

4. **Cryptographic Compatibility**
   - Private message encryption between different platforms
   - Channel encryption with the same password across platforms

### Performance Tests

| Category | Metrics | Target |
|----------|---------|--------|
| Battery | % drain per hour | <5% idle, <10% active |
| Bluetooth | Scan cycle accuracy | ±10% of target |
| Message | Throughput messages/sec | >20 msgs/sec |
| Memory | Peak RAM usage | <100MB |

#### Battery Testing

```dart
void main() {
  group('Battery Performance', () {
    test('Performance mode power consumption', () async {
      final initialBattery = await getBatteryLevel();
      
      // Run in performance mode for 1 hour
      await runTestScenario(
        duration: Duration(hours: 1),
        powerMode: PowerMode.performance,
      );
      
      final finalBattery = await getBatteryLevel();
      final drain = initialBattery - finalBattery;
      
      // Should match iOS/Android drain rates
      expect(drain, lessThan(10));
    });
    
    test('Ultra-low power mode extends battery life', () async {
      // Compare battery drain between performance and ultra-low power modes
      final performanceDrain = await measureBatteryDrain(
        PowerMode.performance,
        Duration(minutes: 30),
      );
      
      final ultraLowDrain = await measureBatteryDrain(
        PowerMode.ultraLowPower,
        Duration(minutes: 30),
      );
      
      // Should save significant battery
      expect(ultraLowDrain, lessThan(performanceDrain * 0.5));
    });
  });
}
```

## Testing Environments

### Device Testing Matrix

| Platform | Minimum Version | Target Version | Devices |
|----------|----------------|----------------|---------|
| iOS | iOS 14.0 | iOS 16.0+ | iPhone 11+, iPad Pro |
| Android | API 26 (8.0) | API 34 (14) | Pixel 5+, Samsung S21+ |
| Flutter iOS | iOS 14.0 | iOS 16.0+ | iPhone 12+, iPad Air |
| Flutter Android | API 26 (8.0) | API 34 (14) | Pixel 6+, Samsung S22+ |

### Test Automation

- **CI/CD Pipeline**: GitHub Actions running tests on each PR
- **Device Farm**: AWS Device Farm for testing across multiple real devices
- **Local Development**: Mock BLE environment for rapid testing

## Binary Protocol Validation

The binary protocol implementation must pass byte-for-byte compatibility tests with reference implementations:

1. **Reference Data Collection**:
   - Capture raw BLE packets from iOS and Android implementations
   - Document format in binary_protocol_reference.md

2. **Verification Tests**:
   - Ensure Flutter implementation produces identical byte patterns
   - Compare encrypted message format
   - Test header format, message types, and fragmentation

3. **Integration Validation**:
   - Live testing with iOS and Android devices
   - Wireshark BLE packet capture and analysis

## Test Data Management

- **Reference Messages**: Standard test message corpus 
- **Test Keys**: Deterministic key generation for reproducible encryption tests
- **Mesh Simulation**: Simulated mesh network topologies

## Reporting

- **Test Coverage Reports**: Coverage dashboard for unit and integration tests
- **Compatibility Matrix**: Cross-platform test results
- **Performance Benchmarks**: Battery usage and network performance data

## Continuous Testing

1. **Pre-commit**: Run unit tests and linting
2. **PR Builds**: Run unit and integration tests
3. **Nightly**: Run full test suite including performance tests
4. **Release Candidates**: Manual compatibility testing on physical devices

## Special Testing Considerations

### Bluetooth Testing Challenges

- **Proximity Requirements**: Tests require physical device proximity
- **Interference**: Environmental factors affecting signal strength
- **Hardware Differences**: BLE hardware variations across devices

### Mitigation Strategies

1. **BLE Simulation**: MockBluetooth class for basic unit testing
2. **Instrumented Testing**: Physical device testing in controlled environments
3. **Long-Running Tests**: Extended testing to capture intermittent issues

## Test Ownership

- **Protocol Tests**: Core library team
- **Bluetooth Tests**: Platform integration team
- **UI Tests**: Frontend team
- **Performance Tests**: Performance optimization team

This testing strategy ensures BitChat Flutter maintains perfect compatibility with existing iOS and Android implementations while delivering a high-quality, reliable user experience across all supported platforms.
