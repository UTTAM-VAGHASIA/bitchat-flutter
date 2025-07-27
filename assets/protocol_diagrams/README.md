# Protocol Diagrams

This directory contains detailed protocol diagrams for the BitChat mesh networking protocol, illustrating message flows, packet structures, network topology, and cryptographic processes.

## Diagram Overview

### 1. Protocol Flow (`protocol_flow.md`)
**Purpose**: Sequence diagrams showing message flow patterns between peers in the BitChat mesh network.

**Key Flows Illustrated**:
- **Direct Message Flow**: End-to-end encrypted person-to-person messaging
- **Channel Message Flow**: Group messaging with channel-based encryption
- **Peer Discovery Flow**: Network discovery and peer announcement process
- **Channel Join Flow**: Process for joining password-protected channels
- **Key Exchange Flow**: X25519 ECDH key establishment between peers
- **Message Acknowledgment Flow**: Delivery confirmation and reliability
- **Store & Forward Flow**: Offline message handling and delivery

**Use Cases**:
- Understanding protocol interactions
- Debugging message delivery issues
- Implementing new message types
- Protocol compliance verification

### 2. Packet Structure (`packet_structure.md`)
**Purpose**: Detailed breakdown of binary packet formats used in the BitChat protocol.

**Key Elements**:
- **BLE Advertisement Packet**: Bluetooth Low Energy advertisement structure
- **BitChat Protocol Header**: Core protocol identification and metadata
- **Routing Header**: Mesh network routing information
- **Encryption Header**: Cryptographic metadata (nonces, auth tags)
- **Message Payload**: Encrypted message content structure
- **Message Types**: Complete enumeration of supported message types
- **Flag Definitions**: Bit-field flags for message properties

**Use Cases**:
- Protocol implementation reference
- Packet parsing and generation
- Network debugging and analysis
- Interoperability testing with iOS/Android

### 3. Mesh Topology (`mesh_topology.md`)
**Purpose**: Network topology patterns, routing algorithms, and mesh network management.

**Key Elements**:
- **Network Topology Patterns**: Star, mesh, and linear network configurations
- **Routing Algorithms**: Distance vector routing and shortest path selection
- **Network Partitioning**: Partition detection and bridge node handling
- **Store and Forward**: Offline message caching and delivery
- **Network Discovery**: Peer discovery and network maintenance processes
- **Quality of Service**: Connection quality metrics and adaptive routing
- **Security Considerations**: Network-level security and attack resistance

**Use Cases**:
- Understanding mesh network behavior
- Optimizing routing performance
- Handling network partitions
- Planning network topology

### 4. Encryption Flow (`encryption_flow.md`)
**Purpose**: Comprehensive cryptographic processes including key generation, exchange, and message encryption/decryption.

**Key Elements**:
- **Key Generation**: Random seed generation and key derivation
- **Key Exchange**: X25519 ECDH key agreement protocol
- **Key Derivation**: HKDF-based key derivation from shared secrets
- **Message Encryption**: AES-256-GCM encryption process
- **Digital Signatures**: Ed25519 signature generation and verification
- **Channel Encryption**: Argon2id-based channel key derivation
- **Forward Secrecy**: Session key rotation and secure deletion

**Use Cases**:
- Implementing cryptographic operations
- Security auditing and verification
- Understanding key management
- Debugging encryption issues

## Protocol Specifications

### BitChat Protocol Version
- **Current Version**: 1.0
- **Magic Number**: `0x42434854` ("BCHT" in ASCII)
- **Compatibility**: Maintains backward compatibility with iOS/Android implementations

### Cryptographic Standards
- **Key Exchange**: X25519 Elliptic Curve Diffie-Hellman
- **Encryption**: AES-256-GCM (Galois/Counter Mode)
- **Digital Signatures**: Ed25519 (Edwards-curve Digital Signature Algorithm)
- **Key Derivation**: HKDF-SHA256 (HMAC-based Key Derivation Function)
- **Password Hashing**: Argon2id for channel passwords

