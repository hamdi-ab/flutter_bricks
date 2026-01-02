# cache_repository Brick

A Mason brick that scaffolds a repository-level caching pattern for Flutter apps using MVVM.

## Features

- **In-Memory Caching**: Avoids redundant network calls by caching data locally in memory.
- **TTL Validation**: Automatically expires cache after a set duration (default: 5 minutes).
- **Force Refresh**: Explicitly request fresh data from the API.
- **Clean Architecture**: Repository pattern with `Result` type for error handling.
- **Pure Dart**: Logic is decoupled from UI and Flutter widgets.

## Generated Files

| File | Description |
|------|-------------|
| `{{feature}}_repository.dart` | Abstract interface defining the contract. |
| `{{feature}}_repository_impl.dart` | Implementation with caching logic. |

## Usage

```bash
mason make cache_repository --feature feed --entity feed_item
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `feature` | Name of the feature (e.g., `feed`, `profile`) | `feed` |
| `entity` | Name of the entity model (e.g., `feed_item`, `user`) | `feed_item` |

## Extension Points

- **Disk Cache**: The implementation has a marked extension point to add persistent storage (e.g., Hive, SQLite).
- **TTL Config**: Determine TTL dynamically based on remote config.
