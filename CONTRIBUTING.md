# Contributing to SpotFinder

Thank you for your interest in contributing to SpotFinder! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions. We aim to maintain a welcoming and inclusive community.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device/OS information
- App version

### Suggesting Features

Feature suggestions are welcome! Please create an issue with:

- A clear description of the feature
- Use case and benefits
- Any implementation ideas (optional)

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Run tests and ensure they pass
5. Commit your changes (`git commit -m 'Add some feature'`)
6. Push to the branch (`git push origin feature/your-feature-name`)
7. Open a Pull Request

## Development Guidelines

### iOS/Swift

- Use Swift 6 features and modern patterns
- Follow Apple's Swift API Design Guidelines
- Include SwiftUI previews for new views
- Maintain MVVM architecture
- Document public APIs with doc comments
- Ensure accessibility support

### Backend/TypeScript

- Follow NestJS best practices
- Use TypeScript strict mode
- Add proper type definitions
- Include unit tests for new features
- Document API endpoints
- Follow existing code style

### Code Style

- Use clear, descriptive variable names
- Keep functions small and focused
- Add comments for complex logic
- Remove debug code before committing
- Follow existing formatting

### Testing

- Write unit tests for new features
- Ensure existing tests pass
- Test on multiple devices/screen sizes
- Verify accessibility features work

### Git Commit Messages

- Use clear, descriptive commit messages
- Start with a verb in present tense (Add, Fix, Update, Remove)
- Keep the first line under 50 characters
- Add detailed description if needed

Example:

```
Add user profile feature

- Create ProfileView with user information
- Add profile editing functionality
- Include avatar upload support
```

## Project Structure

### iOS App (`/SpotFinder`)

- `Models/` - Data structures
- `Views/` - SwiftUI views
- `ViewModels/` - Business logic
- `Services/` - External integrations
- `Utilities/` - Helper functions

### Backend API (`/backend`)

- `src/parking/` - Parking report logic
- `src/websocket/` - Real-time updates
- `src/database/` - Database schema
- `src/common/` - Shared utilities

## Setting Up Development Environment

### iOS App

1. Install Xcode 15+ with Swift 6 support
2. Open `SpotFinder.xcodeproj`
3. Select a simulator or device
4. Build and run (⌘R)

### Backend API

1. Install Node.js 20+
2. Install PostgreSQL 15+
3. Run `npm install` in `/backend`
4. Copy `.env.example` to `.env`
5. Run `npm run start:dev`

## Questions?

If you have questions, feel free to:

- Open an issue for discussion
- Check existing issues and pull requests
- Review the README and documentation

Thank you for contributing to SpotFinder!
