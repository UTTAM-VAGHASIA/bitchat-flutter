# Contributing to BitChat Flutter

**Version:** 1.0  
**Last Updated:** July 26, 2025

## Welcome Contributors! 🎉

Thank you for your interest in contributing to BitChat Flutter! This project aims to create a decentralized, peer-to-peer messaging application that operates over Bluetooth Low Energy (BLE) mesh networks. Your contributions help build a more private, secure, and accessible communication platform.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contribution Process](#contribution-process)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Git Workflow](#git-workflow)
- [Code Review Process](#code-review-process)
- [Issue Reporting](#issue-reporting)
- [Security Contributions](#security-contributions)
- [Community Guidelines](#community-guidelines)

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Development Environment**: Complete setup following `DEVELOPER_SETUP.md`
2. **Project Knowledge**: Read the technical documentation in `docs/` folder
3. **Code Style Understanding**: Review `CODE_STYLE_GUIDE.md`
4. **Workflow Familiarity**: Understand `DEVELOPMENT_WORKFLOW.md`

### First-Time Contributors

If you're new to the project:

1. **Start Small**: Look for issues labeled `good-first-issue` or `help-wanted`
2. **Read Documentation**: Familiarize yourself with the project architecture
3. **Join Discussions**: Participate in GitHub Discussions to understand ongoing work
4. **Ask Questions**: Don't hesitate to ask for clarification on issues or processes

## Development Setup

### Quick Setup
```bash
# Clone the repository
git clone https://github.com/your-org/bitchat-flutter.git
cd bitchat-flutter

# Set up development environment
# Follow detailed instructions in DEVELOPER_SETUP.md

# Navigate to Flutter app
cd bitchat

# Install dependencies
flutter pub get

# Verify setup
flutter doctor -v
flutter test
```

### Development Environment Requirements

- **Flutter SDK**: 3.16.0+ (latest stable recommended)
- **Dart SDK**: 3.0.0+
- **IDE**: VS Code (recommended) or Android Studio
- **Platform Tools**: Xcode (macOS), Android Studio, or platform-specific tools
- **Testing Devices**: Physical devices with Bluetooth 4.0+ for testing

## Contribution Process

### 1. Choose Your Contribution

#### Types of Contributions Welcome
- **Bug Fixes**: Fix existing issues or improve stability
- **Feature Implementation**: Add new features from the roadmap
- **Documentation**: Improve or add documentation
- **Testing**: Add tests or improve test coverage
- **Performance**: Optimize performance or reduce resource usage
- **Security**: Enhance security features or fix vulnerabilities
- **UI/UX**: Improve user interface and user experience

#### Finding Work
- **GitHub Issues**: Browse open issues for tasks
- **Project Roadmap**: Check `context/implementation_roadmap.md` for planned features
- **Documentation Gaps**: Look for missing or incomplete documentation
- **Test Coverage**: Identify areas needing better test coverage

### 2. Prepare Your Contribution

#### Before Starting Work
1. **Check Existing Work**: Ensure no one else is working on the same issue
2. **Create/Comment on Issue**: Create an issue or comment on existing ones to claim work
3. **Discuss Approach**: For significant changes, discuss your approach first
4. **Fork Repository**: Create your own fork for development

#### Development Process
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make your changes following code standards
# Write tests for your changes
# Update documentation as needed

# Test your changes
flutter test
flutter analyze
dart format .

# Commit your changes
git add .
git commit -m "feat: add your feature description"

# Push to your fork
git push origin feature/your-feature-name
```#
# Code Standards

### Code Quality Requirements

All contributions must adhere to the standards defined in `API_DOCUMENTATION_STANDARDS.md` and `CODE_STYLE_GUIDE.md`. Key requirements include:

#### Dart/Flutter Standards
- **Formatting**: Use `dart format .` for consistent formatting
- **Linting**: Pass all `flutter analyze` checks without warnings
- **Documentation**: Document all public APIs with comprehensive dartdoc comments
- **Naming**: Follow Dart naming conventions (PascalCase for classes, camelCase for variables)

#### Architecture Standards
- **Clean Architecture**: Follow the established layer structure
- **Separation of Concerns**: Keep business logic separate from UI
- **Dependency Injection**: Use Provider pattern for state management
- **Error Handling**: Implement proper error handling and user feedback

#### Security Standards
- **Cryptographic Operations**: Follow established security patterns
- **Input Validation**: Validate all user inputs and external data
- **Sensitive Data**: Never log or expose sensitive information
- **Protocol Compatibility**: Maintain compatibility with iOS/Android implementations

### Code Review Checklist

Before submitting, ensure your code meets these criteria:

- [ ] **Functionality**: Code works as intended and handles edge cases
- [ ] **Tests**: Comprehensive unit tests with >80% coverage
- [ ] **Documentation**: All public APIs are documented
- [ ] **Performance**: No performance regressions
- [ ] **Security**: No security vulnerabilities introduced
- [ ] **Compatibility**: Maintains protocol compatibility
- [ ] **Style**: Follows project coding standards
- [ ] **Dependencies**: No unnecessary dependencies added

## Testing Requirements

### Test Coverage Standards

All contributions must include appropriate tests:

#### Unit Tests (Required)
```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Coverage should be >80% for new code
```

#### Integration Tests (When Applicable)
```bash
# Run integration tests
flutter test integration_test

# Required for:
# - Bluetooth functionality
# - Encryption/decryption
# - Message routing
# - UI workflows
```

#### Test Categories

1. **Unit Tests**: Test individual functions and classes
2. **Widget Tests**: Test UI components in isolation
3. **Integration Tests**: Test feature workflows end-to-end
4. **Golden Tests**: Test UI appearance consistency
5. **Performance Tests**: Test performance-critical code

### Writing Good Tests

#### Test Structure
```dart
void main() {
  group('EncryptionService', () {
    late EncryptionService service;
    
    setUp(() {
      service = EncryptionService();
    });
    
    tearDown(() {
      service.dispose();
    });
    
    test('should encrypt and decrypt message correctly', () async {
      // Arrange
      const message = 'Hello, secure world!';
      final keyPair = await service.generateKeyPair();
      
      // Act
      final encrypted = await service.encrypt(message, keyPair.publicKey);
      final decrypted = await service.decrypt(encrypted, keyPair.privateKey);
      
      // Assert
      expect(decrypted, equals(message));
    });
    
    test('should throw exception for invalid key', () async {
      // Arrange
      const message = 'Test message';
      final invalidKey = Uint8List(32); // All zeros
      
      // Act & Assert
      expect(
        () => service.encrypt(message, invalidKey),
        throwsA(isA<CryptographicException>()),
      );
    });
  });
}
```

#### Test Best Practices
- **Descriptive Names**: Use clear, descriptive test names
- **Arrange-Act-Assert**: Structure tests clearly
- **Edge Cases**: Test boundary conditions and error cases
- **Isolation**: Tests should not depend on each other
- **Deterministic**: Tests should produce consistent results

## Documentation Standards

### Documentation Requirements

All contributions must include appropriate documentation following `API_DOCUMENTATION_STANDARDS.md`:

#### Code Documentation
```dart
/// Encrypts a message for secure transmission over the mesh network.
/// 
/// This method implements end-to-end encryption using X25519 key exchange
/// and AES-256-GCM symmetric encryption. The encryption is compatible with
/// the iOS and Android BitChat implementations.
/// 
/// ## Parameters
/// 
/// - [message]: The plaintext message to encrypt. Must not be empty.
/// - [recipientPublicKey]: The recipient's X25519 public key (32 bytes).
/// 
/// ## Returns
/// 
/// Returns an [EncryptedMessage] containing the encrypted data.
/// 
/// ## Throws
/// 
/// - [ArgumentError]: If any parameter is invalid
/// - [CryptographicException]: If encryption fails
/// 
/// ## Example
/// 
/// ```dart
/// final encrypted = await encryptMessage(
///   'Hello, secure world!',
///   recipientPublicKey,
/// );
/// ```
Future<EncryptedMessage> encryptMessage(
  String message,
  Uint8List recipientPublicKey,
) async {
  // Implementation...
}
```

#### Documentation Types Required

1. **API Documentation**: Comprehensive dartdoc for all public APIs
2. **README Updates**: Update relevant README files
3. **Technical Docs**: Update technical specifications if needed
4. **Examples**: Provide usage examples for new features
5. **Migration Guides**: Document breaking changes

### Documentation Quality Standards

- **Clarity**: Documentation should be clear and unambiguous
- **Completeness**: Cover all parameters, return values, and exceptions
- **Examples**: Provide practical usage examples
- **Accuracy**: Keep documentation synchronized with code
- **Context**: Explain why, not just what

## Git Workflow

### Branch Management Strategy

We use a feature branch workflow with the following conventions:

#### Branch Naming
```bash
# Feature branches
feature/bluetooth-mesh-routing
feature/channel-encryption
feature/ui-chat-interface

# Bug fix branches
fix/memory-leak-in-scanner
fix/crash-on-device-disconnect

# Documentation branches
docs/api-documentation-update
docs/setup-guide-improvements

# Hotfix branches (for critical production fixes)
hotfix/security-vulnerability-fix
```

#### Branch Lifecycle
```bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/your-feature-name

# Work on your feature
# Make commits with descriptive messages

# Keep branch updated with main
git fetch origin
git rebase origin/main

# Push your branch
git push origin feature/your-feature-name

# Create pull request
# After review and approval, branch will be merged and deleted
```### 
Commit Message Standards

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

#### Commit Message Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Commit Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring without feature changes
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, dependency updates

#### Examples
```bash
# Feature addition
git commit -m "feat(bluetooth): implement mesh routing algorithm"

# Bug fix
git commit -m "fix(encryption): resolve key exchange timing issue"

# Documentation update
git commit -m "docs(api): add examples for encryption service"

# Breaking change
git commit -m "feat(protocol)!: update message format for v2.0"

# With body and footer
git commit -m "feat(ui): add dark mode support

Implements dark mode theme switching with system preference detection.
Includes Material Design 3 color schemes and proper contrast ratios.

Closes #123
Reviewed-by: @reviewer-name"
```

### Pull Request Process

#### Creating Pull Requests

1. **Ensure Quality**: Run all tests and checks locally
2. **Update Documentation**: Include relevant documentation updates
3. **Write Description**: Provide clear description of changes
4. **Link Issues**: Reference related issues using keywords
5. **Request Review**: Assign appropriate reviewers

#### Pull Request Template
```markdown
## Description
Brief description of the changes and their purpose.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Test coverage maintained/improved

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or properly documented)
- [ ] Security considerations addressed

## Related Issues
Closes #issue-number
Relates to #issue-number

## Screenshots (if applicable)
Include screenshots for UI changes.

## Additional Notes
Any additional information for reviewers.
```

## Code Review Process

### Review Guidelines

#### For Contributors
- **Self-Review**: Review your own code before requesting review
- **Small PRs**: Keep pull requests focused and reasonably sized
- **Responsive**: Respond promptly to review feedback
- **Learning**: Use reviews as learning opportunities

#### For Reviewers
- **Constructive**: Provide constructive, helpful feedback
- **Thorough**: Review code, tests, and documentation
- **Timely**: Provide reviews within 2-3 business days
- **Respectful**: Maintain a respectful, collaborative tone

### Review Criteria

#### Code Quality
- **Functionality**: Does the code work as intended?
- **Readability**: Is the code easy to understand?
- **Maintainability**: Will this code be easy to maintain?
- **Performance**: Are there any performance concerns?

#### Security Review
- **Input Validation**: Are all inputs properly validated?
- **Cryptographic Usage**: Are cryptographic operations correct?
- **Data Handling**: Is sensitive data handled securely?
- **Protocol Compliance**: Does it maintain protocol compatibility?

#### Testing Review
- **Coverage**: Are there adequate tests?
- **Quality**: Are tests well-written and meaningful?
- **Edge Cases**: Are edge cases covered?
- **Integration**: Do integration tests cover the workflow?

### Review Process Flow

1. **Automated Checks**: CI/CD runs automated tests and checks
2. **Initial Review**: Reviewer performs initial code review
3. **Feedback**: Reviewer provides feedback and suggestions
4. **Updates**: Contributor addresses feedback and updates PR
5. **Re-review**: Reviewer checks updates and provides approval
6. **Merge**: PR is merged after all checks pass and approval is given

## Issue Reporting

### Bug Reports

When reporting bugs, please include:

#### Bug Report Template
```markdown
## Bug Description
A clear and concise description of what the bug is.

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
A clear description of what you expected to happen.

## Actual Behavior
A clear description of what actually happened.

## Environment
- **OS**: [e.g. iOS 16.0, Android 13, Windows 11]
- **Device**: [e.g. iPhone 14, Pixel 7, Surface Pro]
- **Flutter Version**: [e.g. 3.16.0]
- **App Version**: [e.g. 1.0.0]

## Screenshots
If applicable, add screenshots to help explain your problem.

## Logs
Include relevant log output or error messages.

## Additional Context
Add any other context about the problem here.
```

### Feature Requests

#### Feature Request Template
```markdown
## Feature Description
A clear and concise description of the feature you'd like to see.

## Problem Statement
What problem does this feature solve? What use case does it address?

## Proposed Solution
Describe the solution you'd like to see implemented.

## Alternative Solutions
Describe any alternative solutions or features you've considered.

## Implementation Considerations
- **Complexity**: How complex would this be to implement?
- **Compatibility**: Any compatibility concerns?
- **Security**: Any security implications?
- **Performance**: Any performance considerations?

## Additional Context
Add any other context, mockups, or examples about the feature request.
```

### Issue Labels

We use the following labels to categorize issues:

#### Type Labels
- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to documentation
- `question`: Further information is requested

#### Priority Labels
- `priority-critical`: Critical issues requiring immediate attention
- `priority-high`: High priority issues
- `priority-medium`: Medium priority issues
- `priority-low`: Low priority issues

#### Status Labels
- `good-first-issue`: Good for newcomers
- `help-wanted`: Extra attention is needed
- `in-progress`: Currently being worked on
- `blocked`: Blocked by other issues or external factors

#### Component Labels
- `bluetooth`: Bluetooth/BLE related
- `encryption`: Cryptography and security
- `ui`: User interface
- `protocol`: Network protocol
- `testing`: Testing related
- `ci-cd`: Continuous integration/deployment## Securi
ty Contributions

### Security-First Approach

BitChat handles sensitive cryptographic operations and personal communications. Security is paramount in all contributions.

#### Security Review Process

1. **Security-Sensitive Changes**: All cryptographic, authentication, or protocol changes require security review
2. **Threat Modeling**: Consider potential attack vectors for your changes
3. **Secure Coding**: Follow secure coding practices
4. **Testing**: Include security-focused tests

#### Reporting Security Vulnerabilities

**⚠️ Do NOT report security vulnerabilities through public GitHub issues.**

Instead:
1. **Email**: Send details to security@bitchat.org (if available)
2. **Private Disclosure**: Use GitHub's private vulnerability reporting
3. **Responsible Disclosure**: Allow time for fixes before public disclosure

#### Security Contribution Guidelines

```dart
// Example: Secure key handling
class SecureKeyManager {
  /// Generates a cryptographically secure key pair.
  /// 
  /// ## Security Considerations
  /// 
  /// - Uses cryptographically secure random number generation
  /// - Keys are generated in secure memory when available
  /// - Private keys are zeroed after use
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final keyPair = await generateKeyPair();
  /// try {
  ///   // Use keys for cryptographic operations
  ///   final encrypted = await encrypt(message, keyPair.publicKey);
  /// } finally {
  ///   // Ensure private key is securely disposed
  ///   keyPair.dispose();
  /// }
  /// ```
  Future<KeyPair> generateKeyPair() async {
    // Implementation with secure random generation
  }
}
```

#### Security Testing Requirements

- **Cryptographic Tests**: Test all cryptographic operations
- **Input Validation**: Test with malicious inputs
- **Protocol Tests**: Verify protocol security properties
- **Timing Attack Tests**: Test for timing vulnerabilities

## Community Guidelines

### Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please:

#### Be Respectful
- **Inclusive Language**: Use inclusive language in code, comments, and discussions
- **Constructive Feedback**: Provide constructive criticism and feedback
- **Professional Conduct**: Maintain professional behavior in all interactions

#### Be Collaborative
- **Help Others**: Help other contributors learn and grow
- **Share Knowledge**: Share your expertise and learn from others
- **Open Communication**: Communicate openly and transparently

#### Be Patient
- **Learning Curve**: Understand that everyone has different experience levels
- **Review Time**: Allow reasonable time for code reviews and responses
- **Iteration**: Expect multiple iterations on contributions

### Communication Channels

#### GitHub
- **Issues**: Bug reports and feature requests
- **Discussions**: General questions and community discussions
- **Pull Requests**: Code contributions and reviews

#### Best Practices for Communication
- **Clear Titles**: Use clear, descriptive titles for issues and PRs
- **Detailed Descriptions**: Provide sufficient context and details
- **Follow Up**: Respond to questions and feedback promptly
- **Search First**: Search existing issues before creating new ones

## Recognition and Attribution

### Contributor Recognition

We value all contributions and recognize contributors through:

#### GitHub Recognition
- **Contributors Graph**: Automatic recognition in GitHub contributors
- **Release Notes**: Major contributors mentioned in release notes
- **Hall of Fame**: Outstanding contributors featured in documentation

#### Types of Contributions Recognized
- **Code Contributions**: Features, bug fixes, improvements
- **Documentation**: Writing, editing, and improving documentation
- **Testing**: Adding tests, finding bugs, improving quality
- **Community**: Helping other contributors, answering questions
- **Design**: UI/UX improvements, visual assets

### Attribution Guidelines

- **Commit Attribution**: Ensure commits are properly attributed to you
- **Co-authored Commits**: Use co-authored-by for collaborative work
- **Third-party Code**: Properly attribute any third-party code or libraries

## Getting Help

### Resources for Contributors

#### Documentation
- **Technical Docs**: `docs/` folder for technical specifications
- **Setup Guide**: `DEVELOPER_SETUP.md` for environment setup
- **Code Style**: `CODE_STYLE_GUIDE.md` for coding standards
- **Workflow**: `DEVELOPMENT_WORKFLOW.md` for development processes

#### Community Support
- **GitHub Discussions**: Ask questions and get help from the community
- **Issue Comments**: Comment on issues for clarification
- **Code Reviews**: Learn from feedback on your contributions

#### Mentorship
- **First-time Contributors**: Experienced contributors help newcomers
- **Pair Programming**: Collaborate on complex features
- **Knowledge Sharing**: Regular knowledge sharing sessions

### Common Questions

#### Q: How do I get started contributing?
A: Start by reading this guide, setting up your development environment following `DEVELOPER_SETUP.md`, and looking for issues labeled `good-first-issue`.

#### Q: What if I'm not sure about my approach?
A: Create an issue or comment on an existing issue to discuss your approach before starting work. The community is happy to provide guidance.

#### Q: How long does code review take?
A: We aim to provide initial feedback within 2-3 business days. Complex changes may require multiple review rounds.

#### Q: Can I work on multiple issues at once?
A: It's better to focus on one issue at a time to ensure quality and avoid conflicts. Complete one contribution before starting another.

#### Q: What if my PR is rejected?
A: Don't be discouraged! Use the feedback to improve your contribution. Rejection often leads to better solutions.

## Conclusion

Thank you for contributing to BitChat Flutter! Your contributions help build a more private, secure, and accessible communication platform. Whether you're fixing bugs, adding features, improving documentation, or helping other contributors, every contribution matters.

### Key Takeaways

1. **Quality First**: Focus on code quality, testing, and documentation
2. **Security Matters**: Always consider security implications
3. **Community Driven**: Collaborate openly and help others
4. **Continuous Learning**: Use contributions as learning opportunities
5. **Have Fun**: Enjoy building something meaningful!

### Next Steps

1. **Set Up Environment**: Follow `DEVELOPER_SETUP.md`
2. **Read Documentation**: Familiarize yourself with the project
3. **Find an Issue**: Look for `good-first-issue` or `help-wanted` labels
4. **Start Contributing**: Create your first pull request
5. **Join Community**: Participate in discussions and help others

---

**Happy Contributing!** 🚀

For questions about this guide or the contribution process, please create an issue or start a discussion on GitHub.