package com.zhitu.library.service;

import com.zhitu.library.entity.Book;
import com.zhitu.library.entity.BorrowRecord;
import com.zhitu.library.entity.User;
import com.zhitu.library.repository.BookRepository;
import com.zhitu.library.repository.BorrowRecordRepository;
import com.zhitu.library.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final BookRepository bookRepository;
    private final BorrowRecordRepository borrowRecordRepository;

    public UserService(UserRepository userRepository, BookRepository bookRepository, BorrowRecordRepository borrowRecordRepository) {
        this.userRepository = userRepository;
        this.bookRepository = bookRepository;
        this.borrowRecordRepository = borrowRecordRepository;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Map<String, Object> register(User user) {
        Map<String, Object> result = new HashMap<>();

        if (userRepository.existsByUsername(user.getUsername())) {
            result.put("success", false);
            result.put("message", "用户名已存在");
            return result;
        }

        User savedUser = userRepository.save(user);
        result.put("success", true);
        result.put("message", "注册成功");
        result.put("user", savedUser);
        return result;
    }

    public Map<String, Object> login(String username, String password) {
        Map<String, Object> result = new HashMap<>();

        Optional<User> optionalUser = userRepository.findByUsername(username);

        if (optionalUser.isEmpty()) {
            result.put("success", false);
            result.put("message", "用户不存在");
            return result;
        }

        User user = optionalUser.get();

        if (!user.getPassword().equals(password)) {
            result.put("success", false);
            result.put("message", "密码错误");
            return result;
        }

        result.put("success", true);
        result.put("message", "登录成功");
        result.put("user", user);
        return result;
    }

    public User updateUser(Long id, User userDetails) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        user.setUsername(userDetails.getUsername());
        user.setEmail(userDetails.getEmail());
        user.setPhone(userDetails.getPhone());
        user.setAvatar(userDetails.getAvatar());
        user.setInterests(userDetails.getInterests());

        return userRepository.save(user);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    public List<Book> getUserFavorites(Long userId) {
        List<Book> allBooks = bookRepository.findAll();
        String userIdStr = String.valueOf(userId);
        return allBooks.stream()
                .filter(book -> book.getFavoriteUserIds() != null &&
                        Arrays.asList(book.getFavoriteUserIds().split(",")).contains(userIdStr))
                .collect(Collectors.toList());
    }

    public Map<String, Object> toggleFavorite(Long userId, Long bookId) {
        Map<String, Object> result = new HashMap<>();

        Optional<Book> optionalBook = bookRepository.findById(bookId);
        if (optionalBook.isEmpty()) {
            result.put("success", false);
            result.put("message", "图书不存在");
            return result;
        }

        Book book = optionalBook.get();
        String userIdStr = String.valueOf(userId);
        List<String> favoriteIds = new ArrayList<>();

        if (book.getFavoriteUserIds() != null && !book.getFavoriteUserIds().isEmpty()) {
            favoriteIds = new ArrayList<>(Arrays.asList(book.getFavoriteUserIds().split(",")));
        }

        boolean isFavorited = favoriteIds.contains(userIdStr);
        if (isFavorited) {
            favoriteIds.remove(userIdStr);
        } else {
            favoriteIds.add(userIdStr);
        }

        book.setFavoriteUserIds(String.join(",", favoriteIds));
        bookRepository.save(book);

        result.put("success", true);
        result.put("isFavorited", !isFavorited);
        result.put("message", isFavorited ? "取消收藏成功" : "收藏成功");
        return result;
    }

    @org.springframework.transaction.annotation.Transactional(readOnly = true)
    public Map<String, Object> generateReadingReport(Long userId) {
        Map<String, Object> report = new HashMap<>();

        List<BorrowRecord> records = borrowRecordRepository.findByUserIdWithBook(userId);

        System.out.println("生成阅读报告 - 用户ID: " + userId + ", 借阅记录数: " + records.size());

        Set<Long> uniqueBookIds = new HashSet<>();
        int totalPages = 0;
        Set<String> readingDays = new HashSet<>();
        Map<String, Integer> categoryStats = new HashMap<>();
        Map<String, Integer> authorStats = new HashMap<>();
        Map<String, Integer> publisherStats = new HashMap<>();
        Map<Integer, Integer> monthlyStats = new HashMap<>();

        for (BorrowRecord r : records) {
            Book book = r.getBook();
            if (book == null) {
                System.out.println("警告: 借阅记录 " + r.getId() + " 的图书信息为空");
                continue;
            }

            System.out.println("处理借阅记录 - 图书: " + book.getTitle() + ", 分类: " + book.getCategory());

            uniqueBookIds.add(book.getId());
            totalPages += 350;
            readingDays.add(r.getBorrowDate().toLocalDate().toString());

            String category = book.getCategory() != null ? book.getCategory() : "其他";
            categoryStats.put(category, categoryStats.getOrDefault(category, 0) + 1);

            String author = book.getAuthor() != null ? book.getAuthor() : "未知作者";
            authorStats.put(author, authorStats.getOrDefault(author, 0) + 1);

            String publisher = book.getPublisher() != null ? book.getPublisher() : "未知出版社";
            publisherStats.put(publisher, publisherStats.getOrDefault(publisher, 0) + 1);

            int month = r.getBorrowDate().getMonthValue();
            monthlyStats.put(month, monthlyStats.getOrDefault(month, 0) + 1);
        }

        int totalBooks = uniqueBookIds.size();

        System.out.println("阅读报告统计 - 总本数: " + totalBooks + ", 总页数: " + totalPages + ", 阅读天数: " + readingDays.size());

        List<String> achievements = new ArrayList<>();
        if (totalBooks >= 1) achievements.add("初出茅庐");
        if (totalBooks >= 5) achievements.add("阅读新手");
        if (totalBooks >= 10) achievements.add("阅读达人");
        if (totalBooks >= 20) achievements.add("阅读大师");
        if (totalBooks >= 50) achievements.add("阅读传奇");
        if (!categoryStats.isEmpty()) achievements.add("涉猎广泛");
        if (!authorStats.isEmpty() && authorStats.values().stream().anyMatch(c -> c >= 3)) {
            achievements.add("忠实读者");
        }

        report.put("userId", userId);
        report.put("totalBooks", totalBooks);
        report.put("totalPages", totalPages);
        report.put("readingDays", readingDays.size());
        report.put("categoryStats", categoryStats);
        report.put("authorStats", authorStats);
        report.put("publisherStats", publisherStats);
        report.put("monthlyStats", monthlyStats);
        report.put("achievements", achievements);

        return report;
    }
}
