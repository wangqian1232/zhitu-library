import '../models/models.dart';
import 'system_settings_service.dart';
import 'system_log_service.dart';

class MockDataService {
  static final Map<String, List<String>> categoryTree = {
    '工学': [
      '计算机科学与技术',
      '软件工程',
      '电子信息工程',
      '通信工程',
      '自动化',
      '机械工程',
      '土木工程',
      '建筑学',
      '材料科学与工程',
      '电气工程及其自动化',
      '车辆工程',
      '航空航天工程',
    ],
    '理学': [
      '数学与应用数学',
      '物理学',
      '化学',
      '生物科学',
      '生物技术',
      '心理学',
      '统计学',
      '地理科学',
      '应用心理学',
    ],
    '经济学与管理学': [
      '金融学',
      '会计学',
      '工商管理',
      '市场营销',
      '国际经济与贸易',
      '人力资源管理',
      '电子商务',
      '财务管理',
      '审计学',
      '旅游管理',
    ],
    '文学与历史学': [
      '汉语言文学',
      '英语',
      '新闻学',
      '历史学',
      '哲学',
      '广告学',
      '传播学',
      '汉语言',
      '翻译',
      '小说',
    ],
    '法学与社会学': ['法学', '社会学', '政治学与行政学', '思想政治教育', '社会工作', '知识产权'],
    '医学': ['临床医学', '药学', '护理学', '口腔医学', '中医学', '法医学', '预防医学'],
    '艺术学': ['视觉传达设计', '音乐学', '美术学', '环境设计', '产品设计', '服装与服饰设计', '广播电视编导'],
    '教育学': ['教育学', '学前教育', '小学教育', '体育教育', '教育技术学'],
    '农学': ['农学', '园艺', '动物医学', '林学', '园林'],
  };

  static final List<User> users = [
    User(
      id: '1',
      username: 'admin',
      password: '123456',
      email: 'admin@library.com',
      phone: '13800138000',
      role: UserRole.admin,
      avatar: 'assets/avatars/admin_avatar.png',
    ),
    User(
      id: '2',
      username: 'yunXianShuoShu',
      password: '123456',
      email: 'user@library.com',
      phone: '13900139000',
      role: UserRole.user,
      avatar: 'assets/avatars/user_avatar.png',
    ),
  ];

