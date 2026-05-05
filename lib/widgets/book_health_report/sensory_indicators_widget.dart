import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/models.dart';

class SensoryIndicatorsWidget extends StatelessWidget {
  final SensoryIndicators indicators;

  const SensoryIndicatorsWidget({super.key, required this.indicators});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.palette,
                  color: Color(0xFFE91E63),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '感官指标：情绪与风格',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEmotionSection(),
          const SizedBox(height: 20),
          _buildStyleSection(),
        ],
      ),
    );
  }

  Widget _buildEmotionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.mood, size: 16, color: Color(0xFFE91E63)),
            const SizedBox(width: 8),
            Text(
              '情绪气象图',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getEmotionColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                indicators.emotionLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: _getEmotionColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          indicators.emotionInterpretation,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildEmotionChart(),
      ],
    );
  }

  Widget _buildEmotionChart() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 100),
        painter: EmotionCurvePainter(waves: indicators.emotionWaves),
      ),
    );
  }

  Widget _buildStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_paint, size: 16, color: Color(0xFF9C27B0)),
            const SizedBox(width: 8),
            Text(
              '文风DNA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: indicators.writingStyles.map((style) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStyleLabel(style),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9C27B0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, size: 16, color: Color(0xFF9C27B0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  indicators.styleAnalogy,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getEmotionColor() {
    switch (indicators.emotionType) {
      case EmotionType.tragedy:
        return Colors.blue.shade700;
      case EmotionType.comedy:
        return Colors.orange.shade700;
      case EmotionType.mixed:
        return Colors.purple.shade700;
    }
  }

  String _getStyleLabel(WritingStyle style) {
    switch (style) {
      case WritingStyle.coldObjective:
        return '冷峻客观';
      case WritingStyle.humorous:
        return '幽默风趣';
      case WritingStyle.ornate:
        return '辞藻华丽';
      case WritingStyle.minimalist:
        return '极简主义';
    }
  }
}

class EmotionCurvePainter extends CustomPainter {
  final List<EmotionWave> waves;

  EmotionCurvePainter({required this.waves});

  @override
  void paint(Canvas canvas, Size size) {
    if (waves.isEmpty) return;

    final path = Path();
    final paint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final gradientPath = Path();
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE91E63).withOpacity(0.3),
          const Color(0xFFE91E63).withOpacity(0.05),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    for (int i = 0; i < waves.length; i++) {
      final x = padding + waves[i].chapterProgress * chartWidth;
      final y = padding + chartHeight - waves[i].emotionValue * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height - padding);
        gradientPath.lineTo(x, y);
      } else {
        final prevX = padding + waves[i - 1].chapterProgress * chartWidth;
        final prevY = padding + chartHeight - waves[i - 1].emotionValue * chartHeight;
        final controlX = (prevX + x) / 2;

        path.cubicTo(controlX, prevY, controlX, y, x, y);
        gradientPath.cubicTo(controlX, prevY, controlX, y, x, y);
      }
    }

    gradientPath.lineTo(padding + chartWidth, size.height - padding);
    gradientPath.lineTo(padding, size.height - padding);
    gradientPath.close();

    canvas.drawPath(gradientPath, gradientPaint);
    canvas.drawPath(path, paint);

    for (final wave in waves) {
      final x = padding + wave.chapterProgress * chartWidth;
      final y = padding + chartHeight - wave.emotionValue * chartHeight;

      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = const Color(0xFFE91E63),
      );
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.white,
      );
    }

    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    final labelStyle = TextStyle(
      fontSize: 9,
      color: Colors.grey.shade500,
    );
    final negativeLabel = TextPainter(
      text: TextSpan(text: '负面', style: labelStyle),
      textDirection: TextDirection.ltr,
    );
    negativeLabel.layout();
    negativeLabel.paint(canvas, Offset(2, padding - 5));

    final positiveLabel = TextPainter(
      text: TextSpan(text: '正面', style: labelStyle),
      textDirection: TextDirection.ltr,
    );
    positiveLabel.layout();
    positiveLabel.paint(canvas, Offset(2, size.height - padding - 12));

    final progressLabel = TextPainter(
      text: TextSpan(text: '章节进度 →', style: labelStyle),
      textDirection: TextDirection.ltr,
    );
    progressLabel.layout();
    progressLabel.paint(
      canvas,
      Offset(size.width - padding - 50, size.height - 2),
    );
  }

  @override
  bool shouldRepaint(EmotionCurvePainter oldDelegate) => oldDelegate.waves != waves;
}
