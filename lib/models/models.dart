enum ReadingPosture { intensive, extensive, reference }

enum EmotionType { tragedy, comedy, mixed }

enum WritingStyle { coldObjective, humorous, ornate, minimalist }

class ReadingDifficulty {
  final int starRating;
  final String aiInterpretation;
  final double difficultyValue;

  ReadingDifficulty({
    required this.starRating,
    required this.aiInterpretation,
    required this.difficultyValue,
  });
}

class ReadingPostureInfo {
  final ReadingPosture posture;
  final String description;
  final String icon;

  ReadingPostureInfo({
    required this.posture,
    required this.description,
    required this.icon,
  });

  String get label {
    switch (posture) {
      case ReadingPosture.intensive:
        return '精读';
      case ReadingPosture.extensive:
        return '泛读';
      case ReadingPosture.reference:
        return '查阅';
    }
  }
}

class TimeCost {
  final int totalMinutes;
  final String aiSuggestion;
  final int suggestedSessions;

  TimeCost({
    required this.totalMinutes,
    required this.aiSuggestion,
    required this.suggestedSessions,
  });

  String get formattedTime {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours小时$minutes分钟';
    } else if (hours > 0) {
      return '$hours小时';
    } else {
      return '$minutes分钟';
    }
  }
}

class EmotionWave {
  final double chapterProgress;
  final double emotionValue;

  EmotionWave({required this.chapterProgress, required this.emotionValue});
}

class SensoryIndicators {
  final EmotionType emotionType;
  final String emotionInterpretation;
  final List<EmotionWave> emotionWaves;
  final List<WritingStyle> writingStyles;
  final String styleAnalogy;

  SensoryIndicators({
    required this.emotionType,
    required this.emotionInterpretation,
    required this.emotionWaves,
    required this.writingStyles,
    required this.styleAnalogy,
  });

  String get emotionLabel {
    switch (emotionType) {
      case EmotionType.tragedy:
        return '悲剧';
      case EmotionType.comedy:
        return '喜剧';
      case EmotionType.mixed:
        return '悲喜交加';
    }
  }
}

class KnowledgeContent {
  final String name;
  final double percentage;
  final String description;

  KnowledgeContent({
    required this.name,
    required this.percentage,
    required this.description,
  });
}

class Skill {
  final String name;
  final String icon;
  final String description;
  final bool isHardSkill;

  Skill({
    required this.name,
    required this.icon,
    required this.description,
    required this.isHardSkill,
  });
}

class NutritionIndicators {
  final List<KnowledgeContent> knowledgeContents;
  final String aiComment;
  final List<Skill> hardSkills;
  final List<Skill> softSkills;

  NutritionIndicators({
    required this.knowledgeContents,
    required this.aiComment,
    required this.hardSkills,
    required this.softSkills,
  });
}

class AudienceMatch {
  final String audience;
  final double matchPercentage;
  final String reason;

  AudienceMatch({
    required this.audience,
    required this.matchPercentage,
    required this.reason,
  });
}

class WarningInfo {
  final String type;
  final String content;
  final String icon;

  WarningInfo({required this.type, required this.content, required this.icon});
}

class SocialAndWarningIndicators {
  final List<AudienceMatch> audienceMatches;
  final List<WarningInfo> warnings;

  SocialAndWarningIndicators({
    required this.audienceMatches,
    required this.warnings,
  });
}

class BookHealthReport {
  final String bookId;
  final ReadingDifficulty readingDifficulty;
  final List<ReadingPostureInfo> readingPostures;
  final TimeCost timeCost;
  final SensoryIndicators sensoryIndicators;
  final NutritionIndicators nutritionIndicators;
  final SocialAndWarningIndicators socialAndWarningIndicators;
  final String summaryQuote;

  BookHealthReport({
    required this.bookId,
    required this.readingDifficulty,
    required this.readingPostures,
    required this.timeCost,
    required this.sensoryIndicators,
    required this.nutritionIndicators,
    required this.socialAndWarningIndicators,
    required this.summaryQuote,
  });
}

enum UserRole { user, admin }

