# 🕸️ radar_chart_widget Brick

A production-ready, animated multi-dimensional radar (spider / web) chart widget for Flutter with concentric polygon grids, radial gradients, vertex glow dots, and perimeter labels.

## Features

- **Any Number of Vertices**: Dynamically renders 3-sided (triangles), 5-sided (pentagons), 6-sided (hexagons), 8-sided (octagons), 9-sided (nonagons), or any $N \ge 3$ polygon.
- **Fluid Animation**: Built-in `AnimationController` with customizable entrance curves (`Curves.easeOutBack`) and duration.
- **Concentric Grid Rings**: Configurable levels (e.g. 20%, 40%, 60%, 80%, 100%) and spoke rays.
- **Gradient Fill & Glowing Vertices**: Radial gradient area fill with highlighted vertex dots and glow halos for peak values.
- **Two Flexible Components**:
  - `RadarChart`: Clean, self-contained custom-painted canvas widget.
  - `RadarChartCard`: Full-featured analytics card with title, average score pill, top strength / growth opportunity callouts, and action buttons.
- **Zero Heavy Dependencies**: Pure Flutter Material and math — no third-party charting libraries required.

## Generated Files

| File | Description |
|------|-------------|
| `lib/shared/widgets/radar_chart/radar_chart.dart` | `RadarDimension`, `RadarChart`, `RadarChartCard`, and `PolygonRadarPainter` |

## Usage Examples

### 1. Minimal Standalone Radar Chart

```dart
RadarChart(
  dimensions: const [
    RadarDimension(key: 'speed', label: 'Speed', score: 85),
    RadarDimension(key: 'power', label: 'Power', score: 92),
    RadarDimension(key: 'stamina', label: 'Stamina', score: 78),
    RadarDimension(key: 'defense', label: 'Defense', score: 65),
    RadarDimension(key: 'technique', label: 'Technique', score: 88),
  ],
)
```

### 2. Full Analytics Card with Callouts

```dart
RadarChartCard(
  title: 'Performance Overview',
  subtitle: 'Weekly multi-dimensional breakdown',
  dimensions: const [
    RadarDimension(key: 'focus', label: 'Focus', score: 94, color: Colors.green),
    RadarDimension(key: 'habits', label: 'Habits', score: 82, color: Colors.blue),
    RadarDimension(key: 'tasks', label: 'Tasks', score: 75, color: Colors.amber),
    RadarDimension(key: 'wellness', label: 'Wellness', score: 60, color: Colors.red),
    RadarDimension(key: 'learning', label: 'Learning', score: 88, color: Colors.purple),
  ],
  actionLabel: 'View Detailed Report',
  onActionTap: () {
    // Navigate or trigger sheet
  },
)
```

### 3. Customizing Rings and Animation

```dart
RadarChart(
  height: 320,
  animationDuration: const Duration(milliseconds: 1500),
  animationCurve: Curves.elasticOut,
  ringLevels: const [0.25, 0.50, 0.75, 1.0],
  strokeColor: Colors.deepPurple,
  dimensions: myDimensions,
)
```
