import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/system_settings_service.dart';

class ExceptionCenterPage extends StatefulWidget {
  final User user;

  const ExceptionCenterPage({super.key, required this.user});

  @override
  State<ExceptionCenterPage> createState() => _ExceptionCenterPageState();
}

class _ExceptionCenterPageState extends State<ExceptionCenterPage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  List<SystemException> _exceptions = [];
  List<SystemException> _filteredExceptions = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  bool _showStats = false;
  String _filterStatus = 'all';
  String _filterType = 'all';
  final Map<String, bool> _processingMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final exceptions = await ApiService.getAllExceptions();
      final stats = await ApiService.getExceptionStatistics();
      if (mounted) {
        setState(() {
          _exceptions = exceptions;
          _statistics = stats;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredExceptions = _exceptions.where((e) {
        bool statusMatch = _filterStatus == 'all' || e.status == _filterStatus;
        bool typeMatch = _filterType == 'all' || e.type == _filterType;
        return statusMatch && typeMatch;
      }).toList();
    });
  }

  Future<void> _handleUpdateStatus(SystemException exception, String newStatus) async {
    String? solution;
    if (newStatus == 'resolved' || newStatus == 'processing') {
      solution = await _showSolutionDialog(exception);
      if (solution == null) return;
    }

    setState(() => _processingMap[exception.id.toString()] = true);

    try {
      final success = await ApiService.updateExceptionStatus(
        exception.id.toString(),
        newStatus,
        solution ?? '',
        widget.user.username,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getStatusMessage(newStatus)),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('操作失败'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingMap.remove(exception.id.toString()));
      }
    }
  }

  Future<String?> _showSolutionDialog(SystemException exception) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('处理记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('异常：${exception.title}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '解决方案',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'processing':
        return '已标记为处理中';
      case 'resolved':
        return '已标记为已解决';
      case 'ignored':
        return '已标记为已忽略';
      default:
        return '操作成功';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(),
          if (_showStats) _buildStatisticsPanel(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExceptions.isEmpty
                    ? _buildEmptyState()
                    : _buildExceptionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExceptionDialog(),
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildHeaderTab(0, '全部', _exceptions.length),
                const SizedBox(width: 8),
                _buildHeaderTab(1, '待处理', _exceptions.where((e) => e.status == 'pending').length),
                const SizedBox(width: 8),
                _buildHeaderTab(2, '处理中', _exceptions.where((e) => e.status == 'processing').length),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _showStats ? Icons.bar_chart : Icons.analytics_outlined,
              color: const Color(0xFF6C5CE7),
            ),
            onPressed: () => setState(() => _showStats = !_showStats),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab(int index, String label, int count) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        switch (index) {
          case 0:
            _filterStatus = 'all';
            break;
          case 1:
            _filterStatus = 'pending';
            break;
          case 2:
            _filterStatus = 'processing';
            break;
        }
        _applyFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF666666),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : const Color(0xFFE74C3C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _filterType,
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: 'all', child: Text('全部类型')),
                const DropdownMenuItem(value: 'overdue', child: Text('借阅逾期')),
                const DropdownMenuItem(value: 'no_show', child: Text('预约未到')),
                const DropdownMenuItem(value: 'system_error', child: Text('系统错误')),
              ],
              onChanged: (value) {
                setState(() => _filterType = value ?? 'all');
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsPanel() {
    final statusCounts = _statistics['statusCounts'] as Map<String, dynamic>? ?? {};
    final typeCounts = _statistics['typeCounts'] as Map<String, dynamic>? ?? {};
    final healthScore = (_statistics['healthScore'] as num?)?.toDouble() ?? 100.0;
    final totalExceptions = (_statistics['totalExceptions'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
              const Text(
                '异常统计',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '系统健康度: ${healthScore.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: healthScore > 80 ? Colors.green : healthScore > 50 ? Colors.orange : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('总异常数', '$totalExceptions', const Color(0xFF6C5CE7))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('已解决', '${statusCounts['resolved'] ?? 0}', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('待处理', '${statusCounts['pending'] ?? 0}', Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('异常类型分布', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: _buildTypePieChart(typeCounts),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTypePieChart(Map<String, dynamic> typeCounts) {
    if (typeCounts.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final sections = <PieChartSectionData>[];
    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFFE74C3C),
      const Color(0xFF3498DB),
      const Color(0xFF2ECC71),
      const Color(0xFFF39C12),
    ];
    int colorIndex = 0;

    typeCounts.forEach((type, count) {
      sections.add(
        PieChartSectionData(
          value: (count as num).toDouble(),
          title: '${_getTypeName(type)}\n$count',
          color: colors[colorIndex % colors.length],
          radius: 50,
          titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'overdue':
        return '逾期';
      case 'no_show':
        return '未到';
      case 'system_error':
        return '系统';
      default:
        return type;
    }
  }

  Widget _buildExceptionList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _filteredExceptions.length,
      itemBuilder: (context, index) {
        final exception = _filteredExceptions[index];
        return _buildExceptionCard(exception);
      },
    );
  }

  Widget _buildExceptionCard(SystemException exception) {
    final isProcessing = _processingMap[exception.id.toString()] ?? false;
    final color = _getSeverityColor(exception.severity);
    final statusColor = _getStatusColor(exception.status);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isProcessing ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTypeName(exception.type),
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getStatusName(exception.status),
                            style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDateTime(exception.occurredAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                exception.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              if (exception.description != null && exception.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  exception.description!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (exception.module != null) ...[
                const SizedBox(height: 6),
                Text(
                  '模块: ${exception.module}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
              if (exception.solution != null && exception.solution!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          exception.solution!,
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (exception.status == 'pending') ...[
                    _buildActionButton(
                      label: '处理中',
                      color: const Color(0xFF3498DB),
                      isLoading: isProcessing,
                      onPressed: () => _handleUpdateStatus(exception, 'processing'),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      label: '已解决',
                      color: const Color(0xFF2ECC71),
                      isLoading: isProcessing,
                      onPressed: () => _handleUpdateStatus(exception, 'resolved'),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      label: '忽略',
                      color: Colors.grey,
                      isLoading: isProcessing,
                      onPressed: () => _handleUpdateStatus(exception, 'ignored'),
                    ),
                  ] else if (exception.status == 'processing') ...[
                    _buildActionButton(
                      label: '已解决',
                      color: const Color(0xFF2ECC71),
                      isLoading: isProcessing,
                      onPressed: () => _handleUpdateStatus(exception, 'resolved'),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      label: '忽略',
                      color: Colors.grey,
                      isLoading: isProcessing,
                      onPressed: () => _handleUpdateStatus(exception, 'ignored'),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    onPressed: () => _showExceptionDetail(exception),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFE74C3C);
      case 'medium':
        return const Color(0xFFF39C12);
      case 'low':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF6C5CE7);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFE74C3C);
      case 'processing':
        return const Color(0xFF3498DB);
      case 'resolved':
        return const Color(0xFF2ECC71);
      case 'ignored':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusName(String status) {
    switch (status) {
      case 'pending':
        return '待处理';
      case 'processing':
        return '处理中';
      case 'resolved':
        return '已解决';
      case 'ignored':
        return '已忽略';
      default:
        return status;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: const Color(0xFFBDC3C7)),
          const SizedBox(height: 16),
          const Text(
            '暂无异常记录',
            style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
          ),
        ],
      ),
    );
  }

  void _showExceptionDetail(SystemException exception) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exception.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('类型', _getTypeName(exception.type)),
              _buildDetailRow('状态', _getStatusName(exception.status)),
              _buildDetailRow('严重程度', exception.severity ?? '未知'),
              _buildDetailRow('模块', exception.module ?? '未知'),
              _buildDetailRow('发生时间', _formatDateTime(exception.occurredAt)),
              if (exception.description != null)
                _buildDetailRow('描述', exception.description!),
              if (exception.stackTrace != null && exception.stackTrace!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('错误堆栈', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    exception.stackTrace!,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ],
              if (exception.solution != null && exception.solution!.isNotEmpty)
                _buildDetailRow('解决方案', exception.solution!),
              if (exception.handledBy != null)
                _buildDetailRow('处理人', exception.handledBy!),
              if (exception.handledAt != null)
                _buildDetailRow('处理时间', _formatDateTime(exception.handledAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddExceptionDialog() async {
    final typeController = TextEditingController();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final moduleController = TextEditingController();
    String selectedSeverity = 'medium';
    String selectedType = 'system_error';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新增异常记录'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: '异常类型'),
                  items: const [
                    DropdownMenuItem(value: 'system_error', child: Text('系统错误')),
                    DropdownMenuItem(value: 'overdue', child: Text('借阅逾期')),
                    DropdownMenuItem(value: 'no_show', child: Text('预约未到')),
                    DropdownMenuItem(value: 'api_error', child: Text('接口调用失败')),
                  ],
                  onChanged: (value) => setDialogState(() => selectedType = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '标题 *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: '描述'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: moduleController,
                  decoration: const InputDecoration(labelText: '模块'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSeverity,
                  decoration: const InputDecoration(labelText: '严重程度'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('低')),
                    DropdownMenuItem(value: 'medium', child: Text('中')),
                    DropdownMenuItem(value: 'high', child: Text('高')),
                  ],
                  onChanged: (value) => setDialogState(() => selectedSeverity = value!),
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
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写标题')),
                  );
                  return;
                }
                Navigator.pop(context);
                try {
                  await ApiService.createException({
                    'type': selectedType,
                    'title': titleController.text,
                    'description': descController.text,
                    'module': moduleController.text,
                    'severity': selectedSeverity,
                  });
                  await _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('添加成功'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('添加失败: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