  static final List<Book> books = [
    Book(
      id: '1',
      title: '数据结构与算法分析',
      author: 'Mark Allen Weiss',
      publisher: '机械工业出版社',
      isbn: '978-7-111-59840-2',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description:
          '本书全面分析了数据结构与算法的基本概念、原理和应用。内容涵盖表、栈、队列、树、散列、优先队列、不相交集、图、排序、算法设计技巧等。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 128,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780321370136-M.jpg',
    ),
    Book(
      id: '2',
      title: '深入理解计算机系统',
      author: 'Randal E. Bryant',
      publisher: '机械工业出版社',
      isbn: '978-7-111-54493-7',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书从程序员的视角详细阐述计算机系统的本质概念，并展示这些概念如何实实在在地影响应用程序的正确性、性能和实用性。',
      totalCopies: 3,
      availableCopies: 0,
      status: BookStatus.borrowed,
      borrowCount: 256,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780134092669-M.jpg',
    ),
    Book(
      id: '3',
      title: '算法导论',
      author: 'Thomas H. Cormen',
      publisher: '机械工业出版社',
      isbn: '978-7-111-40701-0',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面地介绍了计算机算法。对每一个算法的分析既易于理解又十分有趣，并保持了数学严谨性。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780262033848-M.jpg',
    ),
    Book(
      id: '4',
      title: '设计模式：可复用面向对象软件的基础',
      author: 'Erich Gamma',
      publisher: '机械工业出版社',
      isbn: '978-7-111-07575-6',
      majorCategory: '工学',
      category: '软件工程',
      description: '本书结合设计实例从面向对象的设计中精选出23个设计模式，总结了面向对象设计中最有价值的经验。',
      totalCopies: 3,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780201633610-M.jpg',
    ),
    Book(
      id: '5',
      title: '计算机网络：自顶向下方法',
      author: 'James F. Kurose',
      publisher: '机械工业出版社',
      isbn: '978-7-111-59840-3',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书采用自顶向下的方法来介绍计算机网络，从应用层开始，逐层向下讲解。',
      totalCopies: 4,
      availableCopies: 0,
      status: BookStatus.borrowed,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780132856201-M.jpg',
    ),
    Book(
      id: '6',
      title: '操作系统概念',
      author: 'Abraham Silberschatz',
      publisher: '高等教育出版社',
      isbn: '978-7-04-049852-7',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面介绍了操作系统的基本概念、设计原理和实现技术。',
      totalCopies: 3,
      availableCopies: 1,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9781119320913-M.jpg',
    ),
    Book(
      id: '7',
      title: '数据库系统概论',
      author: 'Abraham Silberschatz',
      publisher: '机械工业出版社',
      isbn: '978-7-111-37834-1',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面介绍了数据库系统的基本原理、设计方法和实现技术。',
      totalCopies: 4,
      availableCopies: 4,
      borrowCount: 112,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780073523323-M.jpg',
    ),
    Book(
      id: '8',
      title: '编译原理',
      author: 'Alfred V. Aho',
      publisher: '机械工业出版社',
      isbn: '978-7-111-23746-4',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面介绍了编译器的设计原理和实现技术，是编译领域的经典教材。',
      totalCopies: 2,
      availableCopies: 0,
      status: BookStatus.borrowed,
      borrowCount: 98,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780321486813-M.jpg',
    ),
    Book(
      id: '9',
      title: '人工智能：现代方法',
      author: 'Stuart Russell',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-54240-0',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面介绍了人工智能领域的基本概念、原理和应用。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 203,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780134610993-M.jpg',
    ),
    Book(
      id: '10',
      title: '机器学习',
      author: '周志华',
      publisher: '清华大学出版社',
      isbn: '978-7-302-42328-7',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书系统介绍了机器学习的基本理论、主要方法和典型应用。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 178,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787302423287-M.jpg',
    ),
    Book(
      id: '11',
      title: 'Python编程：从入门到实践',
      author: 'Eric Matthes',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-42802-8',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书是一本针对所有层次的Python读者而作的Python入门书，适合初学者快速上手。',
      totalCopies: 6,
      availableCopies: 2,
      borrowCount: 312,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9781593276034-M.jpg',
    ),
    Book(
      id: '12',
      title: 'Java核心技术?卷I',
      author: 'Cay S. Horstmann',
      publisher: '机械工业出版社',
      isbn: '978-7-111-54742-6',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书是Java领域的经典教程，全面介绍了Java SE的核心技术。',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 234,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780134190563-M.jpg',
    ),
    Book(
      id: '13',
      title: 'C++ Primer',
      author: 'Stanley B. Lippman',
      publisher: '电子工业出版社',
      isbn: '978-7-121-15535-4',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书是C++领域的经典入门教材，全面介绍了C++11标准。',
      totalCopies: 3,
      availableCopies: 0,
      status: BookStatus.borrowed,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780321714114-M.jpg',
    ),
    Book(
      id: '14',
      title: 'JavaScript高级程序设计',
      author: 'Matt Frisbie',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-54537-4',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书是JavaScript领域的经典著作，全面介绍了JavaScript的核心概念和高级特性。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 267,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780135957059-M.jpg',
    ),
    Book(
      id: '15',
      title: 'Vue.js设计与实现',
      author: '霍春阳',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-58218-7',
      majorCategory: '工学',
      category: '软件工程',
      description: '本书深入剖析了Vue.js 3的设计思想和实现原理。',
      totalCopies: 3,
      availableCopies: 1,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787115582188-M.jpg',
    ),
    Book(
      id: '16',
      title: 'Spring Boot实战',
      author: 'Craig Walls',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-43420-9',
      majorCategory: '工学',
      category: '软件工程',
      description: '本书通过实际案例介绍了Spring Boot框架的使用方法和最佳实践。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9781617292545-M.jpg',
    ),
    Book(
      id: '17',
      title: '深度学习',
      author: 'Ian Goodfellow',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-46147-0',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书是深度学习领域的权威教材，全面介绍了深度学习的基本理论和应用。',
      totalCopies: 3,
      availableCopies: 1,
      borrowCount: 221,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780262035613-M.jpg',
    ),
    Book(
      id: '18',
      title: '统计学习方法',
      author: '李航',
      publisher: '清华大学出版社',
      isbn: '978-7-302-49857-1',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面介绍了统计学习的基本方法和理论，是机器学习领域的经典教材。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 198,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787302498575-M.jpg',
    ),
    Book(
      id: '19',
      title: 'Redis设计与实现',
      author: '黄健宏',
      publisher: '机械工业出版社',
      isbn: '978-7-111-46474-7',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书深入剖析了Redis的内部实现机制和设计原理。',
      totalCopies: 3,
      availableCopies: 1,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787111464747-M.jpg',
    ),
    Book(
      id: '20',
      title: 'MySQL必知必会',
      author: 'Ben Forta',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-19390-7',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书是MySQL入门的经典教材，通过实例介绍了SQL的基本用法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780672329074-M.jpg',
    ),
    Book(
      id: '21',
      title: 'Linux命令行与shell脚本编程大全',
      author: 'Richard Blum',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-42896-3',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面介绍了Linux命令行和shell脚本编程的基本知识和高级技巧。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 123,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9781118949115-M.jpg',
    ),
    Book(
      id: '22',
      title: 'Docker技术入门与实战',
      author: '杨保华',
      publisher: '机械工业出版社',
      isbn: '978-7-111-51113-4',
      majorCategory: '工学',
      category: '软件工程',
      description: '本书全面介绍了Docker容器技术的基本概念和实际应用。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787111511137-M.jpg',
    ),
    Book(
      id: '23',
      title: 'Kubernetes权威指南',
      author: '龚正',
      publisher: '电子工业出版社',
      isbn: '978-7-121-35944-2',
      majorCategory: '工学',
      category: '软件工程',
      description: '本书全面介绍了Kubernetes容器编排平台的核心概念和实际应用。',
      totalCopies: 3,
      availableCopies: 1,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787121359446-M.jpg',
    ),
    Book(
      id: '24',
      title: 'TCP/IP详解 卷1?',
      author: 'W. Richard Stevens',
      publisher: '机械工业出版社',
      isbn: '978-7-111-28381-8',
      majorCategory: '工学',
      category: '通信工程',
      description: '本书是计算机网络领域的经典著作，深入剖析了TCP/IP协议族。',
      totalCopies: 3,
      availableCopies: 1,
      borrowCount: 178,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780201633467-M.jpg',
    ),
    Book(
      id: '25',
      title: 'HTTP权威指南',
      author: 'David Gourley',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-28222-0',
      majorCategory: '工学',
      category: '通信工程',
      description: '本书全面介绍了HTTP协议的基本概念、工作原理和实际应用。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9781565925090-M.jpg',
    ),
    Book(
      id: '26',
      title: '算法',
      author: 'Robert Sedgewick',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-29380-0',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面介绍了算法的基本概念和实现方法，配有大量Java代码示例。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 212,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780321573513-M.jpg',
    ),
    Book(
      id: '27',
      title: '代码整洁之道',
      author: 'Robert C. Martin',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-21687-8',
      majorCategory: '工学',
      category: '软件工程',
      description: '本书介绍了编写整洁代码的原则、模式和实践，帮助开发者提高代码质量。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 245,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780132350884-M.jpg',
    ),
    Book(
      id: '28',
      title: '重构：改善既有代码的设计',
      author: 'Martin Fowler',
      publisher: '人民邮电出版社',
      isbn: '978-7-115-50795-5',
      majorCategory: '工学',
      category: '软件工程',
      description: '本书介绍了重构的基本原则和方法，帮助开发者改善现有代码的设计。',
      totalCopies: 3,
      availableCopies: 1,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780134757599-M.jpg',
    ),
    Book(
      id: '29',
      title: 'Go语言圣经',
      author: 'Alan A. A. Donovan',
      publisher: '机械工业出版社',
      isbn: '978-7-111-56179-6',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书是Go语言领域的权威教材，全面介绍了Go语言的特性和应用。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9780134190440-M.jpg',
    ),
    Book(
      id: '30',
      title: 'Rust程序设计',
      author: 'Jim Blandy',
      publisher: '中国电力出版社',
      isbn: '978-7-5198-2778-1',
      majorCategory: '工学',
      category: '计算机科学与技术',
      description: '本书全面介绍了Rust编程语言的核心概念和实际应用。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9781491927281-M.jpg',
    ),
    Book(
      id: '31',
      title: '高等数学',
      author: '同济大学数学系',
      publisher: '高等教育出版社',
      isbn: '978-7-04-049852-8',
      majorCategory: '理学',
      category: '数学与应用数学',
      description: '本书是高等院校理工科专业的经典数学教材，内容涵盖微积分、线性代数等。',
      totalCopies: 8,
      availableCopies: 5,
      borrowCount: 289,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787040498528-M.jpg',
    ),
    Book(
      id: '32',
      title: '线性代数',
      author: '同济大学数学系',
      publisher: '高等教育出版社',
      isbn: '978-7-04-049853-5',
      majorCategory: '理学',
      category: '数学与应用数学',
      description: '本书系统介绍了线性代数的基本概念、理论和应用。',
      totalCopies: 6,
      availableCopies: 4,
      borrowCount: 234,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787040498535-M.jpg',
    ),
    Book(
      id: '33',
      title: '概率论与数理统计',
      author: '浙江大学',
      publisher: '高等教育出版社',
      isbn: '978-7-04-049854-2',
      majorCategory: '理学',
      category: '数学与应用数学',
      description: '本书全面介绍了概率论与数理统计的基本理论和应用方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 198,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787040498542-M.jpg',
    ),
    Book(
      id: '34',
      title: '大学物理',
      author: '张三慧',
      publisher: '清华大学出版社',
      isbn: '978-7-302-42329-4',
      majorCategory: '理学',
      category: '物理学',
      description: '本书是大学物理课程的经典教材，涵盖力学、热学、电磁学、光学等内容',
      totalCopies: 6,
      availableCopies: 4,
      borrowCount: 176,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787302423294-M.jpg',
    ),
    Book(
      id: '35',
      title: '量子力学',
      author: '曾谨言',
      publisher: '科学出版社',
      isbn: '978-7-03-049855-9',
      majorCategory: '理学',
      category: '物理学',
      description: '本书系统介绍了量子力学的基本原理和数学方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787030498559-M.jpg',
    ),
    Book(
      id: '36',
      title: '普通化学',
      author: '浙江大学',
      publisher: '高等教育出版社',
      isbn: '978-7-04-049856-6',
      majorCategory: '理学',
      category: '化学',
      description: '本书是化学专业的基础教材，涵盖了化学的基本原理和实验方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787040498566-M.jpg',
    ),
    Book(
      id: '37',
      title: '有机化学',
      author: '邢其毅',
      publisher: '高等教育出版社',
      isbn: '978-7-04-049857-3',
      majorCategory: '理学',
      category: '化学',
      description: '本书全面介绍了有机化学的基本理论和反应机理。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787040498573-M.jpg',
    ),
    Book(
      id: '38',
      title: '细胞生物学',
      author: '翟中和',
      publisher: '高等教育出版社',
      isbn: '978-7-04-049858-0',
      majorCategory: '理学',
      category: '生物科学',
      description: '本书系统介绍了细胞的结构、功能和生命活动规律。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787040498580-M.jpg',
    ),
    Book(
      id: '39',
      title: '分子生物学',
      author: '朱玉贤',
      publisher: '高等教育出版社',
      isbn: '978-7-04-049859-7',
      majorCategory: '理学',
      category: '生物科学',
      description: '本书全面介绍了分子生物学的基本原理和研究方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 123,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787040498597-M.jpg',
    ),
    Book(
      id: '40',
      title: '心理学导论',
      author: '彭聃龄',
      publisher: '北京师范大学出版社',
      isbn: '978-7-303-04986-0',
      majorCategory: '理学',
      category: '心理学',
      description: '本书是心理学专业的入门教材，全面介绍了心理学的基本概念和理论。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787303049860-M.jpg',
    ),
    Book(
      id: '41',
      title: '微观经济学',
      author: '高鸿业',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-04987-7',
      majorCategory: '经济学与管理学',
      category: '金融学',
      description: '本书系统介绍了微观经济学的基本理论和分析方法。',
      totalCopies: 6,
      availableCopies: 4,
      borrowCount: 234,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300049877-M.jpg',
    ),
    Book(
      id: '42',
      title: '宏观经济学',
      author: '高鸿业',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-04988-4',
      majorCategory: '经济学与管理学',
      category: '金融学',
      description: '本书全面介绍了宏观经济学的基本理论和政策分析。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 212,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300049884-M.jpg',
    ),
    Book(
      id: '43',
      title: '管理学原理',
      author: '罗宾斯',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-04989-1',
      majorCategory: '经济学与管理学',
      category: '工商管理',
      description: '本书是管理学领域的经典教材，全面介绍了管理的基本理论和实践。',
      totalCopies: 7,
      availableCopies: 5,
      borrowCount: 267,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300049891-M.jpg',
    ),
    Book(
      id: '44',
      title: '会计学原理',
      author: '葛家澍',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-04990-8',
      majorCategory: '经济学与管理学',
      category: '会计学',
      description: '本书系统介绍了会计学的基本原理和方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 198,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300049908-M.jpg',
    ),
    Book(
      id: '45',
      title: '财务管理',
      author: '荆新',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-04991-5',
      majorCategory: '经济学与管理学',
      category: '财务管理',
      description: '本书全面介绍了企业财务管理的基本理论和实务操作。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 176,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300049915-M.jpg',
    ),
    Book(
      id: '46',
      title: '市场营销学',
      author: '菲利普·科特勒',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-04992-2',
      majorCategory: '经济学与管理学',
      category: '市场营销',
      description: '本书是市场营销领域的权威教材，全面介绍了营销理论和策略。',
      totalCopies: 6,
      availableCopies: 4,
      borrowCount: 245,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300049922-M.jpg',
    ),
    Book(
      id: '47',
      title: '人力资源管理',
      author: '加里·德斯勒',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-04993-9',
      majorCategory: '经济学与管理学',
      category: '人力资源管理',
      description: '本书系统介绍了人力资源管理的基本理论和实践方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300049939-M.jpg',
    ),
    Book(
      id: '48',
      title: '中国现代文学史',
      author: '钱理群',
      publisher: '北京大学出版社',
      isbn: '978-7-301-04994-6',
      majorCategory: '文学与历史学',
      category: '汉语言文学',
      description: '本书全面介绍了中国现代文学的发展历程和代表作品。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787301049946-M.jpg',
    ),
    Book(
      id: '49',
      title: '古代汉语',
      author: '王力',
      publisher: '中华书局',
      isbn: '978-7-101-04995-3',
      majorCategory: '文学与历史学',
      category: '汉语言文学',
      description: '本书是古代汉语学习的经典教材，系统介绍了古汉语的语法和词汇。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787101049953-M.jpg',
    ),
    Book(
      id: '50',
      title: '现代汉语',
      author: '黄伯荣',
      publisher: '高等教育出版社',
      isbn: '978-7-04-04996-4',
      majorCategory: '文学与历史学',
      category: '汉语言文学',
      description: '本书系统介绍了现代汉语的语音、词汇、语法和修辞。',
      totalCopies: 6,
      availableCopies: 4,
      borrowCount: 178,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704049964-M.jpg',
    ),
    Book(
      id: '51',
      title: '英国文学史',
      author: '王佐良',
      publisher: '外语教学与研究出版社',
      isbn: '978-7-513-04997-1',
      majorCategory: '文学与历史学',
      category: '英语',
      description: '本书全面介绍了英国文学的发展历程和经典作品。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787513049971-M.jpg',
    ),
    Book(
      id: '52',
      title: '中国通史',
      author: '范文澜',
      publisher: '人民出版社',
      isbn: '978-7-01-04998-8',
      majorCategory: '文学与历史学',
      category: '历史学',
      description: '本书全面介绍了中国历史的发展脉络和重大事件。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 198,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978701049988-M.jpg',
    ),
    Book(
      id: '53',
      title: '世界通史',
      author: '吴于廑',
      publisher: '人民出版社',
      isbn: '978-7-01-04999-5',
      majorCategory: '文学与历史学',
      category: '历史学',
      description: '本书系统介绍了世界历史的发展过程和文明演进。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978701049995-M.jpg',
    ),
    Book(
      id: '54',
      title: '哲学导论',
      author: '张世英',
      publisher: '北京大学出版社',
      isbn: '978-7-301-05000-2',
      majorCategory: '文学与历史学',
      category: '哲学',
      description: '本书是哲学入门的经典教材，全面介绍了哲学的基本问题和主要流派。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787301050002-M.jpg',
    ),
    Book(
      id: '55',
      title: '西方哲学史',
      author: '罗素',
      publisher: '商务印书馆',
      isbn: '978-7-100-05001-9',
      majorCategory: '文学与历史学',
      category: '哲学',
      description: '本书全面介绍了西方哲学的发展历程和重要思想家。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787100050019-M.jpg',
    ),
    Book(
      id: '56',
      title: '民法学',
      author: '王利明',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-05002-6',
      majorCategory: '法学与社会学',
      category: '法学',
      description: '本书系统介绍了民法的基本理论和制度体系。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 212,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300050026-M.jpg',
    ),
    Book(
      id: '57',
      title: '刑法学',
      author: '高铭暄',
      publisher: '北京大学出版社',
      isbn: '978-7-301-05003-3',
      majorCategory: '法学与社会学',
      category: '法学',
      description: '本书全面介绍了刑法的基本理论和犯罪构成要件。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787301050033-M.jpg',
    ),
    Book(
      id: '58',
      title: '宪法学',
      author: '许崇德',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-05004-0',
      majorCategory: '法学与社会学',
      category: '法学',
      description: '本书系统介绍了宪法的基本原理和制度设计。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300050040-M.jpg',
    ),
    Book(
      id: '59',
      title: '社会学概论',
      author: '郑杭生',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-05005-7',
      majorCategory: '法学与社会学',
      category: '社会学',
      description: '本书全面介绍了社会学的基本概念、理论和方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300050057-M.jpg',
    ),
    Book(
      id: '60',
      title: '内科学',
      author: '葛均波',
      publisher: '人民卫生出版社',
      isbn: '978-7-117-05006-4',
      majorCategory: '医学',
      category: '临床医学',
      description: '本书是临床医学专业的核心教材，全面介绍了内科疾病的诊断和治疗。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 234,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787117050064-M.jpg',
    ),
    Book(
      id: '61',
      title: '外科学',
      author: '陈孝平',
      publisher: '人民卫生出版社',
      isbn: '978-7-117-05007-1',
      majorCategory: '医学',
      category: '临床医学',
      description: '本书系统介绍了外科疾病的基本理论和手术治疗方法。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 198,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787117050071-M.jpg',
    ),
    Book(
      id: '62',
      title: '药理学',
      author: '杨宝峰',
      publisher: '人民卫生出版社',
      isbn: '978-7-117-05008-8',
      majorCategory: '医学',
      category: '药学',
      description: '本书全面介绍了药物的作用机制和临床应用。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 176,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787117050088-M.jpg',
    ),
    Book(
      id: '63',
      title: '护理学基础',
      author: '李小寒',
      publisher: '人民卫生出版社',
      isbn: '978-7-117-05009-5',
      majorCategory: '医学',
      category: '护理学',
      description: '本书系统介绍了护理学的基本理论和操作技能。',
      totalCopies: 6,
      availableCopies: 4,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787117050095-M.jpg',
    ),
    Book(
      id: '64',
      title: '中医学基础',
      author: '印会河',
      publisher: '中国中医药出版社',
      isbn: '978-7-513-05010-2',
      majorCategory: '医学',
      category: '中医学',
      description: '本书全面介绍了中医学的基本理论和诊疗方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787513050102-M.jpg',
    ),
    Book(
      id: '65',
      title: '教育学原理',
      author: '王道俊',
      publisher: '人民教育出版社',
      isbn: '978-7-107-05011-9',
      majorCategory: '教育学',
      category: '教育学',
      description: '本书系统介绍了教育学的基本理论和教育规律。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 198,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787107050119-M.jpg',
    ),
    Book(
      id: '66',
      title: '学前教育学',
      author: '黄仁宇',
      publisher: '人民教育出版社',
      isbn: '978-7-107-05012-6',
      majorCategory: '教育学',
      category: '学前教育',
      description: '本书全面介绍了学前教育的基本理论和实践方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787107050126-M.jpg',
    ),
    Book(
      id: '67',
      title: '小学教育学',
      author: '陈琦',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05013-3',
      majorCategory: '教育学',
      category: '小学教育',
      description: '本书系统介绍了小学教育的特点和教学方法。',
      totalCopies: 5,
      availableCopies: 4,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050133-M.jpg',
    ),
    Book(
      id: '68',
      title: '设计心理学',
      author: '唐纳德·诺曼',
      publisher: '中信出版社',
      isbn: '978-7-508-05014-0',
      majorCategory: '艺术学',
      category: '视觉传达设计',
      description: '本书从心理学角度分析了设计的基本原则和方法。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 178,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787508050140-M.jpg',
    ),
    Book(
      id: '69',
      title: '色彩构成',
      author: '伊顿',
      publisher: '中国青年出版社',
      isbn: '978-7-500-05015-7',
      majorCategory: '艺术学',
      category: '视觉传达设计',
      description: '本书系统介绍了色彩的基本理论和应用方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787500050157-M.jpg',
    ),
    Book(
      id: '70',
      title: '音乐理论基础',
      author: '李重光',
      publisher: '人民音乐出版社',
      isbn: '978-7-103-05016-4',
      majorCategory: '艺术学',
      category: '音乐学',
      description: '本书全面介绍了音乐的基本理论和乐理知识。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787103050164-M.jpg',
    ),
    Book(
      id: '71',
      title: '西方美术学',
      author: '朱伯雄',
      publisher: '人民美术出版社',
      isbn: '978-7-102-05017-1',
      majorCategory: '艺术学',
      category: '美术学',
      description: '本书系统介绍了西方美术的发展历程和代表作品。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 123,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787102050171-M.jpg',
    ),
    Book(
      id: '72',
      title: '机械设计基础',
      author: '杨可桢',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05018-8',
      majorCategory: '工学',
      category: '机械工程',
      description: '本书全面介绍了机械设计的基本原理和方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050188-M.jpg',
    ),
    Book(
      id: '73',
      title: '材料力学',
      author: '刘鸿文',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05019-5',
      majorCategory: '工学',
      category: '机械工程',
      description: '本书系统介绍了材料力学的基本理论和计算方法。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050195-M.jpg',
    ),
    Book(
      id: '74',
      title: '结构力学',
      author: '龙驭球',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05020-2',
      majorCategory: '工学',
      category: '土木工程',
      description: '本书全面介绍了结构力学的基本理论和分析方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050202-M.jpg',
    ),
    Book(
      id: '75',
      title: '土力学',
      author: '陈仲颐',
      publisher: '清华大学出版社',
      isbn: '978-7-302-05021-9',
      majorCategory: '工学',
      category: '土木工程',
      description: '本书系统介绍了土力学的基本理论和工程应用。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 112,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787302050219-M.jpg',
    ),
    Book(
      id: '76',
      title: '建筑学基础',
      author: '罗小未',
      publisher: '中国建筑工业出版社',
      isbn: '978-7-112-05022-6',
      majorCategory: '工学',
      category: '建筑学',
      description: '本书全面介绍了建筑学的基本理论和设计方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787112050226-M.jpg',
    ),
    Book(
      id: '77',
      title: '材料科学基础',
      author: '胡赓年',
      publisher: '上海交通大学出版社',
      isbn: '978-7-313-05023-3',
      majorCategory: '工学',
      category: '材料科学与工程',
      description: '本书系统介绍了材料科学的基本理论和研究方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 123,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787313050233-M.jpg',
    ),
    Book(
      id: '78',
      title: '电路原理',
      author: '江缉光',
      publisher: '清华大学出版社',
      isbn: '978-7-302-05024-0',
      majorCategory: '工学',
      category: '电气工程及其自动化',
      description: '本书全面介绍了电路的基本理论和分析方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 178,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787302050240-M.jpg',
    ),
    Book(
      id: '79',
      title: '电机学',
      author: '汤蕴璆',
      publisher: '机械工业出版社',
      isbn: '978-7-111-05025-7',
      majorCategory: '工学',
      category: '电气工程及其自动化',
      description: '本书系统介绍了电机的基本原理和运行特性。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787111050257-M.jpg',
    ),
    Book(
      id: '80',
      title: '汽车构造',
      author: '陈家瑞',
      publisher: '人民交通出版社',
      isbn: '978-7-114-05026-4',
      majorCategory: '工学',
      category: '车辆工程',
      description: '本书全面介绍了汽车的结构和工作原理。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787114050264-M.jpg',
    ),
    Book(
      id: '81',
      title: '空气动力学',
      author: '吴子牛',
      publisher: '清华大学出版社',
      isbn: '978-7-302-05027-1',
      majorCategory: '工学',
      category: '航空航天工程',
      description: '本书系统介绍了空气动力学的基本理论和应用。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 112,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787302050271-M.jpg',
    ),
    Book(
      id: '82',
      title: '飞行力学',
      author: '钱学森',
      publisher: '科学出版社',
      isbn: '978-7-03-05028-8',
      majorCategory: '工学',
      category: '航空航天工程',
      description: '本书全面介绍了飞行器的运动规律和控制方法。',
      totalCopies: 2,
      availableCopies: 1,
      borrowCount: 98,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978703050288-M.jpg',
    ),
    Book(
      id: '83',
      title: '信号与系统',
      author: '郑君里',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05029-5',
      majorCategory: '工学',
      category: '电子信息工程',
      description: '本书系统介绍了信号与系统的基本理论和分析方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050295-M.jpg',
    ),
    Book(
      id: '84',
      title: '数字信号处理',
      author: '程佩青',
      publisher: '清华大学出版社',
      isbn: '978-7-302-05030-2',
      majorCategory: '工学',
      category: '电子信息工程',
      description: '本书全面介绍了数字信号处理的基本理论和算法。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787302050302-M.jpg',
    ),
    Book(
      id: '85',
      title: '通信原理',
      author: '樊昌信',
      publisher: '国防工业出版社',
      isbn: '978-7-118-05031-9',
      majorCategory: '工学',
      category: '通信工程',
      description: '本书系统介绍了通信系统的基本原理和技术。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787118050319-M.jpg',
    ),
    Book(
      id: '86',
      title: '自动控制原理',
      author: '胡寿松',
      publisher: '科学出版社',
      isbn: '978-7-03-05032-6',
      majorCategory: '工学',
      category: '自动化',
      description: '本书全面介绍了自动控制的基本理论和设计方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 178,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978703050326-M.jpg',
    ),
    Book(
      id: '87',
      title: '现代控制理论',
      author: '刘豹',
      publisher: '机械工业出版社',
      isbn: '978-7-111-05033-3',
      majorCategory: '工学',
      category: '自动化',
      description: '本书系统介绍了现代控制理论的基本内容和应用。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787111050333-M.jpg',
    ),
    Book(
      id: '88',
      title: '国际经济学',
      author: '克鲁格曼',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-05034-0',
      majorCategory: '经济学与管理学',
      category: '国际经济与贸易',
      description: '本书全面介绍了国际贸易和国际金融的基本理论。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300050340-M.jpg',
    ),
    Book(
      id: '89',
      title: '电子商务概论',
      author: '李琪',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05035-3',
      majorCategory: '经济学与管理学',
      category: '电子商务',
      description: '本书系统介绍了电子商务的基本概念和运营模式。',
      totalCopies: 5,
      availableCopies: 4,
      borrowCount: 189,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050353-M.jpg',
    ),
    Book(
      id: '90',
      title: '审计学',
      author: '秦荣生',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-05036-7',
      majorCategory: '经济学与管理学',
      category: '审计学',
      description: '本书全面介绍了审计的基本理论和实务操作。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300050367-M.jpg',
    ),
    Book(
      id: '91',
      title: '旅游学概论',
      author: '李天元',
      publisher: '南开大学出版社',
      isbn: '978-7-310-05037-4',
      majorCategory: '经济学与管理学',
      category: '旅游管理',
      description: '本书系统介绍了旅游学的基本理论和行业发展。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 123,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787310050374-M.jpg',
    ),
    Book(
      id: '92',
      title: '新闻学概论',
      author: '李良荣',
      publisher: '复旦大学出版社',
      isbn: '978-7-309-05038-1',
      majorCategory: '文学与历史学',
      category: '新闻学',
      description: '本书全面介绍了新闻学的基本理论和实践方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 167,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787309050381-M.jpg',
    ),
    Book(
      id: '93',
      title: '广告学',
      author: '陈培爱',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05039-0',
      majorCategory: '文学与历史学',
      category: '广告学',
      description: '本书系统介绍了广告的基本理论和创意方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050390-M.jpg',
    ),
    Book(
      id: '94',
      title: '传播学教程',
      author: '郭庆光',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-05040-4',
      majorCategory: '文学与历史学',
      category: '传播学',
      description: '本书全面介绍了传播学的基本理论和研究方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 156,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300050404-M.jpg',
    ),
    Book(
      id: '95',
      title: '翻译理论与实践',
      author: '叶子南',
      publisher: '清华大学出版社',
      isbn: '978-7-302-05041-1',
      majorCategory: '文学与历史学',
      category: '翻译',
      description: '本书系统介绍了翻译的基本理论和实践技巧。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 123,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787302050411-M.jpg',
    ),
    Book(
      id: '96',
      title: '政治学原理',
      author: '王浦劬',
      publisher: '北京大学出版社',
      isbn: '978-7-301-05042-8',
      majorCategory: '法学与社会学',
      category: '政治学与行政学',
      description: '本书全面介绍了政治学的基本理论和研究方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787301050428-M.jpg',
    ),
    Book(
      id: '97',
      title: '口腔解剖生理学',
      author: '皮昕',
      publisher: '人民卫生出版社',
      isbn: '978-7-117-05043-5',
      majorCategory: '医学',
      category: '口腔医学',
      description: '本书系统介绍了口腔解剖结构和生理功能。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 112,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787117050435-M.jpg',
    ),
    Book(
      id: '98',
      title: '法医学',
      author: '王保义',
      publisher: '人民卫生出版社',
      isbn: '978-7-117-05044-2',
      majorCategory: '医学',
      category: '法医学',
      description: '本书全面介绍了法医学的基本理论和鉴定方法。',
      totalCopies: 2,
      availableCopies: 1,
      borrowCount: 89,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787117050442-M.jpg',
    ),
    Book(
      id: '99',
      title: '预防医学',
      author: '傅华',
      publisher: '人民卫生出版社',
      isbn: '978-7-117-05045-9',
      majorCategory: '医学',
      category: '预防医学',
      description: '本书系统介绍了预防医学的基本理论和公共卫生实践。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787117050459-M.jpg',
    ),
    Book(
      id: '100',
      title: '环境设计原理',
      author: '林玉莲',
      publisher: '中国建筑工业出版社',
      isbn: '978-7-112-05046-6',
      majorCategory: '艺术学',
      category: '环境设计',
      description: '本书全面介绍了环境设计的基本理论和实践方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 123,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787112050466-M.jpg',
    ),
    Book(
      id: '101',
      title: '产品设计方法学',
      author: '简召全',
      publisher: '北京理工大学出版社',
      isbn: '978-7-564-05047-3',
      majorCategory: '艺术学',
      category: '产品设计',
      description: '本书系统介绍了产品设计的基本方法和创新思维。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 112,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787564050473-M.jpg',
    ),
    Book(
      id: '102',
      title: '服装设计与工程',
      author: '刘元风',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05048-0',
      majorCategory: '艺术学',
      category: '服装与服饰设计',
      description: '本书全面介绍了服装设计的理论和工艺技术。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 98,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050480-M.jpg',
    ),
    Book(
      id: '103',
      title: '广播电视编导基础',
      author: '高鑫',
      publisher: '北京师范大学出版社',
      isbn: '978-7-303-05049-7',
      majorCategory: '艺术学',
      category: '广播电视编导',
      description: '本书系统介绍了广播电视编导的基本理论和创作方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 89,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787303050497-M.jpg',
    ),
    Book(
      id: '104',
      title: '体育教育学',
      author: '毛振明',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05050-7',
      majorCategory: '教育学',
      category: '体育教育',
      description: '本书全面介绍了体育教育的基本理论和教学方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050507-M.jpg',
    ),
    Book(
      id: '105',
      title: '教育技术学',
      author: '何克抗',
      publisher: '北京师范大学出版社',
      isbn: '978-7-303-05051-4',
      majorCategory: '教育学',
      category: '教育技术学',
      description: '本书系统介绍了教育技术的基本理论和应用技术。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 112,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787303050514-M.jpg',
    ),
    Book(
      id: '106',
      title: '作物栽培学',
      author: '王余',
      publisher: '中国农业出版社',
      isbn: '978-7-109-05052-1',
      majorCategory: '农学',
      category: '农学',
      description: '本书全面介绍了作物栽培的基本理论和实践技术。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 89,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787109050521-M.jpg',
    ),
    Book(
      id: '107',
      title: '园艺植物栽培学',
      author: '章镇',
      publisher: '中国农业出版社',
      isbn: '978-7-109-05053-8',
      majorCategory: '农学',
      category: '园艺',
      description: '本书系统介绍了园艺植物的栽培技术和管理方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 78,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787109050538-M.jpg',
    ),
    Book(
      id: '108',
      title: '兽医病理学',
      author: '赵德明',
      publisher: '中国农业大学出版社',
      isbn: '978-7-811-05054-5',
      majorCategory: '农学',
      category: '动物医学',
      description: '本书全面介绍了动物疾病的基本病理和诊断方法。',
      totalCopies: 2,
      availableCopies: 1,
      borrowCount: 67,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787811050545-M.jpg',
    ),
    Book(
      id: '109',
      title: '森林生态学',
      author: '金振洲',
      publisher: '中国林业出版社',
      isbn: '978-7-503-05055-2',
      majorCategory: '农学',
      category: '林学',
      description: '本书系统介绍了森林生态系统的基本理论和研究方法。',
      totalCopies: 2,
      availableCopies: 1,
      borrowCount: 56,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787503050552-M.jpg',
    ),
    Book(
      id: '110',
      title: '园林规划设计',
      author: '胡长清',
      publisher: '中国农业出版社',
      isbn: '978-7-109-05056-9',
      majorCategory: '农学',
      category: '园林',
      description: '本书全面介绍了园林规划设计的基本理论和实践方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 89,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787109050569-M.jpg',
    ),
    Book(
      id: '111',
      title: '应用心理学',
      author: '叶浩生',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05057-6',
      majorCategory: '理学',
      category: '应用心理学',
      description: '本书系统介绍了应用心理学的基本理论和实践方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050576-M.jpg',
    ),
    Book(
      id: '112',
      title: '统计学',
      author: '贾俊平',
      publisher: '中国人民大学出版社',
      isbn: '978-7-300-05058-6',
      majorCategory: '理学',
      category: '统计学',
      description: '本书全面介绍了统计学的基本理论和数据分析方法。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 178,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787300050586-M.jpg',
    ),
    Book(
      id: '113',
      title: '自然地理学',
      author: '伍光和',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05059-3',
      majorCategory: '理学',
      category: '地理科学',
      description: '本书系统介绍了自然地理学的基本理论和研究方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 112,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050593-M.jpg',
    ),
    Book(
      id: '114',
      title: '生物技术概论',
      author: '宋思扬',
      publisher: '科学出版社',
      isbn: '978-7-03-05060-0',
      majorCategory: '理学',
      category: '生物技术',
      description: '本书全面介绍了生物技术的基本原理和应用领域。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 98,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978703050600-M.jpg',
    ),
    Book(
      id: '115',
      title: '社会工作概论',
      author: '王思斌',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05061-7',
      majorCategory: '法学与社会学',
      category: '社会工作',
      description: '本书系统介绍了社会工作的基本理论和实务方法。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 123,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050617-M.jpg',
    ),
    Book(
      id: '116',
      title: '知识产权法',
      author: '吴汉东',
      publisher: '北京大学出版社',
      isbn: '978-7-301-05062-4',
      majorCategory: '法学与社会学',
      category: '知识产权',
      description: '本书全面介绍了知识产权法的基本理论和法律制度。',
      totalCopies: 3,
      availableCopies: 2,
      borrowCount: 134,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/9787301050624-M.jpg',
    ),
    Book(
      id: '117',
      title: '思想政治教育原理',
      author: '陈万柏',
      publisher: '高等教育出版社',
      isbn: '978-7-04-05063-4',
      majorCategory: '法学与社会学',
      category: '思想政治教育',
      description: '本书系统介绍了思想政治教育的基本理论和方法。',
      totalCopies: 4,
      availableCopies: 3,
      borrowCount: 145,
      coverUrl: 'https://covers.openlibrary.org/b/isbn/978704050634-M.jpg',
    ),
    Book(
      id: '118',
      title: '三体',
      author: '刘慈欣',
      publisher: '重庆出版社',
      isbn: '978-7-229-03093-3',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '文化大革命如火如荼进行的同时，军方探寻外星文明的绝秘计划"红岸工程"取得了突破性进展。半个世纪后，叶文洁命运般的选择掀开了人类文明向宇宙进发的序幕。',
      totalCopies: 8,
      availableCopies: 3,
      borrowCount: 456,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357056.jpg',
      coverAsset: 'assets/img/1.jpg',
    ),
    Book(
      id: '119',
      title: '三体II：黑暗森林',
      author: '刘慈欣',
      publisher: '重庆出版社',
      isbn: '978-7-229-03276-0',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '三体人在利用魔法般的科技锁死了地球人的科学之后，庞大的宇宙舰队直扑太阳系，意欲清除地球文明。面对前所未有的危局，人类组建起同样庞大的太空舰队。',
      totalCopies: 6,
      availableCopies: 2,
      borrowCount: 389,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357057.jpg',
      coverAsset: 'assets/img/2.jpg',
    ),
    Book(
      id: '120',
      title: '三体III：死神永生',
      author: '刘慈欣',
      publisher: '重庆出版社',
      isbn: '978-7-229-03494-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '与三体文明的战争使人类第一次看到了宇宙黑暗的真相，地球文明像一个恐惧的孩子，熄灭了寻友的篝火，在暗夜中发抖。',
      totalCopies: 5,
      availableCopies: 1,
      borrowCount: 367,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357058.jpg',
      coverAsset: 'assets/img/3.jpg',
    ),
    Book(
      id: '121',
      title: '活着',
      author: '余华',
      publisher: '作家出版社',
      isbn: '978-7-5063-8423-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '讲述了农村人福贵悲惨的人生遭遇。福贵本是个阔少爷，可他嗜赌如命，终于赌光了家业，一贫如洗。',
      totalCopies: 7,
      availableCopies: 2,
      borrowCount: 523,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s29064533.jpg',
      coverAsset: 'assets/img/4.jpg',
    ),
    Book(
      id: '122',
      title: '百年孤独',
      author: '加西亚·马尔克斯',
      publisher: '南海出版公司公司',
      isbn: '978-7-5442-5399-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '作品描写了布恩迪亚家族七代人的传奇故事，以及加勒比海沿岸小镇马孔多的百年兴衰，反映了拉丁美洲一个世纪以来风云变幻的历史学',
      totalCopies: 6,
      availableCopies: 3,
      borrowCount: 478,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s6384944.jpg',
      coverAsset: 'assets/img/5.jpg',
    ),
    Book(
      id: '123',
      title: '平凡的世界',
      author: '路遥',
      publisher: '北京十月文艺出版社',
      isbn: '978-7-5302-1678-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '该书以中?00年代中期?00年代中期十年间为背景，通过复杂的矛盾纠葛，以孙少安和孙少平两兄弟为中心，刻画了当时社会各阶层众多普通人的形象',
      totalCopies: 8,
      availableCopies: 4,
      borrowCount: 612,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s29432486.jpg',
      coverAsset: 'assets/img/6.jpg',
    ),
    Book(
      id: '124',
      title: '围城',
      author: '钱锺',
      publisher: '人民文学出版社',
      isbn: '978-7-02-007082-1',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '围城故事发生?920?940年代。主角方鸿渐是个从中国南方乡绅家庭走出的青年人，迫于家庭压力与同乡周家女子订亲',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 345,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s1070222.jpg',
      coverAsset: 'assets/img/7.jpg',
    ),
    Book(
      id: '125',
      title: '白夜行',
      author: '东野圭吾',
      publisher: '南海出版公司公司',
      isbn: '978-7-5442-5028-6',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '1973年，大阪的一栋废弃建筑内发现了一具男尸，此后19年，嫌疑人之女雪穗与被害者之子桐原亮司走上截然不同的人生道路',
      totalCopies: 6,
      availableCopies: 1,
      borrowCount: 489,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357059.jpg',
      coverAsset: 'assets/img/8.jpg',
    ),
    Book(
      id: '126',
      title: '解忧杂货店',
      author: '东野圭吾',
      publisher: '南海出版公司公司',
      isbn: '978-7-5442-7027-9',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '僻静街道旁的一家杂货店，只要写下烦恼投进卷帘门的投信口，第二天就会在店后的牛奶箱里得到回答',
      totalCopies: 7,
      availableCopies: 3,
      borrowCount: 567,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s27264181.jpg',
      coverAsset: 'assets/img/9.jpg',
    ),
    Book(
      id: '127',
      title: '追风筝的',
      author: '卡勒德·胡赛尼',
      publisher: '上海人民出版社',
      isbn: '978-7-208-06164-7',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '12岁的阿富汗富家少爷阿米尔与仆人哈桑情同手足。然而，在一场风筝比赛后，发生了一件悲惨不堪的事，阿米尔为自己的懦弱感到自责和痛苦',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 434,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357060.jpg',
      coverAsset: 'assets/img/25.jpg',
    ),
    Book(
      id: '128',
      title: '挪威的森',
      author: '村上春树',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-4354-6',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '这是一部动人心弦的、平缓舒雅的、略带感伤的恋爱小说。小说主人公渡边以第一人称展开他同两个女孩间的爱情纠葛',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 378,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357061.jpg',
    ),
    Book(
      id: '129',
      title: '小王子',
      author: '安托万·德·?埃克苏佩',
      publisher: '天津人民出版社',
      isbn: '978-7-201-08773-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小王子是一个超凡脱俗的仙童，住在一颗只比他大一丁点儿的小行星上。陪伴他的是一朵他非常喜爱的小玫瑰花',
      totalCopies: 9,
      availableCopies: 5,
      borrowCount: 678,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357062.jpg',
      coverAsset: 'assets/img/10.jpg',
    ),
    Book(
      id: '130',
      title: '明朝那些事儿',
      author: '当年明月',
      publisher: '浙江人民出版社',
      isbn: '978-7-213-05678-9',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '主要讲述的是?1344年到1644年这三百年间关于明朝的一些故事。以史料为基础，以年代和具体人物为主线，并加入了小说的笔法',
      totalCopies: 6,
      availableCopies: 2,
      borrowCount: 456,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357063.jpg',
    ),
    Book(
      id: '131',
      title: '盗墓笔记',
      author: '南派三叔',
      publisher: '中国友谊出版公司公司',
      isbn: '978-7-5057-2345-6',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '50年前由长沙土夫子（盗墓贼）出土的战国帛书，记载了一个奇特战国古墓的位置?0年后，其中一个土夫子的孙子在他的笔记中发现这个秘密',
      totalCopies: 5,
      availableCopies: 1,
      borrowCount: 534,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357064.jpg',
    ),
    Book(
      id: '132',
      title: '鬼吹',
      author: '天下霸唱',
      publisher: '安徽文艺出版社',
      isbn: '978-7-5396-2890-1',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '三位当代摸金校尉，为解开部族消失的千古之谜，利用风水秘术，解读天下大山大川的脉搏，寻找一处处失落在大地深处的龙楼宝殿',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 423,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357065.jpg',
    ),
    Book(
      id: '133',
      title: '庆余',
      author: '猫腻',
      publisher: '人民文学出版社',
      isbn: '978-7-02-015678-9',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '一个年轻的病人，因为一次毫不意外的经历，重生到一个完全不同的世界，成为未来庆国伯爵府一个并不光彩的私生子',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 389,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357066.jpg',
    ),
    Book(
      id: '134',
      title: '琅琊',
      author: '海宴',
      publisher: '四川文艺出版社',
      isbn: '978-7-5411-4567-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '十二年前七万赤焰军被奸人所害导致全军覆没，冤死梅岭，只剩少帅林殊侥幸生还。十二年后林殊改头换面化?麒麟才子"梅长苏',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 367,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357067.jpg',
    ),
    Book(
      id: '135',
      title: '斗破苍穹',
      author: '天蚕土豆',
      publisher: '湖北少年儿童出版社',
      isbn: '978-7-5353-6789-0',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '讲述了天才少年萧炎在创造了家族修炼纪录后却突然沦为废人，经过种种打击后，凭借执着与努力，最终成为强者的故事',
      totalCopies: 6,
      availableCopies: 3,
      borrowCount: 445,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357068.jpg',
    ),
    Book(
      id: '136',
      title: '全职高手',
      author: '蝴蝶',
      publisher: '羊城晚报出版社',
      isbn: '978-7-5543-2345-6',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '网游荣耀中被誉为教科书级别的顶尖高手叶修，因为种种原因遭到俱乐部的驱逐，离开职业圈的他寄身于一家网吧成了一个小小的网管',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 412,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357069.jpg',
    ),
    Book(
      id: '137',
      title: '诛仙',
      author: '萧鼎',
      publisher: '朝华出版社',
      isbn: '978-7-5054-1567-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '故事从一?异样"的少年开始，讲述了一个由魔教血洗青云门太极玄清道而引起的江湖恩怨',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 356,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357070.jpg',
    ),
    Book(
      id: '138',
      title: '凡人修仙',
      author: '忘语',
      publisher: '太白文艺出版社',
      isbn: '978-7-5513-2345-6',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '一个普通山村小子，偶然下进入到当地江湖小门派，成了一名记名弟子。他以这样身份，如何在门派中立足，如何以平庸的资质进入到修仙者的行列',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 378,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357071.jpg',
    ),
    Book(
      id: '139',
      title: '雪中悍刀',
      author: '烽火戏诸',
      publisher: '江苏凤凰文艺出版社',
      isbn: '978-7-5399-8901-2',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '讲述了一个关于庙堂权争与刀剑交错的时代，一个暗潮涌动粉墨登场的江湖',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 334,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357072.jpg',
    ),
    Book(
      id: '140',
      title: '择天',
      author: '猫腻',
      publisher: '人民文学出版社',
      isbn: '978-7-02-012345-6',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '命里有时终须有，命里无时要强求。这是一个长生果的故事。三千世界，满天神魔，手握道卷，掌天下天上一应事',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 298,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357073.jpg',
    ),
    Book(
      id: '141',
      title: '傲慢与偏见',
      author: '简·奥斯汀',
      publisher: '人民文学出版社',
      isbn: '978-7-02-007032-5',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '小说以18世纪末19世纪初英国乡村生活为背景，描写了乡绅班纳特家的五个女儿的爱情故事，其中二女儿伊丽莎白与达西先生的爱情故事最为动人。',
      totalCopies: 6,
      availableCopies: 3,
      borrowCount: 456,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357074.jpg',
      coverAsset: 'assets/img/11.jpg',
    ),
    Book(
      id: '142',
      title: '简·爱',
      author: '夏洛蒂·勃朗特',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-4567-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '小说讲述了孤女简·爱在经历了种种磨难后，始终坚持自我，最终与罗切斯特先生获得幸福的故事，是一部具有强烈女性意识的经典之作。',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 389,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357075.jpg',
      coverAsset: 'assets/img/12.jpg',
    ),
    Book(
      id: '143',
      title: '呼啸山庄',
      author: '艾米莉·勃朗特',
      publisher: '人民文学出版社',
      isbn: '978-7-02-007033-2',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以荒原上的呼啸山庄和画眉田庄为背景，讲述了希斯克利夫与凯瑟琳之间跨越生死的爱情悲剧，是英国文学史上的经典之作。',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 312,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357076.jpg',
      coverAsset: 'assets/img/13.jpg',
    ),
    Book(
      id: '144',
      title: '飘',
      author: '玛格丽特·米切尔',
      publisher: '译林出版社',
      isbn: '978-7-5447-1234-5',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以美国南北战争为背景，讲述了南方庄园主女儿斯嘉丽在战争中的成长与爱情，塑造了一个坚强独立的女性形象。',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 423,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357077.jpg',
      coverAsset: 'assets/img/14.jpg',
    ),
    Book(
      id: '145',
      title: '了不起的盖茨比',
      author: 'F·斯科特·菲茨杰拉德',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-5678-9',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以20世纪20年代的美国为背景，通过盖茨比对黛西的执着追求，揭示了美国梦的虚幻与破灭，是爵士时代的经典之作。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 367,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357078.jpg',
      coverAsset: 'assets/img/15.jpg',
    ),
    Book(
      id: '146',
      title: '老人与海',
      author: '欧内斯特·海明威',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-6789-0',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说讲述了一位老渔夫在海上与大马林鱼搏斗的故事，展现了人类不屈不挠的精神，是海明威的代表作，曾获诺贝尔文学奖。',
      totalCopies: 7,
      availableCopies: 4,
      borrowCount: 534,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357079.jpg',
      coverAsset: 'assets/img/16.jpg',
    ),
    Book(
      id: '147',
      title: '麦田里的守望者',
      author: 'J·D·塞林格',
      publisher: '译林出版社',
      isbn: '978-7-5447-2345-6',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以第一人称叙述了16岁少年霍尔顿在被学校开除后在纽约游荡的三天经历，反映了青少年对成人世界的迷茫与反抗。',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 445,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357080.jpg',
      coverAsset: 'assets/img/17.jpg',
    ),
    Book(
      id: '148',
      title: '1984',
      author: '乔治·奥威尔',
      publisher: '北京十月文艺出版社',
      isbn: '978-7-5302-3456-7',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说描绘了一个极权主义社会，主人公温斯顿在"老大哥"的监视下试图反抗，最终被彻底改造。是反乌托邦文学的经典之作。',
      totalCopies: 6,
      availableCopies: 3,
      borrowCount: 567,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357081.jpg',
      coverAsset: 'assets/img/18.jpg',
    ),
    Book(
      id: '149',
      title: '动物农场',
      author: '乔治·奥威尔',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-7890-1',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以寓言形式讲述了农场动物反抗人类统治后建立新秩序的故事，讽刺了极权主义的本质，是政治寓言的经典之作。',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 398,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357082.jpg',
      coverAsset: 'assets/img/19.jpg',
    ),
    Book(
      id: '150',
      title: '美丽新世界',
      author: '阿道斯·赫胥黎',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-8901-2',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说描绘了一个科技高度发达的未来社会，人类通过基因工程和药物控制实现"幸福"，探讨了自由意志与人性的深刻主题。',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 334,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357083.jpg',
      coverAsset: 'assets/img/20.jpg',
    ),
    Book(
      id: '151',
      title: '局外人',
      author: '阿尔贝·加缪',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-9012-3',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '小说以第一人称叙述了主人公默尔索在母亲去世后表现出的冷漠态度，以及他因偶然杀人而被审判的故事，是存在主义文学的代表作。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 356,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357084.jpg',
      coverAsset: 'assets/img/21.jpg',
    ),
    Book(
      id: '152',
      title: '鼠疫',
      author: '阿尔贝·加缪',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-0123-4',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以奥兰城爆发鼠疫为背景，描写了医生里厄等人在灾难面前的人性光辉，探讨了人类面对荒诞时的反抗精神。',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 312,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357085.jpg',
      coverAsset: 'assets/img/22.jpg',
    ),
    Book(
      id: '153',
      title: '霍乱时期的爱情',
      author: '加西亚·马尔克斯',
      publisher: '南海出版公司',
      isbn: '978-7-5442-5678-9',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说讲述了弗洛伦蒂诺·阿里萨对费尔明娜长达半个多世纪的执着爱情，展现了爱情的多种形态，是马尔克斯的代表作之一。',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 423,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357086.jpg',
      coverAsset: 'assets/img/23.jpg',
    ),
    Book(
      id: '154',
      title: '百年孤独',
      author: '加西亚·马尔克斯',
      publisher: '南海出版公司',
      isbn: '978-7-5442-6789-0',
      majorCategory: '文学与历史学',
      category: '小说',
      description:
          '作品描写了布恩迪亚家族七代人的传奇故事，以及加勒比海沿岸小镇马孔多的百年兴衰，反映了拉丁美洲一个世纪以来风云变幻的历史。',
      totalCopies: 6,
      availableCopies: 3,
      borrowCount: 478,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357087.jpg',
      coverAsset: 'assets/img/24.jpg',
    ),
    Book(
      id: '155',
      title: '灿烂千阳',
      author: '卡勒德·胡赛尼',
      publisher: '上海人民出版社',
      isbn: '978-7-208-1234-5',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以阿富汗为背景，讲述了两个女人玛丽雅姆和莱拉在战乱中的命运交织，展现了女性在苦难中的坚韧与希望。',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 389,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357088.jpg',
      coverAsset: 'assets/img/26.jpg',
    ),
    Book(
      id: '156',
      title: '月亮与六便士',
      author: '威廉·萨默塞特·毛姆',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-1234-5',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以法国画家高更为原型，讲述了证券经纪人斯特里克兰德放弃优渥生活追寻艺术梦想的故事，探讨了理想与现实的冲突。',
      totalCopies: 5,
      availableCopies: 3,
      borrowCount: 456,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357089.jpg',
      coverAsset: 'assets/img/27.jpg',
    ),
    Book(
      id: '157',
      title: '刀锋',
      author: '威廉·萨默塞特·毛姆',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-2345-6',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说讲述了美国青年拉里在一战后放弃世俗生活，四处游历寻找人生意义的故事，展现了精神追求与物质世界的对立。',
      totalCopies: 4,
      availableCopies: 2,
      borrowCount: 334,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357090.jpg',
      coverAsset: 'assets/img/28.jpg',
    ),
    Book(
      id: '158',
      title: '人性的枷锁',
      author: '威廉·萨默塞特·毛姆',
      publisher: '上海译文出版社',
      isbn: '978-7-5327-3456-7',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以作者自身经历为蓝本，讲述了主人公菲利普从童年到成年的成长历程，探讨了人生的意义与自由的真谛。',
      totalCopies: 4,
      availableCopies: 1,
      borrowCount: 298,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357091.jpg',
      coverAsset: 'assets/img/29.jpg',
    ),
    Book(
      id: '159',
      title: '红与黑',
      author: '司汤达',
      publisher: '人民文学出版社',
      isbn: '978-7-02-004567-8',
      majorCategory: '文学与历史学',
      category: '小说',
      description: '小说以法国复辟王朝为背景，讲述了木匠之子于连凭借才智和野心向上爬升，最终因爱情与阶级矛盾走向悲剧的故事。',
      totalCopies: 5,
      availableCopies: 2,
      borrowCount: 367,
      coverUrl: 'https://img2.doubanio.com/view/subject/l/public/s28357092.jpg',
      coverAsset: 'assets/img/30.jpg',
    ),
  ];

