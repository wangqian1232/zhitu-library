import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart' as app_models;
import '../services/api_service.dart';
import '../services/ai_reading_report_service.dart';

class ReadingReportPage extends StatefulWidget {
  final app_models.User user;

  const ReadingReportPage({super.key, required this.user});

  @override
  State<ReadingReportPage> createState() => _ReadingReportPageState();
}

class _ReadingReportPageState extends State<ReadingReportPage> {
  app_models.ReadingReport? _report;
  bool _isLoading = true;
  bool _isGeneratingAi = false;
  Map<String, dynamic>? _aiReport;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('开始加载阅读报告，用户ID: ${widget.user.id}');
      final report = await ApiService.generateReadingReport(widget.user.id);

      if (report != null) {
        print('阅读报告加载成功，总阅读本数: ${report.totalBooks}');
        print('分类统计: ${report.categoryStats}');
        print('作者统计: ${report.authorStats}');
        print('月度统计: ${report.monthlyStats}');
      } else {
        print('阅读报告为空，创建空报告');
      }

      setState(() {
        _report =
            report ??
            app_models.ReadingReport(
              userId: widget.user.id,
              totalBooks: 0,
              totalPages: 0,
              readingDays: 0,
              categoryStats: {},
              authorStats: {},
              publisherStats: {},
              monthlyStats: {},
              achievements: [],
            );
        _isLoading = false;
      });
    } catch (e) {
      print('阅读报告加载失败: $e');
      setState(() {
        _report = app_models.ReadingReport(
          userId: widget.user.id,
          totalBooks: 0,
          totalPages: 0,
          readingDays: 0,
          categoryStats: {},
          authorStats: {},
          publisherStats: {},
          monthlyStats: {},
          achievements: ['阅读新手 - 开始你的阅读之旅'],
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAiReport() async {
    if (_report == null) return;

    setState(() {
      _isGeneratingAi = true;
    });

    try {
      final aiResult = await AiReadingReportService.generateAiReadingReport(
        user: widget.user,
        totalBooks: _report!.totalBooks,
        totalPages: _report!.totalPages,
        readingDays: _report!.readingDays,
        categoryStats: _report!.categoryStats,
        authorStats: _report!.authorStats,
        publisherStats: _report!.publisherStats,
        monthlyStats: _report!.monthlyStats,
        existingAchievements: _report!.achievements,
      );

      setState(() {
        _aiReport = aiResult;
        _isGeneratingAi = false;
      });
    } catch (e) {
      print('AI 报告生成失败: $e');
      setState(() {
        _isGeneratingAi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读报告'),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildOverviewCards(),
                  if (_report!.totalBooks > 0) ...[
                    _buildMonthlyChart(),
                    _buildCategoryChart(),
                    _buildTopAuthors(),
                  ] else
                    _buildEmptyState(),
                  _buildAchievements(),
                  _buildAiReportSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_stories, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            '${widget.user.username} 的阅读报告',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '累计阅读 ${_report!.totalBooks} 本书',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildOverviewCard(
              Icons.menu_book,
              '${_report!.totalBooks}',
              '阅读本数',
              const Color(0xFF5C6BC0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildOverviewCard(
              Icons.chrome_reader_mode,
              '${_report!.totalPages}',
              '总页数',
              const Color(0xFF26A69A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildOverviewCard(
              Icons.calendar_today,
              '${_report!.readingDays}',
              '阅读天数',
              const Color(0xFFEF5350),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final monthlyData = _report!.monthlyStats;
    if (monthlyData.isEmpty) return const SizedBox.shrink();

    final spots =
        monthlyData.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
            .toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
            const Text(
              '月度借阅趋势',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            '',
                            '1月',
                            '2月',
                            '3月',
                            '4月',
                            '5月',
                            '6月',
                            '7月',
                            '8月',
                            '9月',
                            '10月',
                            '11月',
                            '12月',
                          ];
                          if (value.toInt() >= 1 && value.toInt() <= 12) {
                            return Text(
                              months[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF5C6BC0),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF5C6BC0).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    final categoryData = _report!.categoryStats;
    if (categoryData.isEmpty) return const SizedBox.shrink();

    final colors = [
      const Color(0xFF5C6BC0),
      const Color(0xFF26A69A),
      const Color(0xFFEF5350),
      const Color(0xFFFFA726),
      const Color(0xFF66BB6A),
      const Color(0xFFAB47BC),
      const Color(0xFF29B6F6),
      const Color(0xFF8D6E63),
      const Color(0xFF78909C),
    ];

    final sections = categoryData.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final catEntry = entry.value;
      return PieChartSectionData(
        value: catEntry.value.toDouble(),
        title:
            '${(catEntry.value / categoryData.values.reduce((a, b) => a + b) * 100).toInt()}%',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
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
            const Text(
              '阅读分类偏好',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: categoryData.entries.toList().asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final catEntry = entry.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(catEntry.key, style: const TextStyle(fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAuthors() {
    final authorData = _report!.authorStats;
    if (authorData.isEmpty) return const SizedBox.shrink();

    final sortedAuthors = authorData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topAuthors = sortedAuthors.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
            const Text(
              '最爱作者 TOP 5',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...topAuthors.asMap().entries.map((entry) {
              final index = entry.key;
              final authorEntry = entry.value;
              final maxCount = topAuthors.first.value;
              final progress = authorEntry.value / maxCount;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: index < 3
                            ? const Color(0xFFFFD700)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: index < 3
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorEntry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF5C6BC0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${authorEntry.value}本',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '暂无阅读记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始借阅书籍，积累你的阅读数据吧！',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = _report!.achievements;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
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
            const Text(
              '阅读成就',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: achievements.map((achievement) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    achievement,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiReportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF5C6BC0)),
                const SizedBox(width: 8),
                const Text(
                  'AI 阅读分析',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (!_isGeneratingAi && _aiReport == null)
                  TextButton.icon(
                    onPressed: _generateAiReport,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('生成报告'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF5C6BC0),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isGeneratingAi)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('AI 正在分析你的阅读数据...'),
                    ],
                  ),
                ),
              )
            else if (_aiReport != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _aiReport!['aiSummary'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAiInfoRow('阅读风格', _aiReport!['readingStyle'] ?? ''),
                  const SizedBox(height: 8),
                  _buildAiInfoRow('阅读习惯', _aiReport!['readingHabit'] ?? ''),
                  const SizedBox(height: 8),
                  _buildAiInfoRow('下一个目标', _aiReport!['nextGoal'] ?? ''),
                  if (_aiReport!['aiAchievements'] != null &&
                      (_aiReport!['aiAchievements'] as List).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'AI 专属成就',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (_aiReport!['aiAchievements'] as List)
                          .map(
                            (a) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                a.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '点击"生成报告"按钮，让 AI 为你分析阅读数据',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label：',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5C6BC0),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
        ),
      ],
    );
  }
}
