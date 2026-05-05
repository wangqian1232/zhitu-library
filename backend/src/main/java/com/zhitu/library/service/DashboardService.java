package com.zhitu.library.service;

import com.zhitu.library.entity.Book;
import com.zhitu.library.entity.BorrowRecord;
import com.zhitu.library.entity.SharedBook;
import com.zhitu.library.entity.User;
import com.zhitu.library.repository.BookRepository;
import com.zhitu.library.repository.BorrowRecordRepository;
import com.zhitu.library.repository.SharedBookRepository;
import com.zhitu.library.repository.UserRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class DashboardService {

    private final BookRepository bookRepository;
    private final BorrowRecordRepository borrowRecordRepository;
    private final SharedBookRepository sharedBookRepository;
    private final UserRepository userRepository;

    public DashboardService(BookRepository bookRepository,
                            BorrowRecordRepository borrowRecordRepository,
                            SharedBookRepository sharedBookRepository,
                            UserRepository userRepository) {
        this.bookRepository = bookRepository;
        this.borrowRecordRepository = borrowRecordRepository;
        this.sharedBookRepository = sharedBookRepository;
        this.userRepository = userRepository;
    }

    public Map<String, Object> getDashboardOverview() {
        Map<String, Object> result = new HashMap<>();

        result.put("realTimeStats", getRealTimeStats());
        result.put("borrowTrend", getBorrowTrend(30));
        result.put("bookStatusDistribution", getBookStatusDistribution());
        result.put("categoryStats", getCategoryStats());
        result.put("topBooks", getTopBooks());
        result.put("recentLogs", getRecentLogs());

        return result;
    }

    private Map<String, Object> getRealTimeStats() {
        Map<String, Object> stats = new HashMap<>();

        LocalDate today = LocalDate.now();
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.plusDays(1).atStartOfDay();

        List<BorrowRecord> allRecords = borrowRecordRepository.findAll();

        long todayBorrowed = allRecords.stream()
                .filter(br -> br.getBorrowDate() != null
                        && !br.getBorrowDate().isBefore(startOfDay)
                        && br.getBorrowDate().isBefore(endOfDay))
                .count();

        long todayReturned = allRecords.stream()
                .filter(br -> br.getReturnDate() != null
                        && !br.getReturnDate().isBefore(startOfDay)
                        && br.getReturnDate().isBefore(endOfDay))
                .count();

        long currentInLibrary = userRepository.count();

        long pendingSharedBooks = sharedBookRepository.findByStatus("pending").size();
        long pendingReservations = 0;

        stats.put("todayBorrowed", todayBorrowed);
        stats.put("todayReturned", todayReturned);
        stats.put("currentInLibrary", currentInLibrary);
        stats.put("pendingTasks", pendingSharedBooks + pendingReservations);

        return stats;
    }

    private List<Map<String, Object>> getBorrowTrend(int days) {
        List<Map<String, Object>> trend = new ArrayList<>();
        LocalDate today = LocalDate.now();
        List<BorrowRecord> allRecords = borrowRecordRepository.findAll();

        for (int i = days - 1; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();

            long borrowed = allRecords.stream()
                    .filter(br -> br.getBorrowDate() != null
                            && !br.getBorrowDate().isBefore(startOfDay)
                            && br.getBorrowDate().isBefore(endOfDay))
                    .count();

            long returned = allRecords.stream()
                    .filter(br -> br.getReturnDate() != null
                            && !br.getReturnDate().isBefore(startOfDay)
                            && br.getReturnDate().isBefore(endOfDay))
                    .count();

            Map<String, Object> dayData = new HashMap<>();
            dayData.put("date", date.format(DateTimeFormatter.ofPattern("MM-dd")));
            dayData.put("borrowed", borrowed);
            dayData.put("returned", returned);
            trend.add(dayData);
        }

        return trend;
    }

    private List<Map<String, Object>> getBookStatusDistribution() {
        List<Map<String, Object>> distribution = new ArrayList<>();

        List<Book> allBooks = bookRepository.findAll();
        long available = allBooks.stream().filter(b -> b.getAvailableCopies() > 0).count();
        long borrowed = allBooks.stream().filter(b -> b.getAvailableCopies() == 0).count();
        long pending = sharedBookRepository.findByStatus("pending").size();

        distribution.add(createStatusItem("可借阅", (int) available, "#4CAF50"));
        distribution.add(createStatusItem("已借出", (int) borrowed, "#3b82f6"));
        distribution.add(createStatusItem("待审核", (int) pending, "#f97316"));

        return distribution;
    }

    private Map<String, Object> createStatusItem(String name, int value, String color) {
        Map<String, Object> item = new HashMap<>();
        item.put("name", name);
        item.put("value", value);
        item.put("color", color);
        return item;
    }

    private List<Map<String, Object>> getCategoryStats() {
        List<Book> allBooks = bookRepository.findAll();

        Map<String, Long> categoryCount = allBooks.stream()
                .filter(b -> b.getCategory() != null && !b.getCategory().isEmpty())
                .collect(Collectors.groupingBy(Book::getCategory, Collectors.counting()));

        int total = categoryCount.values().stream().mapToInt(Long::intValue).sum();

        List<Map<String, Object>> stats = new ArrayList<>();
        List<Map.Entry<String, Long>> sorted = categoryCount.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .collect(Collectors.toList());

        int otherCount = 0;
        for (Map.Entry<String, Long> entry : sorted) {
            double percentage = total > 0 ? (entry.getValue() * 100.0 / total) : 0;
            if (percentage < 3) {
                otherCount += entry.getValue();
            } else {
                Map<String, Object> item = new HashMap<>();
                item.put("name", entry.getKey());
                item.put("value", entry.getValue());
                stats.add(item);
            }
        }

        if (otherCount > 0) {
            Map<String, Object> other = new HashMap<>();
            other.put("name", "其他");
            other.put("value", otherCount);
            stats.add(other);
        }

        return stats;
    }

    private List<Map<String, Object>> getTopBooks() {
        List<Book> allBooks = bookRepository.findAll();

        return allBooks.stream()
                .sorted(Comparator.comparingInt(Book::getBorrowCount).reversed())
                .limit(10)
                .map(book -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("rank", 0);
                    item.put("title", book.getTitle());
                    item.put("count", book.getBorrowCount());
                    item.put("author", book.getAuthor());
                    return item;
                })
                .collect(Collectors.toList());
    }

    private List<Map<String, Object>> getRecentLogs() {
        List<BorrowRecord> records = borrowRecordRepository.findRecentBorrowRecords(PageRequest.of(0, 15));

        return records.stream()
                .map(br -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("user", br.getUser() != null ? br.getUser().getUsername() : "未知");
                    item.put("book", br.getBook() != null ? br.getBook().getTitle() : "未知");
                    item.put("time", br.getBorrowDate() != null
                            ? br.getBorrowDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))
                            : "-");
                    item.put("status", "active".equals(br.getStatus()) ? "借阅中" : "已归还");
                    return item;
                })
                .collect(Collectors.toList());
    }
}
