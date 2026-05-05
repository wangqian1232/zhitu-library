import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../config/app_config.dart';

class BookHealthReportService {
  static const String _baseUrl =
      'https://dashscope.aliyuncs.com/compatible-mode/v1';

  static Future<BookHealthReport> generateReport(Book book) async {
    try {
      final reportJson = await _callAiToGenerateReport(book);
      return _parseReportFromJson(book.id, reportJson);
    } catch (e) {
      return _generateFallbackReport(book);
    }
  }

  static Future<Map<String, dynamic>> _callAiToGenerateReport(Book book) async {
    final prompt =
        '你是专业的图书分析师，请为以下图书生成详细的体检报告JSON。\n\n'
        '图书信息：\n'
        '书名：${book.title}\n'
        '作者：${book.author}\n'
        '出版社：${book.publisher}\n'
        'ISBN：${book.isbn}\n'
        '分类：${book.majorCategory}/${book.category}\n'
        '简介：${book.description}\n'
        '借阅次数：${book.borrowCount}\n\n'
        '请根据图书的实际内容特点，生成以下维度的详细分析：\n\n'
        '1. readingDifficulty: starRating(1-5星), aiInterpretation(具体说明难度和涉及的概念), difficultyValue(0.0-1.0)\n'
        '2. readingPostures: 数组1-3个对象，posture(intensive精读/extensive泛读/reference查阅), description(具体建议), icon(emoji)\n'
        '3. timeCost: totalMinutes(总分钟数), aiSuggestion(时间规划建议), suggestedSessions(建议分几次)\n'
        '4. sensoryIndicators: emotionType(tragedy严肃/comedy轻松/mixed悲喜交加), emotionInterpretation(情感体验描述), emotionWaves(6个点的chapterProgress和emotionValue), writingStyles(数组1-2个: coldObjective/humorous/ornate/minimalist), styleAnalogy(风格类比)\n'
        '5. nutritionIndicators: knowledgeContents(3-5个知识模块，含name/percentage/description), aiComment(知识营养总结), hardSkills(2-3个硬技能), softSkills(1-2个软技能)\n'
        '6. socialAndWarningIndicators: audienceMatches(3个人群匹配), warnings(1-2个预警)\n'
        '7. summaryQuote: 精炼的总结金句\n\n'
        '格式示例：\n'
        '{"readingDifficulty":{"starRating":3,"aiInterpretation":"本书涉及算法复杂度分析，需要数学基础","difficultyValue":0.6},"readingPostures":[{"posture":"intensive","description":"建议精读并实践代码","icon":"📝"}],"timeCost":{"totalMinutes":480,"aiSuggestion":"建议分4次读完","suggestedSessions":4},"sensoryIndicators":{"emotionType":"mixed","emotionInterpretation":"前半部分理论较抽象，后半部分实践有趣","emotionWaves":[{"chapterProgress":0.0,"emotionValue":0.4},{"chapterProgress":0.2,"emotionValue":0.3},{"chapterProgress":0.4,"emotionValue":0.5},{"chapterProgress":0.6,"emotionValue":0.6},{"chapterProgress":0.8,"emotionValue":0.7},{"chapterProgress":1.0,"emotionValue":0.8}],"writingStyles":["coldObjective"],"styleAnalogy":"如果你喜欢严谨的逻辑推理，会喜欢这本书"},"nutritionIndicators":{"knowledgeContents":[{"name":"算法","percentage":40,"description":"排序搜索图算法"}],"aiComment":"高营养硬书","hardSkills":[{"name":"算法设计","icon":"🧮","description":"掌握算法设计"}],"softSkills":[{"name":"逻辑思维","icon":"🧠","description":"培养逻辑推理"}]},"socialAndWarningIndicators":{"audienceMatches":[{"audience":"计算机学生","matchPercentage":90,"reason":"专业核心课程"}],"warnings":[{"type":"难度预警","content":"需要编程基础","icon":"⚠️"}]},"summaryQuote":"值得认真阅读的好书"}\n\n'
        '请返回纯JSON，不要包含任何其他文字或markdown标记。';

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
                'content': '你是专业的图书分析师，擅长深度分析图书内容。返回纯JSON，无markdown标记。',
              },
              {'role': 'user', 'content': prompt},
            ],
            'temperature': 0.8,
            'max_tokens': 3000,
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
  }

  static BookHealthReport _parseReportFromJson(
    String bookId,
    Map<String, dynamic> json,
  ) {
    final rd = json['readingDifficulty'] as Map<String, dynamic>;
    final readingDifficulty = ReadingDifficulty(
      starRating: (rd['starRating'] as num).toInt(),
      aiInterpretation: rd['aiInterpretation'] as String,
      difficultyValue: (rd['difficultyValue'] as num).toDouble(),
    );

    final posturesJson = json['readingPostures'] as List<dynamic>;
    final readingPostures = posturesJson.map((p) {
      final postureMap = p as Map<String, dynamic>;
      final postureStr = postureMap['posture'] as String;
      ReadingPosture posture;
      switch (postureStr) {
        case 'intensive':
          posture = ReadingPosture.intensive;
          break;
        case 'extensive':
          posture = ReadingPosture.extensive;
          break;
        case 'reference':
          posture = ReadingPosture.reference;
          break;
        default:
          posture = ReadingPosture.intensive;
      }
      return ReadingPostureInfo(
        posture: posture,
        description: postureMap['description'] as String,
        icon: postureMap['icon'] as String,
      );
    }).toList();

    final tc = json['timeCost'] as Map<String, dynamic>;
    final timeCost = TimeCost(
      totalMinutes: (tc['totalMinutes'] as num).toInt(),
      aiSuggestion: tc['aiSuggestion'] as String,
      suggestedSessions: (tc['suggestedSessions'] as num).toInt(),
    );

    final si = json['sensoryIndicators'] as Map<String, dynamic>;
    final emotionTypeStr = si['emotionType'] as String;
    EmotionType emotionType;
    switch (emotionTypeStr) {
      case 'tragedy':
        emotionType = EmotionType.tragedy;
        break;
      case 'comedy':
        emotionType = EmotionType.comedy;
        break;
      case 'mixed':
        emotionType = EmotionType.mixed;
        break;
      default:
        emotionType = EmotionType.mixed;
    }

    final wavesJson = si['emotionWaves'] as List<dynamic>;
    final emotionWaves = wavesJson.map((w) {
      final waveMap = w as Map<String, dynamic>;
      return EmotionWave(
        chapterProgress: (waveMap['chapterProgress'] as num).toDouble(),
        emotionValue: (waveMap['emotionValue'] as num).toDouble(),
      );
    }).toList();

    final stylesJson = si['writingStyles'] as List<dynamic>;
    final writingStyles = stylesJson.map((s) {
      final styleStr = s as String;
      switch (styleStr) {
        case 'coldObjective':
          return WritingStyle.coldObjective;
        case 'humorous':
          return WritingStyle.humorous;
        case 'ornate':
          return WritingStyle.ornate;
        case 'minimalist':
          return WritingStyle.minimalist;
        default:
          return WritingStyle.coldObjective;
      }
    }).toList();

    final sensoryIndicators = SensoryIndicators(
      emotionType: emotionType,
      emotionInterpretation: si['emotionInterpretation'] as String,
      emotionWaves: emotionWaves,
      writingStyles: writingStyles,
      styleAnalogy: si['styleAnalogy'] as String,
    );

    final ni = json['nutritionIndicators'] as Map<String, dynamic>;
    final kcJson = ni['knowledgeContents'] as List<dynamic>;
    final knowledgeContents = kcJson.map((k) {
      final kMap = k as Map<String, dynamic>;
      return KnowledgeContent(
        name: kMap['name'] as String,
        percentage: (kMap['percentage'] as num).toDouble(),
        description: kMap['description'] as String,
      );
    }).toList();

    final hsJson = ni['hardSkills'] as List<dynamic>;
    final hardSkills = hsJson.map((s) {
      final sMap = s as Map<String, dynamic>;
      return Skill(
        name: sMap['name'] as String,
        icon: sMap['icon'] as String,
        description: sMap['description'] as String,
        isHardSkill: true,
      );
    }).toList();

    final ssJson = ni['softSkills'] as List<dynamic>;
    final softSkills = ssJson.map((s) {
      final sMap = s as Map<String, dynamic>;
      return Skill(
        name: sMap['name'] as String,
        icon: sMap['icon'] as String,
        description: sMap['description'] as String,
        isHardSkill: false,
      );
    }).toList();

    final nutritionIndicators = NutritionIndicators(
      knowledgeContents: knowledgeContents,
      aiComment: ni['aiComment'] as String,
      hardSkills: hardSkills,
      softSkills: softSkills,
    );

    final swi = json['socialAndWarningIndicators'] as Map<String, dynamic>;
    final amJson = swi['audienceMatches'] as List<dynamic>;
    final audienceMatches = amJson.map((a) {
      final aMap = a as Map<String, dynamic>;
      return AudienceMatch(
        audience: aMap['audience'] as String,
        matchPercentage: (aMap['matchPercentage'] as num).toDouble(),
        reason: aMap['reason'] as String,
      );
    }).toList();

    final wJson = swi['warnings'] as List<dynamic>;
    final warnings = wJson.map((w) {
      final wMap = w as Map<String, dynamic>;
      return WarningInfo(
        type: wMap['type'] as String,
        content: wMap['content'] as String,
        icon: wMap['icon'] as String,
      );
    }).toList();

    final socialAndWarningIndicators = SocialAndWarningIndicators(
      audienceMatches: audienceMatches,
      warnings: warnings,
    );

    return BookHealthReport(
      bookId: bookId,
      readingDifficulty: readingDifficulty,
      readingPostures: readingPostures,
      timeCost: timeCost,
      sensoryIndicators: sensoryIndicators,
      nutritionIndicators: nutritionIndicators,
      socialAndWarningIndicators: socialAndWarningIndicators,
      summaryQuote: json['summaryQuote'] as String,
    );
  }

  static BookHealthReport _generateFallbackReport(Book book) {
    final wordCount = book.description.length;
    final estimatedMinutes = (wordCount * 0.5).round().clamp(120, 900);
    final difficultyValue = (wordCount / 500).clamp(0.2, 0.95);
    final starRating = (difficultyValue * 5).round().clamp(1, 5);

    return BookHealthReport(
      bookId: book.id,
      readingDifficulty: ReadingDifficulty(
        starRating: starRating,
        aiInterpretation:
            '《${book.title}》属于${book.majorCategory}领域的${book.category}方向。根据内容复杂度分析，本书涉及较多专业概念，建议具备相关基础知识后阅读。',
        difficultyValue: difficultyValue,
      ),
      readingPostures: [
        ReadingPostureInfo(
          posture: ReadingPosture.intensive,
          description: '本书内容系统性强，建议精读并做好笔记',
          icon: '📝',
        ),
        ReadingPostureInfo(
          posture: ReadingPosture.reference,
          description: '可作为${book.category}领域的参考书查阅',
          icon: '📖',
        ),
      ],
      timeCost: TimeCost(
        totalMinutes: estimatedMinutes,
        aiSuggestion:
            '按中等阅读速度，读完本书约需${estimatedMinutes ~/ 60}小时。建议分${(estimatedMinutes / 120).round()}次读完。',
        suggestedSessions: (estimatedMinutes / 120).round().clamp(2, 6),
      ),
      sensoryIndicators: SensoryIndicators(
        emotionType: EmotionType.mixed,
        emotionInterpretation: '全书基调理性严谨，前半部分理论讲解较为抽象，后半部分结合实际案例逐渐清晰。',
        emotionWaves: [
          EmotionWave(chapterProgress: 0.0, emotionValue: 0.4),
          EmotionWave(chapterProgress: 0.2, emotionValue: 0.3),
          EmotionWave(chapterProgress: 0.4, emotionValue: 0.5),
          EmotionWave(chapterProgress: 0.6, emotionValue: 0.6),
          EmotionWave(chapterProgress: 0.8, emotionValue: 0.7),
          EmotionWave(chapterProgress: 1.0, emotionValue: 0.8),
        ],
        writingStyles: [WritingStyle.coldObjective],
        styleAnalogy: '如果你喜欢系统化的知识体系，那你也会喜欢这本书的结构。',
      ),
      nutritionIndicators: NutritionIndicators(
        knowledgeContents: [
          KnowledgeContent(
            name: book.category,
            percentage: 50,
            description: '核心专业知识',
          ),
          KnowledgeContent(name: '理论基础', percentage: 25, description: '相关理论框架'),
          KnowledgeContent(name: '实践应用', percentage: 25, description: '实际应用案例'),
        ],
        aiComment:
            '这是一本${book.majorCategory}领域的专业书籍，读完能帮你建立${book.category}方向的知识体系。',
        hardSkills: [
          Skill(
            name: '${book.category}知识',
            icon: '📚',
            description: '掌握${book.category}核心知识',
            isHardSkill: true,
          ),
          Skill(
            name: '专业分析',
            icon: '🔍',
            description: '提升专业问题分析能力',
            isHardSkill: true,
          ),
        ],
        softSkills: [
          Skill(
            name: '系统思维',
            icon: '🧠',
            description: '培养系统化思考能力',
            isHardSkill: false,
          ),
        ],
      ),
      socialAndWarningIndicators: SocialAndWarningIndicators(
        audienceMatches: [
          AudienceMatch(
            audience: '${book.majorCategory}专业学生',
            matchPercentage: 85,
            reason: '适合${book.majorCategory}专业系统学习',
          ),
          AudienceMatch(
            audience: '${book.category}从业者',
            matchPercentage: 75,
            reason: '有助于提升${book.category}专业能力',
          ),
          AudienceMatch(
            audience: '初学者',
            matchPercentage: 45,
            reason: '需要一定基础知识储备',
          ),
        ],
        warnings: [
          WarningInfo(type: '学习建议', content: '建议结合实践学习，加深理解。', icon: '💡'),
        ],
      ),
      summaryQuote: '《${book.title}》是一本值得认真阅读的好书，虽然内容可能有些专业，但收获一定丰厚。',
    );
  }
}
