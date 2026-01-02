# cache_repository Brick

A Mason brick that scaffolds a repository-level caching pattern for Flutter apps using MVVM.

## Features

- **In-Memory Caching**: Avoids redundant network calls by caching data locally in memory.
- **Disk Caching (Optional)**: Persistent caching using [hive](https://pub.dev/packages/hive) to support offline mode.
- **TTL Validation**: Automatically expires cache after a set duration (default: 5 minutes).
- **Force Refresh**: Explicitly request fresh data from the API.
- **Clean Architecture**: Repository pattern with `Result` type for error handling.

## Generated Files

| File | Description |
|------|-------------|
| `{{feature}}_repository.dart` | Abstract interface defining the contract. |
| `{{feature}}_repository_impl.dart` | Implementation with caching logic. |

## Usage

```bash
mason make cache_repository --feature feed --entity feed_item --use_disk_cache true
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `feature` | Name of the feature (e.g., `feed`, `profile`) | `feed` |
| `entity` | Name of the entity model (e.g., `feed_item`, `user`) | `feed_item` |
| `use_disk_cache` | Enable persistent disk caching using Hive | `false` |

## Dependencies (If using Disk Cache)

If you enable `use_disk_cache`, you must add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

> **Note**: Ensure you initialize Hive in your `main.dart` before using the repository:
> ```dart
> await Hive.initFlutter();
> ```

## Extension Points

- **TTL Config**: Determine TTL dynamically based on remote config.
