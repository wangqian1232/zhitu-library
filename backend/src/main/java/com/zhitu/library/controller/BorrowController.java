package com.zhitu.library.controller;

import com.zhitu.library.dto.BorrowRecordDTO;
import com.zhitu.library.service.BorrowService;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/borrow")
@CrossOrigin(origins = "*")
public class BorrowController {

    private final BorrowService borrowService;

    public BorrowController(BorrowService borrowService) {
        this.borrowService = borrowService;
    }

    @PostMapping("/{bookId}")
    public ResponseEntity<Map<String, Object>> borrowBook(
            @PathVariable Long bookId,
            @RequestParam Long userId) {
        return ResponseEntity.ok(borrowService.borrowBook(userId, bookId));
    }

    @PostMapping("/return/{borrowRecordId}")
    public ResponseEntity<Map<String, Object>> returnBook(@PathVariable Long borrowRecordId) {
        return ResponseEntity.ok(borrowService.returnBook(borrowRecordId));
    }

    @PostMapping("/renew/{borrowRecordId}")
    public ResponseEntity<Map<String, Object>> renewBook(@PathVariable Long borrowRecordId) {
        return ResponseEntity.ok(borrowService.renewBook(borrowRecordId));
    }

    @Transactional(readOnly = true)
    @GetMapping("/all")
    public ResponseEntity<List<BorrowRecordDTO>> getAllBorrowRecords() {
        return ResponseEntity.ok(borrowService.getAllBorrowRecords());
    }

    @Transactional(readOnly = true)
    @GetMapping("/recent")
    public ResponseEntity<List<BorrowRecordDTO>> getRecentBorrowRecords(@RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(borrowService.getRecentBorrowRecords(limit));
    }

    @Transactional(readOnly = true)
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<BorrowRecordDTO>> getUserBorrowRecords(@PathVariable Long userId) {
        return ResponseEntity.ok(borrowService.getUserBorrowRecords(userId));
    }

    @Transactional(readOnly = true)
    @GetMapping("/user/{userId}/active")
    public ResponseEntity<List<BorrowRecordDTO>> getUserActiveBorrows(@PathVariable Long userId) {
        return ResponseEntity.ok(borrowService.getUserActiveBorrows(userId));
    }

    @Transactional(readOnly = true)
    @GetMapping("/user/{userId}/overdue")
    public ResponseEntity<List<BorrowRecordDTO>> getUserOverdueBooks(@PathVariable Long userId) {
        return ResponseEntity.ok(borrowService.getUserOverdueBooks(userId));
    }

    @Transactional(readOnly = true)
    @GetMapping("/overdue/all")
    public ResponseEntity<List<BorrowRecordDTO>> getAllOverdueBooks() {
        return ResponseEntity.ok(borrowService.getAllOverdueBooks());
    }

    @GetMapping("/user/{userId}/stats")
    public ResponseEntity<Map<String, Object>> getUserBorrowStats(@PathVariable Long userId) {
        return ResponseEntity.ok(borrowService.getUserBorrowStats(userId));
    }
}
