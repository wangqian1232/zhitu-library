import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/system_settings_service.dart';
import '../services/system_log_service.dart';
import '../widgets/borrow_setting_dialog.dart';
import 'system_log_page.dart';
import 'exception_center_page.dart';

class AdminPage extends StatefulWidget {
  final User user;

  const AdminPage({super.key, required this.user});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => (_bookManagementKey.currentState as dynamic)
                  ?._showAddBookDialog(),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BookManagementPage(key: _bookManagementKey, user: widget.user),
          UserManagementPage(user: widget.user),
          AdminSystemSettingsPage(user: widget.user),
          ExceptionCenterPage(user: widget.user),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return '图书管理';
      case 1:
        return '用户管理';
      case 2:
        return '系统设置';
      case 3:
        return '异常处理中心';
      default:
        return '管理员面板';
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '管理员',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(0, Icons.menu_book_outlined, '图书管理'),
                _buildDrawerItem(1, Icons.people_outline, '用户管理'),
                _buildDrawerItem(2, Icons.settings_outlined, '系统设置'),
                _buildDrawerItem(3, Icons.warning_amber_outlined, '异常处理中心'),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('返回个人中心', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF7C4DFF) : Colors.grey.shade600,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF7C4DFF) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF7C4DFF).withOpacity(0.08),
      onTap: () {
        Navigator.pop(context);
        setState(() => _selectedIndex = index);
      },
    );
  }
}

final GlobalKey _bookManagementKey = GlobalKey();

class BookManagementPage extends StatefulWidget {
  final User user;

  const BookManagementPage({super.key, required this.user});

  @override
  State<BookManagementPage> createState() => _BookManagementPageState();
}

