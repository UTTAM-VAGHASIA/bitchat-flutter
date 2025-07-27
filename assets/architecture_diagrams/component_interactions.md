# BitChat Flutter - Component Interactions

```mermaid
graph TB
    subgraph "UI Components"
        CHAT_SCREEN[Chat Screen]
        CHANNEL_LIST[Channel List]
        SETTINGS[Settings Screen]
        PEER_DISC[Peer Discovery]
    end
    
    subgraph "State Management"
        CHAT_PROV[Chat Provider]
        CHANNEL_PROV[Channel Provider]
        MESH_PROV[Mesh Provider]
        SETTINGS_PROV[Settings Provider]
    end
    
    subgraph "Use Cases"
        SEND_MSG[Send Message]
        JOIN_CHAN[Join Channel]
        DISCOVER_PEERS[Discover Peers]
        MANAGE_KEYS[Manage Keys]
    end
    
    subgraph "Services"
        MESH_SERV[Mesh Service]
        CRYPTO_SERV[Crypto Service]
        STORAGE_SERV[Storage Service]
        BLE_SERV[BLE Service]
    end
    
    subgraph "Repositories"
        MSG_REPO[Message Repository]
        CHAN_REPO[Channel Repository]
        PEER_REPO[Peer Repository]
        KEY_REPO[Key Repository]
    end
    
    subgraph "Data Sources"
        LOCAL_DB[Local Database]
        BLE_ADAPTER[BLE Adapter]
        SECURE_STORE[Secure Storage]
    end
    
    %% UI to Provider connections
    CHAT_SCREEN --> CHAT_PROV
    CHANNEL_LIST --> CHANNEL_PROV
    SETTINGS --> SETTINGS_PROV
    PEER_DISC --> MESH_PROV
    
    %% Provider to Use Case connections
    CHAT_PROV --> SEND_MSG
    CHANNEL_PROV --> JOIN_CHAN
    MESH_PROV --> DISCOVER_PEERS
    SETTINGS_PROV --> MANAGE_KEYS
    
    %% Use Case to Service connections
    SEND_MSG --> MESH_SERV
    SEND_MSG --> CRYPTO_SERV
    JOIN_CHAN --> MESH_SERV
    JOIN_CHAN --> STORAGE_SERV
    DISCOVER_PEERS --> BLE_SERV
    MANAGE_KEYS --> CRYPTO_SERV
    
    %% Service to Repository connections
    MESH_SERV --> MSG_REPO
    MESH_SERV --> PEER_REPO
    CRYPTO_SERV --> KEY_REPO
    STORAGE_SERV --> CHAN_REPO
    BLE_SERV --> PEER_REPO
    
    %% Repository to Data Source connections
    MSG_REPO --> LOCAL_DB
    CHAN_REPO --> LOCAL_DB
    PEER_REPO --> BLE_ADAPTER
    KEY_REPO --> SECURE_STORE
    
    %% Cross-cutting interactions
    MESH_SERV --> CRYPTO_SERV
    BLE_SERV --> MESH_SERV
    CRYPTO_SERV --> STORAGE_SERV
    
    %% Notification flows (dashed lines)
    BLE_ADAPTER -.-> MESH_SERV
    MESH_SERV -.-> CHAT_PROV
    CRYPTO_SERV -.-> SETTINGS_PROV
    
    classDef ui fill:#e1f5fe
    classDef provider fill:#f3e5f5
    classDef usecase fill:#e8f5e8
    classDef service fill:#fff3e0
    classDef repository fill:#fce4ec
    classDef datasource fill:#f1f8e9
    
    class CHAT_SCREEN,CHANNEL_LIST,SETTINGS,PEER_DISC ui
    class CHAT_PROV,CHANNEL_PROV,MESH_PROV,SETTINGS_PROV provider
    class SEND_MSG,JOIN_CHAN,DISCOVER_PEERS,MANAGE_KEYS usecase
    class MESH_SERV,CRYPTO_SERV,STORAGE_SERV,BLE_SERV service
    class MSG_REPO,CHAN_REPO,PEER_REPO,KEY_REPO repository
    class LOCAL_DB,BLE_ADAPTER,SECURE_STORE datasource
```

## Component Interaction Patterns

### Request Flow (Solid Lines)
1. **UI Components** trigger actions through **State Providers**
2. **Providers** coordinate **Use Cases** to handle business logic
3. **Use Cases** orchestrate **Services** to perform operations
4. **Services** use **Repositories** to access data
5. **Repositories** interact with **Data Sources** for persistence/communication

### Notification Flow (Dashed Lines)
- **BLE Adapter** notifies **Mesh Service** of incoming data
- **Mesh Service** notifies **Chat Provider** of new messages
- **Crypto Service** notifies **Settings Provider** of key events

### Key Interactions

#### Message Sending Flow
1. User types message in **Chat Screen**
2. **Chat Provider** calls **Send Message** use case
3. Use case coordinates **Mesh Service** and **Crypto Service**
4. Message is encrypted and transmitted via **BLE Service**
5. Message is stored locally via **Message Repository**

#### Channel Joining Flow
1. User selects channel in **Channel List**
2. **Channel Provider** calls **Join Channel** use case
3. Use case uses **Mesh Service** to announce join
4. Channel data is persisted via **Storage Service**

#### Peer Discovery Flow
1. **Peer Discovery** screen triggers discovery
2. **Mesh Provider** calls **Discover Peers** use case
3. Use case activates **BLE Service** scanning
4. Discovered peers are cached via **Peer Repository**

### Design Patterns Used
- **Provider Pattern**: State management and UI updates
- **Repository Pattern**: Data access abstraction
- **Use Case Pattern**: Business logic encapsulation
- **Observer Pattern**: Event notifications and updates