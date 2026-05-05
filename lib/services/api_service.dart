import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.getBaseUrl();

  static Future<Map<String, dynamic>> _get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load data: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to post data: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> _put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update data: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> _delete(String path) async {
    final response = await http.delete(Uri.parse('$baseUrl$path'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to delete data: ${response.statusCode}');
  }

  static User _parseUser(Map<String, dynamic> data) {
    String roleStr = data['role'] ?? 'user';
    UserRole role = roleStr == 'admin' ? UserRole.admin : UserRole.user;

    dynamic interestsData = data['interests'];
    List<String> interests = [];
    if (interestsData is String && interestsData.isNotEmpty) {
      interests = interestsData.split(',');
    } else if (interestsData is List) {
      interests = interestsData.map((e) => e.toString()).toList();
    }

    return User(
      id: data['id']?.toString() ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatar: data['avatar'],
      role: role,
      interests: interests,
      isFirstLogin: data['firstLogin'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : null,
    );
  }

  static Book _parseBook(Map<String, dynamic> data) {
    int statusInt = data['status'] ?? 0;
    BookStatus status;
    switch (statusInt) {
      case 0:
        status = BookStatus.available;
        break;
      case 1:
        status = BookStatus.borrowed;
        break;
      case 2:
        status = BookStatus.maintenance;
        break;
      default:
        status = BookStatus.available;
    }

    List<String> favoriteUserIds = [];
    final favData = data['favoriteUserIds'];
    if (favData is String && favData.isNotEmpty) {
      favoriteUserIds = favData.split(',');
    } else if (favData is List) {
      favoriteUserIds = favData.map((e) => e.toString()).toList();
    }

    return Book(
      id: data['id']?.toString() ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      publisher: data['publisher'] ?? '',
      isbn: data['isbn'] ?? '',
      description: data['description'] ?? '',
      coverUrl: data['coverUrl'],
      coverAsset: data['coverAsset'],
      category: data['category'] ?? '',
      majorCategory: data['majorCategory'] ?? '',
      totalCopies: data['totalCopies'] ?? 1,
      availableCopies: data['availableCopies'] ?? 0,
      borrowCount: data['borrowCount'] ?? 0,
      status: status,
      sharedBy: data['sharedBy'],
      sharedByName: data['sharedByName'],
      favoriteUserIds: favoriteUserIds,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : null,
    );
  }

  static BorrowRecord _parseBorrowRecord(Map<String, dynamic> data) {
    String statusStr = data['status'] ?? 'active';
    BorrowStatus status;
    switch (statusStr) {
      case 'returned':
        status = BorrowStatus.returned;
        break;
      case 'overdue':
        status = BorrowStatus.overdue;
        break;
      default:
        status = BorrowStatus.active;
    }

    return BorrowRecord(
      id: data['id']?.toString() ?? '',
      bookId:
          data['bookId']?.toString() ?? data['book']?['id']?.toString() ?? '',
      bookTitle: data['bookTitle'] ?? data['book']?['title'] ?? '未知书籍',
      bookCover: data['bookCoverUrl'] ?? data['book']?['coverUrl'] ?? '',
      bookCoverAsset: data['bookCoverAsset'] ?? data['book']?['coverAsset'],
      userId:
          data['userId']?.toString() ?? data['user']?['id']?.toString() ?? '',
      borrowDate: DateTime.parse(
        data['borrowDate'] ?? DateTime.now().toIso8601String(),
      ),
      dueDate: DateTime.parse(
        data['dueDate'] ?? DateTime.now().toIso8601String(),
      ),
      returnDate: data['returnDate'] != null
          ? DateTime.parse(data['returnDate'])
          : null,
      status: status,
      fine: (data['fine'] as num?)?.toDouble(),
      finePaid: data['finePaid'] ?? false,
      renewCount: data['renewCount'] ?? 0,
    );
  }

  static Reservation _parseReservation(Map<String, dynamic> data) {
    String statusStr = data['status'] ?? 'pending';
    ReservationStatus status;
    switch (statusStr) {
      case 'checked_in':
        status = ReservationStatus.checkedIn;
        break;
      case 'cancelled':
        status = ReservationStatus.cancelled;
        break;
      case 'no_show':
        status = ReservationStatus.noShow;
        break;
      default:
        status = ReservationStatus.pending;
    }

    return Reservation(
      id: data['id']?.toString() ?? '',
      userId:
          data['userId']?.toString() ?? data['user']?['id']?.toString() ?? '',
      bookId: data['bookId']?.toString() ?? data['book']?['id']?.toString(),
      bookTitle: data['bookTitle'] ?? data['book']?['title'],
      bookCover: data['bookCoverUrl'] ?? data['book']?['coverUrl'],
      bookCoverAsset: data['bookCoverAsset'] ?? data['book']?['coverAsset'],
      date: data['reservationDate'] != null
          ? DateTime.parse(data['reservationDate'])
          : DateTime.now(),
      timeSlot: data['timeSlot'] != null
          ? TimeSlot.fromJson(data['timeSlot'])
          : TimeSlot(
              id: 'default',
              label: '默认时段',
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 2)),
              maxCapacity: 10,
              currentReservations: 0,
            ),
      status: status,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      checkedInAt: data['checkedInAt'] != null
          ? DateTime.parse(data['checkedInAt'])
          : null,
      isViolated: data['isViolated'] ?? false,
      violationReason: data['violationReason'],
    );
  }

  static Notification _parseNotification(Map<String, dynamic> data) {
    String typeStr = data['type'] ?? 'system';
    NotificationType type;
    switch (typeStr) {
      case 'borrow':
        type = NotificationType.borrow;
        break;
      case 'reservation':
        type = NotificationType.reservation;
        break;
      case 'fine':
        type = NotificationType.fine;
        break;
      default:
        type = NotificationType.system;
    }

    return Notification(
      id: data['id']?.toString() ?? '',
      userId:
          data['userId']?.toString() ?? data['user']?['id']?.toString() ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: type,
      isRead: data['isRead'] ?? false,
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static SharedBook _parseSharedBook(Map<String, dynamic> data) {
    String conditionStr = data['condition'] ?? 'like_new';
    BookCondition condition;
    switch (conditionStr) {
      case 'brand_new':
        condition = BookCondition.brandNew;
        break;
      case 'has_notes':
        condition = BookCondition.hasNotes;
        break;
      case 'has_damage':
        condition = BookCondition.hasDamage;
        break;
      default:
        condition = BookCondition.likeNew;
    }

    String shareTypeStr = data['shareType'] ?? 'temporary';
    ShareType shareType;
    switch (shareTypeStr) {
      case 'permanent':
        shareType = ShareType.permanent;
        break;
      default:
        shareType = ShareType.temporary;
    }

    String statusStr = data['status'] ?? 'pending';
    SharedBookStatus status;
    switch (statusStr) {
      case 'available':
        status = SharedBookStatus.available;
        break;
      case 'borrowed':
        status = SharedBookStatus.borrowed;
        break;
      case 'reserved':
        status = SharedBookStatus.reserved;
        break;
      case 'maintenance':
        status = SharedBookStatus.maintenance;
        break;
      default:
        status = SharedBookStatus.pending;
    }

    return SharedBook(
      id: data['id']?.toString() ?? '',
      isbn: data['isbn'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      publisher: data['publisher'] ?? '',
      coverUrl: data['coverUrl'],
      coverAsset: data['coverAsset'],
      sharerId: data['sharer']?['id']?.toString() ?? '',
      sharerName: data['sharerName'] ?? '',
      sharerGrade: data['sharerGrade'] ?? '',
      sharerDepartment: data['sharerDepartment'] ?? '',
      condition: condition,
      shareType: shareType,
      returnDate: data['returnDate'] != null
          ? DateTime.parse(data['returnDate'])
          : null,
      remark: data['remark'],
      shelfNumber: data['shelfNumber'] ?? '',
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      status: status,
      borrowerId: data['borrower']?['id']?.toString(),
      borrowedAt: data['borrowedAt'] != null
          ? DateTime.parse(data['borrowedAt'])
          : null,
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
    );
  }

  static Future<User?> login(String username, String password) async {
    try {
      final response = await _post(
        '/users/login',
        body: {'username': username, 'password': password},
      );
      if (response['success'] == true) {
        return _parseUser(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> register({
    required String username,
    required String password,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _post(
        '/users/register',
        body: {
          'username': username,
          'password': password,
          'email': email,
          'phone': phone,
        },
      );
      if (response['success'] == true) {
        return _parseUser(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> getUserById(String userId) async {
    try {
      final response = await _get('/users/$userId');
      if (response['success'] == true) {
        return _parseUser(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _put('/users/$userId', body: updates);
      return _parseUser(response);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Book>> getAllBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> getTopBooks({int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books/top?limit=$limit'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> getBooksByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books/category/$category'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> searchBooks({String? title, String? author}) async {
    try {
      String path = '$baseUrl/books/search?';
      if (title != null) path += 'title=$title&';
      if (author != null) path += 'author=$author';
      final response = await http.get(Uri.parse(path));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> getAvailableBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/available'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> borrowBook(
    String userId,
    String bookId,
  ) async {
    try {
      final response = await _post('/borrow/$bookId?userId=$userId');
      return response;
    } catch (e) {
      return {'success': false, 'message': '借阅失败: $e'};
    }
  }

  static Future<Map<String, dynamic>> returnBook(String borrowRecordId) async {
    try {
      final response = await _post('/borrow/return/$borrowRecordId');
      return response;
    } catch (e) {
      return {'success': false, 'message': '归还失败: $e'};
    }
  }

  static Future<Map<String, dynamic>> renewBook(String borrowRecordId) async {
    try {
      final response = await _post('/borrow/renew/$borrowRecordId');
      return response;
    } catch (e) {
      return {'success': false, 'message': '续借失败: $e'};
    }
  }

  static Future<List<BorrowRecord>> getUserBorrowRecords(String userId) async {
    try {
      print('API请求: 获取用户 $userId 的借阅记录');
      final response = await http.get(
        Uri.parse('$baseUrl/borrow/user/$userId'),
      );
      print('API响应状态: ${response.statusCode}');
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print('API返回借阅记录数量: ${data.length}');
        return data.map((json) => _parseBorrowRecord(json)).toList();
      }
      return [];
    } catch (e) {
      print('API请求失败: $e');
      return [];
    }
  }

  static Future<List<BorrowRecord>> getUserActiveBorrows(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrow/user/$userId/active'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBorrowRecord(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<BorrowRecord>> getUserOverdueBooks(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrow/user/$userId/overdue'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBorrowRecord(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserBorrowStats(String userId) async {
    try {
      return await _get('/borrow/user/$userId/stats');
    } catch (e) {
      return {'totalBorrows': 0, 'activeBorrows': 0, 'overdueCount': 0};
    }
  }

  static Future<Map<String, dynamic>> reserveBook(
    String userId,
    String bookId,
  ) async {
    try {
      final response = await _post(
        '/reservations?userId=$userId&bookId=$bookId',
      );
      return response;
    } catch (e) {
      return {'success': false, 'message': '预约失败: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkInReservation(
    String reservationId,
  ) async {
    try {
      final response = await _post('/reservations/$reservationId/checkin');
      return response;
    } catch (e) {
      return {'success': false, 'message': '签到失败: $e'};
    }
  }

  static Future<Map<String, dynamic>> cancelReservation(
    String reservationId,
  ) async {
    try {
      final response = await _post('/reservations/$reservationId/cancel');
      return response;
    } catch (e) {
      return {'success': false, 'message': '取消失败: $e'};
    }
  }

  static Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/user/$userId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseReservation(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Reservation>> getUserPendingReservations(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/user/$userId/pending'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseReservation(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> publishSharedBook(
    String userId,
    Map<String, String> bookData,
  ) async {
    try {
      final response = await _post(
        '/shared-books?userId=$userId',
        body: bookData.cast<String, dynamic>(),
      );
      return response;
    } catch (e) {
      return {'success': false, 'message': '发布失败: $e'};
    }
  }

  static Future<List<SharedBook>> getAllSharedBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/shared-books'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseSharedBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<SharedBook>> getAvailableSharedBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shared-books/available'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseSharedBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<SharedBook>> getUserSharedBooks(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shared-books/user/$userId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseSharedBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> borrowSharedBook(
    String sharedBookId,
    String borrowerId,
  ) async {
    try {
      final response = await _post(
        '/shared-books/$sharedBookId/borrow?borrowerId=$borrowerId',
      );
      return response;
    } catch (e) {
      return {'success': false, 'message': '借阅失败: $e'};
    }
  }

  static Future<Map<String, dynamic>> returnSharedBook(
    String sharedBookId,
  ) async {
    try {
      final response = await _post('/shared-books/$sharedBookId/return');
      return response;
    } catch (e) {
      return {'success': false, 'message': '归还失败: $e'};
    }
  }

  static Future<List<Notification>> getUserNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/user/$userId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseNotification(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Notification>> getUnreadNotifications(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/user/$userId/unread'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseNotification(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await _get('/notifications/user/$userId/unread-count');
      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      return await _post('/notifications/$notificationId/read');
    } catch (e) {
      return {'success': false, 'message': '标记失败: $e'};
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead(
    String userId,
  ) async {
    try {
      return await _post('/notifications/user/$userId/read-all');
    } catch (e) {
      return {'success': false, 'message': '标记失败: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteNotification(
    String notificationId,
  ) async {
    try {
      return await _delete('/notifications/$notificationId');
    } catch (e) {
      return {'success': false, 'message': '删除失败: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCategories() async {
    try {
      return await _get('/books/categories');
    } catch (e) {
      return {'categories': [], 'majorCategories': []};
    }
  }

  static Future<List<Book>> getBooksByMajorCategory(
    String majorCategory,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books/major-category/$majorCategory'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> getBooksWithCovers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/with-covers'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> getRecommendedBooks(List<String> interests) async {
    try {
      String interestsParam = interests.join(',');
      final response = await http.get(
        Uri.parse('$baseUrl/books/recommended?interests=$interestsParam'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> getNovelsWithCovers({int batchIndex = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books/novels-with-covers?batchIndex=$batchIndex'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _parseUser(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<TimeSlot>> getTimeSlotsForDate(DateTime date) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _get('/reservations/timeslots?date=$dateStr');
      if (response['success'] == true) {
        List<dynamic> data = response['data'];
        return data.map((json) => TimeSlot.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Reservation?> createReservation({
    required String userId,
    required DateTime date,
    required TimeSlot timeSlot,
  }) async {
    try {
      final response = await _post(
        '/reservations',
        body: {
          'userId': userId,
          'date': date.toIso8601String(),
          'timeSlot': timeSlot.toJson(),
        },
      );
      if (response['success'] == true) {
        return Reservation.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> payFine(String userId) async {
    try {
      return await _post('/users/$userId/pay-fine');
    } catch (e) {
      return {'success': false, 'message': '缴纳失败'};
    }
  }

  static Future<List<Book>> getUserFavorites(String userId) async {
    try {
      final response = await _get('/users/$userId/favorites');
      if (response['success'] == true) {
        List<dynamic> data = response['data'];
        return data.map((json) => _parseBook(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> toggleFavorite(
    String userId,
    String bookId,
  ) async {
    try {
      return await _post('/users/favorites?userId=$userId&bookId=$bookId');
    } catch (e) {
      return {'success': false, 'message': '操作失败'};
    }
  }

  static Future<ReadingReport?> generateReadingReport(String userId) async {
    try {
      print('API调用: /users/$userId/reading-report');
      print('API基础URL: $baseUrl');
      final response = await _get('/users/$userId/reading-report');
      print('API响应: $response');
      if (response['success'] == true) {
        print('API成功，数据: ${response['data']}');
        return ReadingReport.fromJson(response['data']);
      }
      print('API返回success为false');
      return null;
    } catch (e) {
      print('API调用异常: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> checkIn(String reservationId) async {
    try {
      return await _post('/reservations/$reservationId/check-in');
    } catch (e) {
      return {'success': false, 'message': '签到失败'};
    }
  }

  static Future<List<Map<String, dynamic>>> getVisitTimeSlotsForDate(
    DateTime date,
  ) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _get(
        '/visit-appointments/timeslots?date=$dateStr',
      );
      if (response['success'] == true) {
        List<dynamic> data = response['data'];
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createVisitAppointment({
    required String userId,
    required String timeSlotId,
    required DateTime date,
  }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return await _post(
        '/visit-appointments?userId=$userId&timeSlotId=$timeSlotId&date=$dateStr',
      );
    } catch (e) {
      return {'success': false, 'message': '预约失败'};
    }
  }

  static Future<Map<String, dynamic>> checkInVisitAppointment(
    String appointmentId,
  ) async {
    try {
      return await _post('/visit-appointments/$appointmentId/check-in');
    } catch (e) {
      return {'success': false, 'message': '签到失败'};
    }
  }

  static Future<Map<String, dynamic>> cancelVisitAppointment(
    String appointmentId,
  ) async {
    try {
      return await _post('/visit-appointments/$appointmentId/cancel');
    } catch (e) {
      return {'success': false, 'message': '取消失败'};
    }
  }

  static Future<List<Map<String, dynamic>>> getUserVisitAppointments(
    String userId,
  ) async {
    try {
      final response = await _get('/visit-appointments/user/$userId');
      final data = response['data'];
      if (data is List) {
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getUserPendingVisitAppointments(
    String userId,
  ) async {
    try {
      final response = await _get('/visit-appointments/user/$userId/pending');
      final data = response['data'];
      if (data is List) {
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<SystemException>> getAllExceptions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/exceptions'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => SystemException.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getExceptionStatistics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/exceptions/statistics'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<bool> updateExceptionStatus(
    String id,
    String status,
    String solution,
    String handledBy,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/exceptions/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
          'solution': solution,
          'handledBy': handledBy,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> createException(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/exceptions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
