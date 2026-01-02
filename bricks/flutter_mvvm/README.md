# 🚀 Flutter MVVM Mason Brick

A production-ready **Mason brick** for generating Flutter applications using **MVVM architecture** with modern best practices.

[![Mason](https://img.shields.io/badge/Mason-Powered-blue)](https://github.com/felangel/mason)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.2.0-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- 🏗️ **Feature-First MVVM Architecture** - Scalable and maintainable project structure
- 🔄 **Riverpod State Management** - Type-safe, compile-time dependency injection
- ❄️ **Freezed Models** - Immutable data classes with JSON serialization
- 🧭 **GoRouter Navigation** - Declarative routing with auth guards
- 🌐 **Dio Network Layer** - HTTP client with interceptors
- 🎨 **Material 3 Theme System** - Light/dark mode support
- ✅ **Result Type** - Explicit error handling without exceptions
- 🔐 **Complete Auth Feature** - Login/logout reference implementation
- 📱 **Shared Widgets** - Reusable UI components
- 🧪 **Test-Ready** - Architecture designed for unit/widget testing

---

## 🏛️ Architecture Overview

This boilerplate implements **MVVM (Model-View-ViewModel)** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────┐
│                   View                      │
│  (UI - Screens & Widgets)                   │
│  • ConsumerWidget/StatefulWidget            │
│  • No business logic                        │
└──────────────┬──────────────────────────────┘
               │ watches
               ▼
┌─────────────────────────────────────────────┐
│                ViewModel                    │
│  (State Management - Riverpod Notifiers)    │
│  • Business logic                           │
│  • State management                         │
│  • No Flutter imports                       │
└──────────────┬──────────────────────────────┘
               │ calls
               ▼
┌─────────────────────────────────────────────┐
│            Repository/Service               │
│  (Data Layer)                               │
│  • API calls                                │
│  • Database operations                      │
│  • Returns Result<T>                        │
└──────────────┬──────────────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────────────┐
│                  Model                      │
│  (Data Classes - Freezed)                   │
│  • Immutable entities                       │
│  • JSON serialization                       │
└─────────────────────────────────────────────┘
```

---

## 📁 Folder Structure

```
lib/
├── core/                     # App-wide utilities
│   ├── constants/            # App constants, API endpoints
│   ├── errors/               # Exception hierarchy, Result type
│   ├── extensions/           # Dart/Flutter extensions
│   ├── theme/                # Theme configuration
│   └── utils/                # Validators, logger, formatters
│
├── config/                   # App configuration
│   ├── env/                  # Environment configs (dev/prod)
│   ├── providers/            # Global Riverpod providers
│   └── router/               # GoRouter configuration
│
├── network/                  # Network layer
│   ├── api_client.dart       # Dio HTTP client
│   └── interceptors/         # Auth, logging interceptors
│
├── features/                 # Feature modules (vertical slices)
│   └── auth/                 # Example: Authentication
│       ├── model/            # User, AuthResponse (Freezed)
│       ├── service/          # AuthRepository interface & impl
│       ├── view_model/       # AuthNotifier (Riverpod)
│       └── view/             # Login/Home screens
│
├── shared/                   # Reusable components
│   └── widgets/              # Buttons, inputs, feedback
│
├── bootstrap.dart            # App initialization
└── main.dart                 # Entry point
```

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK `>=3.2.0`
- Dart SDK `>=3.2.0`
- Mason CLI

### 1. Install Mason CLI

```bash
dart pub global activate mason_cli
```

### 2. Add the Brick

```bash
# From local path
mason add flutter_mvvm --path ./bricks/flutter_mvvm

# Or from Git (once published)
mason add flutter_mvvm --git-url https://github.com/yourusername/flutter_mvvm_brick
```

### 3. Generate a New Project

```bash
mason make flutter_mvvm
```

You'll be prompted for:
- **project_name**: Your app name (e.g., `my_awesome_app`)
- **org_name**: Organization ID (e.g., `com.example`)
- **description**: Short app description
- **use_firebase**: Include Firebase setup (true/false)
- **use_analytics**: Include analytics (true/false)

**Non-interactive mode:**
```bash
mason make flutter_mvvm \
  --project_name my_app \
  --org_name com.example \
  --description "My awesome Flutter app" \
  --use_firebase false \
  --use_analytics false
```

### 4. Run Code Generation

```bash
cd my_app
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
flutter run
```

---

## 📖 Usage Examples

### Adding a New Feature

1. **Create feature structure:**
```bash
mkdir -p lib/features/profile/{model,service,view_model,view/screens}
```

2. **Create Freezed model:**
```dart
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => 
      _$ProfileFromJson(json);
}
```

3. **Create repository:**
```dart
abstract class ProfileRepository {
  Future<Result<Profile>> getProfile(String userId);
}
```

4. **Create Riverpod notifier:**
```dart
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  FutureOr<Profile?> build() => null;

  Future<void> loadProfile(String userId) async {
    state = const AsyncLoading();
    final result = await ref.read(profileRepositoryProvider).getProfile(userId);
    state = result.when(
      success: (profile) => AsyncData(profile),
      failure: (error) => AsyncError(error, StackTrace.current),
    );
  }
}
```

5. **Run code generation:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 🎯 Best Practices

### MVVM Principles
- ✅ **Views are dumb** - Delegate all logic to ViewModels
- ✅ **ViewModels have no Flutter imports** (except `foundation.dart`)
- ✅ **Repositories return `Result<T>`** - Explicit error handling
- ✅ **Use Freezed for all models** - Immutability by default
- ✅ **Keep features isolated** - Avoid cross-feature dependencies

### Code Generation
```bash
# Watch mode (auto-regenerate on save)
dart run build_runner watch --delete-conflicting-outputs

# One-time build
dart run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Follow the existing code style**
4. **Write tests** for new features
5. **Update documentation** as needed
6. **Commit with conventional commits** (see below)
7. **Push to your fork** (`git push origin feature/amazing-feature`)
8. **Open a Pull Request**

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add password reset functionality
fix(router): correct navigation guard logic
docs(readme): update installation instructions
refactor(network): extract interceptor logic
```

---

## 📚 Documentation

- [Mason Usage Guide](./docs/mason_usage_guide.md) - Detailed usage instructions
- [Best Practices](./docs/best_practices.md) - Architecture guidelines
- [Production Roadmap](./docs/production_roadmap.md) - Scaling to production

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| [Flutter](https://flutter.dev) | >=3.2.0 | Framework |
| [Riverpod](https://riverpod.dev) | ^2.4.9 | State management |
| [Freezed](https://pub.dev/packages/freezed) | ^2.4.6 | Immutable models |
| [GoRouter](https://pub.dev/packages/go_router) | ^13.0.0 | Navigation |
| [Dio](https://pub.dev/packages/dio) | ^5.4.0 | HTTP client |
| [Mason](https://github.com/felangel/mason) | >=0.1.0 | Code generation |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Mason](https://github.com/felangel/mason) by Felix Angelov
- [Riverpod](https://riverpod.dev) by Remi Rousselet
- [Freezed](https://pub.dev/packages/freezed) by Remi Rousselet
- Flutter community for best practices and patterns

---

## 📞 Support

- 📧 Email: your.email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/flutter_mvvm_brick/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/flutter_mvvm_brick/discussions)

---

<p align="center">Made with ❤️ for the Flutter community</p>