### Network Parameters
- **Maximum Packet Size**: 512 bytes (BLE GATT limitation)
- **Maximum Hop Count**: 15 hops
- **Default TTL**: 255 seconds
- **Connection Timeout**: 30 seconds
- **Scan Interval**: 30 seconds (configurable)

## Implementation Guidelines

### Protocol Compliance
When implementing the BitChat protocol:

1. **Strict Compatibility**: Maintain exact binary compatibility with iOS/Android
2. **Error Handling**: Implement robust error handling for malformed packets
3. **Security First**: Never compromise on cryptographic requirements
4. **Performance**: Optimize for battery life and bandwidth efficiency
5. **Extensibility**: Design for future protocol extensions

### Testing Requirements
- **Interoperability**: Test with iOS and Android implementations
- **Security**: Validate all cryptographic operations
- **Network**: Test various network topologies and conditions
- **Performance**: Measure battery usage and throughput
- **Reliability**: Test message delivery under adverse conditions

## Diagram Formats

All protocol diagrams use **Mermaid** syntax for:

- **Sequence Diagrams**: Message flow between participants
- **Graph Diagrams**: Network topology and relationships
- **Flowcharts**: Process flows and decision trees
- **State Diagrams**: Protocol state machines

## Security Considerations

### Threat Model
The protocol diagrams illustrate defenses against:

- **Passive Eavesdropping**: End-to-end encryption prevents message interception
- **Active Man-in-the-Middle**: Digital signatures prevent message tampering
- **Replay Attacks**: Nonces and sequence numbers prevent message replay
- **Network Analysis**: Traffic padding and timing obfuscation
- **Sybil Attacks**: Node authentication and proof-of-work requirements

### Privacy Features
- **No Persistent Identifiers**: Node IDs change between sessions
- **Forward Secrecy**: Past messages remain secure even if keys are compromised
- **Traffic Analysis Resistance**: Message padding and dummy traffic
- **Metadata Protection**: Minimal metadata exposure in packet headers

## Integration with Technical Documentation

These protocol diagrams are referenced in:

- **docs/PROTOCOL_SPEC.md**: Complete protocol specification with diagram references
- **docs/BLUETOOTH_IMPLEMENTATION.md**: BLE-specific implementation details
- **docs/ENCRYPTION_SPEC.md**: Cryptographic implementation requirements
- **docs/SECURITY_SPEC.md**: Security model and threat analysis
- **docs/ARCHITECTURE.md**: High-level protocol architecture

## Debugging and Analysis

### Network Analysis Tools
- **Wireshark**: BLE packet capture and analysis
- **nRF Connect**: Nordic BLE debugging tool
- **Custom Tools**: BitChat-specific protocol analyzers

### Common Issues
- **Packet Fragmentation**: Large messages split across BLE packets
- **Connection Drops**: BLE connection stability issues
- **Key Synchronization**: Encryption key mismatch between peers
- **Routing Loops**: Mesh routing algorithm failures
- **Battery Drain**: Excessive scanning or connection attempts

## Contributing

When adding new protocol diagrams:

1. **Follow Standards**: Use established Mermaid diagram types
2. **Document Thoroughly**: Include comprehensive explanations
3. **Maintain Consistency**: Use consistent terminology and styling
4. **Reference Specs**: Link to relevant protocol specifications
5. **Test Accuracy**: Verify diagrams match actual implementation

## Future Protocol Enhancements

Planned protocol improvements:

- **Protocol Version 2.0**: Enhanced routing algorithms
- **Quantum Resistance**: Post-quantum cryptographic algorithms
- **Improved Efficiency**: Reduced packet overhead and battery usage
- **Enhanced Privacy**: Additional metadata protection features
- **IoT Integration**: Support for IoT device mesh networking

## Compliance and Standards

The BitChat protocol follows these standards:

- **RFC 7748**: Elliptic Curves for Security (X25519)
- **RFC 8032**: Edwards-Curve Digital Signature Algorithm (Ed25519)
- **RFC 5869**: HMAC-based Extract-and-Expand Key Derivation Function
- **NIST SP 800-38D**: Galois/Counter Mode for AES
- **Bluetooth Core Specification**: BLE GATT and advertisement standards