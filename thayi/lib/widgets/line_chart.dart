import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class ChartSeries {
  const ChartSeries({
    required this.values,
    required this.color,
    required this.label,
  });

  final List<double> values;
  final Color color;
  final String label;
}

/// Deliberately small: a grid, one or two lines, dots, and edge labels.
/// Drawn with CustomPainter rather than a dashboard library.
class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart({
    super.key,
    required this.series,
    required this.xLabels,
    this.height = 190,
  });

  final List<ChartSeries> series;
  final List<String> xLabels;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _LineChartPainter(
              series: series,
              xLabels: xLabels,
              textDirection: Directionality.of(context),
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
                    Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: S.xs),
                    Text(s.label, style: T.label),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.xLabels,
    required this.textDirection,
  });

  final List<ChartSeries> series;
  final List<String> xLabels;
  final TextDirection textDirection;

  static const _leftGutter = 44.0;
  static const _bottomGutter = 26.0;
  static const _topPad = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || series.first.values.isEmpty) return;

    final all = series.expand((s) => s.values).toList();
    var minY = all.reduce((a, b) => a < b ? a : b);
    var maxY = all.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) == 0 ? 2.0 : (maxY - minY) * 0.18;
    minY -= pad;
    maxY += pad;

    final plot = Rect.fromLTRB(
      _leftGutter,
      _topPad,
      size.width - S.sm,
      size.height - _bottomGutter,
    );

    final grid = Paint()
      ..color = C.divider
      ..strokeWidth = 1;

    // Three gridlines with their values on the left.
    for (var i = 0; i < 3; i++) {
      final t = i / 2;
      final y = plot.bottom - plot.height * t;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      final value = minY + (maxY - minY) * t;
      _text(
        canvas,
        value.toStringAsFixed(0),
        Offset(plot.left - S.sm, y),
        align: _Align.right,
        style: T.label.copyWith(fontSize: 13),
      );
    }

    final count = series.first.values.length;
    double xAt(int i) => count == 1
        ? plot.center.dx
        : plot.left + plot.width * (i / (count - 1));
    double yAt(double v) =>
        plot.bottom - plot.height * ((v - minY) / (maxY - minY));

    for (final s in series) {
      final path = Path();
      for (var i = 0; i < s.values.length; i++) {
        final p = Offset(xAt(i), yAt(s.values[i]));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      for (var i = 0; i < s.values.length; i++) {
        final p = Offset(xAt(i), yAt(s.values[i]));
        canvas.drawCircle(p, 5, Paint()..color = C.card);
        canvas.drawCircle(
          p,
          5,
          Paint()
            ..color = s.color
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }
    }

    for (var i = 0; i < xLabels.length && i < count; i++) {
      _text(
        canvas,
        xLabels[i],
        Offset(xAt(i), size.height - _bottomGutter + S.xs),
        align: _Align.center,
        style: T.label.copyWith(fontSize: 13),
      );
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset at, {
    required _Align align,
    required TextStyle style,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
    )..layout();
    final dx = switch (align) {
      _Align.left => at.dx,
      _Align.center => at.dx - tp.width / 2,
      _Align.right => at.dx - tp.width,
    };
    final dy = align == _Align.right ? at.dy - tp.height / 2 : at.dy;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.series != series || old.xLabels != xLabels;
}

enum _Align { left, center, right }
