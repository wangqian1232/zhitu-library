import 'package:flutter/material.dart';
import '../../models/models.dart';

class SocialAndWarningWidget extends StatelessWidget {
  final SocialAndWarningIndicators indicators;

  const SocialAndWarningWidget({super.key, required this.indicators});

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
                  color: const Color(0xFF607D8B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people,
                  color: Color(0xFF607D8B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '社交与避雷指标',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAudienceSection(),
          const SizedBox(height: 20),
          _buildWarningSection(),
        ],
      ),
    );
  }

  Widget _buildAudienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.group, size: 16, color: Color(0xFF607D8B)),
            const SizedBox(width: 8),
            Text(
              '人群适配度',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...indicators.audienceMatches.map((match) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      match.audience,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${match.matchPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _getMatchColor(match.matchPercentage),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: match.matchPercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getMatchColor(match.matchPercentage),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  match.reason,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWarningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber, size: 16, color: Color(0xFFF44336)),
            const SizedBox(width: 8),
            Text(
              '阅读避雷针',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...indicators.warnings.map((warning) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getWarningBgColor(warning.type),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getWarningBorderColor(warning.type),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(warning.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        warning.type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getWarningTextColor(warning.type),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        warning.content,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green.shade600;
    if (percentage >= 60) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getWarningBgColor(String type) {
    switch (type) {
      case '内容时效':
        return Colors.orange.shade50;
      case '难度预警':
        return Colors.red.shade50;
      case '学习建议':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getWarningBorderColor(String type) {
    switch (type) {
      case '内容时效':
        return Colors.orange.shade200;
      case '难度预警':
        return Colors.red.shade200;
      case '学习建议':
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getWarningTextColor(String type) {
    switch (type) {
      case '内容时效':
        return Colors.orange.shade700;
      case '难度预警':
        return Colors.red.shade700;
      case '学习建议':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
