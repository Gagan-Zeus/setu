import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class Series {
  const Series(
      {required this.values, required this.color, required this.label});
  final List<double> values;
  final Color color;
  final String label;
}

/// A reference line, e.g. the 140/90 hypertension threshold on the BP chart.
class RefLine {
  const RefLine({required this.value, required this.label});
  final double value;
  final String label;
}

/// Thin lines, no fills, no gradients, no 3D. Per the brief.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.series,
    required this.xLabels,
    this.refLines = const [],
    this.height = 168,
  });

  final List<Series> series;
  final List<String> xLabels;
  final List<RefLine> refLines;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasData = series.any((s) => s.values.isNotEmpty);
    if (!hasData) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No readings yet', style: T.small),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendPainter(
              series: series,
              xLabels: xLabels,
              refLines: refLines,
              direction: Directionality.of(context),
            ),
          ),
        ),
        if (series.length > 1) ...[
          const SizedBox(height: S.sm),
          Wrap(
            spacing: S.md,
            runSpacing: S.xs,
            children: [
              for (final s in series)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 14, height: 2, color: s.color),
                    const SizedBox(width: S.xs),
                    Text(s.label, style: T.small),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.series,
    required this.xLabels,
    required this.refLines,
    required this.direction,
  });

  final List<Series> series;
  final List<String> xLabels;
  final List<RefLine> refLines;
  final TextDirection direction;

  static const _left = 34.0;
  static const _bottom = 20.0;
  static const _top = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final all = series.expand((s) => s.values).toList();
    if (all.isEmpty) return;

    var minY = all.reduce((a, b) => a < b ? a : b);
    var maxY = all.reduce((a, b) => a > b ? a : b);
    for (final r in refLines) {
      minY = minY < r.value ? minY : r.value;
      maxY = maxY > r.value ? maxY : r.value;
    }
    final pad = (maxY - minY) == 0 ? 2.0 : (maxY - minY) * 0.2;
    minY -= pad;
    maxY += pad;

    final plot =
        Rect.fromLTRB(_left, _top, size.width - 4, size.height - _bottom);
    double yAt(double v) =>
        plot.bottom - plot.height * ((v - minY) / (maxY - minY));

    // Two hairline gridlines, values on the left.
    final grid = Paint()
      ..color = C.divider
      ..strokeWidth = 1;
    for (final t in [0.0, 0.5, 1.0]) {
      final y = plot.bottom - plot.height * t;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      _text(canvas, (minY + (maxY - minY) * t).toStringAsFixed(0),
          Offset(plot.left - 6, y),
          align: _Align.right);
    }

    // Reference bands sit behind the data, dashed, in the clinical colour.
    for (final r in refLines) {
      final y = yAt(r.value);
      _dashed(canvas, Offset(plot.left, y), Offset(plot.right, y), C.amber);
      _text(canvas, r.label, Offset(plot.right, y - 12),
          align: _Align.right, colour: C.amber);
    }

    for (final s in series) {
      if (s.values.isEmpty) continue;
      final n = s.values.length;
      double xAt(int i) =>
          n == 1 ? plot.center.dx : plot.left + plot.width * (i / (n - 1));

      final path = Path();
      for (var i = 0; i < n; i++) {
        final p = Offset(xAt(i), yAt(s.values[i]));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
      for (var i = 0; i < n; i++) {
        canvas.drawCircle(
            Offset(xAt(i), yAt(s.values[i])), 2.4, Paint()..color = s.color);
      }
    }

    final n = series.first.values.length;
    for (var i = 0; i < xLabels.length && i < n; i++) {
      // Only the ends, so a dense series does not turn into mush.
      if (n > 4 && i != 0 && i != n - 1) continue;
      final x =
          n == 1 ? plot.center.dx : plot.left + plot.width * (i / (n - 1));
      _text(canvas, xLabels[i], Offset(x, size.height - _bottom + 4),
          align: i == 0 ? _Align.left : _Align.right);
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Color colour) {
    final paint = Paint()
      ..color = colour.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const dash = 4.0;
    var x = a.dx;
    while (x < b.dx) {
      canvas.drawLine(Offset(x, a.dy), Offset(x + dash, a.dy), paint);
      x += dash * 2;
    }
  }

  void _text(Canvas canvas, String text, Offset at,
      {required _Align align, Color colour = C.textSoft}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: T.label.copyWith(color: colour, letterSpacing: 0),
      ),
      textDirection: direction,
    )..layout();
    final dx = switch (align) {
      _Align.left => at.dx,
      _Align.right => at.dx - tp.width,
    };
    tp.paint(canvas, Offset(dx, at.dy - (align == _Align.right ? 5 : 0)));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.series != series || old.refLines != refLines;
}

enum _Align { left, right }

/// Horizontal bars. Used for registrations by village.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({super.key, required this.data, this.colour = C.teal});

  final Map<String, int> data;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const EmptyBar();
    }
    final max = data.values.reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final e in data.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: S.sm),
            child: Row(
              children: [
                SizedBox(width: 92, child: Text(e.key, style: T.small)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: max == 0 ? 0 : e.value / max,
                      minHeight: 6,
                      backgroundColor: C.bg,
                      valueColor: AlwaysStoppedAnimation<Color>(colour),
                    ),
                  ),
                ),
                const SizedBox(width: S.sm),
                SizedBox(
                  width: 22,
                  child: Text('${e.value}',
                      style: T.mono.copyWith(fontSize: 13),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class EmptyBar extends StatelessWidget {
  const EmptyBar({super.key});

  @override
  Widget build(BuildContext context) => const Text('No data', style: T.small);
}
