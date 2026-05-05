package com.zhitu.library.controller;

import com.zhitu.library.entity.SystemException;
import com.zhitu.library.service.ExceptionService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/exceptions")
@CrossOrigin(origins = "*")
public class ExceptionController {

    private final ExceptionService exceptionService;

    public ExceptionController(ExceptionService exceptionService) {
        this.exceptionService = exceptionService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getExceptions(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {

        List<SystemException> exceptions;
        if (status != null && type != null) {
            exceptions = exceptionService.getExceptionsByStatusAndType(status, type);
        } else if (status != null) {
            exceptions = exceptionService.getExceptionsByStatus(status);
        } else if (type != null) {
            exceptions = exceptionService.getExceptionsByType(type);
        } else if (startDate != null && endDate != null) {
            exceptions = exceptionService.getExceptionsByDateRange(startDate, endDate);
        } else {
            exceptions = exceptionService.getExceptionsByStatus("pending");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", exceptions);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getExceptionById(@PathVariable Long id) {
        Map<String, Object> result = new HashMap<>();
        return exceptionService.getExceptionById(id)
                .map(exception -> {
                    result.put("success", true);
                    result.put("data", exception);
                    return ResponseEntity.ok(result);
                })
                .orElseGet(() -> {
                    result.put("success", false);
                    result.put("message", "异常记录不存在");
                    return ResponseEntity.notFound().build();
                });
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createException(@RequestBody Map<String, Object> body) {
        SystemException exception = new SystemException();
        exception.setType((String) body.get("type"));
        exception.setTitle((String) body.get("title"));
        exception.setDescription((String) body.get("description"));
        exception.setStackTrace((String) body.get("stackTrace"));
        exception.setSeverity((String) body.get("severity"));
        exception.setModule((String) body.get("module"));
        exception.setRelatedUserId(body.get("relatedUserId") != null ? Long.valueOf(body.get("relatedUserId").toString()) : null);
        exception.setRelatedBookId(body.get("relatedBookId") != null ? Long.valueOf(body.get("relatedBookId").toString()) : null);
        exception.setRelatedRecordId(body.get("relatedRecordId") != null ? Long.valueOf(body.get("relatedRecordId").toString()) : null);
        exception.setRelatedData((String) body.get("relatedData"));

        SystemException saved = exceptionService.createException(exception);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", saved);
        return ResponseEntity.ok(result);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateExceptionStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        String status = body.get("status");
        String solution = body.get("solution");
        String handledBy = body.get("handledBy");

        SystemException updated = exceptionService.updateExceptionStatus(id, status, solution, handledBy);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", updated);
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteException(@PathVariable Long id) {
        exceptionService.deleteException(id);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "删除成功");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        Map<String, Object> stats = exceptionService.getExceptionStatistics();
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", stats);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/overdue")
    public ResponseEntity<Map<String, Object>> recordOverdue(@RequestBody Map<String, Object> body) {
        exceptionService.recordOverdueException(
                Long.valueOf(body.get("userId").toString()),
                Long.valueOf(body.get("bookId").toString()),
                Long.valueOf(body.get("borrowRecordId").toString()),
                (String) body.get("userName"),
                (String) body.get("bookName"),
                Integer.valueOf(body.get("overdueDays").toString())
        );
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "逾期异常已记录");
        return ResponseEntity.ok(result);
    }

    @PostMapping("/no-show")
    public ResponseEntity<Map<String, Object>> recordNoShow(@RequestBody Map<String, Object> body) {
        exceptionService.recordNoShowException(
                Long.valueOf(body.get("userId").toString()),
                Long.valueOf(body.get("bookId").toString()),
                (String) body.get("userName"),
                (String) body.get("bookName"),
                LocalDateTime.parse((String) body.get("appointmentTime"))
        );
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "预约未到异常已记录");
        return ResponseEntity.ok(result);
    }

    @PutMapping("/batch/status")
    public ResponseEntity<Map<String, Object>> batchUpdateStatus(@RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        java.util.List<Long> ids = (java.util.List<Long>) body.get("ids");
        String status = (String) body.get("status");
        String solution = (String) body.get("solution");
        String handledBy = (String) body.get("handledBy");

        Map<String, Object> result = exceptionService.batchUpdateStatus(ids, status, solution, handledBy);
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/batch")
    public ResponseEntity<Map<String, Object>> batchDelete(@RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        java.util.List<Long> ids = (java.util.List<Long>) body.get("ids");

        Map<String, Object> result = exceptionService.batchDelete(ids);
        return ResponseEntity.ok(result);
    }
}
