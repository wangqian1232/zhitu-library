import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CheckInPage extends StatefulWidget {
  final User user;
  final Reservation reservation;

  const CheckInPage({super.key, required this.user, required this.reservation});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  bool _isLoading = false;
  bool _isCheckedIn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reservation = widget.reservation;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('到馆签到'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildStatusIcon(),
            const SizedBox(height: 24),
            _buildReservationDetail(),
            const SizedBox(height: 24),
            _buildCheckInButton(),
            const SizedBox(height: 16),
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final reservation = widget.reservation;
    IconData icon;
    Color color;
    String text;

    if (_isCheckedIn || reservation.isCheckedIn) {
      icon = Icons.check_circle;
      color = Colors.green;
      text = '已签到';
    } else if (reservation.isOverdue) {
      icon = Icons.error_outline;
      color = Colors.red;
      text = '已逾期';
    } else if (reservation.canCheckIn) {
      icon = Icons.check_circle_outline;
      color = Colors.orange;
      text = '待签到';
    } else {
      icon = Icons.access_time;
      color = Colors.grey;
      text = '未到签到时间';
    }

    return Column(
      children: [
        Icon(icon, size: 80, color: color),
        const SizedBox(height: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationDetail() {
    final reservation = widget.reservation;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '预约详情',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('预约ID', reservation.id),
          _buildDetailRow('预约日期', _formatDate(reservation.date)),
          _buildDetailRow('预约时段', reservation.timeSlot.label),
          _buildDetailRow('签到码', reservation.qrCode ?? '无'),
          if (reservation.checkedInAt != null)
            _buildDetailRow('签到时间', _formatDateTime(reservation.checkedInAt!)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton() {
    final reservation = widget.reservation;
    final canCheckIn = reservation.canCheckIn && !_isCheckedIn;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canCheckIn && !_isLoading ? _performCheckIn : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canCheckIn
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            foregroundColor: canCheckIn ? Colors.white : Colors.grey.shade500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: canCheckIn ? 4 : 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isCheckedIn || reservation.isCheckedIn ? '已签到' : '立即签到',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '签到提示',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 请在预约时段开始后30分钟内完成签到\n• 签到成功后将释放预约名额\n• 逾期未签到将标记为违约',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Future<void> _performCheckIn() async {
    final reservation = widget.reservation;

    if (!reservation.canCheckIn) {
      _showErrorDialog('当前不可签到，请在预约时段开始后30分钟内操作');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.checkIn(reservation.id);

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _isCheckedIn = true;
      }
    });

    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      _showErrorDialog('签到失败，请稍后重试或联系管理员');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
            const SizedBox(width: 8),
            const Text('签到成功'),
          ],
        ),
        content: const Text('欢迎使用图书馆！祝您阅读愉快。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
            const SizedBox(width: 8),
            const Text('签到失败'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