class _BookManagementPageState extends State<BookManagementPage> {
  List<Book> _books = [];
  final List<Book> _selectedBooks = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final books = await ApiService.searchBooks(
      title: _searchQuery.isEmpty ? null : _searchQuery,
    );
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  int get _totalCount => _books.length;
  int get _availableCount => _books.where((b) => b.availableCopies > 0).length;
  int get _borrowedCount => _totalCount - _availableCount;

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final publisherController = TextEditingController();
    final isbnController = TextEditingController();
    final categoryController = TextEditingController();
    final copiesController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增图书'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '书名 *',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: '作者 *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: publisherController,
                decoration: const InputDecoration(
                  labelText: '出版社',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: '分类',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: copiesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '副本数量',
                  prefixIcon: Icon(Icons.copy),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  authorController.text.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('请填写必填项')));
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('添加成功')));
              _loadBooks();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除《${book.title}》吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('删除成功')));
              _loadBooks();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatsCards(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索书名、作者...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  onSubmitted: (_) => _loadBooks(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddBookDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新增'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedBooks.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text('已选择 ${_selectedBooks.length} 本'),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _selectedBooks.clear()),
                  child: const Text('取消选择'),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('批量操作成功')));
                    setState(() => _selectedBooks.clear());
                  },
                  child: const Text('批量修改状态'),
                ),
              ],
            ),
          ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _books.isEmpty
              ? const Center(child: Text('暂无图书数据'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    final isSelected = _selectedBooks.contains(book);
                    return _buildBookCard(context, book, isSelected);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '$_totalCount',
              '图书总数',
              const Color(0xFF7C4DFF),
              Icons.menu_book,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              '$_availableCount',
              '可借阅',
              Colors.green,
              Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              '$_borrowedCount',
              '已借出',
              Colors.red.shade400,
              Icons.library_books_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isSelected
            ? BorderSide(color: const Color(0xFF7C4DFF), width: 1.5)
            : BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedBooks.add(book);
                  } else {
                    _selectedBooks.remove(book);
                  }
                });
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7C4DFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '库存 ${book.availableCopies}/${book.totalCopies}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: book.availableCopies > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    book.availableCopies > 0 ? '可借阅' : '已借出',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: book.availableCopies > 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('编辑功能开发中...')),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showDeleteConfirmDialog(book),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserManagementPage extends StatefulWidget {
  final User user;

  const UserManagementPage({super.key, required this.user});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await ApiService.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final u = _users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(u.username),
            subtitle: Text('${u.email} | ${u.phone}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: u.role == UserRole.admin
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    u.role == UserRole.admin ? '管理员' : '用户',
                    style: TextStyle(
                      fontSize: 12,
                      color: u.role == UserRole.admin
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('权限管理功能开发中...')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdminSystemSettingsPage extends StatefulWidget {
  final User user;

  const AdminSystemSettingsPage({super.key, required this.user});

  @override
  State<AdminSystemSettingsPage> createState() =>
      _AdminSystemSettingsPageState();
}

class _AdminSystemSettingsPageState extends State<AdminSystemSettingsPage> {
  final _settingsService = SystemSettingsService();

  String get _borrowDaysValue => '${_settingsService.settings.borrowDays} 天';
  String get _renewCountValue => '${_settingsService.settings.renewCount} 次';
  String get _overdueFineValue =>
      '${_settingsService.settings.overdueFine} 元/天';
  String get _maxBorrowCountValue =>
      '${_settingsService.settings.maxBorrowCount} 本';

  void _showBorrowDaysDialog() {
    showDialog(
      context: context,
      builder: (context) => BorrowSettingDialog(
        title: '借阅期限',
        currentValue: _settingsService.settings.borrowDays.toString(),
        unit: '天',
        icon: Icons.calendar_today,
        onSave: (val) async {
          final days = int.tryParse(val);
          if (days != null && days > 0) {
            await _settingsService.updateBorrowDays(days);
            setState(() {});
          }
        },
        logType: SystemLogType.settingChange,
        logMessage: '管理员修改了借阅期限设置',
      ),
    );
  }

  void _showRenewCountDialog() {
    showDialog(
      context: context,
      builder: (context) => BorrowSettingDialog(
        title: '续借次数',
        currentValue: _settingsService.settings.renewCount.toString(),
        unit: '次',
        icon: Icons.refresh,
        onSave: (val) async {
          final count = int.tryParse(val);
          if (count != null && count >= 0) {
            await _settingsService.updateRenewCount(count);
            setState(() {});
          }
        },
        logType: SystemLogType.settingChange,
        logMessage: '管理员修改了续借次数设置',
      ),
    );
  }

  void _showOverdueFineDialog() {
    showDialog(
      context: context,
      builder: (context) => FineSettingDialog(
        currentValue: _settingsService.settings.overdueFine.toString(),
        onSave: (fine) async {
          await _settingsService.updateOverdueFine(fine);
          setState(() {});
        },
      ),
    );
  }

  void _showMaxBorrowCountDialog() {
    showDialog(
      context: context,
      builder: (context) => BorrowSettingDialog(
        title: '最大借阅数量',
        currentValue: _settingsService.settings.maxBorrowCount.toString(),
        unit: '本',
        icon: Icons.library_books,
        onSave: (val) async {
          final count = int.tryParse(val);
          if (count != null && count > 0) {
            await _settingsService.updateMaxBorrowCount(count);
            setState(() {});
          }
        },
        logType: SystemLogType.settingChange,
        logMessage: '管理员修改了最大借阅数量设置',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '借阅设置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  context,
                  '借阅期限',
                  _borrowDaysValue,
                  Icons.calendar_today,
                  _showBorrowDaysDialog,
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  '续借次数',
                  _renewCountValue,
                  Icons.refresh,
                  _showRenewCountDialog,
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  '逾期罚款',
                  _overdueFineValue,
                  Icons.attach_money,
                  _showOverdueFineDialog,
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  '最大借阅数量',
                  _maxBorrowCountValue,
                  Icons.library_books,
                  _showMaxBorrowCountDialog,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '数据管理',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('数据备份'),
                  subtitle: const Text('备份所有图书和用户数据'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    SystemLogService().addLog(
                      '管理员执行了数据备份',
                      SystemLogType.system,
                      operator: 'admin',
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('备份成功')));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('数据恢复'),
                  subtitle: const Text('从备份恢复数据'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    SystemLogService().addLog(
                      '管理员执行了数据恢复',
                      SystemLogType.system,
                      operator: 'admin',
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('恢复成功')));
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '系统日志',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('查看全部日志'),
                  subtitle: const Text('查看系统操作记录'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SystemLogPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildLogItem('用户 admin 登录系统', '2 分钟前'),
                const Divider(height: 1),
                _buildLogItem('用户 user 借阅《算法导论》', '1 小时前'),
                const Divider(height: 1),
                _buildLogItem('用户 user 归还《数据结构》', '3 小时前'),
                const Divider(height: 1),
                _buildLogItem('管理员修改了借阅期限设置', '1 天前'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7C4DFF)),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF7C4DFF),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogItem(String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF7C4DFF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
