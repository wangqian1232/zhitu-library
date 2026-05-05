import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'visit_appointment_confirm_page.dart';
import 'visit_appointment_records_page.dart';
import 'visit_appointment_check_in_page.dart';

class ReservationPage extends StatefulWidget {
  final User user;

  const ReservationPage({super.key, required this.user});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _timeSlots = [];
  List<Map<String, dynamic>> _pendingAppointments = [];
  bool _isLoading = true;
  bool _hasViolations = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });

    final slots = await ApiService.getVisitTimeSlotsForDate(_selectedDate);
    final appointments =
        await ApiService.getUserVisitAppointments(widget.user.id);
    final pending = appointments
        .where((a) => a['status'] == 'pending')
        .toList();
    final violations = appointments.where((a) => a['isViolated'] == true).toList();

    setState(() {
      _timeSlots = slots;
      _pendingAppointments = pending;
      _hasViolations = violations.isNotEmpty;
      _isLoading = false;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    loadData();
  }

  void _onTimeSlotSelected(Map<String, dynamic> slot) {
    if (slot['isAvailable'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisitAppointmentConfirmPage(
            user: widget.user,
            date: _selectedDate,
            timeSlot: slot,
          ),
        ),
      ).then((_) => loadData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('预约到馆'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VisitAppointmentRecordsPage(user: widget.user),
                ),
              ).then((_) => loadData());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_hasViolations) _buildViolationWarning(),
                if (_pendingAppointments.isNotEmpty) _buildPendingWarning(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        _buildDatePicker(),
                        const SizedBox(height: 16),
                        _buildTimeSlotPanel(),
                        const SizedBox(height: 16),
                        _buildRulesCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildViolationWarning() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '您有未处理的违约记录，请先联系管理员处理',
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '您有 ${_pendingAppointments.length} 条待签到预约',
              style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisitAppointmentCheckInPage(
                    user: widget.user,
                    appointment: _pendingAppointments.first,
                  ),
                ),
              ).then((_) => loadData());
            },
            child: const Text('去签到'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
            '选择日期',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = _isSameDay(date, _selectedDate);
                final isToday = _isSameDay(date, DateTime.now());
                final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                final weekDay = weekDays[date.weekday - 1];

                return GestureDetector(
                  onTap: () => _onDateSelected(date),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday ? '今天' : weekDay,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.month}/${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
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
      ),
    );
  }

  Widget _buildTimeSlotPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
            '选择时段',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._timeSlots.map((slot) => _buildTimeSlotItem(slot)),
        ],
      ),
    );
  }

  Widget _buildTimeSlotItem(Map<String, dynamic> slot) {
    final theme = Theme.of(context);
    final isAvailable = slot['isAvailable'] == true;
    final isFull = slot['isFull'] == true;
    final isUnavailable = slot['isUnavailable'] == true;
    final remainingSlots = slot['remainingSlots'] ?? 0;
    final unavailableReason = slot['unavailableReason'] as String?;

    Color bgColor;
    Color textColor;
    String statusText;
    bool isEnabled;

    if (isUnavailable) {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade500;
      statusText = unavailableReason ?? '不可预约';
      isEnabled = false;
    } else if (isFull) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      statusText = '已满';
      isEnabled = false;
    } else {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      statusText = '可预约';
      isEnabled = true;
    }

    return GestureDetector(
      onTap: isEnabled ? () => _onTimeSlotSelected(slot) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? Colors.green.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot['label'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable
                        ? '剩余 $remainingSlots 个名额'
                        : statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (isEnabled)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '预约',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
            '预约规则',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildRuleItem('可提前7天预约'),
          _buildRuleItem('每日限预约1次'),
          _buildRuleItem('预约成功后请在时段开始后30分钟内签到'),
          _buildRuleItem('逾期未签到将标记违约，累计3次将限制预约'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
