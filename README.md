# 🧱 Flutter Bricks

A collection of production-ready Mason bricks for Flutter development.

## 📦 Bricks

| Brick | Description | Path |
|-------|-------------|------|
| [**flutter_mvvm**](./bricks/flutter_mvvm) | A complete MVVM project boilerplate with Riverpod, Freezed, GoRouter, and more. | `bricks/flutter_mvvm` |
| [**cache_repository**](./bricks/cache_repository) | A repository pattern generator with in-memory and optional disk caching (Hive). | `bricks/cache_repository` |
| [**media_picker_service**](./bricks/media_picker_service) | A reusable service for picking images/files with permission handling. | `bricks/media_picker_service` |
| [**theme_controller**](./bricks/theme_controller) | A reusable theme management system (Light/Dark/System) with persistence. | `bricks/theme_controller` |
| [**pagination_utils**](./bricks/pagination_utils) | A generic pagination controller and state system. | `bricks/pagination_utils` |

## 🛠️ Usage

### Prerequisites
- [Mason CLI](https://github.com/felangel/mason) installed (`dart pub global activate mason_cli`)

### Adding Bricks
You can add these bricks locally or from this git repository.

```bash
# From Git
mason add flutter_mvvm --git-url https://github.com/hamdi-ab/flutter_mvvm_brick.git --git-path bricks/flutter_mvvm
mason add cache_repository --git-url https://github.com/hamdi-ab/flutter_mvvm_brick.git --git-path bricks/cache_repository
```

### Generating Code

#### Scaffolding a New App
```bash
mason make flutter_mvvm
```

#### Generating a Repository
```bash
mason make cache_repository --feature feed --entity feed_item
```

## 🤝 Contributing

Contributions are welcome! If you have a new brick idea, feel free to open a PR.

1. Create a new directory in `bricks/`
2. Create your brick (`mason new <brick_name>`)
3. Document it here
