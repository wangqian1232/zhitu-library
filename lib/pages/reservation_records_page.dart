import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'check_in_page.dart';

class ReservationRecordsPage extends StatefulWidget {
  final User user;

  const ReservationRecordsPage({super.key, required this.user});

  @override
  State<ReservationRecordsPage> createState() => _ReservationRecordsPageState();
}

class _ReservationRecordsPageState extends State<ReservationRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Reservation> _allReservations = [];
  List<Reservation> _filteredReservations = [];
  bool _isLoading = true;
  ReservationStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterReservations();
      }
    });
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reservations = await ApiService.getUserReservations(widget.user.id);
      print('预约记录加载成功，共 ${reservations.length} 条');
      
      setState(() {
        _allReservations = reservations;
        _filteredReservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      print('预约记录加载失败: $e');
      setState(() {
        _allReservations = [];
        _filteredReservations = [];
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载预约记录失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterReservations() {
    final tabIndex = _tabController.index;
    setState(() {
      switch (tabIndex) {
        case 0:
          _selectedStatus = null;
          _filteredReservations = _allReservations;
          break;
        case 1:
          _selectedStatus = ReservationStatus.pending;
          _filteredReservations = _allReservations
              .where((r) => r.status == ReservationStatus.pending)
              .toList();
          break;
        case 2:
          _selectedStatus = ReservationStatus.checkedIn;
          _filteredReservations = _allReservations
              .where((r) => r.status == ReservationStatus.checkedIn)
              .toList();
          break;
        case 3:
          _selectedStatus = ReservationStatus.cancelled;
          _filteredReservations = _allReservations
              .where((r) => r.status == ReservationStatus.cancelled)
              .toList();
          break;
        case 4:
          _selectedStatus = ReservationStatus.noShow;
          _filteredReservations = _allReservations
              .where((r) => r.status == ReservationStatus.noShow)
              .toList();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('预约记录'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '待签到'),
            Tab(text: '已签到'),
            Tab(text: '已取消'),
            Tab(text: '逾期未签到'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredReservations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredReservations.length,
              itemBuilder: (context, index) {
                final reservation = _filteredReservations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReservationCard(reservation),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '暂无预约记录',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reservation.id,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildStatusChip(reservation.status),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, _formatDate(reservation.date)),
          _buildInfoRow(Icons.access_time, reservation.timeSlot.label),
          if (reservation.checkedInAt != null)
            _buildInfoRow(
              Icons.check_circle,
              '签到时间：${_formatDateTime(reservation.checkedInAt!)}',
            ),
          if (reservation.isViolated && reservation.violationReason != null)
            _buildInfoRow(
              Icons.warning,
              '违约原因：${reservation.violationReason}',
              color: Colors.red,
            ),
          const SizedBox(height: 12),
          if (reservation.isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelReservation(reservation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('取消预约'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckInPage(
                            user: widget.user,
                            reservation: reservation,
                          ),
                        ),
                      ).then((_) => _loadReservations());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('立即签到'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ReservationStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case ReservationStatus.pending:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        text = '待签到';
        break;
      case ReservationStatus.checkedIn:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        text = '已签到';
        break;
      case ReservationStatus.cancelled:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        text = '已取消';
        break;
      case ReservationStatus.noShow:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        text = '逾期未签到';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color ?? Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认取消'),
        content: const Text('确定要取消此预约吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('再想想'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认取消'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.cancelReservation(reservation.id);
      if (result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('预约已取消')));
        _loadReservations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '取消失败，请稍后重试')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
