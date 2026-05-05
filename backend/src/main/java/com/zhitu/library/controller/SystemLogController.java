package com.zhitu.library.controller;

import com.zhitu.library.entity.SystemLog;
import com.zhitu.library.service.SystemLogService;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/system-logs")
public class SystemLogController {

    private final SystemLogService logService;

    public SystemLogController(SystemLogService logService) {
        this.logService = logService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getLogs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String level,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        
        Map<String, Object> result = new HashMap<>();
        Page<SystemLog> logs;

        if (level != null && !level.isEmpty()) {
            logs = logService.getLogsByLevel(level, page, size);
        } else if (module != null && !module.isEmpty()) {
            logs = logService.getLogsByModule(module, page, size);
        } else if (userId != null) {
            logs = logService.getLogsByUserId(userId, page, size);
        } else if (start != null && end != null) {
            logs = logService.getLogsByDateRange(start, end, page, size);
        } else {
            logs = logService.getLogs(page, size);
        }

        result.put("success", true);
        result.put("data", logs.getContent());
        result.put("total", logs.getTotalElements());
        result.put("page", logs.getNumber());
        result.put("size", logs.getSize());
        result.put("totalPages", logs.getTotalPages());

        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getLogById(@PathVariable Long id) {
        Map<String, Object> result = new HashMap<>();
        SystemLog log = logService.getLogById(id);

        if (log == null) {
            result.put("success", false);
            result.put("message", "日志不存在");
            return ResponseEntity.ok(result);
        }

        result.put("success", true);
        result.put("data", log);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", logService.getLogStatistics());
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/cleanup")
    public ResponseEntity<Map<String, Object>> cleanupOldLogs(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime before) {
        Map<String, Object> result = new HashMap<>();
        try {
            logService.deleteLogsOlderThan(before);
            result.put("success", true);
            result.put("message", "清理成功");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "清理失败: " + e.getMessage());
        }
        return ResponseEntity.ok(result);
    }
}