enum BookStatus { available, borrowed, maintenance }

enum BorrowStatus { active, returned, overdue }

enum ReservationStatus { pending, checkedIn, cancelled, noShow }

enum TimeSlotStatus { available, full, unavailable }

enum NotificationType { system, borrow, reservation, fine }

class Notification {
  final String id;
  final String userId;
  final String title;
  final String content;
  final NotificationType type;
  final DateTime createdAt;
  bool isRead;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  String get typeLabel {
    switch (type) {
      case NotificationType.system:
        return '系统通知';
      case NotificationType.borrow:
        return '借阅提醒';
      case NotificationType.reservation:
        return '预约通知';
      case NotificationType.fine:
        return '罚款通知';
    }
  }
}

class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatar;
  final List<String> interests;
  final bool isFirstLogin;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    this.password = '',
    required this.email,
    required this.phone,
    this.role = UserRole.user,
    this.avatar,
    this.interests = const [],
    this.isFirstLogin = true,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String roleStr = json['role'] ?? 'user';
    UserRole role = roleStr == 'admin' ? UserRole.admin : UserRole.user;

    dynamic interestsData = json['interests'];
    List<String> interests = [];
    if (interestsData is String && interestsData.isNotEmpty) {
      interests = interestsData.split(',');
    } else if (interestsData is List) {
      interests = interestsData.map((e) => e.toString()).toList();
    }

    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: role,
      avatar: json['avatar'],
      interests: interests,
      isFirstLogin: json['firstLogin'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? phone,
    UserRole? role,
    String? avatar,
    List<String>? interests,
    bool? isFirstLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      interests: interests ?? this.interests,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final String isbn;
  final String majorCategory;
  final String category;
  final String description;
  BookStatus status;
  final int totalCopies;
  int availableCopies;
  final String? coverUrl;
  final String? coverAsset;
  final int borrowCount;
  List<String> favoriteUserIds;
  List<String> reservationUserIds;
  final String? sharedBy;
  final String? sharedByName;
  final DateTime? createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn,
    this.majorCategory = '',
    this.category = '',
    this.description = '',
    this.status = BookStatus.available,
    this.totalCopies = 1,
    this.availableCopies = 1,
    this.coverUrl,
    this.coverAsset,
    this.borrowCount = 0,
    List<String>? favoriteUserIds,
    List<String>? reservationUserIds,
    this.sharedBy,
    this.sharedByName,
    this.createdAt,
  }) : favoriteUserIds = favoriteUserIds ?? [],
       reservationUserIds = reservationUserIds ?? [];

  factory Book.fromJson(Map<String, dynamic> json) {
    int statusInt = json['status'] ?? 0;
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

    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      isbn: json['isbn'] ?? '',
      majorCategory: json['majorCategory'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      status: status,
      totalCopies: json['totalCopies'] ?? 1,
      availableCopies: json['availableCopies'] ?? 0,
      coverUrl: json['coverUrl'],
      coverAsset: json['coverAsset'],
      borrowCount: json['borrowCount'] ?? 0,
      favoriteUserIds:
          (json['favoriteUserIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reservationUserIds:
          (json['reservationUserIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sharedBy: json['sharedBy'],
      sharedByName: json['sharedByName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  bool isFavoriteBy(String userId) => favoriteUserIds.contains(userId);
  bool isReservedBy(String userId) => reservationUserIds.contains(userId);
}

class BorrowRecord {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookCover;
  final String? bookCoverAsset;
  final String userId;
  final DateTime borrowDate;
  DateTime dueDate;
  DateTime? returnDate;
  BorrowStatus status;
  double? fine;
  bool finePaid;
  int renewCount;

  BorrowRecord({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookCover,
    this.bookCoverAsset,
    required this.userId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.status = BorrowStatus.active,
    this.fine,
    this.finePaid = false,
    this.renewCount = 0,
  });

  factory BorrowRecord.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'] ?? 'active';
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
      id: json['id']?.toString() ?? '',
      bookId: json['book']?['id']?.toString() ?? '',
      bookTitle: json['book']?['title'] ?? '',
      bookCover: json['book']?['coverUrl'] ?? '',
      bookCoverAsset: json['book']?['coverAsset'],
      userId: json['user']?['id']?.toString() ?? '',
      borrowDate: json['borrowDate'] != null
          ? DateTime.parse(json['borrowDate'])
          : DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now().add(const Duration(days: 30)),
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'])
          : null,
      status: status,
      fine: (json['fine'] as num?)?.toDouble(),
      finePaid: json['finePaid'] ?? false,
      renewCount: json['renewCount'] ?? 0,
    );
  }

  bool get isOverdue {
    if (status == BorrowStatus.returned) return false;
    return DateTime.now().isAfter(dueDate);
  }

  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  double get unpaidFine {
    if (fine == null || finePaid) return 0;
    return fine!;
  }
}

class TimeSlot {
  final String id;
  final String label;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCapacity;
  final int currentReservations;
  final TimeSlotStatus status;
  final String? unavailableReason;

  TimeSlot({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    required this.currentReservations,
    this.status = TimeSlotStatus.available,
    this.unavailableReason,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'] ?? 'available';
    TimeSlotStatus status;
    switch (statusStr) {
      case 'full':
        status = TimeSlotStatus.full;
        break;
      case 'unavailable':
        status = TimeSlotStatus.unavailable;
        break;
      default:
        status = TimeSlotStatus.available;
    }
    return TimeSlot(
      id: json['id']?.toString() ?? '',
      label: json['label'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now().add(const Duration(hours: 2)),
      maxCapacity: json['maxCapacity'] ?? 10,
      currentReservations: json['currentReservations'] ?? 0,
      status: status,
      unavailableReason: json['unavailableReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'maxCapacity': maxCapacity,
      'currentReservations': currentReservations,
      'status': status.name,
      'unavailableReason': unavailableReason,
    };
  }

  bool get isAvailable => status == TimeSlotStatus.available;
  bool get isFull => status == TimeSlotStatus.full;
  bool get isUnavailable => status == TimeSlotStatus.unavailable;
  int get remainingSlots => maxCapacity - currentReservations;
}

class Reservation {
  final String id;
  final String userId;
  final String? bookId;
  final String? bookTitle;
  final String? bookCover;
  final String? bookCoverAsset;
  final DateTime date;
  final TimeSlot timeSlot;
  final ReservationStatus status;
  final DateTime createdAt;
  DateTime? checkedInAt;
  final String? qrCode;
  final bool isViolated;
  final String? violationReason;

  Reservation({
    required this.id,
    required this.userId,
    String? bookId,
    String? bookTitle,
    String? bookCover,
    String? bookCoverAsset,
    required this.date,
    required this.timeSlot,
    this.status = ReservationStatus.pending,
    required this.createdAt,
    this.checkedInAt,
    this.qrCode,
    this.isViolated = false,
    this.violationReason,
  }) : this.bookId = bookId,
       this.bookTitle = bookTitle,
       this.bookCover = bookCover,
       this.bookCoverAsset = bookCoverAsset;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'] ?? 'pending';
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
      id: json['id']?.toString() ?? '',
      userId:
          json['userId']?.toString() ?? json['user']?['id']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? json['book']?['id']?.toString(),
      bookTitle: json['bookTitle'] ?? json['book']?['title'],
      bookCover: json['bookCoverUrl'] ?? json['book']?['coverUrl'],
      bookCoverAsset: json['bookCoverAsset'] ?? json['book']?['coverAsset'],
      date: json['reservationDate'] != null
          ? DateTime.parse(json['reservationDate'])
          : DateTime.now(),
      timeSlot: json['timeSlot'] != null
          ? TimeSlot.fromJson(json['timeSlot'])
          : TimeSlot(
              id: 'default',
              label: '默认时段',
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 2)),
              maxCapacity: 10,
              currentReservations: 0,
            ),
      status: status,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'])
          : null,
      isViolated: json['isViolated'] == true,
      violationReason: json['violationReason'],
    );
  }

  bool get isPending => status == ReservationStatus.pending;
  bool get isCheckedIn => status == ReservationStatus.checkedIn;
  bool get isCancelled => status == ReservationStatus.cancelled;
  bool get isNoShow => status == ReservationStatus.noShow;

  bool get canCheckIn {
    if (status != ReservationStatus.pending) return false;
    final now = DateTime.now();
    final slotStart = timeSlot.startTime;
    final checkInWindow = slotStart.add(const Duration(minutes: 30));
    return now.isBefore(checkInWindow) &&
        now.isAfter(slotStart.subtract(const Duration(hours: 1)));
  }

  bool get isOverdue {
    if (status != ReservationStatus.pending) return false;
    final now = DateTime.now();
    final slotEnd = timeSlot.endTime;
    return now.isAfter(slotEnd);
  }
}

class ReadingReport {
  final String userId;
  final int totalBooks;
  final int totalPages;
  final int readingDays;
  final Map<String, int> categoryStats;
  final Map<String, int> authorStats;
  final Map<String, int> publisherStats;
  final Map<int, int> monthlyStats;
  final List<String> achievements;

  ReadingReport({
    required this.userId,
    required this.totalBooks,
    required this.totalPages,
    required this.readingDays,
    required this.categoryStats,
    required this.authorStats,
    required this.publisherStats,
    required this.monthlyStats,
    required this.achievements,
  });

  factory ReadingReport.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseMap(Map? data) {
      if (data == null) return {};
      return data.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }

    Map<int, int> parseIntKeyMap(Map? data) {
      if (data == null) return {};
      return data.map(
        (k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt()),
      );
    }

    return ReadingReport(
      userId: json['userId']?.toString() ?? '',
      totalBooks: json['totalBooks'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      readingDays: json['readingDays'] ?? 0,
      categoryStats: parseMap(json['categoryStats']),
      authorStats: parseMap(json['authorStats']),
      publisherStats: parseMap(json['publisherStats']),
      monthlyStats: parseIntKeyMap(json['monthlyStats']),
      achievements:
          (json['achievements'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }
}

class OverdueRecord {
  final String id;
  final String bookId;
  final String bookName;
  final String borrowerId;
  final String borrowerName;
  final int overdueDays;
  final DateTime dueDate;
  final String? bookCover;
  bool reminded;

  OverdueRecord({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.borrowerId,
    required this.borrowerName,
    required this.overdueDays,
    required this.dueDate,
    this.bookCover,
    this.reminded = false,
  });
}

class NoShowRecord {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final String bookName;
  final DateTime appointmentTime;
  final String? userAvatar;
  bool reminded;

  NoShowRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    required this.bookName,
    required this.appointmentTime,
    this.userAvatar,
    this.reminded = false,
  });
}

class ExceptionCount {
  final int overdueCount;
  final int noShowCount;

  ExceptionCount({required this.overdueCount, required this.noShowCount});
}

enum MessageType {
  system,
  borrow_reminder,
  reservation_reminder,
  overdue_reminder,
}

class Message {
  final String id;
  final String userId;
  final String title;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  bool isRead;

  Message({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  String get typeLabel {
    switch (type) {
      case MessageType.system:
        return '系统通知';
      case MessageType.borrow_reminder:
        return '借阅提醒';
      case MessageType.reservation_reminder:
        return '预约提醒';
      case MessageType.overdue_reminder:
        return '逾期提醒';
    }
  }
}

enum BookCondition { brandNew, likeNew, hasNotes, hasDamage }

enum ShareType { permanent, temporary }

enum SharedBookStatus { pending, available, borrowed, reserved, maintenance }

class SharedBook {
  final String id;
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String? coverUrl;
  final String? coverAsset;
  final String sharerId;
  final String sharerName;
  final String sharerGrade;
  final String sharerDepartment;
  final BookCondition condition;
  final ShareType shareType;
  final DateTime? returnDate;
  final String? remark;
  final String shelfNumber;
  final DateTime createdAt;
  SharedBookStatus status;
  String? borrowerId;
  DateTime? borrowedAt;
  DateTime? dueDate;

  SharedBook({
    required this.id,
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    this.coverUrl,
    this.coverAsset,
    required this.sharerId,
    required this.sharerName,
    required this.sharerGrade,
    required this.sharerDepartment,
    required this.condition,
    required this.shareType,
    this.returnDate,
    this.remark,
    required this.shelfNumber,
    required this.createdAt,
    this.status = SharedBookStatus.pending,
    this.borrowerId,
    this.borrowedAt,
    this.dueDate,
  });

  factory SharedBook.fromJson(Map<String, dynamic> json) {
    String conditionStr = json['conditionLevel'] ?? 'likeNew';
    BookCondition condition;
    switch (conditionStr) {
      case 'brandNew':
        condition = BookCondition.brandNew;
        break;
      case 'hasNotes':
        condition = BookCondition.hasNotes;
        break;
      case 'hasDamage':
        condition = BookCondition.hasDamage;
        break;
      default:
        condition = BookCondition.likeNew;
    }

    String shareTypeStr = json['shareType'] ?? 'temporary';
    ShareType shareType = shareTypeStr == 'permanent'
        ? ShareType.permanent
        : ShareType.temporary;

    String statusStr = json['status'] ?? 'pending';
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
      id: json['id']?.toString() ?? '',
      isbn: json['isbn'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      coverUrl: json['coverUrl'],
      coverAsset: json['coverAsset'],
      sharerId: json['sharer']?['id']?.toString() ?? '',
      sharerName: json['sharerName'] ?? '',
      sharerGrade: json['sharerGrade'] ?? '',
      sharerDepartment: json['sharerDepartment'] ?? '',
      condition: condition,
      shareType: shareType,
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'])
          : null,
      remark: json['remark'],
      shelfNumber: json['shelfNumber'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: status,
      borrowerId: json['borrower']?['id']?.toString(),
      borrowedAt: json['borrowedAt'] != null
          ? DateTime.parse(json['borrowedAt'])
          : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  String get conditionLabel {
    switch (condition) {
      case BookCondition.brandNew:
        return '全新（未拆封）';
      case BookCondition.likeNew:
        return '九成新（有轻微翻阅痕迹）';
      case BookCondition.hasNotes:
        return '有笔记（书内有划线或笔记）';
      case BookCondition.hasDamage:
        return '有破损（封面折角或书页破损）';
    }
  }

  String get shareTypeLabel {
    switch (shareType) {
      case ShareType.permanent:
        return '永久捐赠';
      case ShareType.temporary:
        return '临时寄存';
    }
  }

  String get sharerDisplayName {
    return '$sharerGrade$sharerDepartment$sharerName同学';
  }
}

class SystemException {
  final String id;
  final String type;
  final String title;
  final String? description;
  final String? stackTrace;
  final String status;
  final String? severity;
  final String? module;
  final int? relatedUserId;
  final int? relatedBookId;
  final int? relatedRecordId;
  final String? relatedData;
  final String? solution;
  final String? handledBy;
  final DateTime occurredAt;
  final DateTime? handledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SystemException({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.stackTrace,
    required this.status,
    this.severity,
    this.module,
    this.relatedUserId,
    this.relatedBookId,
    this.relatedRecordId,
    this.relatedData,
    this.solution,
    this.handledBy,
    required this.occurredAt,
    this.handledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SystemException.fromJson(Map<String, dynamic> json) {
    return SystemException(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      stackTrace: json['stackTrace'],
      status: json['status'] ?? 'pending',
      severity: json['severity'],
      module: json['module'],
      relatedUserId: json['relatedUserId'] != null ? int.tryParse(json['relatedUserId'].toString()) : null,
      relatedBookId: json['relatedBookId'] != null ? int.tryParse(json['relatedBookId'].toString()) : null,
      relatedRecordId: json['relatedRecordId'] != null ? int.tryParse(json['relatedRecordId'].toString()) : null,
      relatedData: json['relatedData'],
      solution: json['solution'],
      handledBy: json['handledBy'],
      occurredAt: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'])
          : DateTime.now(),
      handledAt: json['handledAt'] != null
          ? DateTime.parse(json['handledAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
