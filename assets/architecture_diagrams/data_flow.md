# BitChat Flutter - Data Flow

```mermaid
flowchart TD
    subgraph "User Input"
        USER_MSG[User Types Message]
        USER_JOIN[User Joins Channel]
        USER_DISC[User Starts Discovery]
    end
    
    subgraph "UI Layer"
        CHAT_UI[Chat Interface]
        CHAN_UI[Channel Interface]
        PEER_UI[Peer Interface]
    end
    
    subgraph "State Management"
        CHAT_STATE[Chat State]
        CHAN_STATE[Channel State]
        PEER_STATE[Peer State]
    end
    
    subgraph "Business Logic"
        MSG_PROC[Message Processing]
        CHAN_MGMT[Channel Management]
        PEER_MGMT[Peer Management]
        ENCRYPT[Encryption/Decryption]
    end
    
    subgraph "Network Layer"
        BLE_TX[BLE Transmission]
        BLE_RX[BLE Reception]
        MESH_ROUTE[Mesh Routing]
    end
    
    subgraph "Storage Layer"
        MSG_STORE[Message Storage]
        CHAN_STORE[Channel Storage]
        PEER_STORE[Peer Storage]
        KEY_STORE[Key Storage]
    end
    
    subgraph "External Events"
        INCOMING_MSG[Incoming Message]
        PEER_FOUND[Peer Discovered]
        CONN_LOST[Connection Lost]
    end
    
    %% User Input Flow
    USER_MSG --> CHAT_UI
    USER_JOIN --> CHAN_UI
    USER_DISC --> PEER_UI
    
    %% UI to State Flow
    CHAT_UI --> CHAT_STATE
    CHAN_UI --> CHAN_STATE
    PEER_UI --> PEER_STATE
    
    %% State to Business Logic Flow
    CHAT_STATE --> MSG_PROC
    CHAN_STATE --> CHAN_MGMT
    PEER_STATE --> PEER_MGMT
    
    %% Message Processing Flow
    MSG_PROC --> ENCRYPT
    ENCRYPT --> BLE_TX
    BLE_TX --> MESH_ROUTE
    MSG_PROC --> MSG_STORE
    
    %% Channel Management Flow
    CHAN_MGMT --> CHAN_STORE
    CHAN_MGMT --> BLE_TX
    
    %% Peer Management Flow
    PEER_MGMT --> PEER_STORE
    PEER_MGMT --> BLE_TX
    
    %% Incoming Data Flow
    BLE_RX --> MESH_ROUTE
    MESH_ROUTE --> INCOMING_MSG
    INCOMING_MSG --> ENCRYPT
    ENCRYPT --> MSG_PROC
    
    %% Peer Discovery Flow
    BLE_RX --> PEER_FOUND
    PEER_FOUND --> PEER_MGMT
    
    %% Connection Management Flow
    BLE_RX --> CONN_LOST
    CONN_LOST --> PEER_MGMT
    
    %% Storage to State Flow (Data Loading)
    MSG_STORE -.-> CHAT_STATE
    CHAN_STORE -.-> CHAN_STATE
    PEER_STORE -.-> PEER_STATE
    KEY_STORE -.-> ENCRYPT
    
    %% State to UI Flow (Updates)
    CHAT_STATE -.-> CHAT_UI
    CHAN_STATE -.-> CHAN_UI
    PEER_STATE -.-> PEER_UI
    
    %% Key Management Flow
    ENCRYPT --> KEY_STORE
    KEY_STORE --> ENCRYPT
    
    classDef input fill:#ffebee
    classDef ui fill:#e1f5fe
    classDef state fill:#f3e5f5
    classDef logic fill:#e8f5e8
    classDef network fill:#fff3e0
    classDef storage fill:#fce4ec
    classDef external fill:#f1f8e9
    
    class USER_MSG,USER_JOIN,USER_DISC input
    class CHAT_UI,CHAN_UI,PEER_UI ui
    class CHAT_STATE,CHAN_STATE,PEER_STATE state
    class MSG_PROC,CHAN_MGMT,PEER_MGMT,ENCRYPT logic
    class BLE_TX,BLE_RX,MESH_ROUTE network
    class MSG_STORE,CHAN_STORE,PEER_STORE,KEY_STORE storage
    class INCOMING_MSG,PEER_FOUND,CONN_LOST external
```

## Data Flow Patterns

### Primary Data Flows

#### 1. Outgoing Message Flow
```
User Input → UI → State → Business Logic → Encryption → Network → Mesh Routing
                                      ↓
                                   Storage
```

#### 2. Incoming Message Flow
```
Network Reception → Mesh Routing → Decryption → Business Logic → State → UI
                                                      ↓
                                                  Storage
```

#### 3. Peer Discovery Flow
```
User Action → UI → State → Peer Management → Network Scanning
                                    ↓
                                 Storage
                                    ↓
                            State Update → UI
```

### Data Types and Transformations

#### Message Data Flow
1. **User Input**: Plain text message
2. **UI Layer**: Formatted message with metadata
3. **State Layer**: Message object with channel context
4. **Business Logic**: Validated message with routing info
5. **Encryption**: Encrypted binary payload
6. **Network**: BLE packet with mesh headers
7. **Storage**: Persisted message record

#### Channel Data Flow
1. **User Input**: Channel name/password
2. **UI Layer**: Channel join request
3. **State Layer**: Channel state update
4. **Business Logic**: Channel validation and key derivation
5. **Network**: Channel announcement packet
6. **Storage**: Channel membership record

#### Peer Data Flow
1. **Network Input**: BLE advertisement
2. **Business Logic**: Peer validation and capability detection
3. **State Layer**: Peer list update
4. **Storage**: Peer cache record
5. **UI Layer**: Peer list display

### State Synchronization

#### Reactive Updates (Dashed Lines)
- **Storage → State**: Data loading on app start
- **State → UI**: Reactive UI updates via Provider pattern
- **Network → State**: Real-time updates from mesh network

#### Bidirectional Flows
- **Encryption ↔ Key Storage**: Key generation, storage, and retrieval
- **State ↔ Storage**: Data persistence and loading
- **Business Logic ↔ Network**: Send/receive operations

### Error Handling Flows
- Network failures trigger retry mechanisms
- Encryption failures trigger key renegotiation
- Storage failures trigger cache rebuilding
- UI errors trigger user notifications

### Performance Optimizations
- **Lazy Loading**: UI components load data on demand
- **Caching**: Frequently accessed data cached in memory
- **Batching**: Multiple operations batched for efficiency
- **Background Processing**: Heavy operations run off main thread