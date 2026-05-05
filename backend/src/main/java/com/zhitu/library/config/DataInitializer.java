package com.zhitu.library.config;

import com.zhitu.library.entity.*;
import com.zhitu.library.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Component
public class DataInitializer implements CommandLineRunner {

    private final TimeSlotRepository timeSlotRepository;
    private final UserRepository userRepository;
    private final SystemExceptionRepository exceptionRepository;
    private final SharedBookRepository sharedBookRepository;

    public DataInitializer(TimeSlotRepository timeSlotRepository,
                           UserRepository userRepository,
                           SystemExceptionRepository exceptionRepository,
                           SharedBookRepository sharedBookRepository) {
        this.timeSlotRepository = timeSlotRepository;
        this.userRepository = userRepository;
        this.exceptionRepository = exceptionRepository;
        this.sharedBookRepository = sharedBookRepository;
    }

    @Override
    public void run(String... args) {
        initTimeSlots();
        initUsers();
        initExceptions();
        initSharedBooks();
    }

    private void initTimeSlots() {
        if (timeSlotRepository.count() == 0) {
            createTimeSlot("上午 08:00-10:00", "08:00", "10:00");
            createTimeSlot("上午 10:00-12:00", "10:00", "12:00");
            createTimeSlot("下午 14:00-16:00", "14:00", "16:00");
            createTimeSlot("下午 16:00-18:00", "16:00", "18:00");
            createTimeSlot("晚上 19:00-21:00", "19:00", "21:00");
            System.out.println("时间段数据初始化完成");
        }
    }

    private void createTimeSlot(String label, String start, String end) {
        TimeSlot slot = new TimeSlot();
        slot.setLabel(label);
        slot.setStartTime(LocalTime.parse(start));
        slot.setEndTime(LocalTime.parse(end));
        slot.setMaxCapacity(20);
        slot.setCurrentReservations(0);
        slot.setIsAvailable(true);
        timeSlotRepository.save(slot);
    }

    private void initUsers() {
        createUser("admin", "admin123", "A001", "admin@library.com", "13800000001", "admin", "系统管理,数据分析");
        createUser("张三", "user123", "2024001", "zhangsan@stu.edu.cn", "13800000002", "user", "计算机科学,人工智能");
        createUser("李四", "user123", "2024002", "lisi@stu.edu.cn", "13800000003", "user", "文学,历史");
        createUser("王五", "user123", "2024003", "wangwu@stu.edu.cn", "13800000004", "user", "数学,物理");
        createUser("赵六", "user123", "2024004", "zhaoliu@stu.edu.cn", "13800000005", "user", "经济学,金融");
        createUser("孙七", "user123", "2024005", "sunqi@stu.edu.cn", "13800000006", "user", "生物学,化学");
        createUser("周八", "user123", "2024006", "zhouba@stu.edu.cn", "13800000007", "user", "哲学,社会学");
        createUser("吴九", "user123", "2024007", "wujiu@stu.edu.cn", "13800000008", "user", "艺术,音乐");
        createUser("郑十", "user123", "2024008", "zhengshi@stu.edu.cn", "13800000009", "user", "法学,政治学");
        createUser("陈明", "user123", "2024009", "chenming@stu.edu.cn", "13800000010", "user", "计算机科学,软件工程");
        System.out.println("用户数据初始化完成");
    }

    private void createUser(String username, String password, String studentId,
                            String email, String phone, String role, String interests) {
        if (userRepository.findByUsername(username).isEmpty()) {
            User user = new User();
            user.setUsername(username);
            user.setPassword(password);
            user.setStudentId(studentId);
            user.setEmail(email);
            user.setPhone(phone);
            user.setRole(role);
            user.setInterests(interests);
            userRepository.save(user);
        }
    }

    private void initExceptions() {
        if (exceptionRepository.count() == 0) {
            createException("overdue", "图书借阅逾期", "用户 张三 借阅的《深入理解计算机系统》已逾期 15 天",
                    null, "medium", "borrow", 2L, 1L, 1L);
            createException("overdue", "图书借阅逾期", "用户 李四 借阅的《算法导论》已逾期 7 天",
                    null, "low", "borrow", 3L, 2L, 2L);
            createException("no_show", "预约未到", "用户 王五 预约的《数据结构与算法》(2026-05-01 14:00) 未按时到馆",
                    null, "medium", "reservation", 4L, 3L, null);
            createException("system_error", "数据库连接超时", "借阅模块数据库连接超时，影响用户借阅操作",
                    "java.sql.SQLException: Connection timed out\n\tat com.mysql.cj.jdbc.ConnectionImpl.createNewIO(ConnectionImpl.java:836)\n\tat com.mysql.cj.jdbc.ConnectionImpl.<init>(ConnectionImpl.java:456)",
                    "high", "database", null, null, null);
            createException("api_error", "第三方接口调用失败", "图书ISBN查询接口调用失败，无法获取图书信息",
                    "java.net.ConnectException: Connection refused\n\tat java.net.PlainSocketImpl.socketConnect(Native Method)\n\tat java.net.AbstractPlainSocketImpl.doConnect(AbstractPlainSocketImpl.java:350)",
                    "medium", "api", null, null, null);
            createException("overdue", "图书借阅逾期", "用户 赵六 借阅的《设计模式》已逾期 32 天",
                    null, "high", "borrow", 5L, 4L, 3L);
            createException("system_error", "文件上传失败", "图书封面图片上传失败，服务器磁盘空间不足",
                    "java.io.IOException: No space left on device\n\tat java.io.FileOutputStream.writeBytes(Native Method)\n\tat java.io.FileOutputStream.write(FileOutputStream.java:326)",
                    "high", "upload", null, null, null);
            createException("no_show", "预约未到", "用户 孙七 预约的《机器学习实战》(2026-04-30 10:00) 未按时到馆",
                    null, "low", "reservation", 6L, 5L, null);
            System.out.println("异常数据初始化完成");
        }
    }

