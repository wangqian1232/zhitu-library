import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/models.dart';

class TimeCostWidget extends StatelessWidget {
  final TimeCost timeCost;

  const TimeCostWidget({super.key, required this.timeCost});

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
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '时间成本预估',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeDisplay(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSessionDisplay(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            timeCost.aiSuggestion,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomPaint(
            size: const Size(60, 60),
            painter: ClockPainter(progress: timeCost.totalMinutes / 600),
          ),
          const SizedBox(height: 8),
          Text(
            timeCost.formattedTime,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
          Text(
            '预计阅读时长',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${timeCost.suggestedSessions}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          Text(
            '建议分${timeCost.suggestedSessions}次读完',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final double progress;

  ClockPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    final hourAngle = (progress * 12 / 10) * 2 * math.pi - math.pi / 2;
    final hourHandLength = radius * 0.5;
    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(hourAngle) * hourHandLength,
        center.dy + math.sin(hourAngle) * hourHandLength,
      ),
      Paint()
        ..color = const Color(0xFF333333)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    final minuteAngle = (progress * 60 / 600) * 2 * math.pi - math.pi / 2;
    final minuteHandLength = radius * 0.7;
    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(minuteAngle) * minuteHandLength,
        center.dy + math.sin(minuteAngle) * minuteHandLength,
      ),
      Paint()
        ..color = const Color(0xFFFF9800)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      center,
      3,
      Paint()..color = const Color(0xFF333333),
    );
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => oldDelegate.progress != progress;
}
