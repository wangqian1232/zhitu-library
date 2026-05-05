import 'package:flutter/material.dart';

class InterestTag {
  final String id;
  final String label;
  final String emoji;
  final List<String> categories;

  const InterestTag({
    required this.id,
    required this.label,
    required this.emoji,
    required this.categories,
  });
}

class InterestSelectionPage extends StatefulWidget {
  final Function(List<String>) onComplete;
  final VoidCallback onSkip;

  const InterestSelectionPage({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<InterestSelectionPage> createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> {
  final Set<String> _selectedTags = {};

  static const List<InterestTag> _allTags = [
    InterestTag(
      id: 'exam',
      label: '考研考证',
      emoji: '📚',
      categories: ['计算机科学与技术', '数学与应用数学', '英语', '政治学与行政学'],
    ),
    InterestTag(
      id: 'cs',
      label: '计算机/编程',
      emoji: '💻',
      categories: ['计算机科学与技术', '软件工程', '电子信息工程'],
    ),
    InterestTag(
      id: 'literature',
      label: '文学/小说',
      emoji: '📖',
      categories: ['汉语言文学', '小说', '英语', '翻译'],
    ),
    InterestTag(
      id: 'art',
      label: '艺术/设计',
      emoji: '🎨',
      categories: ['视觉传达设计', '音乐学', '美术学', '环境设计', '产品设计'],
    ),
    InterestTag(
      id: 'science',
      label: '科普/百科',
      emoji: '🔬',
      categories: ['物理学', '化学', '生物科学', '数学与应用数学', '地理科学'],
    ),
    InterestTag(
      id: 'business',
      label: '经管/职场',
      emoji: '💼',
      categories: ['金融学', '会计学', '工商管理', '市场营销', '人力资源管理'],
    ),
    InterestTag(
      id: 'law',
      label: '法学/社科',
      emoji: '⚖️',
      categories: ['法学', '社会学', '政治学与行政学', '社会工作'],
    ),
    InterestTag(
      id: 'medicine',
      label: '医学/健康',
      emoji: '🏥',
      categories: ['临床医学', '药学', '护理学', '心理学', '中医学'],
    ),
    InterestTag(
      id: 'education',
      label: '教育/心理',
      emoji: '🎓',
      categories: ['教育学', '心理学', '学前教育', '小学教育', '应用心理学'],
    ),
    InterestTag(
      id: 'history',
      label: '历史/哲学',
      emoji: '🏛️',
      categories: ['历史学', '哲学', '汉语言文学'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text(
                        '暂时跳过',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '选择你感兴趣的领域',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '为你定制专属书单',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '已选择 ${_selectedTags.length} 个标签',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _allTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag.id);
                      return _buildTagChip(tag, isSelected);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedTags.isEmpty ? null : _handleComplete,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: _selectedTags.isEmpty
                ? Colors.grey.shade300
                : theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(
            '完成并进入 (${_selectedTags.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(InterestTag tag, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag.id);
          } else {
            _selectedTags.add(tag.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tag.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              tag.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade700,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleComplete() {
    final categories = <String>{};
    for (final tagId in _selectedTags) {
      final tag = _allTags.firstWhere((t) => t.id == tagId);
      categories.addAll(tag.categories);
    }
    widget.onComplete(categories.toList());
  }
}
