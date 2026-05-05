import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/models.dart';

class NutritionIndicatorsWidget extends StatefulWidget {
  final NutritionIndicators indicators;

  const NutritionIndicatorsWidget({super.key, required this.indicators});

  @override
  State<NutritionIndicatorsWidget> createState() => _NutritionIndicatorsWidgetState();
}

class _NutritionIndicatorsWidgetState extends State<NutritionIndicatorsWidget> {
  int? _selectedSkillIndex;

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
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '营养指标：知识摄入与技能',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildKnowledgeSection(),
          const SizedBox(height: 20),
          _buildSkillsSection(),
        ],
      ),
    );
  }

  Widget _buildKnowledgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.pie_chart, size: 16, color: Color(0xFF2196F3)),
            const SizedBox(width: 8),
            Text(
              '知识营养成分表',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: DonutChartPainter(contents: widget.indicators.knowledgeContents),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.indicators.knowledgeContents.map((content) {
                  final index = widget.indicators.knowledgeContents.indexOf(content);
                  final colors = [
                    const Color(0xFF2196F3),
                    const Color(0xFF4CAF50),
                    const Color(0xFFFF9800),
                    const Color(0xFF9C27B0),
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${content.name} ${content.percentage.toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.comment, size: 16, color: Color(0xFF2196F3)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.indicators.aiComment,
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

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, size: 16, color: Color(0xFFFF9800)),
            const SizedBox(width: 8),
            Text(
              '技能树点亮',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.indicators.hardSkills.isNotEmpty) ...[
          Text(
            '硬技能',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.indicators.hardSkills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              final isSelected = _selectedSkillIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSkillIndex = isSelected ? null : index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF9800).withOpacity(0.2)
                        : const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF9800)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(skill.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        skill.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFFF9800),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (widget.indicators.softSkills.isNotEmpty) ...[
          Text(
            '软技能',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.indicators.softSkills.asMap().entries.map((entry) {
              final index = entry.key + widget.indicators.hardSkills.length;
              final skill = entry.value;
              final isSelected = _selectedSkillIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSkillIndex = isSelected ? null : index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50).withOpacity(0.2)
                        : const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(skill.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        skill.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (_selectedSkillIndex != null) ...[
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF667EEA)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getSelectedSkillDescription(),
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
      ],
    );
  }

  String _getSelectedSkillDescription() {
    final allSkills = [
      ...widget.indicators.hardSkills,
      ...widget.indicators.softSkills,
    ];
    if (_selectedSkillIndex != null && _selectedSkillIndex! < allSkills.length) {
      return allSkills[_selectedSkillIndex!].description;
    }
    return '';
  }
}

class DonutChartPainter extends CustomPainter {
  final List<KnowledgeContent> contents;

  DonutChartPainter({required this.contents});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final strokeWidth = 16.0;

    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
    ];

    double startAngle = -math.pi / 2;

    for (int i = 0; i < contents.length; i++) {
      final sweepAngle = 2 * math.pi * (contents[i].percentage / 100);

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    canvas.drawCircle(
      center,
      radius - strokeWidth / 2 - 4,
      Paint()..color = Colors.white,
    );

    final totalText = TextPainter(
      text: const TextSpan(
        text: '100%',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    totalText.layout();
    totalText.paint(
      canvas,
      Offset(
        center.dx - totalText.width / 2,
        center.dy - totalText.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) => oldDelegate.contents != contents;
}
