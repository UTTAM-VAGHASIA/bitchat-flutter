# BitChat Flutter - System Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[UI Screens]
        NAV[Navigation]
        PROV[State Providers]
        THEME[Theming System]
    end
    
    subgraph "Application Layer"
        UC[Use Cases]
        SERV[Application Services]
        VALID[Validation]
    end
    
    subgraph "Domain Layer"
        ENT[Domain Entities]
        REPO_INT[Repository Interfaces]
        DOMAIN_SERV[Domain Services]
    end
    
    subgraph "Infrastructure Layer"
        REPO_IMPL[Repository Implementations]
        DATA_SRC[Data Sources]
        EXT_SERV[External Services]
    end
    
    subgraph "Platform Layer"
        BLE[Bluetooth LE]
        STORAGE[Local Storage]
        CRYPTO[Cryptography]
        PERMS[Permissions]
    end
    
    subgraph "Core Features"
        MESH[Mesh Networking]
        ENCRYPT[Encryption Engine]
        CHANNELS[Channel Management]
        MESSAGES[Message Processing]
    end
    
    %% Presentation Layer connections
    UI --> PROV
    UI --> NAV
    UI --> THEME
    PROV --> UC
    
    %% Application Layer connections
    UC --> DOMAIN_SERV
    UC --> REPO_INT
    SERV --> UC
    VALID --> ENT
    
    %% Domain Layer connections
    DOMAIN_SERV --> ENT
    REPO_INT --> ENT
    
    %% Infrastructure Layer connections
    REPO_IMPL --> REPO_INT
    REPO_IMPL --> DATA_SRC
    DATA_SRC --> EXT_SERV
    
    %% Platform Layer connections
    EXT_SERV --> BLE
    EXT_SERV --> STORAGE
    EXT_SERV --> CRYPTO
    EXT_SERV --> PERMS
    
    %% Core Features connections
    MESH --> BLE
    ENCRYPT --> CRYPTO
    CHANNELS --> STORAGE
    MESSAGES --> MESH
    MESSAGES --> ENCRYPT
    
    %% Cross-layer connections
    UC --> MESH
    UC --> ENCRYPT
    UC --> CHANNELS
    UC --> MESSAGES
    
    classDef presentation fill:#e1f5fe
    classDef application fill:#f3e5f5
    classDef domain fill:#e8f5e8
    classDef infrastructure fill:#fff3e0
    classDef platform fill:#fce4ec
    classDef features fill:#f1f8e9
    
    class UI,NAV,PROV,THEME presentation
    class UC,SERV,VALID application
    class ENT,REPO_INT,DOMAIN_SERV domain
    class REPO_IMPL,DATA_SRC,EXT_SERV infrastructure
    class BLE,STORAGE,CRYPTO,PERMS platform
    class MESH,ENCRYPT,CHANNELS,MESSAGES features
```

## Architecture Overview

This diagram shows the high-level system architecture of BitChat Flutter following Clean Architecture principles:

### Layers (Top to Bottom)
1. **Presentation Layer**: UI components, navigation, state management, and theming
2. **Application Layer**: Use cases, application services, and validation logic
3. **Domain Layer**: Core business entities, repository interfaces, and domain services
4. **Infrastructure Layer**: Repository implementations, data sources, and external service adapters
5. **Platform Layer**: Platform-specific implementations (Bluetooth, storage, crypto, permissions)

### Core Features (Cross-cutting)
- **Mesh Networking**: Bluetooth LE mesh network management
- **Encryption Engine**: End-to-end encryption and key management
- **Channel Management**: Channel creation, joining, and moderation
- **Message Processing**: Message routing, storage, and delivery

### Key Principles
- **Dependency Inversion**: Higher layers depend on abstractions, not implementations
- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Business logic is isolated from platform dependencies
- **Maintainability**: Clear boundaries between different aspects of the system