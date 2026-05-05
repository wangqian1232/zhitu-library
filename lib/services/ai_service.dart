import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart' as app_models;
import '../config/app_config.dart';
import 'mock_data_service.dart';

class AiService {
  static const String _baseUrl =
      'https://dashscope.aliyuncs.com/compatible-mode/v1';

  static Future<String> chatWithAi({
    required String userId,
    required String message,
    required List<Map<String, String>> history,
  }) async {
    final user = MockDataService.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => MockDataService.users.first,
    );

    final borrowRecords = MockDataService.borrowRecords
        .where((r) => r.userId == userId)
        .toList();
    final favoriteBooks = MockDataService.books
        .where((b) => b.isFavoriteBy(userId))
        .toList();

    final allBooks = MockDataService.books;
    final availableBooks = allBooks.where((b) => b.status == '可借').toList();

    final categoryStats = <String, int>{};
    for (final record in borrowRecords) {
      final book = allBooks.firstWhere(
        (b) => b.id == record.bookId,
        orElse: () => allBooks.first,
      );
      categoryStats[book.majorCategory] =
          (categoryStats[book.majorCategory] ?? 0) + 1;
    }
    final topCategories = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final libraryBookList = availableBooks
        .take(20)
        .map((b) {
          return '- 《${b.title}》| ${b.author} | ${b.majorCategory}/${b.category} | ${b.publisher} | ${b.isbn}';
        })
        .join('\n');

    final borrowedBookTitles = borrowRecords
        .take(10)
        .map((r) {
          final book = allBooks.firstWhere(
            (b) => b.id == r.bookId,
            orElse: () => allBooks.first,
          );
          return '《${book.title}》';
        })
        .join('、');

    final favoriteBookTitles = favoriteBooks
        .take(5)
        .map((b) => '《${b.title}》')
        .join('、');

    final systemPrompt =
        '''你是图书馆AI助手"小图"，一个专业、友好的图书推荐和阅读顾问。

## 用户信息
- 用户名：${user.username}
- 用户角色：${user.role == app_models.UserRole.admin ? '管理员' : '普通读者'}

## 用户阅读画像
- 借阅历史：$borrowedBookTitles
- 收藏图书：$favoriteBookTitles
- 偏好学科：${topCategories.map((e) => '${e.key}(${e.value}本)').join('、')}

## 图书馆藏书（部分可借图书）
$libraryBookList

## 你的能力
1. **图书推荐**：根据用户兴趣推荐图书。优先推荐图书馆内的书（上面列出的），如果馆内没有，也可以推荐馆外知名图书。推荐时给出书名、作者、简介。
2. **智能预约管家**：根据用户习惯推荐最佳预约时间。如果用户问预约，分析其借阅历史中的时间规律，结合常见高峰时段（上午9-11点、下午2-4点人多），推荐人少的时段（早上8-9点、下午4-6点）。
3. **阅读建议**：根据用户阅读历史给出个性化建议，如"你最近读了不少计算机类书籍，可以尝试看看数据科学方向的书"。
4. **一般问答**：回答图书馆相关问题，如开放时间、借阅规则等。

## 回复要求
- 语气友好、专业，像一个热情的图书管理员
- 推荐图书时必须给出书名、作者、简要介绍
- 预约相关问题要给出具体时间段建议
- 使用简洁的中文回复，适当使用emoji增加亲和力
- 如果用户的问题与图书无关，也可以正常回答
''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((h) => {'role': h['role'], 'content': h['content']}),
      {'role': 'user', 'content': message},
    ];

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.dashScopeApiKey}',
            },
            body: jsonEncode({
              'model': 'qwen-turbo',
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 1000,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return '抱歉，AI服务暂时不可用，请稍后再试。';
      }
    } catch (e) {
      return '网络连接异常，请检查网络后重试。';
    }
  }

  static String generateSmartReservationSuggestion(String userId) {
    final borrowRecords = MockDataService.borrowRecords
        .where((r) => r.userId == userId)
        .toList();

    if (borrowRecords.isEmpty) {
      return '检测到您是新读者，建议预约工作日上午8:00-10:00时段，人少安静，适合沉浸式学习。';
    }

    final dayOfWeekStats = <int, int>{};
    for (final record in borrowRecords) {
      final day = record.borrowDate.weekday;
      dayOfWeekStats[day] = (dayOfWeekStats[day] ?? 0) + 1;
    }

    final sortedDays = dayOfWeekStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topDay = sortedDays.first;

    const dayNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final preferredDay = dayNames[topDay.key];

    final suggestions = [
      '📊 根据您过去的借阅记录，您通常在$preferredDay到馆学习。',
      '目前${_getNextDayName(topDay.key)}下午14:00-16:00时段还有较多空位，需要帮您预约吗？',
      '💡 小贴士：早上8:00-10:00时段通常人最少，适合需要专注的学习。',
    ];

    return suggestions.join('\n');
  }

  static String _getNextDayName(int dayOfWeek) {
    final today = DateTime.now().weekday;
    int daysUntil = dayOfWeek - today;
    if (daysUntil <= 0) daysUntil += 7;

    const dayNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final nextDay = (today + daysUntil - 1) % 7 + 1;
    return dayNames[nextDay];
  }

  static String generateQuickReply(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('python') ||
        lowerMessage.contains('编程') ||
        lowerMessage.contains('编程入门')) {
      return '推荐Python学习路线';
    }

    if (lowerMessage.contains('预约') || lowerMessage.contains('到馆')) {
      return '帮我预约明天下午';
    }

    if (lowerMessage.contains('推荐') || lowerMessage.contains('有什么好书')) {
      return '推荐几本好书';
    }

    if (lowerMessage.contains('小说') || lowerMessage.contains('文学')) {
      return '推荐一些小说';
    }

    return '';
  }

  static List<String> getQuickActions() {
    return ['📚 推荐好书', '📅 帮我预约', '🐍 学Python', '📖 阅读建议'];
  }
}
