import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/ai_search_service.dart';
import 'book_detail_page.dart';

class AISearchPage extends StatefulWidget {
  final User user;

  const AISearchPage({super.key, required this.user});

  @override
  State<AISearchPage> createState() => _AISearchPageState();
}

class _AISearchPageState extends State<AISearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _suggestionPrompts = [];
  List<String> _searchHistory = [];
  List<Book> _searchResults = [];
  Map<String, dynamic>? _aiRecommendation;
  bool _isLoading = false;
  final bool _isSearching = false;
  bool _showSuggestions = true;
  bool _hasSearched = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history =
          prefs.getStringList('search_history_${widget.user.id}') ?? [];
      setState(() {
        _searchHistory = history;
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveSearchHistory(String query) async {
    if (query.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final history =
          prefs.getStringList('search_history_${widget.user.id}') ?? [];
      history.remove(query);
      history.insert(0, query);
      if (history.length > 10) history.removeLast();
      await prefs.setStringList('search_history_${widget.user.id}', history);
      setState(() {
        _searchHistory = history;
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history_${widget.user.id}');
      setState(() {
        _searchHistory = [];
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _loadSuggestions() async {
    final prompts = await AISearchService.getAISuggestionPrompts();
    setState(() {
      _suggestionPrompts = prompts;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _searchQuery = query.trim();
      _isLoading = true;
      _showSuggestions = false;
      _hasSearched = true;
      _searchResults = [];
      _aiRecommendation = null;
    });

    await _saveSearchHistory(query.trim());

    final extracted = await AISearchService.extractSearchKeywords(query.trim());
    final searchType = extracted['searchType'] as String? ?? 'direct';
    final keywords =
        (extracted['keywords'] as List<dynamic>?)?.cast<String>() ?? [];

    List<Book> results = [];
    if (searchType == 'direct' && keywords.isNotEmpty) {
      for (final keyword in keywords) {
        final books = await ApiService.searchBooks(title: keyword);
        for (final book in books) {
          if (!results.any((b) => b.id == book.id)) {
            results.add(book);
          }
        }
      }
      if (results.length > 5) {
        results = results.take(5).toList();
      }
    }

    if (results.isNotEmpty && searchType == 'direct') {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } else {
      final allBooks = await ApiService.getAllBooks();
      final bookTitles = allBooks.map((b) => b.title).toList();
      final recommendation = await AISearchService.generateRecommendations(
        query.trim(),
        bookTitles,
      );

      final recommendedTitles =
          (recommendation['recommendedBooks'] as List<dynamic>?)
              ?.cast<String>() ??
          [];
      final recommendedBooks = allBooks
          .where((b) => recommendedTitles.contains(b.title))
          .toList();

      setState(() {
        _searchResults = recommendedBooks;
        _aiRecommendation = recommendation;
        _isLoading = false;
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  void _onHistoryTap(String history) {
    _searchController.text = history;
    _performSearch(history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: '搜索书名、作者或描述...',
                hintStyle: const TextStyle(color: Colors.white70, fontSize: 15),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _showSuggestions = true;
                            _hasSearched = false;
                            _searchResults = [];
                            _aiRecommendation = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(fontSize: 15, color: Colors.white),
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
              onChanged: (value) {
                setState(() {
                  _showSuggestions = value.isEmpty;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI 正在理解你的搜索意图...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildDefaultState();
    }

    if (_searchResults.isEmpty && _aiRecommendation == null) {
      return _buildEmptyState();
    }

    return _buildSearchResults();
  }

  Widget _buildDefaultState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAISuggestions(),
        if (_searchHistory.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSearchHistory(),
        ],
      ],
    );
  }

  Widget _buildAISuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI 猜你想搜',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _suggestionPrompts.map((prompt) {
            return GestureDetector(
              onTap: () => _onSuggestionTap(prompt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF3E5F5), Color(0xFFE8EAF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF7C4DFF).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Color(0xFF7C4DFF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prompt,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.history, size: 18, color: Color(0xFF95A5A6)),
                SizedBox(width: 6),
                Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _clearSearchHistory,
              child: const Text(
                '清除',
                style: TextStyle(fontSize: 12, color: Color(0xFF95A5A6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _searchHistory.map((history) {
            return GestureDetector(
              onTap: () => _onHistoryTap(history),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF95A5A6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      history,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_aiRecommendation != null) _buildAIRecommendationHeader(),
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._searchResults.map((book) => _buildBookCard(book)),
        ],
        if (_aiRecommendation != null) ...[
          const SizedBox(height: 16),
          _buildFeedbackSection(),
        ],
      ],
    );
  }

  Widget _buildAIRecommendationHeader() {
    final text =
        _aiRecommendation!['recommendationText'] as String? ?? '为你推荐以下相关书籍：';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFE8EAF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BookDetailPage(book: book, user: widget.user),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.coverAsset != null && book.coverAsset!.isNotEmpty
                  ? Image.asset(
                      book.coverAsset!,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderCover(book);
                      },
                    )
                  : book.coverUrl != null && book.coverUrl!.isNotEmpty
                      ? Image.network(
                          book.coverUrl!,
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildPlaceholderCover(book);
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderCover(book);
                          },
                        )
                      : _buildPlaceholderCover(book),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF95A5A6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: book.availableCopies > 0
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          book.availableCopies > 0 ? '可借阅' : '已借出',
                          style: TextStyle(
                            fontSize: 11,
                            color: book.availableCopies > 0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '借阅 ${book.borrowCount} 次',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF95A5A6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(Book book) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            book.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI 推荐对你有帮助吗？',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFeedbackButton(
                  icon: Icons.thumb_up_outlined,
                  label: '有用',
                  color: const Color(0xFF4CAF50),
                  onTap: () => _submitFeedback(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeedbackButton(
                  icon: Icons.thumb_down_outlined,
                  label: '无用',
                  color: const Color(0xFFF44336),
                  onTap: () => _submitFeedback(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback(bool isHelpful) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackKey = 'feedback_${widget.user.id}_${_searchQuery.hashCode}';
      await prefs.setBool(feedbackKey, isHelpful);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isHelpful ? '感谢你的反馈！我们会继续优化推荐' : '感谢反馈，我们会改进推荐算法'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // ignore
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '未找到相关图书',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词吧',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
