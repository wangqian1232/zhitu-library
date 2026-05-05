enum SystemLogType {
  login,
  borrow,
  returnBook,
  settingChange,
  userManage,
  bookManage,
  system,
}

class SystemLog {
  final String id;
  final String message;
  final DateTime timestamp;
  final SystemLogType type;
  final String? operator;

  SystemLog({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.type,
    this.operator,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} 天前';
    } else {
      return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    }
  }

  String get formattedTime {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class SystemLogService {
  static final SystemLogService _instance = SystemLogService._internal();
  factory SystemLogService() => _instance;
  SystemLogService._internal();

  final List<SystemLog> _logs = [
    SystemLog(
      id: '1',
      message: '用户 admin 登录系统',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      type: SystemLogType.login,
      operator: 'admin',
    ),
    SystemLog(
      id: '2',
      message: '用户 user 借阅《算法导论》',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: SystemLogType.borrow,
      operator: 'user',
    ),
    SystemLog(
      id: '3',
      message: '用户 user 归还《数据结构》',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: SystemLogType.returnBook,
      operator: 'user',
    ),
    SystemLog(
      id: '4',
      message: '管理员修改了借阅期限设置',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: SystemLogType.settingChange,
      operator: 'admin',
    ),
    SystemLog(
      id: '5',
      message: '新增图书《Flutter实战》',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: SystemLogType.bookManage,
      operator: 'admin',
    ),
    SystemLog(
      id: '6',
      message: '用户 user 注册账号',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: SystemLogType.userManage,
      operator: 'user',
    ),
    SystemLog(
      id: '7',
      message: '系统执行自动备份',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      type: SystemLogType.system,
      operator: 'system',
    ),
    SystemLog(
      id: '8',
      message: '用户 admin 修改了逾期罚款设置',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      type: SystemLogType.settingChange,
      operator: 'admin',
    ),
    SystemLog(
      id: '9',
      message: '用户 user 借阅《深入理解计算机系统》',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
      type: SystemLogType.borrow,
      operator: 'user',
    ),
    SystemLog(
      id: '10',
      message: '用户 user 归还《操作系统概念》',
      timestamp: DateTime.now().subtract(const Duration(days: 12)),
      type: SystemLogType.returnBook,
      operator: 'user',
    ),
  ];

  List<SystemLog> getLogs({SystemLogType? type}) {
    if (type != null) {
      return _logs.where((log) => log.type == type).toList();
    }
    return List.from(_logs);
  }

  void addLog(String message, SystemLogType type, {String? operator}) {
    _logs.insert(
      0,
      SystemLog(
        id: '${_logs.length + 1}',
        message: message,
        timestamp: DateTime.now(),
        type: type,
        operator: operator,
      ),
    );
  }
}
