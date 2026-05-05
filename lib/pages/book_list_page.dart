import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/shared_book_service.dart';
import '../widgets/carousel_banner.dart';
import 'ai_search_page.dart';
import 'book_detail_page.dart';
import 'borrow_ranking_page.dart';
import 'shared_book_detail_page.dart';

class BookListPage extends StatefulWidget {
  final User user;
  final VoidCallback? onNavigateToProfile;

  const BookListPage({super.key, required this.user, this.onNavigateToProfile});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  String _searchQuery = '';
  String? _selectedMajorCategory;
  String? _selectedCategory;
  BookStatus? _selectedStatus;
  List<Book> _books = [];
  List<Book> _topBorrowedBooks = [];
  List<SharedBook> _sharedBooks = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadBooks();
    loadRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    List<Book> books;
    if (_searchQuery.isNotEmpty) {
      books = await ApiService.searchBooks(title: _searchQuery);
    } else if (_selectedMajorCategory != null && _selectedCategory != null) {
      books = await ApiService.getBooksByMajorCategory(_selectedMajorCategory!);
      books = books
          .where((book) => book.category == _selectedCategory)
          .toList();
    } else if (_selectedMajorCategory != null) {
      books = await ApiService.getBooksByMajorCategory(_selectedMajorCategory!);
    } else if (_selectedCategory != null) {
      books = await ApiService.getBooksByCategory(_selectedCategory!);
    } else {
      books = await ApiService.getAllBooks();
    }

    final sharedBooks = SharedBookService().getAllSharedBooks();

