import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents a single dimension / axis on the radar chart.
class RadarDimension {
  final String key;
  final String label;
  final double score; // 0.0 to 100.0
  final Color? color;

  const RadarDimension({
    required this.key,
    required this.label,
    required this.score,
    this.color,
  });

  RadarDimension copyWith({
    String? key,
    String? label,
    double? score,
    Color? color,
  }) {
    return RadarDimension(
      key: key ?? this.key,
      label: label ?? this.label,
      score: score ?? this.score,
      color: color ?? this.color,
    );
  }
}

/// Standalone animated multi-sided radar (spider/web) chart widget.
///
/// Supports any number of vertices (N >= 3).
class RadarChart extends StatefulWidget {
  final List<RadarDimension> dimensions;
  final double height;
  final Duration animationDuration;
  final Curve animationCurve;
  final List<double> ringLevels;
  final Color? strokeColor;
  final Gradient? fillGradient;
  final Color? gridColor;
  final TextStyle? labelStyle;

  const RadarChart({
    super.key,
    required this.dimensions,
    this.height = 280,
    this.animationDuration = const Duration(milliseconds: 1100),
    this.animationCurve = Curves.easeOutBack,
    this.ringLevels = const [0.20, 0.40, 0.60, 0.80, 1.0],
    this.strokeColor,
    this.fillGradient,
    this.gridColor,
    this.labelStyle,
  }) : assert(dimensions.length >= 3, 'RadarChart requires at least 3 dimensions');

  @override
  State<RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: widget.animationCurve,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant RadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dimensions != oldWidget.dimensions) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: PolygonRadarPainter(
              dimensions: widget.dimensions,
              progress: _animation.value,
              isDark: isDark,
              ringLevels: widget.ringLevels,
              strokeColor: widget.strokeColor ?? theme.colorScheme.primary,
              fillGradient: widget.fillGradient,
              gridColor: widget.gridColor,
              labelStyle: widget.labelStyle,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that renders an N-sided concentric radar/spider grid
/// with filled polygon values and perimeter labels.
class PolygonRadarPainter extends CustomPainter {
  final List<RadarDimension> dimensions;
  final double progress;
  final bool isDark;
  final List<double> ringLevels;
  final Color strokeColor;
  final Gradient? fillGradient;
  final Color? gridColor;
  final TextStyle? labelStyle;

  PolygonRadarPainter({
    required this.dimensions,
    required this.progress,
    required this.isDark,
    required this.ringLevels,
    required this.strokeColor,
    this.fillGradient,
    this.gridColor,
    this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dimensions.isEmpty) return;

    final n = dimensions.length;
    final center = Offset(size.width / 2, size.height / 2);
    // Reserve margin for surrounding perimeter labels
    final maxRadius = math.min(size.width, size.height) * 0.36;

    final effectiveGridColor = gridColor ??
        (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08));

    final spokePaint = Paint()
      ..color = effectiveGridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final ringPaint = Paint()
      ..color = effectiveGridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 1. Draw Concentric Polygon Rings
    for (final level in ringLevels) {
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = -math.pi / 2 + i * (2 * math.pi / n);
        final r = maxRadius * level;
        final point = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, ringPaint);
    }

    // 2. Draw Spoke Rays from Center to Perimeter
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / n);
      final outer = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, outer, spokePaint);
    }

    // 3. Compute Value Polygon Points
    final dataPoints = <Offset>[];
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / n);
      final scoreRatio = (dimensions[i].score.clamp(0.0, 100.0) / 100.0) * progress;
      final r = maxRadius * scoreRatio;
      dataPoints.add(
        Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ),
      );
    }

    // 4. Fill Data Polygon
    final polyPath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      if (i == 0) {
        polyPath.moveTo(dataPoints[i].dx, dataPoints[i].dy);
      } else {
        polyPath.lineTo(dataPoints[i].dx, dataPoints[i].dy);
      }
    }
    polyPath.close();

    final effectiveFill = fillGradient ??
        RadialGradient(
          colors: [
            strokeColor.withValues(alpha: 0.5),
            strokeColor.withValues(alpha: 0.25),
          ],
        );

    final fillPaint = Paint()
      ..shader = effectiveFill.createShader(
        Rect.fromCircle(center: center, radius: maxRadius),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(polyPath, fillPaint);

    // 5. Stroke Data Polygon
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(polyPath, strokePaint);

    // 6. Draw Vertex Dots & Perimeter Labels
    for (int i = 0; i < n; i++) {
      final p = dataPoints[i];
      final item = dimensions[i];
      final itemColor = item.color ?? strokeColor;
      final isTop = item.score >= 90;

      if (isTop) {
        final glowPaint = Paint()
          ..color = itemColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 7.0, glowPaint);
      }

      final dotPaint = Paint()
        ..color = itemColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, 4.0, dotPaint);

      final dotBorderPaint = Paint()
        ..color = isDark ? Colors.black : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(p, 4.0, dotBorderPaint);

      // Label Positioning around perimeter
      final angle = -math.pi / 2 + i * (2 * math.pi / n);
      final labelDist = maxRadius + 18.0;
      final labelPos = Offset(
        center.dx + labelDist * math.cos(angle),
        center.dy + labelDist * math.sin(angle),
      );

      final textSpan = TextSpan(
        text: '${item.label}\n${item.score.toInt()}%',
        style: labelStyle ??
            TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 9.0,
              fontWeight: isTop ? FontWeight.bold : FontWeight.w600,
              height: 1.15,
            ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        labelPos.dx - textPainter.width / 2,
        labelPos.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant PolygonRadarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.dimensions != dimensions;
  }
}

/// Container card wrapping the radar chart with analytics (average score,
/// highest strength, growth opportunity, and action buttons).
class RadarChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<RadarDimension> dimensions;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const RadarChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.dimensions,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sorted = List<RadarDimension>.from(dimensions)
      ..sort((a, b) => b.score.compareTo(a.score));
    final topStrength = sorted.isNotEmpty ? sorted.first : null;
    final growthFocus = sorted.isNotEmpty ? sorted.last : null;

    final avgScore = dimensions.isEmpty
        ? 0
        : (dimensions.fold<double>(0, (s, e) => s + e.score) / dimensions.length).round();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$avgScore% Avg',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Radar Canvas
            RadarChart(dimensions: dimensions),
            const SizedBox(height: 16),

            // Highlights
            if (topStrength != null && growthFocus != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      icon: Icons.star_rounded,
                      label: 'Top Strength',
                      value: '${topStrength.label} (${topStrength.score.toInt()}%)',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      icon: Icons.trending_up_rounded,
                      label: 'Growth Focus',
                      value: '${growthFocus.label} (${growthFocus.score.toInt()}%)',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],

            if (onActionTap != null && actionLabel != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onActionTap!();
                },
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
