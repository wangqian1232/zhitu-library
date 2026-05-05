package com.zhitu.library.service;

import com.zhitu.library.dto.BorrowRecordDTO;
import com.zhitu.library.entity.*;
import com.zhitu.library.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class BorrowService {

    private final BorrowRecordRepository borrowRecordRepository;
    private final BookRepository bookRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final SystemSettingsService systemSettingsService;

    public BorrowService(BorrowRecordRepository borrowRecordRepository,
                         BookRepository bookRepository,
                         UserRepository userRepository,
                         NotificationService notificationService,
                         SystemSettingsService systemSettingsService) {
        this.borrowRecordRepository = borrowRecordRepository;
        this.bookRepository = bookRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
        this.systemSettingsService = systemSettingsService;
    }

    @Transactional
    public Map<String, Object> borrowBook(Long userId, Long bookId) {
        Map<String, Object> result = new HashMap<>();

        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isEmpty()) {
            result.put("success", false);
            result.put("message", "用户不存在");
            return result;
        }

        Optional<Book> optionalBook = bookRepository.findById(bookId);
        if (optionalBook.isEmpty()) {
            result.put("success", false);
            result.put("message", "图书不存在");
            return result;
        }

        User user = optionalUser.get();
        Book book = optionalBook.get();

        if (book.getStatus() != 0 || book.getAvailableCopies() <= 0) {
            result.put("success", false);
            result.put("message", "图书当前不可借阅");
            return result;
        }

        long activeBorrows = borrowRecordRepository.countByUserIdAndStatus(userId, "active");
        var settings = systemSettingsService.getSettings();
        if (activeBorrows >= settings.getMaxBorrowCount()) {
            result.put("success", false);
            result.put("message", "您已达到最大借阅数量(" + settings.getMaxBorrowCount() + "本)");
            return result;
        }

        double unpaidFine = borrowRecordRepository.getTotalUnpaidFine(userId);
        if (unpaidFine > 0) {
            result.put("success", false);
            result.put("message", "您有未缴纳的罚款 ¥" + String.format("%.1f", unpaidFine) + "，请先缴纳后再借阅");
            return result;
        }

        BorrowRecord record = new BorrowRecord();
        record.setUser(user);
        record.setBook(book);
        record.setBorrowDate(LocalDateTime.now());
        record.setDueDate(LocalDateTime.now().plusDays(settings.getBorrowDays()));
        record.setStatus("active");
        record.setRenewCount(0);
        borrowRecordRepository.save(record);

        book.setAvailableCopies(book.getAvailableCopies() - 1);
        if (book.getAvailableCopies() == 0) {
            book.setStatus(1);
        }
        book.setBorrowCount(book.getBorrowCount() + 1);
        bookRepository.save(book);

        notificationService.createNotification(
                user.getId(),
                "借阅成功",
                "您已成功借阅《" + book.getTitle() + "》，请在" + settings.getBorrowDays() + "天内归还。",
                "borrow"
        );

        BorrowRecordDTO dto = convertToDTO(record);
        result.put("success", true);
        result.put("message", "借阅成功");
        result.put("record", dto);
        result.put("dueDate", record.getDueDate());
        return result;
    }

    @Transactional
    public Map<String, Object> returnBook(Long borrowRecordId) {
        Map<String, Object> result = new HashMap<>();

        Optional<BorrowRecord> optionalRecord = borrowRecordRepository.findById(borrowRecordId);
        if (optionalRecord.isEmpty()) {
            result.put("success", false);
            result.put("message", "借阅记录不存在");
            return result;
        }

        BorrowRecord record = optionalRecord.get();
        record.setReturnDate(LocalDateTime.now());
        record.setStatus("returned");

        Book book = record.getBook();
        book.setAvailableCopies(book.getAvailableCopies() + 1);
        if (book.getAvailableCopies() > 0) {
            book.setStatus(0);
        }
        bookRepository.save(book);

        if (record.getReturnDate().isAfter(record.getDueDate())) {
            long overdueDays = java.time.Duration.between(record.getDueDate(), record.getReturnDate()).toDays();
            double fine = overdueDays * 0.5;
            record.setFine(fine);
            record.setFinePaid(false);
            result.put("overdue", true);
            result.put("overdueDays", overdueDays);
            result.put("fine", fine);
        }

        borrowRecordRepository.save(record);

        BorrowRecordDTO dto = convertToDTO(record);
        result.put("success", true);
        result.put("message", "归还成功");
        result.put("record", dto);
        return result;
    }

    @Transactional
    public Map<String, Object> renewBook(Long borrowRecordId) {
        Map<String, Object> result = new HashMap<>();

        Optional<BorrowRecord> optionalRecord = borrowRecordRepository.findById(borrowRecordId);
        if (optionalRecord.isEmpty()) {
            result.put("success", false);
            result.put("message", "借阅记录不存在");
            return result;
        }

        BorrowRecord record = optionalRecord.get();
        if (!"active".equals(record.getStatus())) {
            result.put("success", false);
            result.put("message", "该借阅记录已归还");
            return result;
        }

        var settings = systemSettingsService.getSettings();
        if (record.getRenewCount() >= settings.getRenewCount()) {
            result.put("success", false);
            result.put("message", "已达到最大续借次数(" + settings.getRenewCount() + "次)");
            return result;
        }

        if (record.getDueDate().isBefore(LocalDateTime.now())) {
            result.put("success", false);
            result.put("message", "图书已逾期，无法续借，请尽快归还");
            return result;
        }

        int renewDays = settings.getBorrowDays() / 2;
        record.setDueDate(record.getDueDate().plusDays(renewDays));
        record.setRenewCount(record.getRenewCount() + 1);
        borrowRecordRepository.save(record);

        BorrowRecordDTO dto = convertToDTO(record);
        result.put("success", true);
        result.put("message", "续借成功");
        result.put("newDueDate", record.getDueDate());
        result.put("record", dto);
        return result;
    }

    @Transactional(readOnly = true)
    public List<BorrowRecordDTO> getAllBorrowRecords() {
        return borrowRecordRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BorrowRecordDTO> getRecentBorrowRecords(int limit) {
        return borrowRecordRepository.findRecentBorrowRecords(org.springframework.data.domain.PageRequest.of(0, limit)).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BorrowRecordDTO> getUserBorrowRecords(Long userId) {
        return borrowRecordRepository.findByUserId(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BorrowRecordDTO> getUserActiveBorrows(Long userId) {
        return borrowRecordRepository.findByUserIdAndStatus(userId, "active").stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BorrowRecordDTO> getUserOverdueBooks(Long userId) {
        return borrowRecordRepository.findOverdueByUserId(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BorrowRecordDTO> getAllOverdueBooks() {
        return borrowRecordRepository.findAllOverdue().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private BorrowRecordDTO convertToDTO(BorrowRecord record) {
        BorrowRecordDTO dto = new BorrowRecordDTO();
        dto.setId(record.getId());
        dto.setBookId(record.getBook().getId());
        dto.setBookTitle(record.getBook().getTitle());
        dto.setBookCoverUrl(record.getBook().getCoverUrl());
        dto.setBookCoverAsset(record.getBook().getCoverAsset());
        dto.setUserId(record.getUser().getId());
        dto.setUsername(record.getUser().getUsername());
        dto.setBorrowDate(record.getBorrowDate());
        dto.setDueDate(record.getDueDate());
        dto.setReturnDate(record.getReturnDate());
        dto.setStatus(record.getStatus());
        dto.setFine(record.getFine());
        dto.setFinePaid(record.getFinePaid());
        dto.setRenewCount(record.getRenewCount());
        return dto;
    }

    public Map<String, Object> getUserBorrowStats(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalBorrows", borrowRecordRepository.countByUserIdAndStatus(userId, "returned") +
                borrowRecordRepository.countByUserIdAndStatus(userId, "active"));
        stats.put("activeBorrows", borrowRecordRepository.countByUserIdAndStatus(userId, "active"));
        stats.put("overdueCount", borrowRecordRepository.findOverdueByUserId(userId).size());
        return stats;
    }

    @Transactional
    public Map<String, Object> payFine(Long userId) {
        Map<String, Object> result = new HashMap<>();

        List<BorrowRecord> records = borrowRecordRepository.findByUserId(userId);
        double totalFine = 0;
        int paidCount = 0;

        for (BorrowRecord record : records) {
            if (record.getFine() != null && record.getFine() > 0 && !record.getFinePaid()) {
                record.setFinePaid(true);
                totalFine += record.getFine();
                paidCount++;
            }
        }

        borrowRecordRepository.saveAll(records);

        result.put("success", true);
        result.put("message", "罚款缴纳成功");
        result.put("paidAmount", totalFine);
        result.put("paidCount", paidCount);
        return result;
    }
}
