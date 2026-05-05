import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'book_list_page.dart';
import 'borrow_page.dart';
import 'profile_page.dart';
import 'reservation_page.dart';
import 'ai_chat_page.dart';
import 'recommendation_dialog.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  int _currentIndex = 0;
  final GlobalKey _borrowKey = GlobalKey();
  final GlobalKey _bookListKey = GlobalKey();
  final GlobalKey _reservationKey = GlobalKey();
  final GlobalKey _aiChatKey = GlobalKey();
  int _unreadCount = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _showRecommendationIfNeeded();
    _startNotificationRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    _loadUnreadCount();
  }

  @override
  void didPopNext() {
    _loadUnreadCount();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _startNotificationRefresh() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadUnreadCount();
      }
    });
  }

  Future<void> _showRecommendationIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RecommendationDialog(
          user: widget.user,
          onDismiss: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await ApiService.getUnreadNotificationCount(widget.user.id);
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BookListPage(
            key: _bookListKey,
            user: widget.user,
            onNavigateToProfile: () {
              setState(() {
                _currentIndex = 4;
              });
              _loadUnreadCount();
            },
          ),
          BorrowPage(key: _borrowKey, user: widget.user),
          AiChatPage(key: _aiChatKey, user: widget.user),
          ReservationPage(key: _reservationKey, user: widget.user),
          ProfilePage(user: widget.user),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.menu_book_outlined, Icons.menu_book, '图书'),
              _buildNavItem(
                1,
                Icons.swap_horiz_outlined,
                Icons.swap_horiz,
                '借阅',
              ),
              const SizedBox(width: 56),
              _buildNavItem(
                3,
                Icons.calendar_today_outlined,
                Icons.calendar_today,
                '预约到馆',
              ),
              _buildNavItemWithBadge(
                4,
                Icons.person_outline,
                Icons.person,
                '我的',
                _unreadCount,
              ),
            ],
          ),
        ),
        Positioned(top: -20, child: _buildCenterAiButton()),
      ],
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_currentIndex == index) return;
        setState(() {
          _currentIndex = index;
        });

        if (index == 1) {
          final state = _borrowKey.currentState;
          if (state != null) {
            (state as dynamic).loadRecords?.call();
          }
        } else if (index == 0) {
          final state = _bookListKey.currentState;
          if (state != null) {
            (state as dynamic).loadBooks?.call();
          }
        } else if (index == 3) {
          final state = _reservationKey.currentState;
          if (state != null) {
            (state as dynamic).loadData?.call();
          }
        } else if (index == 4) {
          _loadUnreadCount();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color(0xFF7C4DFF).withOpacity(0.08)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + value * 0.1,
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    color: isSelected
                        ? const Color(0xFF7C4DFF)
                        : Colors.grey.shade400,
                    size: 24,
                  ),
                );
              },
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? const Color(0xFF7C4DFF)
                    : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
    int badgeCount,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_currentIndex == index) return;
        setState(() {
          _currentIndex = index;
        });
        _loadUnreadCount();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color(0xFF7C4DFF).withOpacity(0.08)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1.0 + value * 0.1,
                      child: Icon(
                        isSelected ? selectedIcon : icon,
                        color: isSelected
                            ? const Color(0xFF7C4DFF)
                            : Colors.grey.shade400,
                        size: 24,
                      ),
                    );
                  },
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? const Color(0xFF7C4DFF)
                    : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAiButton() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_currentIndex == 2) return;
        setState(() {
          _currentIndex = 2;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? const [Color(0xFF9C27B0), Color(0xFF7C4DFF)]
                : const [Color(0xFF7C4DFF), Color(0xFF536DFE)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C4DFF).withOpacity(0.4),
              blurRadius: isSelected ? 16 : 12,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF7C4DFF).withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(isSelected ? 0.5 : 0.3),
                  width: 2,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1.0 + value * 0.15,
                      child: Icon(
                        isSelected
                            ? Icons.auto_awesome
                            : Icons.auto_awesome_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 1),
                Text(
                  '小图',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
