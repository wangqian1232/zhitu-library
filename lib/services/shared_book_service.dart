import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class SharedBookService {
  static final SharedBookService _instance = SharedBookService._internal();
  factory SharedBookService() => _instance;
  SharedBookService._internal();

  final List<SharedBook> _sharedBooks = [];

  List<SharedBook> get sharedBooks => List.unmodifiable(_sharedBooks);

  void _initMockData() {
    if (_sharedBooks.isNotEmpty) return;
    _sharedBooks.addAll([
      SharedBook(
        id: 'sb_001',
        isbn: '9787229030933',
        title: '三体',
        author: '刘慈欣',
        publisher: '重庆出版社',
        coverAsset: 'assets/img/40.jpg',
        sharerId: '2',
        sharerName: '张同学',
        sharerGrade: '2021级',
        sharerDepartment: '计算机系',
        condition: BookCondition.likeNew,
        shareType: ShareType.permanent,
        remark: '这本书保存得很好，希望能传给下一位爱书的同学。',
        shelfNumber: 'X10001',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: SharedBookStatus.available,
      ),
      SharedBook(
        id: 'sb_002',
        isbn: '9787229032760',
        title: '三体II：黑暗森林',
        author: '刘慈欣',
        publisher: '重庆出版社',
        coverAsset: 'assets/img/2.jpg',
        sharerId: '2',
        sharerName: '李同学',
        sharerGrade: '2022级',
        sharerDepartment: '数学系',
        condition: BookCondition.hasNotes,
        shareType: ShareType.permanent,
        remark: '书内有少量笔记，不影响阅读。',
        shelfNumber: 'X10002',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: SharedBookStatus.available,
      ),
      SharedBook(
        id: 'sb_003',
        isbn: '9787229034948',
        title: '三体III：死神永生',
        author: '刘慈欣',
        publisher: '重庆出版社',
        coverAsset: 'assets/img/3.jpg',
        sharerId: '2',
        sharerName: '王同学',
        sharerGrade: '2021级',
        sharerDepartment: '物理系',
        condition: BookCondition.brandNew,
        shareType: ShareType.permanent,
        remark: '全新未拆封，科幻迷必备！',
        shelfNumber: 'X10003',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: SharedBookStatus.available,
      ),
      SharedBook(
        id: 'sb_004',
        isbn: '9787111123456',
        title: '百年孤独',
        author: '加西亚·马尔克斯',
        publisher: '南海出版公司',
        coverAsset: 'assets/img/4.jpg',
        sharerId: '2',
        sharerName: '赵同学',
        sharerGrade: '2020级',
        sharerDepartment: '中文系',
        condition: BookCondition.likeNew,
        shareType: ShareType.temporary,
        returnDate: DateTime.now().add(const Duration(days: 180)),
        remark: '经典文学，值得一读再读。',
        shelfNumber: 'X10004',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        status: SharedBookStatus.available,
      ),
      SharedBook(
        id: 'sb_005',
        isbn: '9787532712345',
        title: '活着',
        author: '余华',
        publisher: '上海文艺出版社',
        coverAsset: 'assets/img/5.jpg',
        sharerId: '2',
        sharerName: '陈同学',
        sharerGrade: '2022级',
        sharerDepartment: '历史系',
        condition: BookCondition.hasNotes,
        shareType: ShareType.permanent,
        remark: '书内有划线，但都是重点内容。',
        shelfNumber: 'X10005',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        status: SharedBookStatus.available,
      ),
      SharedBook(
        id: 'sb_006',
        isbn: '9787544123456',
        title: '小王子',
        author: '安托万·德·圣-埃克苏佩里',
        publisher: '湖南文艺出版社',
        coverAsset: 'assets/img/6.jpg',
        sharerId: '2',
        sharerName: '刘同学',
        sharerGrade: '2021级',
        sharerDepartment: '外语系',
        condition: BookCondition.brandNew,
        shareType: ShareType.permanent,
        remark: '精装版，适合收藏。',
        shelfNumber: 'X10006',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: SharedBookStatus.available,
      ),
    ]);
  }

  Future<Map<String, dynamic>> queryBookByISBN(String isbn) async {
    await Future.delayed(const Duration(seconds: 1));

    final mockBooks = {
      '9787040506345': {
        'title': '深入理解计算机系统',
        'author': 'Randal E. Bryant',
        'publisher': '高等教育出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357056.jpg',
      },
      '9787111544937': {
        'title': '算法导论',
        'author': 'Thomas H. Cormen',
        'publisher': '机械工业出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357057.jpg',
      },
      '9787115428028': {
        'title': '代码整洁之道',
        'author': 'Robert C. Martin',
        'publisher': '人民邮电出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357058.jpg',
      },
      '9787229030933': {
        'title': '三体',
        'author': '刘慈欣',
        'publisher': '重庆出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357059.jpg',
      },
      '9787229032760': {
        'title': '三体II：黑暗森林',
        'author': '刘慈欣',
        'publisher': '重庆出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357060.jpg',
      },
      '9787229034948': {
        'title': '三体III：死神永生',
        'author': '刘慈欣',
        'publisher': '重庆出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357061.jpg',
      },
      '9787111123456': {
        'title': '百年孤独',
        'author': '加西亚·马尔克斯',
        'publisher': '南海出版公司',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357062.jpg',
      },
      '9787532712345': {
        'title': '活着',
        'author': '余华',
        'publisher': '上海文艺出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357063.jpg',
      },
      '9787020012345': {
        'title': '围城',
        'author': '钱钟书',
        'publisher': '人民文学出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357064.jpg',
      },
      '9787544123456': {
        'title': '小王子',
        'author': '安托万·德·圣-埃克苏佩里',
        'publisher': '湖南文艺出版社',
        'coverUrl':
            'https://img2.doubanio.com/view/subject/l/public/s28357065.jpg',
      },
    };

    if (mockBooks.containsKey(isbn)) {
      return {'success': true, 'data': mockBooks[isbn]};
    }

    return {'success': false, 'message': '未找到该图书信息，请手动填写'};
  }

  String generateShelfNumber() {
    final random = Random();
    final number = random.nextInt(90000) + 10000;
    return 'X$number';
  }

  Future<SharedBook> addSharedBook({
    required String isbn,
    required String title,
    required String author,
    required String publisher,
    String? coverUrl,
    String? coverAsset,
    required String sharerId,
    required String sharerName,
    required String sharerGrade,
    required String sharerDepartment,
    required BookCondition condition,
    required ShareType shareType,
    DateTime? returnDate,
    String? remark,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final book = SharedBook(
      id: 'sb_${DateTime.now().millisecondsSinceEpoch}',
      isbn: isbn,
      title: title,
      author: author,
      publisher: publisher,
      coverUrl: coverUrl,
      coverAsset: coverAsset,
      sharerId: sharerId,
      sharerName: sharerName,
      sharerGrade: sharerGrade,
      sharerDepartment: sharerDepartment,
      condition: condition,
      shareType: shareType,
      returnDate: returnDate,
      remark: remark,
      shelfNumber: generateShelfNumber(),
      createdAt: DateTime.now(),
      status: SharedBookStatus.available,
    );

    _sharedBooks.add(book);
    return book;
  }

  Future<bool> borrowSharedBook(String bookId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final book = _sharedBooks.firstWhere(
      (b) => b.id == bookId,
      orElse: () => throw Exception('图书不存在'),
    );

    if (book.status != SharedBookStatus.available) {
      return false;
    }

    book.status = SharedBookStatus.borrowed;
    book.borrowerId = userId;
    book.borrowedAt = DateTime.now();
    book.dueDate = DateTime.now().add(const Duration(days: 30));

    return true;
  }

  Future<bool> returnSharedBook(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final book = _sharedBooks.firstWhere(
      (b) => b.id == bookId,
      orElse: () => throw Exception('图书不存在'),
    );

    if (book.status != SharedBookStatus.borrowed) {
      return false;
    }

    book.status = SharedBookStatus.available;
    book.borrowerId = null;
    book.borrowedAt = null;
    book.dueDate = null;

    return true;
  }

  List<SharedBook> getAvailableBooks() {
    return _sharedBooks
        .where((b) => b.status == SharedBookStatus.available)
        .toList();
  }

  List<SharedBook> getUserSharedBooks(String userId) {
    return _sharedBooks.where((b) => b.sharerId == userId).toList();
  }

  SharedBook? getBookById(String bookId) {
    try {
      return _sharedBooks.firstWhere((b) => b.id == bookId);
    } catch (e) {
      return null;
    }
  }

  List<SharedBook> getAllSharedBooks() {
    _initMockData();
    return List.unmodifiable(_sharedBooks);
  }
}
