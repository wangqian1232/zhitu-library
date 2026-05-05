import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AISearchService {
  static const String _baseUrl =
      'https://dashscope.aliyuncs.com/compatible-mode/v1';

  static final List<String> defaultSuggestionPrompts = [
    '适合大一新生读的社会学书',
    '最近很火的悬疑推理小说',
    '关于人工智能的入门教材',
    '让人不焦虑的心理治愈书',
    '提升沟通技巧的实用好书',
  ];

  static Future<List<String>> getAISuggestionPrompts() async {
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
              'messages': [
                {
                  'role': 'system',
                  'content': '你是图书推荐助手。请返回5个有趣的图书搜索提示词，覆盖不同类别和阅读场景。',
                },
                {
                  'role': 'user',
                  'content':
                      '请生成5个图书搜索提示词，要求多样化、有吸引力，能引导用户探索不同类型的图书。每行一个，不要编号。',
                },
              ],
              'temperature': 0.9,
              'max_tokens': 200,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final prompts = content
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .take(5)
            .toList();
        if (prompts.isNotEmpty) return prompts;
      }
    } catch (e) {
      // ignore
    }
    return defaultSuggestionPrompts;
  }

  static Future<Map<String, dynamic>> extractSearchKeywords(
    String query,
  ) async {
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
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '你是图书搜索助手。分析用户搜索意图，返回JSON格式：{"searchType":"direct"|"recommend","keywords":["关键词"],"reason":"判断理由"}。searchType规则：direct=用户输入的是具体书名或作者名，可直接搜索；recommend=用户输入的是描述性语句（如"适合新生的书"、"科幻与哲学交织的小说"），需要AI推荐。',
                },
                {
                  'role': 'user',
                  'content':
                      '请分析以下搜索语句："$query"。判断是直接搜索还是推荐搜索。如果是直接搜索，提取精确的书名或作者名作为keywords；如果是推荐搜索，keywords留空数组。返回纯JSON。',
                },
              ],
              'temperature': 0.3,
              'max_tokens': 200,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return {
      'searchType': 'direct',
      'keywords': [query],
      'reason': 'API error, fallback to direct',
    };
  }

  static Future<Map<String, dynamic>> generateRecommendations(
    String query,
    List<String> availableBooks,
  ) async {
    try {
      final booksContext = availableBooks.take(20).join('、');
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.dashScopeApiKey}',
            },
            body: jsonEncode({
              'model': 'qwen-turbo',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '你是图书推荐助手。根据用户搜索意图和可用图书列表，生成推荐语和推荐图书。返回JSON格式：{"recommendationText":"推荐语","recommendedBooks":["书名1","书名2","书名3"]}',
                },
                {
                  'role': 'user',
                  'content':
                      '用户搜索："$query"\n\n可用图书列表：$booksContext\n\n请根据用户搜索意图，从可用图书中推荐3-5本最相关的书。返回纯JSON。',
                },
              ],
              'temperature': 0.7,
              'max_tokens': 500,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return {
      'recommendationText': '为你推荐以下相关书籍：',
      'recommendedBooks': availableBooks.take(3).toList(),
    };
  }
}
