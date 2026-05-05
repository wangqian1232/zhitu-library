import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/book_health_report_service.dart';
import '../widgets/book_health_report/reading_difficulty_widget.dart';
import '../widgets/book_health_report/reading_posture_widget.dart';
import '../widgets/book_health_report/time_cost_widget.dart';
import '../widgets/book_health_report/sensory_indicators_widget.dart';
import '../widgets/book_health_report/nutrition_indicators_widget.dart';
import '../widgets/book_health_report/social_and_warning_widget.dart';
import '../widgets/book_health_report/summary_quote_widget.dart';

class BookHealthReportPage extends StatefulWidget {
  final Book book;

  const BookHealthReportPage({super.key, required this.book});

  @override
  State<BookHealthReportPage> createState() => _BookHealthReportPageState();
}

class _BookHealthReportPageState extends State<BookHealthReportPage>
    with SingleTickerProviderStateMixin {
  BookHealthReport? _report;
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await BookHealthReportService.generateReport(widget.book);
      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('生成报告失败：$e')));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('AI体检报告'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _generateReport,
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildReportView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF667EEA),
                          const Color(0xFF764BA2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF667EEA).withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI正在分析图书内容...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '预计需要15-30秒',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReportView() {
    if (_report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '报告生成失败',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _generateReport, child: const Text('重试')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            ReadingDifficultyWidget(difficulty: _report!.readingDifficulty),
            const SizedBox(height: 16),
            ReadingPostureWidget(postures: _report!.readingPostures),
            const SizedBox(height: 16),
            TimeCostWidget(timeCost: _report!.timeCost),
            const SizedBox(height: 16),
            SensoryIndicatorsWidget(indicators: _report!.sensoryIndicators),
            const SizedBox(height: 16),
            NutritionIndicatorsWidget(indicators: _report!.nutritionIndicators),
            const SizedBox(height: 16),
            SocialAndWarningWidget(
              indicators: _report!.socialAndWarningIndicators,
            ),
            const SizedBox(height: 16),
            SummaryQuoteWidget(quote: _report!.summaryQuote),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '作者：${widget.book.author}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
