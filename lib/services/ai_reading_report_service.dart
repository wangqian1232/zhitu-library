import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../config/app_config.dart';

class AiReadingReportService {
  static const String _baseUrl =
      'https://dashscope.aliyuncs.com/compatible-mode/v1';

  static Future<Map<String, dynamic>> generateAiReadingReport({
    required User user,
    required int totalBooks,
    required int totalPages,
    required int readingDays,
    required Map<String, int> categoryStats,
    required Map<String, int> authorStats,
    required Map<String, int> publisherStats,
    required Map<int, int> monthlyStats,
    required List<String> existingAchievements,
  }) async {
    try {
      final prompt = _buildPrompt(
        user: user,
        totalBooks: totalBooks,
        totalPages: totalPages,
        readingDays: readingDays,
        categoryStats: categoryStats,
        authorStats: authorStats,
        publisherStats: publisherStats,
        monthlyStats: monthlyStats,
        existingAchievements: existingAchievements,
      );

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.dashScopeApiKey}',
            },
            body: jsonEncode({
              'model': 'qwen-plus',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '你是专业的阅读分析师，擅长分析用户的阅读习惯并生成个性化的阅读报告和成就。返回纯JSON，无markdown标记。',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 2000,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content) as Map<String, dynamic>;
      } else {
        throw Exception('AI API 请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('AI 阅读报告生成失败: $e');
      return _generateFallbackReport(
        totalBooks: totalBooks,
        existingAchievements: existingAchievements,
      );
    }
  }

  static String _buildPrompt({
    required User user,
    required int totalBooks,
    required int totalPages,
    required int readingDays,
    required Map<String, int> categoryStats,
    required Map<String, int> authorStats,
    required Map<String, int> publisherStats,
    required Map<int, int> monthlyStats,
    required List<String> existingAchievements,
  }) {
    final categoryStr = categoryStats.entries
        .map((e) => '${e.key}: ${e.value}本')
        .join(', ');
    final authorStr = authorStats.entries
        .map((e) => '${e.key}: ${e.value}本')
        .take(5)
        .join(', ');
    final monthlyStr = monthlyStats.entries
        .map((e) => '${e.key}月: ${e.value}本')
        .join(', ');

    return '''
你是专业的阅读分析师，请根据以下用户的阅读数据生成个性化的阅读报告和成就。

用户信息：
- 用户名：${user.username}
- 累计阅读：$totalBooks 本书
- 总页数：$totalPages 页
- 阅读天数：$readingDays 天

阅读分类偏好：
$categoryStr

最爱作者（TOP 5）：
$authorStr

月度借阅趋势：
$monthlyStr

已有成就：
${existingAchievements.join(', ')}

请生成以下内容（返回纯JSON格式）：
{
  "aiSummary": "一段个性化的阅读总结，2-3句话，鼓励用户继续阅读",
  "readingStyle": "用户的阅读风格描述，如'广泛涉猎型'、'深度专注型'等",
  "readingHabit": "用户的阅读习惯分析，如'喜欢在周末阅读'、'偏好文学类书籍'等",
  "nextGoal": "下一个阅读目标建议",
  "aiAchievements": ["3-5个新的个性化成就，用emoji开头，如'📚 文学爱好者'、'🌟 月度阅读达人'等"]
}

注意：
1. aiSummary 要温暖、鼓励性强
2. readingStyle 和 readingHabit 要基于实际数据
3. aiAchievements 要与已有成就不重复
4. 如果数据较少（totalBooks < 5），成就要偏向鼓励性质
5. 返回纯JSON，不要包含任何其他文字或markdown标记
''';
  }

  static Map<String, dynamic> _generateFallbackReport({
    required int totalBooks,
    required List<String> existingAchievements,
  }) {
    String aiSummary;
    String readingStyle;
    String readingHabit;
    String nextGoal;
    List<String> aiAchievements;

    if (totalBooks == 0) {
      aiSummary = '阅读之旅即将开始！每一本书都是一次新的冒险，期待你开启属于自己的阅读篇章。';
      readingStyle = '阅读新手';
      readingHabit = '尚未形成阅读习惯';
      nextGoal = '完成第一本书的阅读';
      aiAchievements = [' 阅读萌芽', '📖 启程之星'];
    } else if (totalBooks < 5) {
      aiSummary = '你已经迈出了阅读的第一步！继续保持这个好习惯，书籍会为你打开更广阔的世界。';
      readingStyle = '探索型读者';
      readingHabit = '正在培养阅读兴趣';
      nextGoal = '本月读完3本书';
      aiAchievements = ['🌱 阅读萌芽', '📖 启程之星', ' 坚持阅读'];
    } else if (totalBooks < 10) {
      aiSummary = '你的阅读之路越走越宽！从这些数据中可以看出你对知识的渴望，继续保持这份热情。';
      readingStyle = '成长型读者';
      readingHabit = '已形成稳定的阅读节奏';
      nextGoal = '挑战阅读10本书';
      aiAchievements = ['📚 阅读新星', ' 知识探索者', '💪 阅读坚持者'];
    } else if (totalBooks < 20) {
      aiSummary = '你已经成为了一名真正的阅读爱好者！你的阅读量和坚持令人钦佩，书籍是你最好的朋友。';
      readingStyle = '资深读者';
      readingHabit = '热爱阅读，涉猎广泛';
      nextGoal = '尝试不同领域的书籍';
      aiAchievements = ['📚 阅读达人', '🏆 知识渊博', '🌈 博览群书'];
    } else {
      aiSummary = '你是一位真正的阅读大师！你的阅读量和深度都令人惊叹，书籍已经融入了你的生活。';
      readingStyle = '阅读大师';
      readingHabit = '阅读已成为生活方式';
      nextGoal = '分享你的阅读心得';
      aiAchievements = [' 阅读传奇', '🎓 智慧之星', '🌟 阅读导师'];
    }

    return {
      'aiSummary': aiSummary,
      'readingStyle': readingStyle,
      'readingHabit': readingHabit,
      'nextGoal': nextGoal,
      'aiAchievements': aiAchievements,
    };
  }
}
