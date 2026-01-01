# Flutter MVVM Brick

A production-ready Flutter boilerplate using MVVM architecture with:

- **State Management**: Riverpod (flutter_riverpod + riverpod_generator)
- **Code Generation**: Freezed + JsonSerializable
- **Navigation**: GoRouter
- **Network**: Dio
- **Architecture**: Feature-First MVVM

## Installation

```bash
mason add flutter_mvvm --path ./path/to/brick
```

## Usage

```bash
mason make flutter_mvvm \
  --project_name my_awesome_app \
  --org_name com.mycompany \
  --description "My awesome Flutter app"
```

## What's Included

- ✅ Feature-first folder structure
- ✅ Riverpod state management with code generation
- ✅ Freezed models with JSON serialization
- ✅ GoRouter navigation with guards
- ✅ Dio network layer with interceptors
- ✅ Result type for error handling
- ✅ Base classes for ViewModels and screens
- ✅ Auth feature as reference implementation
- ✅ Shared widgets and layouts
- ✅ Theme system with dark mode support

## Post-Generation Steps

```bash
cd {{project_name}}
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Architecture

See the generated `README.md` in your project for detailed architecture documentation.
