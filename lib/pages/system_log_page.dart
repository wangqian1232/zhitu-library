import 'package:flutter/material.dart';
import '../services/system_log_service.dart';

class SystemLogPage extends StatefulWidget {
  const SystemLogPage({super.key});

  @override
  State<SystemLogPage> createState() => _SystemLogPageState();
}

class _SystemLogPageState extends State<SystemLogPage> {
  SystemLogType? _selectedType;
  List<SystemLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _logs = SystemLogService().getLogs(type: _selectedType);
      _isLoading = false;
    });
  }

  Color _getTypeColor(SystemLogType type) {
    switch (type) {
      case SystemLogType.login:
        return Colors.blue;
      case SystemLogType.borrow:
        return Colors.green;
      case SystemLogType.returnBook:
        return Colors.orange;
      case SystemLogType.settingChange:
        return Colors.purple;
      case SystemLogType.userManage:
        return Colors.teal;
      case SystemLogType.bookManage:
        return Colors.indigo;
      case SystemLogType.system:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(SystemLogType type) {
    switch (type) {
      case SystemLogType.login:
        return Icons.login;
      case SystemLogType.borrow:
        return Icons.library_books;
      case SystemLogType.returnBook:
        return Icons.assignment_return;
      case SystemLogType.settingChange:
        return Icons.settings;
      case SystemLogType.userManage:
        return Icons.people;
      case SystemLogType.bookManage:
        return Icons.menu_book;
      case SystemLogType.system:
        return Icons.computer;
    }
  }

  String _getTypeLabel(SystemLogType type) {
    switch (type) {
      case SystemLogType.login:
        return '登录';
      case SystemLogType.borrow:
        return '借阅';
      case SystemLogType.returnBook:
        return '归还';
      case SystemLogType.settingChange:
        return '设置';
      case SystemLogType.userManage:
        return '用户';
      case SystemLogType.bookManage:
        return '图书';
      case SystemLogType.system:
        return '系统';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统日志'),
        actions: [
          PopupMenuButton<SystemLogType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _selectedType = type;
              });
              _loadLogs();
            },
            itemBuilder: (context) => [
              const PopupMenuItem<SystemLogType?>(
                value: null,
                child: Text('全部日志'),
              ),
              const PopupMenuDivider(),
              ...SystemLogType.values.map(
                (type) => PopupMenuItem<SystemLogType?>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        size: 18,
                        color: _getTypeColor(type),
                      ),
                      const SizedBox(width: 8),
                      Text(_getTypeLabel(type)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无日志记录',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTypeColor(log.type).withOpacity(0.1),
                      child: Icon(
                        _getTypeIcon(log.type),
                        color: _getTypeColor(log.type),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      log.message,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(log.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getTypeLabel(log.type),
                              style: TextStyle(
                                fontSize: 11,
                                color: _getTypeColor(log.type),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (log.operator != null)
                            Text(
                              '操作人: ${log.operator}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    trailing: Text(
                      log.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
