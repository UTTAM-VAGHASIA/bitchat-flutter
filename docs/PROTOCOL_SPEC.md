# BitChat Protocol Specification

## Table of Contents
1. [Overview](#overview)
2. [Binary Packet Format](#binary-packet-format)
3. [Header Structure](#header-structure)
4. [Message Types](#message-types)
5. [TTL-Based Routing](#ttl-based-routing)
6. [Packet Fragmentation](#packet-fragmentation)
7. [Bluetooth LE Implementation](#bluetooth-le-implementation)
8. [Protocol Constants](#protocol-constants)
9. [Error Handling](#error-handling)
10. [Compatibility Requirements](#compatibility-requirements)

## Overview

BitChat uses a custom binary protocol designed for efficient communication over Bluetooth Low Energy (BLE) mesh networks. The protocol supports:

- **Mesh Routing**: TTL-based multi-hop message delivery (max 7 hops)
- **Message Types**: Channel messages, private messages, discovery, routing
- **Fragmentation**: Large message splitting for BLE MTU constraints
- **Compression**: LZ4 compression for messages >100 bytes
- **Encryption**: End-to-end encryption with forward secrecy
- **Store & Forward**: Message caching for offline peers

The protocol maintains strict binary compatibility across iOS, Android, and Flutter implementations.

## Binary Packet Format

All BitChat packets follow this structure:

```
+------------------+------------------+------------------+
|     Header       |     Payload      |    Optional      |
|    (13 bytes)    |   (Variable)     |   Signature      |
+------------------+------------------+------------------+
```

### Total Packet Size Limits
- **Maximum BLE MTU**: 512 bytes
- **Maximum Payload**: 499 bytes (512 - 13 header)
- **Fragmented Payload**: 491 bytes (499 - 8 fragment header)

## Header Structure

The 13-byte header contains essential routing and message information:

```
Byte Offset | Length | Field Name        | Description
------------|--------|-------------------|---------------------------
0           | 1      | Version           | Protocol version (0x01)
1           | 1      | Message Type      | See Message Types section
2           | 1      | TTL               | Time-to-live (max 7)
3           | 1      | Flags             | Control flags
4           | 4      | Source ID         | Originating device ID
8           | 4      | Destination ID    | Target device ID (0x00000000 for broadcast)
12          | 1      | Payload Length    | Length of payload data
```

### Version Field (Byte 0)
- **Current Version**: `0x01`
- **Future Compatibility**: Versions 0x02-0xFF reserved

### Message Type Field (Byte 1)
See [Message Types](#message-types) section for complete list.

### TTL Field (Byte 2)
- **Range**: 0-7 (3 bits used)
- **Decrement**: Reduced by 1 at each hop
- **Drop Rule**: Packets with TTL=0 are discarded

### Flags Field (Byte 3)
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

### Source/Destination ID Fields (Bytes 4-11)
- **Format**: 32-bit unsigned integer (big-endian)
- **Generation**: First 4 bytes of device's Ed25519 public key
- **Broadcast**: Destination `0x00000000` for channel messages

### Payload Length Field (Byte 12)
- **Range**: 0-255 bytes
- **Actual Length**: May be larger for fragmented messages

## Message Types

### Core Message Types

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

### Discovery Message (0x01)
```
+----------+----------+----------+----------+
| Version  | Channels | Services | Reserved |
|  (1)     |   (1)    |   (1)    |   (1)    |
+----------+----------+----------+----------+
| Public Key (32 bytes)                     |
+-------------------------------------------+
| Device Name (Variable, NULL-terminated)   |
+-------------------------------------------+
```

### Channel Message (0x02)
```
+----------+----------+----------+----------+
| Chan ID  | Msg ID   | Timestamp (4 bytes) |
|  (2)     |   (2)    |                     |
+----------+----------+---------------------+
| Sender Name (Variable, NULL-terminated)   |
+-------------------------------------------+
| Message Content (Variable)                |
+-------------------------------------------+
```

### Private Message (0x03)
```
+----------+----------+----------+----------+
| Msg ID   | Timestamp (4 bytes) | Reserved |
|  (2)     |                     |   (2)    |
+----------+---------------------+----------+
| Encrypted Content (Variable)              |
+-------------------------------------------+
```

### Routing Message (0x04)
```
+----------+----------+----------+----------+
| Seq Num  | Entries  | Reserved | Reserved |
|  (2)     |   (1)    |   (1)    |   (1)    |
+----------+----------+----------+----------+
| Route Entry 1 (8 bytes)                   |
+-------------------------------------------+
| Route Entry 2 (8 bytes)                   |
+-------------------------------------------+
| ... (Additional entries)                  |
+-------------------------------------------+
```

#### Route Entry Format
```
+----------+----------+----------+----------+
| Dest ID  | Next Hop | Metric   | TTL      |
|  (4)     |   (4)    |   (1)    |   (1)    |
+----------+----------+----------+----------+
```

### Fragment Message (0x06)
```
+----------+----------+----------+----------+
| Frag ID  | Seq Num  | Total    | Offset   |
|  (2)     |   (2)    |   (2)    |   (2)    |
+----------+----------+----------+----------+
| Fragment Data (Variable)                  |
+-------------------------------------------+
```

## TTL-Based Routing

### Routing Algorithm
1. **Initialization**: Set TTL to 7 for new messages
2. **Forwarding**: Decrement TTL by 1 before forwarding
3. **Discard**: Drop packets with TTL=0
4. **Loop Prevention**: Track message IDs to prevent loops

### Routing Table
Each device maintains a routing table with:
- **Destination ID**: Target device
- **Next Hop**: Immediate neighbor to reach destination
- **Metric**: Path cost (hop count)
- **Age**: Time since last update
- **TTL**: Time to live for route entry

### Route Discovery
```
Source -> Neighbor1 (TTL=7) -> Neighbor2 (TTL=6) -> ... -> Destination
```

### Store & Forward
- **Buffer Size**: 64 messages per channel
- **Retention**: 24 hours maximum
- **Delivery**: Attempt delivery when peer comes online

## Packet Fragmentation

### Fragmentation Threshold
- **Trigger**: Messages >491 bytes
- **MTU Consideration**: BLE MTU - header - fragment header

### Fragment Header (8 bytes)
```
Byte Offset | Length | Field Name | Description
------------|--------|------------|---------------------------
0           | 2      | Fragment ID| Unique fragment sequence
2           | 2      | Sequence   | Fragment number (0-based)
4           | 2      | Total      | Total fragments count
6           | 2      | Offset     | Byte offset in original message
```

### Fragmentation Process
1. **Split**: Divide message into 491-byte chunks
2. **Number**: Assign sequential fragment IDs
3. **Send**: Transmit fragments with delays
4. **Reassemble**: Reconstruct at destination

### Fragment Reassembly
```
Fragment Buffer:
+----------+----------+----------+----------+
| Frag ID  | Received | Timeout  | Data     |
|  (2)     | Bitmap   | (4)      | Buffer   |
+----------+----------+----------+----------+
```

## Bluetooth LE Implementation

### Service UUID
```
Primary Service: F47B5E2D-4A9E-4C5A-9B3F-8E1D2C3A4B5C
```

### Characteristics
```
TX Characteristic: A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D
RX Characteristic: A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D
```

### Connection Parameters
- **Connection Interval**: 20ms - 40ms
- **Supervision Timeout**: 4000ms
- **Slave Latency**: 0
- **MTU**: 512 bytes (negotiated)

### Dual Role Operation
Each device operates as both:
- **Central**: Scans and connects to peripherals
- **Peripheral**: Advertises and accepts connections

### Advertisement Data
```
+----------+----------+----------+----------+
| Flags    | Service  | Local    | Tx Power |
|  (3)     | UUID(17) | Name(9)  |   (3)    |
+----------+----------+----------+----------+
```

## Protocol Constants

### Timing Constants
```dart
const int DISCOVERY_INTERVAL = 30000; // 30 seconds
const int ROUTING_UPDATE_INTERVAL = 60000; // 1 minute
const int MESSAGE_TIMEOUT = 10000; // 10 seconds
const int FRAGMENT_TIMEOUT = 30000; // 30 seconds
const int CONNECTION_TIMEOUT = 5000; // 5 seconds
const int RETRY_DELAY = 1000; // 1 second
```

### Protocol Limits
```dart
const int MAX_TTL = 7;
const int MAX_PAYLOAD_SIZE = 499;
const int MAX_FRAGMENT_SIZE = 491;
const int MAX_FRAGMENTS = 64;
const int MAX_CHANNELS = 256;
const int MAX_PEERS = 1024;
const int MAX_ROUTE_ENTRIES = 256;
```

### Message IDs
```dart
const int MSG_DISCOVERY = 0x01;
const int MSG_CHANNEL = 0x02;
const int MSG_PRIVATE = 0x03;
const int MSG_ROUTING = 0x04;
const int MSG_ACK = 0x05;
const int MSG_FRAGMENT = 0x06;
const int MSG_PING = 0x07;
const int MSG_PONG = 0x08;
```

### Flag Masks
```dart
const int FLAG_ACK = 0x80;
const int FLAG_FRAG = 0x40;
const int FLAG_COMP = 0x20;
const int FLAG_ENC = 0x10;
const int FLAG_SIGN = 0x08;
```

## Error Handling

### Error Types
1. **Malformed Packet**: Invalid header or payload
2. **Unknown Message Type**: Unsupported message type
3. **TTL Exceeded**: Message TTL reached zero
4. **Fragmentation Error**: Fragment reassembly failed
5. **Encryption Error**: Decryption failed
6. **Routing Error**: No route to destination

### Error Responses
- **Silent Drop**: For most protocol errors
- **Error Message**: For critical application errors
- **Retry Logic**: With exponential backoff

### Packet Validation
```dart
bool validatePacket(List<int> packet) {
  if (packet.length < 13) return false;
  if (packet[0] != 0x01) return false; // Version check
  if (packet[2] > 7) return false; // TTL check
  if (packet[12] != packet.length - 13) return false; // Length check
  return true;
}
```

## Compatibility Requirements

### Cross-Platform Compatibility
- **Byte Order**: Big-endian for multi-byte fields
- **String Encoding**: UTF-8 for all text
- **Timestamp Format**: Unix timestamp (32-bit)
- **Compression**: LZ4 algorithm
- **Encryption**: Standard implementations only

### Version Compatibility
- **Forward Compatibility**: Ignore unknown flags/fields
- **Backward Compatibility**: Support version 0x01
- **Graceful Degradation**: Fallback for unsupported features

### Implementation Notes
1. **Atomic Operations**: Use proper synchronization
2. **Memory Management**: Clean up buffers promptly
3. **Error Logging**: Log all protocol violations
4. **Performance**: Optimize for mobile constraints
5. **Testing**: Validate against iOS/Android implementations

## Protocol Flow Examples

### Channel Message Flow
```
1. User types message in channel
2. Encrypt message with channel key
3. Create MSG_CHANNEL packet
4. Add to routing queue
5. Broadcast to all connected peers
6. Peers forward based on TTL
7. Destination peers decrypt and display
```

### Private Message Flow
```
1. User sends private message
2. Encrypt with recipient's public key
3. Create MSG_PRIVATE packet
4. Route directly to recipient
5. Recipient decrypts and displays
6. Send ACK if requested
```

### Discovery Flow
```
1. Device starts advertising
2. Broadcasts MSG_DISCOVERY periodically
3. Peers respond with their discovery
4. Update peer list and routing table
5. Establish secure channels
```

This specification ensures complete protocol compatibility across all BitChat implementations while providing the necessary detail for robust Flutter development.