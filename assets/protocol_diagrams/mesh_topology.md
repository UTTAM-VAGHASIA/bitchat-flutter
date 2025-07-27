# BitChat Protocol - Mesh Network Topology

```mermaid
graph TB
    subgraph "Mesh Network Topology"
        A[Alice<br/>Node A]
        B[Bob<br/>Node B]
        C[Carol<br/>Node C]
        D[Dave<br/>Node D]
        E[Eve<br/>Node E]
        F[Frank<br/>Node F]
        G[Grace<br/>Node G]
        H[Henry<br/>Node H]
    end
    
    subgraph "Connection Types"
        DIRECT[Direct BLE Connection]
        MULTI_HOP[Multi-hop Route]
        BROADCAST[Broadcast Path]
    end
    
    subgraph "Network Partitions"
        PARTITION_1[Partition 1<br/>A, B, C, D]
        PARTITION_2[Partition 2<br/>E, F, G, H]
        BRIDGE[Bridge Node<br/>Connects Partitions]
    end
    
    %% Direct BLE connections (solid lines)
    A --- B
    A --- C
    B --- C
    B --- D
    C --- D
    D --- E
    E --- F
    E --- G
    F --- G
    F --- H
    G --- H
    
    %% Multi-hop routes (dashed lines)
    A -.-> D
    A -.-> E
    B -.-> F
    C -.-> G
    
    %% Broadcast propagation (dotted lines)
    A -.-> B
    A -.-> C
    B -.-> D
    C -.-> D
    
    classDef node fill:#e1f5fe
    classDef connection fill:#f3e5f5
    classDef partition fill:#e8f5e8
    
    class A,B,C,D,E,F,G,H node
    class DIRECT,MULTI_HOP,BROADCAST connection
    class PARTITION_1,PARTITION_2,BRIDGE partition
```

## Mesh Network Architecture

### Network Topology Patterns

#### 1. Star Topology (Limited Range)
```mermaid
graph TB
    CENTER[Central Node]
    N1[Node 1] --- CENTER
    N2[Node 2] --- CENTER
    N3[Node 3] --- CENTER
    N4[Node 4] --- CENTER
    N5[Node 5] --- CENTER
    
    classDef center fill:#ff9800
    classDef node fill:#e1f5fe
    class CENTER center
    class N1,N2,N3,N4,N5 node
```

#### 2. Mesh Topology (Optimal)
```mermaid
graph TB
    A[Node A] --- B[Node B]
    A --- C[Node C]
    B --- C
    B --- D[Node D]
    C --- D
    C --- E[Node E]
    D --- E
    
    classDef node fill:#4caf50
    class A,B,C,D,E node
```

#### 3. Linear Topology (Extended Range)
```mermaid
graph LR
    A[Node A] --- B[Node B] --- C[Node C] --- D[Node D] --- E[Node E]
    
    classDef node fill:#2196f3
    class A,B,C,D,E node
```

### Routing Algorithms

#### Distance Vector Routing
```mermaid
graph TB
    subgraph "Routing Table Updates"
        A[Node A<br/>Distance: 0]
        B[Node B<br/>Distance: 1]
        C[Node C<br/>Distance: 2]
        D[Node D<br/>Distance: 3]
    end
    
    A --> B
    B --> C
    C --> D
    
    A -.-> C
    A -.-> D
    B -.-> D
    
    classDef direct fill:#4caf50
    classDef indirect fill:#ff9800
    
    class A,B direct
    class C,D indirect
```

#### Shortest Path Selection
```mermaid
graph TB
    SOURCE[Source Node]
    DEST[Destination Node]
    
    subgraph "Route Options"
        PATH1[Path 1: 2 hops<br/>Quality: 85%]
        PATH2[Path 2: 3 hops<br/>Quality: 95%]
        PATH3[Path 3: 4 hops<br/>Quality: 70%]
    end
    
    SOURCE --> PATH1
    SOURCE --> PATH2
    SOURCE --> PATH3
    
    PATH1 --> DEST
    PATH2 --> DEST
    PATH3 --> DEST
    
    classDef best fill:#4caf50
    classDef good fill:#ff9800
    classDef poor fill:#f44336
    
    class PATH2 best
    class PATH1 good
    class PATH3 poor
```

### Network Partitioning

#### Partition Detection
```mermaid
graph TB
    subgraph "Partition A"
        A1[Node A1]
        A2[Node A2]
        A3[Node A3]
        A1 --- A2
        A2 --- A3
        A3 --- A1
    end
    
    subgraph "Partition B"
        B1[Node B1]
        B2[Node B2]
        B3[Node B3]
        B1 --- B2
        B2 --- B3
        B3 --- B1
    end
    
    subgraph "Bridge Node"
        BRIDGE[Mobile Node<br/>Connects Partitions]
    end
    
    BRIDGE -.-> A2
    BRIDGE -.-> B2
    
    classDef partition_a fill:#e3f2fd
    classDef partition_b fill:#f3e5f5
    classDef bridge fill:#fff3e0
    
    class A1,A2,A3 partition_a
    class B1,B2,B3 partition_b
    class BRIDGE bridge
```

