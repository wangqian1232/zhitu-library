import 'package:flutter/material.dart';
import '../models/models.dart';

class SystemSettingsPage extends StatefulWidget {
  final User user;

  const SystemSettingsPage({super.key, required this.user});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  bool _borrowReminderEnabled = true;
  bool _reservationReminderEnabled = true;
  bool _fineReminderEnabled = true;
  bool _systemNotificationEnabled = true;
  int _reminderDaysBefore = 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('系统设置'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('通知设置'),
            const SizedBox(height: 12),
            _buildNotificationCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('系统信息'),
            const SizedBox(height: 12),
            _buildSystemInfoCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
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
        children: [
          _buildSwitchItem(
            icon: Icons.notifications_active,
            iconColor: Colors.blue,
            title: '借阅到期提醒',
            subtitle: '图书到期前发送提醒通知',
            value: _borrowReminderEnabled,
            onChanged: (value) {
              setState(() => _borrowReminderEnabled = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchItem(
            icon: Icons.event_available,
            iconColor: Colors.green,
            title: '预约提醒',
            subtitle: '预约成功和签到提醒',
            value: _reservationReminderEnabled,
            onChanged: (value) {
              setState(() => _reservationReminderEnabled = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchItem(
            icon: Icons.warning_amber,
            iconColor: Colors.orange,
            title: '罚款提醒',
            subtitle: '产生逾期罚款时通知',
            value: _fineReminderEnabled,
            onChanged: (value) {
              setState(() => _fineReminderEnabled = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchItem(
            icon: Icons.campaign,
            iconColor: Colors.purple,
            title: '系统通知',
            subtitle: '接收系统公告和活动通知',
            value: _systemNotificationEnabled,
            onChanged: (value) {
              setState(() => _systemNotificationEnabled = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.access_time,
            iconColor: Colors.teal,
            title: '提前提醒天数',
            subtitle: '到期前多少天开始提醒',
            trailing: Text(
              '$_reminderDaysBefore 天',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C4DFF),
              ),
            ),
            onTap: () => _showEditReminderDaysDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoCard() {
    return Container(
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
        children: [
          _buildInfoItem('系统版本', 'v1.0.0'),
          const Divider(height: 1, indent: 56),
          _buildInfoItem('数据库版本', 'v2.1.0'),
          const Divider(height: 1, indent: 56),
          _buildInfoItem('最后更新', '2026-04-24'),
          const Divider(height: 1, indent: 56),
          _buildInfoItem('运行环境', 'Flutter 3.11.5'),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          trailing,
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF7C4DFF),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  void _showEditReminderDaysDialog() {
    final controller = TextEditingController(
      text: _reminderDaysBefore.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改提前提醒天数'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '天数',
            hintText: '请输入提前提醒天数',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final days = int.tryParse(controller.text);
              if (days != null && days > 0) {
                setState(() => _reminderDaysBefore = days);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('提醒天数已更新')));
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
