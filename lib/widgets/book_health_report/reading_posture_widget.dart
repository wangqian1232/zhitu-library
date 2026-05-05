import 'package:flutter/material.dart';
import '../../models/models.dart';

class ReadingPostureWidget extends StatelessWidget {
  final List<ReadingPostureInfo> postures;

  const ReadingPostureWidget({super.key, required this.postures});

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
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '最佳阅读姿势',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: postures.map((posture) => _buildPostureCard(posture)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostureCard(ReadingPostureInfo posture) {
    Color bgColor;
    Color iconColor;
    switch (posture.posture) {
      case ReadingPosture.intensive:
        bgColor = const Color(0xFF667EEA).withOpacity(0.1);
        iconColor = const Color(0xFF667EEA);
        break;
      case ReadingPosture.extensive:
        bgColor = const Color(0xFF4CAF50).withOpacity(0.1);
        iconColor = const Color(0xFF4CAF50);
        break;
      case ReadingPosture.reference:
        bgColor = const Color(0xFFFF9800).withOpacity(0.1);
        iconColor = const Color(0xFFFF9800);
        break;
    }

    return Container(
      width: (MediaQueryData.fromView(
                    WidgetsBinding.instance.platformDispatcher.views.first,
                  ).size.width -
              64) /
          2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            posture.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            posture.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            posture.description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