    setState(() {
      _books = books;
      _sharedBooks = sharedBooks;
      _isLoading = false;
    });
  }

  List<Book> get _filteredBooks {
    if (_selectedStatus == null) return _books;
    return _books.where((book) {
      switch (_selectedStatus) {
        case BookStatus.available:
          return book.status == BookStatus.available;
        case BookStatus.borrowed:
          return book.status == BookStatus.borrowed;
        default:
          return true;
      }
    }).toList();
  }

  Future<void> loadRecommendations() async {
    final topBorrowed = await ApiService.getTopBooks(limit: 10);
    setState(() {
      _topBorrowedBooks = topBorrowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      '智图图书馆',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onNavigateToProfile,
                      child: Row(
                        children: [
                          Text(
                            widget.user.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            backgroundImage: widget.user.avatar != null
                                ? AssetImage(widget.user.avatar!)
                                : null,
                            child: widget.user.avatar == null
                                ? Text(
                                    widget.user.username.isNotEmpty
                                        ? widget.user.username[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AISearchPage(user: widget.user),
                      ),
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索书名、作者或描述...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  loadBooks();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                        loadBooks();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (_searchQuery.isEmpty) ...[
                  SliverToBoxAdapter(child: _buildCarouselBanner(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _buildBorrowRanking(context)),
                ],
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '分类筛选',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildMajorCategoryFilterChip(null, '全部'),
                                    _buildMajorCategoryFilterChip('工学', '工学'),
                                    _buildMajorCategoryFilterChip('理学', '理学'),
                                    _buildMajorCategoryFilterChip('文学', '文学'),
                                    _buildMajorCategoryFilterChip('艺术', '艺术'),
                                    _buildMajorCategoryFilterChip('历史', '历史'),
                                    _buildMajorCategoryFilterChip('哲学', '哲学'),
                                    _buildMajorCategoryFilterChip('经济', '经济'),
                                    _buildMajorCategoryFilterChip('管理', '管理'),
                                    _buildMajorCategoryFilterChip('医学', '医学'),
                                    _buildMajorCategoryFilterChip('教育学', '教育学'),
                                    _buildMajorCategoryFilterChip('农学', '农学'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedMajorCategory != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                '二级分类',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterChip(null, '全部'),
                                      ..._getSubCategories().map(
                                        (c) => _buildFilterChip(c, c),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              '状态筛选',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(null, '全部'),
                            _buildStatusChip(BookStatus.available, '可借'),
                            _buildStatusChip(BookStatus.borrowed, '借出'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '共 ${_filteredBooks.length} 本图书',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (widget.user.role == UserRole.admin)
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('新增图书'),
                          ),
                      ],
                    ),
                  ),
                ),
                _isLoading
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _filteredBooks.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '未找到相关图书',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final totalItems =
                                _filteredBooks.length + _sharedBooks.length;
                            if (index < _filteredBooks.length) {
                              final book = _filteredBooks[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildBookCard(
                                  context,
                                  book,
                                  isShared: false,
                                ),
                              );
                            } else {
                              final sharedBookIndex =
                                  index - _filteredBooks.length;
                              final sharedBook = _sharedBooks[sharedBookIndex];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildSharedBookCard(
                                  context,
                                  sharedBook,
                                ),
                              );
                            }
                          },
                          childCount:
                              _filteredBooks.length + _sharedBooks.length,
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMajorCategoryFilterChip(String? value, String label) {
    final isSelected = _selectedMajorCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedMajorCategory = value;
              _selectedCategory = null;
            } else {
              _selectedMajorCategory = null;
              _selectedCategory = null;
            }
          });
          loadBooks();
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        showCheckmark: false,
      ),
    );
  }

  Widget _buildFilterChip(String? value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? value : null;
          });
          loadBooks();
        },
        selectedColor: Theme.of(context).colorScheme.secondaryContainer,
        showCheckmark: false,
      ),
    );
  }

  Widget _buildStatusChip(BookStatus? value, String label) {
    final isSelected = _selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? value : null;
          });
          loadBooks();
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        showCheckmark: false,
      ),
    );
  }

  Widget _buildCarouselBanner(BuildContext context) {
    final bannerItems = [
      BannerItem(
        title: '新书推荐',
        subtitle: '本月新入库的好书，快来抢先阅读！',
        tag: 'NEW',
        tagColor: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFF2196F3),
        icon: Icons.auto_stories,
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('新书推荐页面开发中...')));
        },
      ),
      BannerItem(
        title: '21天阅读打卡挑战',
        subtitle: '坚持阅读21天，养成好习惯！',
        tag: '活动',
        tagColor: const Color(0xFFFF9800),
        backgroundColor: const Color(0xFF9C27B0),
        icon: Icons.emoji_events,
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('活动详情页面开发中...')));
        },
      ),
      BannerItem(
        title: '馆长本月私藏书单',
        subtitle: '精选经典好书，值得一读再读',
        tag: '推荐',
        tagColor: const Color(0xFFE91E63),
        backgroundColor: const Color(0xFFFF5722),
        icon: Icons.favorite,
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('推荐书单页面开发中...')));
        },
      ),
      BannerItem(
        title: '五一假期开放时间调整',
        subtitle: '5月1日-5月3日 9:00-17:00',
        tag: '通知',
        tagColor: const Color(0xFF607D8B),
        backgroundColor: const Color(0xFF009688),
        icon: Icons.notifications_active,
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('通知详情页面开发中...')));
        },
      ),
    ];

    return CarouselBanner(items: bannerItems, height: 140);
  }

  Widget _buildSharedBooksSection(BuildContext context) {
    final sharedBooks = SharedBookService().getAllSharedBooks();
    if (sharedBooks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9A56), Color(0xFFFF6B6B)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '共享图书专区',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('共享图书列表页开发中...')),
                  );
                },
                child: const Row(
                  children: [
                    Text('查看全部', style: TextStyle(fontSize: 14)),
                    Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sharedBooks.length,
            itemBuilder: (context, index) {
              final book = sharedBooks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SharedBookDetailPage(book: book),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 3 / 4,
                              child:
                                  book.coverAsset != null &&
                                      book.coverAsset!.isNotEmpty
                                  ? Image.asset(
                                      book.coverAsset!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.book,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : book.coverUrl != null
                                  ? Image.network(
                                      book.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.book,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.book,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF9A56),
                                      Color(0xFFFF6B6B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '共享',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 10,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    book.sharerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBorrowRanking(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: ApiService.getTopBooks(limit: 10),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final top3 = snapshot.data!.take(3).toList();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF8F9FA)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [Colors.amber.shade50, Colors.orange.shade50],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '借阅榜单',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const BorrowRankingPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '查看全部',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: top3.asMap().entries.map((entry) {
                    final index = entry.key;
                    final book = entry.value;
                    return _buildRankingItem(context, book, index + 1);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingItem(BuildContext context, Book book, int rank) {
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) =>
                      BookDetailPage(book: book, user: widget.user),
                ),
              )
              .then((_) => loadBooks());
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: rank <= 3
                      ? LinearGradient(
                          colors: [rankColor, rankColor.withOpacity(0.7)],
                        )
                      : null,
                  color: rank > 3 ? Colors.grey.shade100 : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: rank <= 3 ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${book.borrowCount}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    Book book, {
    bool isShared = false,
  }) {
    final theme = Theme.of(context);
    final isFavorite = book.isFavoriteBy(widget.user.id);

    return Card(
      elevation: isShared ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isShared
            ? BorderSide(
                color: const Color(0xFFFF9A56).withOpacity(0.6),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Container(
        decoration: isShared
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFFF9A56).withOpacity(0.05),
                  ],
                ),
              )
            : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) =>
                        BookDetailPage(book: book, user: widget.user),
                  ),
                )
                .then((_) => loadBooks());
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isShared
                            ? Border.all(
                                color: const Color(0xFFFF9A56),
                                width: 2,
                              )
                            : Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildBookCover(book),
                      ),
                    ),
                    if (isShared)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9A56), Color(0xFFFF6B6B)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9A56).withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.volunteer_activism,
                                color: Colors.white,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                '共享',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          bool currentFavorite = book.isFavoriteBy(
                            widget.user.id,
                          );
                          return GestureDetector(
                            onTap: () async {
                              final result = await ApiService.toggleFavorite(
                                widget.user.id,
                                book.id,
                              );
                              if (result['success'] == true) {
                                setState(() {
                                  currentFavorite =
                                      result['isFavorited'] == true;
                                });
                                if (mounted) {
                                  loadBooks();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['isFavorited'] == true
                                            ? '成功收藏《${book.title}》'
                                            : '已取消收藏《${book.title}》',
                                      ),
                                      backgroundColor:
                                          result['isFavorited'] == true
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                currentFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: currentFavorite
                                    ? Colors.red
                                    : Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isShared)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9A56),
                                    Color(0xFFFF6B6B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.volunteer_activism,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '共享图书',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '同学共享',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFFFF9A56),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isShared ? const Color(0xFFE65100) : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '作者：${book.author}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '出版社：${book.publisher}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${book.borrowCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: book.availableCopies > 0
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  book.availableCopies > 0
                                      ? Icons.check_circle
                                      : Icons.access_time,
                                  size: 14,
                                  color: book.availableCopies > 0
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  book.availableCopies > 0
                                      ? '可借 (${book.availableCopies})'
                                      : '已借出',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: book.availableCopies > 0
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (book.availableCopies > 0)
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => BookDetailPage(
                                          book: book,
                                          user: widget.user,
                                        ),
                                      ),
                                    )
                                    .then((_) => loadBooks());
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                side: BorderSide(
                                  color: isShared
                                      ? const Color(0xFFFF9A56)
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '借阅',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isShared
                                      ? const Color(0xFFFF9A56)
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                          else
                            OutlinedButton(
                              onPressed: () async {
                                final result = await ApiService.reserveBook(
                                  widget.user.id,
                                  book.id,
                                );
                                if (result['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('预约成功《${book.title}》'),
                                    ),
                                  );
                                  loadBooks();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['message'] ?? '预约失败',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                side: BorderSide(color: Colors.orange.shade600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '预约',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade600,
                                ),
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
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(BuildContext context, Book book) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.menu_book, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          book.category,
          style: TextStyle(fontSize: 9, color: theme.colorScheme.primary),
          textAlign: TextAlign.center,
        ),
      ],
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getCoverColors(book.category),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              book.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              book.category,
              style: const TextStyle(color: Colors.white, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getCoverColors(String category) {
    switch (category) {
      case '计算机科学':
        return [const Color(0xFF1A237E), const Color(0xFF283593)];
      case '软件工程':
        return [const Color(0xFF004D40), const Color(0xFF00695C)];
      case '计算机网络':
        return [const Color(0xFFB71C1C), const Color(0xFFC62828)];
      case '操作系统':
        return [const Color(0xFFE65100), const Color(0xFFF57C00)];
      case '数据库':
        return [const Color(0xFF4A148C), const Color(0xFF6A1B9A)];
      case '编译原理':
        return [const Color(0xFF1B5E20), const Color(0xFF2E7D32)];
      case '人工智能':
        return [const Color(0xFF0D47A1), const Color(0xFF1565C0)];
      default:
        return [const Color(0xFF37474F), const Color(0xFF455A64)];
    }
  }

  List<String> _getSubCategories() {
    final Map<String, List<String>> categoryTree = {
      '工学': [
        '计算机系统',
        '数据结构',
        '算法',
        '计算机网络',
        '操作系统',
        '编译原理',
        '数据库',
        '人工智能',
        '编程语言',
        '软件工程',
        '机械工程',
        '土木工程',
        '电子工程',
      ],
      '理学': ['数学', '物理', '化学', '生物', '地理'],
      '文学': ['小说', '散文', '诗歌', '戏剧', '文学理论'],
      '艺术': ['音乐', '美术', '设计', '电影', '舞蹈'],
      '历史': ['中国历史', '世界历史', '考古学', '历史地理'],
      '哲学': ['中国哲学', '西方哲学', '伦理学', '逻辑学', '美学'],
      '经济': ['经济学原理', '金融学', '国际贸易', '财政学', '统计学'],
      '管理': ['管理学', '会计学', '市场营销', '人力资源管理', '工商管理'],
      '医学': ['基础医学', '临床医学', '药学', '护理学', '中医学'],
      '教育学': ['教育学', '体育教育', '教育技术学'],
      '农学': ['农学'],
    };
    return categoryTree[_selectedMajorCategory] ?? [];
  }

  Widget _buildSharedBookCard(BuildContext context, SharedBook book) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFFF9A56).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SharedBookDetailPage(book: book),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          book.coverAsset != null && book.coverAsset!.isNotEmpty
                          ? Image.asset(
                              book.coverAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.book,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.book,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A56), Color(0xFFFF6B6B)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '共享',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.sharerGrade} ${book.sharerDepartment} ${book.sharerName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(
                              book.condition,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getConditionText(book.condition),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getConditionColor(book.condition),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: book.shareType == ShareType.permanent
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            book.shareType == ShareType.permanent
                                ? '永久捐赠'
                                : '临时寄存',
                            style: TextStyle(
                              fontSize: 11,
                              color: book.shareType == ShareType.permanent
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '索书号: ${book.shelfNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Color _getConditionColor(BookCondition condition) {
    switch (condition) {
      case BookCondition.brandNew:
        return Colors.green;
      case BookCondition.likeNew:
        return Colors.blue;
      case BookCondition.hasNotes:
        return Colors.orange;
      case BookCondition.hasDamage:
        return Colors.red;
    }
  }

  String _getConditionText(BookCondition condition) {
    switch (condition) {
      case BookCondition.brandNew:
        return '全新';
      case BookCondition.likeNew:
        return '九成新';
      case BookCondition.hasNotes:
        return '有笔记';
      case BookCondition.hasDamage:
        return '有破损';
    }
  }
}
