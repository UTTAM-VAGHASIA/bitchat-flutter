# Architecture Diagrams

This directory contains comprehensive architecture diagrams for the BitChat Flutter application, illustrating the system design, component relationships, and data flow patterns.

## Diagram Overview

### 1. System Architecture (`system_architecture.md`)
**Purpose**: High-level overview of the entire BitChat Flutter system architecture following Clean Architecture principles.

**Key Elements**:
- **Presentation Layer**: UI screens, navigation, state providers, and theming
- **Application Layer**: Use cases, application services, and validation logic
- **Domain Layer**: Core business entities, repository interfaces, and domain services
- **Infrastructure Layer**: Repository implementations, data sources, and external service adapters
- **Platform Layer**: Platform-specific implementations (Bluetooth, storage, crypto, permissions)
- **Core Features**: Cross-cutting concerns (mesh networking, encryption, channels, messages)

**Use Cases**:
- Understanding overall system structure
- Onboarding new developers
- Architecture reviews and planning
- Identifying layer dependencies and boundaries

### 2. Component Interactions (`component_interactions.md`)
**Purpose**: Detailed view of how Flutter components interact with each other through the application layers.

**Key Elements**:
- **UI Components**: Chat screens, channel lists, settings, peer discovery
- **State Management**: Provider-based state management with ChangeNotifier
- **Use Cases**: Business logic orchestration
- **Services**: Core application services (mesh, crypto, storage, BLE)
- **Repositories**: Data access layer abstractions
- **Data Sources**: Concrete data implementations

**Use Cases**:
- Understanding component relationships
- Debugging interaction flows
- Planning new feature integrations
- Optimizing performance bottlenecks

### 3. Data Flow (`data_flow.md`)
**Purpose**: Visualization of how data moves through the application from user input to storage and network transmission.

**Key Elements**:
- **User Input Flow**: From UI interactions to business logic
- **Network Data Flow**: Incoming and outgoing message processing
- **Storage Flow**: Data persistence and retrieval patterns
- **State Synchronization**: Reactive updates between layers
- **Error Handling**: Error propagation and recovery flows

**Use Cases**:
- Tracing data transformations
- Understanding message lifecycle
- Debugging data consistency issues
- Planning caching strategies

### 4. Flutter Architecture (`flutter_architecture.md`)
**Purpose**: Flutter-specific architectural patterns, widget trees, and platform integration details.

**Key Elements**:
- **Widget Architecture**: Widget tree structure and organization
- **State Management**: Provider pattern implementation details
- **Navigation**: GoRouter configuration and route management
- **Feature Modules**: Modular architecture for different app features
- **Platform Channels**: Native platform integration
- **Background Processing**: Isolates and background task management

**Use Cases**:
- Flutter-specific implementation guidance
- Understanding widget hierarchies
- Platform integration planning
- Performance optimization strategies

## Diagram Formats

All diagrams are created using **Mermaid** syntax within Markdown files for the following benefits:

- **Version Control Friendly**: Text-based format that works well with Git
- **Maintainable**: Easy to update and modify without specialized tools
- **Accessible**: Can be viewed in any text editor or Markdown viewer
- **Consistent**: Uniform styling and formatting across all diagrams
- **Collaborative**: Easy for team members to contribute and review changes

## Viewing the Diagrams

### In GitHub/GitLab
Most modern Git hosting platforms render Mermaid diagrams automatically in Markdown files.

### In IDEs
- **VS Code**: Install the "Mermaid Preview" extension
- **IntelliJ/WebStorm**: Built-in Mermaid support in Markdown files
- **Vim/Neovim**: Use plugins like `mermaid.vim`

### Online Viewers
- [Mermaid Live Editor](https://mermaid.live/)
- [GitHub Gist](https://gist.github.com/) (renders Mermaid automatically)

### Local Rendering
```bash
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Generate SVG from Mermaid
mmdc -i system_architecture.md -o system_architecture.svg
```

## Updating Diagrams

When modifying these diagrams:

1. **Maintain Consistency**: Use the same color schemes and styling across diagrams
2. **Update Related Docs**: Ensure technical documentation references are updated
3. **Validate Syntax**: Test Mermaid syntax in a viewer before committing
4. **Document Changes**: Update this README if new diagrams are added

## Color Scheme Reference

The diagrams use a consistent color scheme:

- **Presentation Layer**: `#e1f5fe` (Light Blue)
- **Application Layer**: `#f3e5f5` (Light Purple)
- **Domain Layer**: `#e8f5e8` (Light Green)
- **Infrastructure Layer**: `#fff3e0` (Light Orange)
- **Platform Layer**: `#fce4ec` (Light Pink)
- **Core Features**: `#f1f8e9` (Light Lime)

## Integration with Documentation

These architecture diagrams are referenced throughout the technical documentation:

- **docs/ARCHITECTURE.md**: References system_architecture.md and flutter_architecture.md
- **docs/PROTOCOL_SPEC.md**: May reference component_interactions.md for protocol handling
- **docs/UI_REQUIREMENTS.md**: References flutter_architecture.md for widget specifications
- **context/technical_specifications.md**: References all architecture diagrams

## Contributing

When adding new architecture diagrams:

1. Follow the existing naming convention: `descriptive_name.md`
2. Use Mermaid syntax for consistency
3. Include comprehensive documentation in the file
4. Update this README with the new diagram description
5. Reference the diagram in relevant technical documentation
6. Use the established color scheme for visual consistency

## Future Enhancements

Planned additions to this directory:

- **Deployment Architecture**: Infrastructure and deployment patterns
- **Security Architecture**: Security boundaries and trust relationships
- **Performance Architecture**: Performance-critical paths and optimizations
- **Testing Architecture**: Test strategy and coverage visualization