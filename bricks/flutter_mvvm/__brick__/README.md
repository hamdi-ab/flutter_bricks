# {{project_name.titleCase()}}

{{description}}

## Architecture

This project follows **Feature-First MVVM** architecture:

- **Model**: Data classes with Freezed for immutability
- **View**: UI components (Screens & Widgets)
- **ViewModel**: Riverpod Notifiers for state management
- **Service/Repository**: Data sources and business logic

## Tech Stack

- **State Management**: Riverpod (flutter_riverpod + riverpod_generator)
- **Code Generation**: Freezed + JsonSerializable
- **Navigation**: GoRouter
- **Network**: Dio
- **Storage**: SharedPreferences

## Project Structure

```
lib/
├── core/              # App-wide utilities
├── config/            # Configuration & DI
├── network/           # API client
├── features/          # Feature modules
│   └── auth/          # Example feature
└── shared/            # Reusable components
```

## Getting Started

### Prerequisites

- Flutter SDK >=3.2.0
- Dart SDK >=3.2.0

### Installation

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Code Generation

When you modify Freezed models or Riverpod providers:

```bash
# Watch mode (auto-regenerate)
dart run build_runner watch --delete-conflicting-outputs

# One-time build
dart run build_runner build --delete-conflicting-outputs
```

## Adding New Features

1. Create feature folder in `lib/features/`
2. Add `model/`, `view/`, `view_model/`, `service/` subdirectories
3. Implement your feature following the Auth example
4. Run code generation if using Freezed/Riverpod annotations

## Best Practices

- ✅ Keep ViewModels free of Flutter imports (except foundation)
- ✅ Use Freezed for all data models
- ✅ Return `Result<T>` from repositories
- ✅ Use ConsumerWidget for Riverpod state
- ✅ Keep features isolated and self-contained

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## License

This project is licensed under the MIT License.