    private void createException(String type, String title, String description,
                                 String stackTrace, String severity, String module,
                                 Long userId, Long bookId, Long recordId) {
        SystemException exception = new SystemException();
        exception.setType(type);
        exception.setTitle(title);
        exception.setDescription(description);
        exception.setStackTrace(stackTrace);
        exception.setSeverity(severity);
        exception.setModule(module);
        exception.setRelatedUserId(userId);
        exception.setRelatedBookId(bookId);
        exception.setRelatedRecordId(recordId);
        exception.setStatus("pending");
        exception.setOccurredAt(LocalDateTime.now().minusHours((long) (Math.random() * 72)));
        exception.setCreatedAt(LocalDateTime.now());
        exception.setUpdatedAt(LocalDateTime.now());
        exceptionRepository.save(exception);
    }

    private void initSharedBooks() {
        if (sharedBookRepository.count() == 0) {
            java.util.List<User> users = userRepository.findAll();
            if (users.isEmpty()) return;

            createSharedBook(users.get(1), "9787111544937", "深入理解计算机系统", "Randal E. Bryant", "机械工业出版社",
                    "assets/img/1.jpg", "九成新", "permanent", "A-1-01", "经典教材，笔记完整", "pending");
            createSharedBook(users.get(2), "9787115428028", "算法导论", "Thomas H. Cormen", "机械工业出版社",
                    "assets/img/2.jpg", "八成新", "permanent", "A-1-02", "有少量划线", "pending");
            createSharedBook(users.get(3), "9787111407010", "设计模式", "Erich Gamma", "机械工业出版社",
                    "assets/img/3.jpg", "全新", "temporary", "A-1-03", "未拆封", "pending");
            createSharedBook(users.get(4), "9787302473961", "机器学习", "周志华", "清华大学出版社",
                    "assets/img/4.jpg", "九成新", "permanent", "B-2-01", "附带光盘", "pending");
            createSharedBook(users.get(5), "9787111558422", "Python编程", "Eric Matthes", "人民邮电出版社",
                    "assets/img/5.jpg", "八成新", "temporary", "B-2-02", "有笔记", "pending");
            createSharedBook(users.get(6), "9787115275790", "代码大全", "Steve McConnell", "电子工业出版社",
                    "assets/img/6.jpg", "九成新", "permanent", "C-3-01", "经典书籍", "pending");
            createSharedBook(users.get(7), "9787111467890", "数据库系统概念", "Abraham Silberschatz", "机械工业出版社",
                    "assets/img/7.jpg", "八成新", "permanent", "C-3-02", "有书签", "pending");
            createSharedBook(users.get(8), "9787111544938", "计算机网络", "James F. Kurose", "机械工业出版社",
                    "assets/img/8.jpg", "九成新", "temporary", "D-4-01", "笔记详细", "pending");
            createSharedBook(users.get(9), "9787111544939", "操作系统概念", "Abraham Silberschatz", "机械工业出版社",
                    "assets/img/9.jpg", "全新", "permanent", "D-4-02", "未使用", "pending");
            createSharedBook(users.get(1), "9787111544940", "编译原理", "Alfred V. Aho", "机械工业出版社",
                    "assets/img/10.jpg", "八成新", "permanent", "E-5-01", "有少量笔记", "approved");
            System.out.println("共享图书数据初始化完成");
        }
    }

    private void createSharedBook(User sharer, String isbn, String title, String author, String publisher,
                                  String coverAsset, String conditionLevel, String shareType, String shelfNumber,
                                  String remark, String status) {
        SharedBook book = new SharedBook();
        book.setIsbn(isbn);
        book.setTitle(title);
        book.setAuthor(author);
        book.setPublisher(publisher);
        book.setCoverAsset(coverAsset);
        book.setSharer(sharer);
        book.setSharerName(sharer.getUsername());
        book.setSharerDepartment("计算机学院");
        book.setConditionLevel(conditionLevel);
        book.setShareType(shareType);
        book.setShelfNumber(shelfNumber);
        book.setRemark(remark);
        book.setStatus(status);
        book.setCreatedAt(LocalDateTime.now().minusDays((long) (Math.random() * 30)));
        sharedBookRepository.save(book);
    }
}
