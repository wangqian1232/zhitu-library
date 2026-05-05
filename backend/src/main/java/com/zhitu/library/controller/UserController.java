package com.zhitu.library.controller;

import com.zhitu.library.entity.Book;
import com.zhitu.library.entity.User;
import com.zhitu.library.service.BorrowService;
import com.zhitu.library.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;
    private final BorrowService borrowService;

    public UserController(UserService userService, BorrowService borrowService) {
        this.userService = userService;
        this.borrowService = borrowService;
    }

    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getUserById(@PathVariable Long id) {
        Map<String, Object> result = new HashMap<>();
        return userService.getUserById(id)
                .map(user -> {
                    result.put("success", true);
                    result.put("user", user);
                    return ResponseEntity.ok(result);
                })
                .orElseGet(() -> {
                    result.put("success", false);
                    result.put("message", "用户不存在");
                    return ResponseEntity.notFound().build();
                });
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> credentials) {
        String username = credentials.get("username");
        String password = credentials.get("password");
        Map<String, Object> result = userService.login(username, password);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> userData) {
        User user = new User();
        user.setUsername(userData.get("username"));
        user.setPassword(userData.get("password"));
        user.setEmail(userData.get("email"));
        user.setPhone(userData.get("phone"));
        user.setRole("user");

        Map<String, Object> result = userService.register(user);
        return ResponseEntity.ok(result);
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User userDetails) {
        return ResponseEntity.ok(userService.updateUser(id, userDetails));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/pay-fine")
    public ResponseEntity<Map<String, Object>> payFine(@PathVariable Long id) {
        return ResponseEntity.ok(borrowService.payFine(id));
    }

    @Transactional(readOnly = true)
    @GetMapping("/{id}/favorites")
    public ResponseEntity<Map<String, Object>> getUserFavorites(@PathVariable Long id) {
        List<Book> favorites = userService.getUserFavorites(id);
        List<Map<String, Object>> result = favorites.stream().map(b -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", b.getId());
            map.put("title", b.getTitle());
            map.put("author", b.getAuthor());
            map.put("coverUrl", b.getCoverUrl());
            map.put("coverAsset", b.getCoverAsset());
            map.put("category", b.getCategory());
            map.put("majorCategory", b.getMajorCategory());
            map.put("status", b.getStatus());
            map.put("borrowCount", b.getBorrowCount());
            map.put("isbn", b.getIsbn());
            map.put("publisher", b.getPublisher());
            map.put("description", b.getDescription());
            map.put("totalCopies", b.getTotalCopies());
            map.put("availableCopies", b.getAvailableCopies());
            map.put("favoriteUserIds", b.getFavoriteUserIds() != null ? 
                java.util.Arrays.asList(b.getFavoriteUserIds().split(",")) : new java.util.ArrayList<>());
            return map;
        }).collect(Collectors.toList());
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", result);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/favorites")
    public ResponseEntity<Map<String, Object>> toggleFavorite(
            @RequestParam Long userId,
            @RequestParam Long bookId) {
        return ResponseEntity.ok(userService.toggleFavorite(userId, bookId));
    }

    @GetMapping("/{id}/reading-report")
    public ResponseEntity<Map<String, Object>> getReadingReport(@PathVariable Long id) {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", userService.generateReadingReport(id));
        return ResponseEntity.ok(result);
    }
}
