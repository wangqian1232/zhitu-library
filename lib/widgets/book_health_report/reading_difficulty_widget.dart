import 'package:flutter/material.dart';
import '../../models/models.dart';

class ReadingDifficultyWidget extends StatelessWidget {
  final ReadingDifficulty difficulty;

  const ReadingDifficultyWidget({super.key, required this.difficulty});

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
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '阅读难度指数',
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
              Text(
                '难度评分',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < difficulty.starRating
                        ? Icons.star
                        : Icons.star_border,
                    color: index < difficulty.starRating
                        ? Colors.amber
                        : Colors.grey.shade300,
                    size: 20,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            difficulty.aiInterpretation,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildDifficultyGauge(),
        ],
      ),
    );
  }

  Widget _buildDifficultyGauge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '通俗易懂',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green.shade600,
              ),
            ),
            Text(
              '晦涩难懂',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF8BC34A),
                    Color(0xFFFFEB3B),
                    Color(0xFFFF9800),
                    Color(0xFFF44336),
                  ],
                ),
              ),
            ),
            Positioned(
              left: difficulty.difficultyValue *
                  (MediaQueryData.fromView(
                            WidgetsBinding.instance.platformDispatcher.views.first,
                          ).size.width -
                      64),
              top: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF667EEA),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