#### Store and Forward
```mermaid
sequenceDiagram
    participant S as Sender (Partition A)
    participant B as Bridge Node
    participant R as Recipient (Partition B)
    
    Note over S,R: Partitions are disconnected
    
    S->>B: Send message for offline recipient
    B->>B: Store message in cache
    
    Note over B,R: Bridge node moves to Partition B
    
    B->>R: Deliver cached message
    R->>B: Send acknowledgment
    B->>B: Clear cached message
    
    Note over B,S: Bridge node returns to Partition A
    
    B->>S: Forward acknowledgment
```

### Network Discovery

#### Peer Discovery Process
```mermaid
stateDiagram-v2
    [*] --> Scanning
    Scanning --> Advertising : Start advertising
    Advertising --> Connected : Peer found
    Connected --> Mesh_Active : Join mesh
    Mesh_Active --> Scanning : Connection lost
    
    state Scanning {
        [*] --> Active_Scan
        Active_Scan --> Passive_Listen
        Passive_Listen --> Active_Scan
    }
    
    state Connected {
        [*] --> Handshake
        Handshake --> Key_Exchange
        Key_Exchange --> Authenticated
    }
```

#### Network Maintenance
```mermaid
graph TB
    subgraph "Periodic Tasks"
        HEARTBEAT[Heartbeat Messages<br/>Every 30 seconds]
        DISCOVERY[Peer Discovery<br/>Every 60 seconds]
        CLEANUP[Dead Peer Cleanup<br/>Every 120 seconds]
        ROUTE_UPDATE[Route Table Update<br/>Every 90 seconds]
    end
    
    subgraph "Event-Driven Tasks"
        CONN_LOST[Connection Lost]
        NEW_PEER[New Peer Found]
        ROUTE_FAIL[Route Failure]
        PARTITION[Partition Detected]
    end
    
    HEARTBEAT --> CONN_LOST
    DISCOVERY --> NEW_PEER
    CLEANUP --> ROUTE_UPDATE
    ROUTE_FAIL --> ROUTE_UPDATE
    PARTITION --> DISCOVERY
    
    classDef periodic fill:#e8f5e8
    classDef event fill:#fff3e0
    
    class HEARTBEAT,DISCOVERY,CLEANUP,ROUTE_UPDATE periodic
    class CONN_LOST,NEW_PEER,ROUTE_FAIL,PARTITION event
```

### Quality of Service

#### Connection Quality Metrics
```mermaid
graph TB
    subgraph "Quality Factors"
        RSSI[Signal Strength<br/>RSSI: -40 to -100 dBm]
        LATENCY[Round Trip Time<br/>10ms to 1000ms]
        RELIABILITY[Packet Loss Rate<br/>0% to 50%]
        STABILITY[Connection Stability<br/>Uptime percentage]
    end
    
    subgraph "Quality Score"
        EXCELLENT[90-100: Excellent]
        GOOD[70-89: Good]
        FAIR[50-69: Fair]
        POOR[0-49: Poor]
    end
    
    RSSI --> EXCELLENT
    LATENCY --> GOOD
    RELIABILITY --> FAIR
    STABILITY --> POOR
    
    classDef excellent fill:#4caf50
    classDef good fill:#8bc34a
    classDef fair fill:#ff9800
    classDef poor fill:#f44336
    
    class EXCELLENT excellent
    class GOOD good
    class FAIR fair
    class POOR poor
```

#### Adaptive Routing
```mermaid
graph TB
    subgraph "Route Selection Criteria"
        HOPS[Hop Count<br/>Weight: 30%]
        QUALITY[Link Quality<br/>Weight: 40%]
        LOAD[Network Load<br/>Weight: 20%]
        HISTORY[Historical Performance<br/>Weight: 10%]
    end
    
    subgraph "Route Decision"
        CALCULATE[Calculate Route Score]
        SELECT[Select Best Route]
        FALLBACK[Fallback Route]
    end
    
    HOPS --> CALCULATE
    QUALITY --> CALCULATE
    LOAD --> CALCULATE
    HISTORY --> CALCULATE
    
    CALCULATE --> SELECT
    SELECT --> FALLBACK
    
    classDef criteria fill:#e1f5fe
    classDef decision fill:#f3e5f5
    
    class HOPS,QUALITY,LOAD,HISTORY criteria
    class CALCULATE,SELECT,FALLBACK decision
```

### Security Considerations

#### Network-Level Security
- **Node Authentication**: Ed25519 signatures for node identity
- **Route Verification**: Cryptographic proof of route integrity
- **Replay Protection**: Sequence numbers and timestamps
- **Sybil Attack Prevention**: Proof-of-work for node registration

#### Traffic Analysis Resistance
- **Message Padding**: Fixed-size packets to hide content length
- **Dummy Traffic**: Random messages to obscure communication patterns
- **Route Randomization**: Multiple paths for the same destination
- **Timing Obfuscation**: Random delays to hide traffic patterns

This mesh topology design ensures robust, scalable, and secure peer-to-peer communication while adapting to dynamic network conditions and maintaining optimal performance.