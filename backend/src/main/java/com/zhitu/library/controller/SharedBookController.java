package com.zhitu.library.controller;

import com.zhitu.library.entity.SharedBook;
import com.zhitu.library.service.SharedBookService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/shared-books")
@CrossOrigin(origins = "*")
public class SharedBookController {

    private final SharedBookService sharedBookService;

    public SharedBookController(SharedBookService sharedBookService) {
        this.sharedBookService = sharedBookService;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> publishSharedBook(
            @RequestParam Long userId,
            @RequestBody Map<String, String> bookData) {
        return ResponseEntity.ok(sharedBookService.publishSharedBook(userId, bookData));
    }

    @GetMapping
    public ResponseEntity<List<SharedBook>> getAllSharedBooks() {
        return ResponseEntity.ok(sharedBookService.getAllSharedBooks());
    }

    @GetMapping("/available")
    public ResponseEntity<List<SharedBook>> getAvailableSharedBooks() {
        return ResponseEntity.ok(sharedBookService.getAvailableSharedBooks());
    }

    @GetMapping("/{id}")
    public ResponseEntity<SharedBook> getSharedBookById(@PathVariable Long id) {
        return sharedBookService.getSharedBookById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<SharedBook>> getUserSharedBooks(@PathVariable Long userId) {
        return ResponseEntity.ok(sharedBookService.getUserSharedBooks(userId));
    }

    @PostMapping("/{id}/borrow")
    public ResponseEntity<Map<String, Object>> borrowSharedBook(
            @PathVariable Long id,
            @RequestParam Long borrowerId) {
        return ResponseEntity.ok(sharedBookService.borrowSharedBook(id, borrowerId));
    }

    @PostMapping("/{id}/return")
    public ResponseEntity<Map<String, Object>> returnSharedBook(@PathVariable Long id) {
        return ResponseEntity.ok(sharedBookService.returnSharedBook(id));
    }

    @PutMapping("/{id}/approve")
    public ResponseEntity<Map<String, Object>> approveSharedBook(@PathVariable Long id) {
        return ResponseEntity.ok(sharedBookService.approveSharedBook(id));
    }

    @PutMapping("/{id}/reject")
    public ResponseEntity<Map<String, Object>> rejectSharedBook(
            @PathVariable Long id,
            @RequestBody Map<String, String> requestData) {
        String reason = requestData.getOrDefault("reason", "");
        return ResponseEntity.ok(sharedBookService.rejectSharedBook(id, reason));
    }
}