  static final List<BorrowRecord> borrowRecords = [
    BorrowRecord(
      id: '1',
      bookId: '2',
      bookTitle: '深入理解计算机系统',
      bookCover: '',
      userId: '2',
      borrowDate: DateTime.now().subtract(const Duration(days: 20)),
      dueDate: DateTime.now().add(const Duration(days: 10)),
      status: BorrowStatus.active,
    ),
    BorrowRecord(
      id: '2',
      bookId: '5',
      bookTitle: '计算机网络：自顶向下方法',
      bookCover: '',
      userId: '2',
      borrowDate: DateTime.now().subtract(const Duration(days: 35)),
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      status: BorrowStatus.active,
      fine: 5.0,
    ),
    BorrowRecord(
      id: '3',
      bookId: '1',
      bookTitle: '数据结构与算法分析',
      bookCover: '',
      userId: '2',
      borrowDate: DateTime.now().subtract(const Duration(days: 40)),
      dueDate: DateTime.now().subtract(const Duration(days: 10)),
      returnDate: DateTime.now().subtract(const Duration(days: 8)),
      status: BorrowStatus.returned,
    ),
  ];

  static final List<TimeSlot> timeSlots = [
    TimeSlot(
      id: '1',
      label: '08:00-10:00',
      startTime: DateTime.now().copyWith(
        hour: 8,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      endTime: DateTime.now().copyWith(
        hour: 10,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      maxCapacity: 50,
      currentReservations: 32,
      status: TimeSlotStatus.available,
    ),
    TimeSlot(
      id: '2',
      label: '10:00-12:00',
      startTime: DateTime.now().copyWith(
        hour: 10,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      endTime: DateTime.now().copyWith(
        hour: 12,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      maxCapacity: 50,
      currentReservations: 48,
      status: TimeSlotStatus.full,
    ),
    TimeSlot(
      id: '3',
      label: '14:00-16:00',
      startTime: DateTime.now().copyWith(
        hour: 14,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      endTime: DateTime.now().copyWith(
        hour: 16,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      maxCapacity: 50,
      currentReservations: 25,
      status: TimeSlotStatus.available,
    ),
    TimeSlot(
      id: '4',
      label: '16:00-18:00',
      startTime: DateTime.now().copyWith(
        hour: 16,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      endTime: DateTime.now().copyWith(
        hour: 18,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      maxCapacity: 50,
      currentReservations: 15,
      status: TimeSlotStatus.available,
    ),
    TimeSlot(
      id: '5',
      label: '19:00-21:00',
      startTime: DateTime.now().copyWith(
        hour: 19,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      endTime: DateTime.now().copyWith(
        hour: 21,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      maxCapacity: 40,
      currentReservations: 0,
      status: TimeSlotStatus.unavailable,
      unavailableReason: '夜间维护',
    ),
  ];

  static final List<Reservation> reservations = [
    Reservation(
      id: 'R001',
      userId: '2',
      date: DateTime.now(),
      timeSlot: TimeSlot(
        id: '1',
        label: '08:00-10:00',
        startTime: DateTime.now().copyWith(
          hour: 8,
          minute: 0,
          second: 0,
          millisecond: 0,
        ),
        endTime: DateTime.now().copyWith(
          hour: 10,
          minute: 0,
          second: 0,
          millisecond: 0,
        ),
        maxCapacity: 50,
        currentReservations: 32,
      ),
      status: ReservationStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      qrCode: 'QR-R001-20260424',
    ),
    Reservation(
      id: 'R002',
      userId: '2',
      date: DateTime.now().subtract(const Duration(days: 1)),
      timeSlot: TimeSlot(
        id: '3',
        label: '14:00-16:00',
        startTime: DateTime.now()
            .subtract(const Duration(days: 1))
            .copyWith(hour: 14, minute: 0, second: 0, millisecond: 0),
        endTime: DateTime.now()
            .subtract(const Duration(days: 1))
            .copyWith(hour: 16, minute: 0, second: 0, millisecond: 0),
        maxCapacity: 50,
        currentReservations: 25,
      ),
      status: ReservationStatus.checkedIn,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      checkedInAt: DateTime.now()
          .subtract(const Duration(days: 1))
          .copyWith(hour: 14, minute: 15, second: 0, millisecond: 0),
      qrCode: 'QR-R002-20260423',
    ),
    Reservation(
      id: 'R003',
      userId: '2',
      date: DateTime.now().subtract(const Duration(days: 3)),
      timeSlot: TimeSlot(
        id: '2',
        label: '10:00-12:00',
        startTime: DateTime.now()
            .subtract(const Duration(days: 3))
            .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0),
        endTime: DateTime.now()
            .subtract(const Duration(days: 3))
            .copyWith(hour: 12, minute: 0, second: 0, millisecond: 0),
        maxCapacity: 50,
        currentReservations: 48,
      ),
      status: ReservationStatus.noShow,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      isViolated: true,
      violationReason: '逾期未签',
      qrCode: 'QR-R003-20260421',
    ),
    Reservation(
      id: 'R004',
      userId: '2',
      date: DateTime.now().subtract(const Duration(days: 5)),
      timeSlot: TimeSlot(
        id: '4',
        label: '16:00-18:00',
        startTime: DateTime.now()
            .subtract(const Duration(days: 5))
            .copyWith(hour: 16, minute: 0, second: 0, millisecond: 0),
        endTime: DateTime.now()
            .subtract(const Duration(days: 5))
            .copyWith(hour: 18, minute: 0, second: 0, millisecond: 0),
        maxCapacity: 50,
        currentReservations: 15,
      ),
      status: ReservationStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      qrCode: 'QR-R004-20260419',
    ),
  ];

  static Future<List<TimeSlot>> getTimeSlotsForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return timeSlots.map((slot) {
      return TimeSlot(
        id: slot.id,
        label: slot.label,
        startTime: date.copyWith(
          hour: slot.startTime.hour,
          minute: slot.startTime.minute,
          second: 0,
          millisecond: 0,
        ),
        endTime: date.copyWith(
          hour: slot.endTime.hour,
          minute: slot.endTime.minute,
          second: 0,
          millisecond: 0,
        ),
        maxCapacity: slot.maxCapacity,
        currentReservations: slot.currentReservations,
        status: slot.status,
        unavailableReason: slot.unavailableReason,
      );
    }).toList();
  }

  static Future<Reservation?> createReservation({
    required String userId,
    required DateTime date,
    required TimeSlot timeSlot,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (timeSlot.isFull || timeSlot.isUnavailable) {
      return null;
    }
    final hasPending = reservations.any(
      (r) => r.userId == userId && r.status == ReservationStatus.pending,
    );
    if (hasPending) {
      return null;
    }
    final newReservation = Reservation(
      id: 'R${reservations.length + 1}',
      userId: userId,
      date: date,
      timeSlot: timeSlot,
      status: ReservationStatus.pending,
      createdAt: DateTime.now(),
      qrCode:
          'QR-R${reservations.length + 1}-${date.toString().substring(0, 10).replaceAll('-', '')}',
    );
    reservations.add(newReservation);
    return newReservation;
  }

  static Future<bool> checkIn(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = reservations.indexWhere((r) => r.id == reservationId);
      if (index == -1) return false;
      final reservation = reservations[index];
      if (reservation.status != ReservationStatus.pending) return false;
      if (!reservation.canCheckIn) return false;
      reservations[index] = Reservation(
        id: reservation.id,
        userId: reservation.userId,
        date: reservation.date,
        timeSlot: reservation.timeSlot,
        status: ReservationStatus.checkedIn,
        createdAt: reservation.createdAt,
        checkedInAt: DateTime.now(),
        qrCode: reservation.qrCode,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final index = reservations.indexWhere((r) => r.id == reservationId);
      if (index == -1) return false;
      final reservation = reservations[index];
      if (reservation.status != ReservationStatus.pending) return false;
      reservations[index] = Reservation(
        id: reservation.id,
        userId: reservation.userId,
        date: reservation.date,
        timeSlot: reservation.timeSlot,
        status: ReservationStatus.cancelled,
        createdAt: reservation.createdAt,
        checkedInAt: reservation.checkedInAt,
        qrCode: reservation.qrCode,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Reservation>> getReservationsByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return reservations.where((r) => r.userId == userId).toList();
  }

  static Future<List<Reservation>> getReservationsByStatus(
    String userId,
    ReservationStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return reservations
        .where((r) => r.userId == userId && r.status == status)
        .toList();
  }

  static Future<Reservation?> getReservationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return reservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<User?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final user = users.firstWhere((u) => u.username == username);
      if (user.password == password) {
        return user;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<User?> register({
    required String username,
    required String password,
    required String email,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final exists = users.any((u) => u.username == username);
    if (exists) {
      return null;
    }
    final newUser = User(
      id: '${users.length + 1}',
      username: username,
      password: password,
      email: email,
      phone: phone,
      role: UserRole.user,
      avatar: 'assets/avatars/user_avatar.png',
      isFirstLogin: true,
    );
    users.add(newUser);
    return newUser;
  }

  static Future<User?> updateUserInterests(
    String userId,
    List<String> interests,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final index = users.indexWhere((u) => u.id == userId);
      if (index == -1) return null;
      final user = users[index];
      users[index] = user.copyWith(interests: interests, isFirstLogin: false);
      return users[index];
    } catch (e) {
      return null;
    }
  }

  static Future<User?> markFirstLoginComplete(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final index = users.indexWhere((u) => u.id == userId);
      if (index == -1) return null;
      final user = users[index];
      users[index] = user.copyWith(isFirstLogin: false);
      return users[index];
    } catch (e) {
      return null;
    }
  }

  static Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final user = users.firstWhere((u) => u.id == userId);
      if (user.password != oldPassword) {
        return false;
      }
      final index = users.indexOf(user);
      users[index] = User(
        id: user.id,
        username: user.username,
        password: newPassword,
        email: user.email,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Book>> getBooks({
    String? majorCategory,
    String? category,
    String? keyword,
    BookStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var result = books;

    if (majorCategory != null && majorCategory.isNotEmpty) {
      result = result.where((b) => b.majorCategory == majorCategory).toList();
    }

    if (category != null && category.isNotEmpty) {
      result = result.where((b) => b.category == category).toList();
    }

    if (keyword != null && keyword.isNotEmpty) {
      result = result
          .where(
            (b) =>
                b.title.toLowerCase().contains(keyword.toLowerCase()) ||
                b.author.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    }

    if (status != null) {
      result = result.where((b) => b.status == status).toList();
    }

    return result;
  }

  static Future<Book?> getBookById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return books.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<BorrowRecord>> getBorrowRecords(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return borrowRecords.where((r) => r.userId == userId).toList();
  }

  static Future<bool> borrowBook(String userId, String bookId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final userRecords = borrowRecords.where((r) => r.userId == userId).toList();
    final totalUnpaidFine = userRecords.fold<double>(
      0,
      (sum, r) => sum + r.unpaidFine,
    );
    if (totalUnpaidFine > 0) {
      return false;
    }

    final activeRecords = userRecords
        .where((r) => r.status == BorrowStatus.active)
        .toList();
    if (activeRecords.length >=
        SystemSettingsService().settings.maxBorrowCount) {
      return false;
    }

    final book = books.firstWhere((b) => b.id == bookId);
    if (book.availableCopies > 0) {
      book.availableCopies--;
      if (book.availableCopies == 0) {
        book.status = BookStatus.borrowed;
      }

      final recordId = '${borrowRecords.length + 1}';
      final borrowRecord = BorrowRecord(
        id: recordId,
        bookId: book.id,
        bookTitle: book.title,
        bookCover: book.coverUrl ?? '',
        bookCoverAsset: book.coverAsset,
        userId: userId,
        borrowDate: DateTime.now(),
        dueDate: DateTime.now().add(
          Duration(days: SystemSettingsService().settings.borrowDays),
        ),
        status: BorrowStatus.active,
      );
      borrowRecords.add(borrowRecord);

      try {
        final user = users.firstWhere((u) => u.id == userId);
        SystemLogService().addLog(
          '用户 ${user.username} 借阅${book.title}',
          SystemLogType.borrow,
          operator: user.username,
        );
      } catch (e) {}

      return true;
    }
    return false;
  }

  static Future<bool> returnBook(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final record = borrowRecords.firstWhere((r) => r.id == recordId);
    record.status = BorrowStatus.returned;
    record.returnDate = DateTime.now();
    if (record.isOverdue && record.fine == null) {
      final overdueDays = record.dueDate
          .difference(record.returnDate!)
          .inDays
          .abs();
      record.fine = overdueDays * SystemSettingsService().settings.overdueFine;
    }
    final book = books.firstWhere((b) => b.id == record.bookId);
    book.availableCopies++;
    if (book.availableCopies > 0) {
      book.status = BookStatus.available;
    }

    try {
      final user = users.firstWhere((u) => u.id == record.userId);
      SystemLogService().addLog(
        '用户 ${user.username} 归还${record.bookTitle}',
        SystemLogType.returnBook,
        operator: user.username,
      );
    } catch (e) {}

    return true;
  }

  static double getTotalUnpaidFine(String userId) {
    final userRecords = borrowRecords.where((r) => r.userId == userId).toList();
    return userRecords.fold<double>(0, (sum, r) => sum + r.unpaidFine);
  }

  static Future<bool> payFine(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final userRecords = borrowRecords.where((r) => r.userId == userId).toList();
    for (final record in userRecords) {
      if (!record.finePaid && record.fine != null && record.fine! > 0) {
        record.finePaid = true;
      }
    }

    try {
      final user = users.firstWhere((u) => u.id == userId);
      SystemLogService().addLog(
        '用户 ${user.username} 缴纳了逾期罚款',
        SystemLogType.system,
        operator: user.username,
      );
    } catch (e) {}

    return true;
  }

  static Future<Map<String, dynamic>> renewBook(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final record = borrowRecords.firstWhere((r) => r.id == recordId);
      if (record.isOverdue) {
        return {'success': false, 'message': '图书已逾期，无法续'};
      }
      if (record.renewCount >= SystemSettingsService().settings.renewCount) {
        return {'success': false, 'message': '该书已达到最大续借次'};
      }
      record.dueDate = record.dueDate.add(
        Duration(days: SystemSettingsService().settings.borrowDays ~/ 2),
      );
      record.renewCount++;
      return {'success': true, 'newDueDate': record.dueDate};
    } catch (e) {
      return {'success': false, 'message': '续借失'};
    }
  }

  static List<String> get categories {
    return books.map((b) => b.category).toSet().toList();
  }

  static Future<bool> toggleFavorite(String userId, String bookId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final book = books.firstWhere((b) => b.id == bookId);
      if (book.isFavoriteBy(userId)) {
        book.favoriteUserIds.remove(userId);
      } else {
        book.favoriteUserIds.add(userId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> reserveBook(String userId, String bookId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final book = books.firstWhere((b) => b.id == bookId);
      if (book.isReservedBy(userId)) {
        return false;
      }
      book.reservationUserIds.add(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelBookReservation(
    String userId,
    String bookId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final book = books.firstWhere((b) => b.id == bookId);
      book.reservationUserIds.remove(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Book>> getFavoriteBooks(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return books.where((b) => b.isFavoriteBy(userId)).toList();
  }

  static Future<List<Book>> getReservedBooks(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return books.where((b) => b.isReservedBy(userId)).toList();
  }

  static final List<Notification> notifications = [
    Notification(
      id: 'n1',
      userId: 'user1',
      title: '借阅到期提醒',
      content: '您借阅的《深入理解计算机系统》将3天后到期，请及时归还或续借。',
      type: NotificationType.borrow,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Notification(
      id: 'n2',
      userId: 'user1',
      title: '预约成功通知',
      content: '您预约的《C++ Primer》已成功，请在图书到馆后7天内前来借阅',
      type: NotificationType.reservation,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Notification(
      id: 'n3',
      userId: 'user1',
      title: '系统通知',
      content: '图书馆将于五一假期期间调整开放时间，具体安排请关注公告栏',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Notification(
      id: 'n4',
      userId: 'user1',
      title: '罚款通知',
      content: '您有一笔?.0的逾期罚款待缴纳，请及时处理以免影响后续借阅',
      type: NotificationType.fine,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
    ),
    Notification(
      id: 'n5',
      userId: 'user1',
      title: '新书推荐',
      content: '本月新上架图?0余册，涵盖人工智能、大数据等热门领域，欢迎前来借阅',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
    ),
  ];

  static Future<List<Notification>> getUserNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final notification = notifications.firstWhere(
        (n) => n.id == notificationId,
      );
      notification.isRead = true;
    } catch (e) {
      // ignore
    }
  }

  static Future<void> markAllNotificationsAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final notification in notifications) {
      if (notification.userId == userId) {
        notification.isRead = true;
      }
    }
  }

  static Future<int> getUnreadCount(String userId) async {
    final notificationCount = notifications
        .where((n) => n.userId == userId && !n.isRead)
        .length;
    final messageCount = messages
        .where((m) => m.userId == userId && !m.isRead)
        .length;
    return notificationCount + messageCount;
  }

  static Future<ReadingReport> generateReadingReport(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userRecords = borrowRecords.where((r) => r.userId == userId).toList();
    final returnedRecords = userRecords
        .where((r) => r.status == BorrowStatus.returned)
        .toList();

    final categoryStats = <String, int>{};
    final authorStats = <String, int>{};
    final publisherStats = <String, int>{};
    final monthlyStats = <int, int>{};

    for (final record in userRecords) {
      final book = books.firstWhere(
        (b) => b.id == record.bookId,
        orElse: () => books.first,
      );

      categoryStats[book.majorCategory] =
          (categoryStats[book.majorCategory] ?? 0) + 1;
      authorStats[book.author] = (authorStats[book.author] ?? 0) + 1;
      publisherStats[book.publisher] =
          (publisherStats[book.publisher] ?? 0) + 1;

      final month = record.borrowDate.month;
      monthlyStats[month] = (monthlyStats[month] ?? 0) + 1;
    }

    final uniqueDays = userRecords.map((r) => r.borrowDate.day).toSet().length;

    final achievements = <String>[];
    if (returnedRecords.length >= 10) achievements.add('📚 阅读达人');
    if (returnedRecords.length >= 5) achievements.add('📖 勤读之星');
    if (authorStats.values.any((v) => v >= 3)) achievements.add('✍️ 专注读者');
    if (categoryStats.keys.length >= 3) achievements.add('🌟 博览群书');
    if (returnedRecords.isNotEmpty) achievements.add('🎯 阅读新手');
    if (achievements.isEmpty) achievements.add('📝 开始你的阅读之旅');

    return ReadingReport(
      userId: userId,
      totalBooks: userRecords.length,
      totalPages: userRecords.length * 350,
      readingDays: uniqueDays,
      categoryStats: categoryStats,
      authorStats: authorStats,
      publisherStats: publisherStats,
      monthlyStats: monthlyStats,
      achievements: achievements,
    );
  }

  static final List<OverdueRecord> overdueRecords = [
    OverdueRecord(
      id: 'o1',
      bookId: '2',
      bookName: '深入理解计算机系统',
      borrowerId: '2',
      borrowerName: 'yunXianShuoShu',
      overdueDays: 5,
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      bookCover: 'https://covers.openlibrary.org/b/isbn/9780134092669-M.jpg',
    ),
    OverdueRecord(
      id: 'o2',
      bookId: '5',
      bookName: '计算机网络：自顶向下方法',
      borrowerId: '2',
      borrowerName: 'yunXianShuoShu',
      overdueDays: 3,
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      bookCover: 'https://covers.openlibrary.org/b/isbn/9780132856201-M.jpg',
    ),
    OverdueRecord(
      id: 'o3',
      bookId: '8',
      bookName: '编译原理',
      borrowerId: '2',
      borrowerName: 'yunXianShuoShu',
      overdueDays: 7,
      dueDate: DateTime.now().subtract(const Duration(days: 7)),
      bookCover: 'https://covers.openlibrary.org/b/isbn/9780321486813-M.jpg',
    ),
    OverdueRecord(
      id: 'o4',
      bookId: '13',
      bookName: 'C++ Primer',
      borrowerId: '2',
      borrowerName: 'yunXianShuoShu',
      overdueDays: 2,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      bookCover: 'https://covers.openlibrary.org/b/isbn/9780321714114-M.jpg',
    ),
  ];

  static final List<NoShowRecord> noShowRecords = [
    NoShowRecord(
      id: 'n1',
      userId: '2',
      userName: 'yunXianShuoShu',
      bookId: '1',
      bookName: '数据结构与算法分析',
      appointmentTime: DateTime.now().subtract(const Duration(hours: 2)),
      userAvatar: 'assets/avatars/user_avatar.png',
    ),
    NoShowRecord(
      id: 'n2',
      userId: '2',
      userName: 'yunXianShuoShu',
      bookId: '3',
      bookName: '算法导论',
      appointmentTime: DateTime.now().subtract(const Duration(days: 1)),
      userAvatar: 'assets/avatars/user_avatar.png',
    ),
    NoShowRecord(
      id: 'n3',
      userId: '2',
      userName: 'yunXianShuoShu',
      bookId: '10',
      bookName: '机器学习',
      appointmentTime: DateTime.now().subtract(const Duration(hours: 5)),
      userAvatar: 'assets/avatars/user_avatar.png',
    ),
  ];

  static Future<List<OverdueRecord>> getOverdueRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(overdueRecords);
  }

  static Future<List<NoShowRecord>> getNoShowRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(noShowRecords);
  }

  static Future<ExceptionCount> getExceptionCount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ExceptionCount(
      overdueCount: overdueRecords.length,
      noShowCount: noShowRecords.length,
    );
  }

  static Future<bool> sendRemind(String id, String type) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      if (type == 'overdue') {
        final record = overdueRecords.firstWhere((r) => r.id == id);
        record.reminded = true;
      } else {
        final record = noShowRecords.firstWhere((r) => r.id == id);
        record.reminded = true;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markReturned(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final record = overdueRecords.firstWhere((r) => r.id == id);
      overdueRecords.remove(record);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelBooking(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final record = noShowRecords.firstWhere((r) => r.id == id);
      noShowRecords.remove(record);
      return true;
    } catch (e) {
      return false;
    }
  }

  static final List<Message> messages = [
    Message(
      id: 'msg1',
      userId: '2',
      title: '借阅提醒',
      content: '您借阅的《数据结构与算法分析》将3天后到期，请及时归还或续借。',
      type: MessageType.borrow_reminder,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    Message(
      id: 'msg2',
      userId: '2',
      title: '预约成功通知',
      content: '您预约的《算法导论》已成功，预约时间为2026-04-24 08:00，请准时到馆签到',
      type: MessageType.reservation_reminder,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    Message(
      id: 'msg3',
      userId: '2',
      title: '逾期提醒',
      content: '您借阅的《深入理解计算机系统》已逾期5天，请尽快归还并缴纳逾期费用',
      type: MessageType.overdue_reminder,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: false,
    ),
    Message(
      id: 'msg4',
      userId: '2',
      title: '系统通知',
      content: '图书馆系统将于本周末进行维护升级，届时部分功能可能暂时不可用',
      type: MessageType.system,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  static Future<List<Message>> getMessages(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return messages.where((m) => m.userId == userId).toList();
  }

  static Future<int> getUnreadMessageCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return messages.where((m) => m.userId == userId && !m.isRead).length;
  }

  static Future<bool> markMessageAsRead(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final message = messages.firstWhere((m) => m.id == messageId);
      message.isRead = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markAllMessagesAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final message in messages) {
      if (message.userId == userId) {
        message.isRead = true;
      }
    }
    return true;
  }

  static Future<Message> addMessage({
    required String userId,
    required String title,
    required String content,
    required MessageType type,
  }) async {
    final newMessage = Message(
      id: 'msg${messages.length + 1}',
      userId: userId,
      title: title,
      content: content,
      type: type,
      createdAt: DateTime.now(),
      isRead: false,
    );
    messages.add(newMessage);
    return newMessage;
  }

  static Future<List<Book>> getNovelRecommendations(
    List<String> interests, {
    int batchIndex = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final novels = books
        .where((b) => b.category == '小说' && b.coverAsset != null)
        .toList();
    novels.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));

    final pageSize = 9;
    final start = (batchIndex * pageSize) % novels.length;
    final end = start + pageSize;

    if (end <= novels.length) {
      return novels.sublist(start, end);
    } else {
      final firstPart = novels.sublist(start);
      final secondPart = novels.sublist(0, end - novels.length);
      return [...firstPart, ...secondPart];
    }
  }

  static Future<List<Book>> getRecommendedBooks(List<String> interests) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (interests.isEmpty) {
      final sorted = List<Book>.from(books);
      sorted.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
      return sorted.take(10).toList();
    }
    final matched = books.where((b) => interests.contains(b.category)).toList();
    matched.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
    if (matched.length >= 10) {
      return matched.take(10).toList();
    }
    final remaining = books
        .where((b) => !interests.contains(b.category))
        .toList();
    remaining.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
    final result = List<Book>.from(matched);
    result.addAll(remaining.take(10 - matched.length));
    return result;
  }

  static Future<List<Book>> getBooksByCategories(
    List<String> categories, {
    int limit = 6,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final matched = books
        .where((b) => categories.contains(b.category))
        .toList();
    matched.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
    return matched.take(limit).toList();
  }

  static Future<List<Book>> getTopBorrowedBooks({int limit = 6}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final sorted = List<Book>.from(books);
    sorted.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
    return sorted.take(limit).toList();
  }
}
