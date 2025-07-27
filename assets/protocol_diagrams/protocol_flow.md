# BitChat Protocol - Message Flow Sequences

```mermaid
sequenceDiagram
    participant A as Alice (Sender)
    participant B as Bob (Intermediate)
    participant C as Carol (Recipient)
    participant D as Dave (Channel Member)
    
    Note over A,D: Direct Message Flow
    
    A->>A: Generate ephemeral key pair
    A->>A: Encrypt message with recipient's public key
    A->>B: Send encrypted message packet
    B->>B: Check routing table
    B->>C: Forward message packet
    C->>C: Decrypt message with private key
    C->>A: Send delivery acknowledgment
    
    Note over A,D: Channel Message Flow
    
    A->>A: Derive channel key from password
    A->>A: Encrypt message with channel key
    A->>B: Broadcast channel message
    B->>C: Forward to channel members
    B->>D: Forward to channel members
    C->>C: Decrypt with channel key
    D->>D: Decrypt with channel key
    
    Note over A,D: Peer Discovery Flow
    
    A->>A: Generate discovery announcement
    A->>B: Broadcast peer announcement
    B->>B: Update peer table
    B->>C: Forward announcement
    B->>D: Forward announcement
    C->>C: Update peer table
    D->>D: Update peer table
    C->>A: Send peer response
    D->>A: Send peer response
    
    Note over A,D: Channel Join Flow
    
    A->>A: Derive channel key from password
    A->>B: Send channel join request
    B->>C: Forward join request
    B->>D: Forward join request
    C->>C: Validate channel password
    D->>D: Validate channel password
    C->>A: Send join acknowledgment
    D->>A: Send join acknowledgment
    A->>A: Add to channel member list
    
    Note over A,D: Key Exchange Flow
    
    A->>A: Generate X25519 key pair
    A->>C: Send public key + identity
    C->>C: Generate X25519 key pair
    C->>A: Send public key + identity
    A->>A: Compute shared secret
    C->>C: Compute shared secret
    A->>A: Derive AES-256-GCM key
    C->>C: Derive AES-256-GCM key
    
    Note over A,D: Message Acknowledgment Flow
    
    A->>B: Send message with sequence number
    B->>C: Forward message
    C->>C: Process message
    C->>B: Send ACK with sequence number
    B->>A: Forward ACK
    A->>A: Mark message as delivered
    
    Note over A,D: Store & Forward Flow
    
    A->>B: Send message for offline peer
    B->>B: Store message in cache
    Note over C: Carol comes online
    C->>B: Send presence announcement
    B->>C: Deliver cached messages
    C->>B: Send delivery confirmation
    B->>B: Clear cached messages
```

## Protocol Flow Details

### Message Types and Flows

#### 1. Direct Message (End-to-End Encrypted)
```
Sender → [Encrypt with recipient's public key] → Mesh Network → Recipient
```
- Uses X25519 key exchange for session keys
- AES-256-GCM for message encryption
- Ed25519 signatures for authentication

#### 2. Channel Message (Group Encrypted)
```
Sender → [Encrypt with channel key] → Broadcast → All Channel Members
```
- Channel key derived from password using Argon2id
- Messages broadcast to all known channel members
- Forward secrecy through periodic key rotation

#### 3. Peer Discovery
```
Node → [Broadcast announcement] → Mesh Network → [Update peer tables]
```
- Periodic announcements with node capabilities
- Exponential backoff for announcement frequency
- Peer table maintenance with TTL

#### 4. Channel Management
```
User → [Join/Leave request] → Channel Members → [Update membership]
```
- Password-based channel access control
- Distributed membership management
- Channel moderation capabilities

### Protocol States

#### Connection States
- **DISCONNECTED**: No BLE connections
- **SCANNING**: Actively discovering peers
- **CONNECTED**: Established BLE connections
- **MESH_ACTIVE**: Participating in mesh network

#### Message States
- **PENDING**: Message queued for transmission
- **SENT**: Message transmitted to mesh
- **DELIVERED**: Delivery confirmation received
- **FAILED**: Transmission failed after retries

#### Channel States
- **NOT_JOINED**: Not a member of channel
- **JOINING**: Join request in progress
- **JOINED**: Active channel member
- **LEAVING**: Leave request in progress

### Error Handling

#### Network Errors
- Connection timeouts trigger peer discovery
- Failed transmissions use exponential backoff
- Mesh partitions handled through store-and-forward

#### Cryptographic Errors
- Key exchange failures trigger renegotiation
- Decryption failures logged and ignored
- Invalid signatures cause message rejection

#### Protocol Errors
- Malformed packets are discarded
- Version mismatches trigger compatibility mode
- Rate limiting prevents spam attacks

### Performance Optimizations

#### Message Batching
- Multiple small messages combined into single packet
- Reduces BLE overhead and improves throughput
- Configurable batch size and timeout

#### Routing Optimization
- Shortest path routing with loop prevention
- Peer quality metrics for route selection
- Adaptive routing based on network conditions

#### Caching Strategy
- Recent messages cached for duplicate detection
- Peer information cached with TTL
- Channel membership cached locally