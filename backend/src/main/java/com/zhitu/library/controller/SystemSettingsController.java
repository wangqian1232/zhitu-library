package com.zhitu.library.controller;

import com.zhitu.library.service.SystemSettingsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/settings")
@CrossOrigin(origins = "*")
public class SystemSettingsController {

    private final SystemSettingsService systemSettingsService;

    public SystemSettingsController(SystemSettingsService systemSettingsService) {
        this.systemSettingsService = systemSettingsService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getSettings() {
        var settings = systemSettingsService.getSettings();
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("data", Map.of(
                "borrowDays", settings.getBorrowDays(),
                "renewCount", settings.getRenewCount(),
                "overdueFine", settings.getOverdueFine(),
                "maxBorrowCount", settings.getMaxBorrowCount()
        ));
        return ResponseEntity.ok(result);
    }

    @PutMapping("/borrow-days")
    public ResponseEntity<Map<String, Object>> updateBorrowDays(@RequestBody Map<String, Integer> body) {
        return ResponseEntity.ok(systemSettingsService.updateBorrowDays(body.get("borrowDays")));
    }

    @PutMapping("/renew-count")
    public ResponseEntity<Map<String, Object>> updateRenewCount(@RequestBody Map<String, Integer> body) {
        return ResponseEntity.ok(systemSettingsService.updateRenewCount(body.get("renewCount")));
    }

    @PutMapping("/overdue-fine")
    public ResponseEntity<Map<String, Object>> updateOverdueFine(@RequestBody Map<String, Double> body) {
        return ResponseEntity.ok(systemSettingsService.updateOverdueFine(body.get("overdueFine")));
    }

    @PutMapping("/max-borrow-count")
    public ResponseEntity<Map<String, Object>> updateMaxBorrowCount(@RequestBody Map<String, Integer> body) {
        return ResponseEntity.ok(systemSettingsService.updateMaxBorrowCount(body.get("maxBorrowCount")));
    }
}
