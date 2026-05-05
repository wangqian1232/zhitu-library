import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'book_detail_page.dart';

class BorrowRankingPage extends StatefulWidget {
  const BorrowRankingPage({super.key});

  @override
  State<BorrowRankingPage> createState() => _BorrowRankingPageState();
}

class _BorrowRankingPageState extends State<BorrowRankingPage> {
  List<Book> _topBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    final books = await ApiService.getTopBooks(limit: 20);
    if (mounted) {
      setState(() {
        _topBooks = books;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('借阅榜单'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _topBooks.length,
              itemBuilder: (context, index) {
                final book = _topBooks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRankingCard(context, book, index + 1),
                );
              },
            ),
    );
  }

  Widget _buildRankingCard(BuildContext context, Book book, int rank) {
    final isTop1 = rank == 1;
    final isTop2 = rank == 2;
    final isTop3 = rank == 3;

    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        gradient: isTop1
            ? LinearGradient(
                colors: [const Color(0xFFFFF8E1), const Color(0xFFFFF3E0)],
              )
            : isTop2
            ? LinearGradient(
                colors: [const Color(0xFFF5F5F5), const Color(0xFFEEEEEE)],
              )
            : isTop3
            ? LinearGradient(
                colors: [const Color(0xFFFFF3E0), const Color(0xFFFBE9E7)],
              )
            : null,
        color: rank > 3 ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isTop1
                ? Colors.amber.withOpacity(0.2)
                : isTop2
                ? Colors.grey.withOpacity(0.15)
                : isTop3
                ? Colors.orange.withOpacity(0.15)
                : Colors.black.withOpacity(0.06),
            blurRadius: isTop1 ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isTop1
              ? Colors.amber.shade200
              : isTop2
              ? Colors.grey.shade300
              : isTop3
              ? Colors.orange.shade200
              : Colors.grey.shade100,
          width: isTop1 ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookDetailPage(
                  book: book,
                  user: User(
                    id: 'temp',
                    username: 'user',
                    email: '',
                    phone: '',
                    role: UserRole.user,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: rank <= 3
                        ? LinearGradient(
                            colors: [rankColor, rankColor.withOpacity(0.7)],
                          )
                        : null,
                    color: rank > 3 ? Colors.grey.shade100 : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: rank <= 3
                        ? [
                            BoxShadow(
                              color: rankColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: rank <= 3 ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: rank <= 3 ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: isTop1 ? 16 : 15,
                          fontWeight: isTop1
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${book.author} · ${book.publisher}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: isTop1 ? 18 : 16,
                          color: isTop1
                              ? Colors.red.shade500
                              : Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.borrowCount}',
                          style: TextStyle(
                            fontSize: isTop1 ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: isTop1
                                ? Colors.red.shade600
                                : Colors.red.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '次借阅',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
