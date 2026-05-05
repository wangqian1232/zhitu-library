import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'book_detail_page.dart';

class RecommendationDialog extends StatefulWidget {
  final User user;
  final VoidCallback onDismiss;

  const RecommendationDialog({
    super.key,
    required this.user,
    required this.onDismiss,
  });

  @override
  State<RecommendationDialog> createState() => _RecommendationDialogState();
}

class _RecommendationDialogState extends State<RecommendationDialog> {
  List<Book> _books = [];
  bool _isLoading = true;
  int _batchIndex = 0;
  final List<String> _categories = [
    '小说',
    '计算机科学',
    '数学',
    '物理',
    '化学',
    '经济学',
    '管理学',
    '中国历史',
    '中国哲学',
  ];
  int _currentCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    final category = _categories[_currentCategoryIndex % _categories.length];
    final books = await ApiService.getBooksByCategory(category);
    books.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
    if (mounted) {
      setState(() {
        _books = books.take(6).toList();
        _isLoading = false;
      });
    }
  }

  void _refreshBatch() {
    setState(() {
      _batchIndex++;
      _currentCategoryIndex = (_currentCategoryIndex + 1) % _categories.length;
    });
    _loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final categoryNames = {
      '小说': '小说精选',
      '计算机科学': '计算机精选',
      '数学': '数学精选',
      '物理': '物理精选',
      '化学': '化学精选',
      '经济学原理': '经济精选',
      '管理学': '管理精选',
      '中国历史': '历史精选',
      '中国哲学': '哲学精选',
    };
    final currentCategory = _categories[_currentCategoryIndex % _categories.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '为你精选',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '根据你的阅读喜好推荐',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    final displayBooks = _books.length > 6 ? _books.sublist(0, 6) : _books;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getCategoryLabel(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '共 ${_books.length} 本好书',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
            ),
            itemCount: displayBooks.length,
            itemBuilder: (context, index) {
              return _buildBookCard(context, displayBooks[index]);
            },
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel() {
    final categoryNames = {
      '小说': '小说精选',
      '计算机科学': '计算机精选',
      '数学': '数学精选',
      '物理': '物理精选',
      '化学': '化学精选',
      '经济学原理': '经济精选',
      '管理学': '管理精选',
      '中国历史': '历史精选',
      '中国哲学': '哲学精选',
    };
    final currentCategory = _categories[_currentCategoryIndex % _categories.length];
    return categoryNames[currentCategory] ?? '精选推荐';
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        widget.onDismiss();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BookDetailPage(book: book, user: widget.user),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildBookCover(book),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 7, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 7,
                color: Colors.orange.shade600,
              ),
              const SizedBox(width: 1),
              Text(
                '${book.borrowCount}',
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover(Book book) {
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return Image.network(
        book.coverUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderCover(book);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderCover(book);
        },
      );
    }
    if (book.coverAsset != null && book.coverAsset!.isNotEmpty) {
      return Image.asset(
        book.coverAsset!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderCover(book);
        },
      );
    }
    return _buildPlaceholderCover(book);
  }

  Widget _buildPlaceholderCover(Book book) {
    final colors = _getCoverColors(book.category);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 20, color: Colors.white),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                book.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getCoverColors(String category) {
    switch (category) {
      case '小说':
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
      case '计算机科学':
        return [const Color(0xFF11998E), const Color(0xFF38EF7D)];
      case '数学':
        return [const Color(0xFFFC5C7D), const Color(0xFF6A82FB)];
      case '物理':
        return [const Color(0xFF4568DC), const Color(0xFFB06AB3)];
      case '化学':
        return [const Color(0xFF00B4DB), const Color(0xFF0083B0)];
      case '经济学原理':
        return [const Color(0xFFF7971E), const Color(0xFFFFD200)];
      case '管理学':
        return [const Color(0xFF1A2980), const Color(0xFF26D0CE)];
      case '中国历史':
        return [const Color(0xFFC33764), const Color(0xFF1D2671)];
      case '中国哲学':
        return [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)];
      default:
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _refreshBatch,
              icon: const Icon(Icons.refresh, size: 12),
              label: const Text('换一批', style: TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: BorderSide(color: Colors.white.withOpacity(0.5)),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.onDismiss,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667EEA),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '开始阅读',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
