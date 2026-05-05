package com.zhitu.library.service;

import com.zhitu.library.entity.SystemException;
import com.zhitu.library.repository.SystemExceptionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ExceptionService {

    private final SystemExceptionRepository exceptionRepository;

    public ExceptionService(SystemExceptionRepository exceptionRepository) {
        this.exceptionRepository = exceptionRepository;
    }

    public List<SystemException> getExceptionsByStatus(String status) {
        return exceptionRepository.findByStatusOrderByOccurredAtDesc(status);
    }

    public List<SystemException> getExceptionsByType(String type) {
        return exceptionRepository.findByTypeOrderByOccurredAtDesc(type);
    }

    public List<SystemException> getExceptionsByStatusAndType(String status, String type) {
        return exceptionRepository.findByStatusAndTypeOrderByOccurredAtDesc(status, type);
    }

    public List<SystemException> getExceptionsByDateRange(LocalDateTime start, LocalDateTime end) {
        return exceptionRepository.findByDateRange(start, end);
    }

    public Optional<SystemException> getExceptionById(Long id) {
        return exceptionRepository.findById(id);
    }

    @Transactional
    public SystemException createException(SystemException exception) {
        exception.setCreatedAt(LocalDateTime.now());
        exception.setUpdatedAt(LocalDateTime.now());
        exception.setStatus("pending");
        return exceptionRepository.save(exception);
    }

    @Transactional
    public SystemException updateExceptionStatus(Long id, String status, String solution, String handledBy) {
        SystemException exception = exceptionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("异常记录不存在"));
        exception.setStatus(status);
        exception.setSolution(solution);
        exception.setHandledBy(handledBy);
        exception.setHandledAt("resolved".equals(status) || "ignored".equals(status) ? LocalDateTime.now() : null);
        exception.setUpdatedAt(LocalDateTime.now());
        return exceptionRepository.save(exception);
    }

    @Transactional
    public void deleteException(Long id) {
        exceptionRepository.deleteById(id);
    }

    public Map<String, Object> getExceptionStatistics() {
        Map<String, Object> stats = new HashMap<>();

        List<Object[]> statusCounts = exceptionRepository.countByStatus();
        Map<String, Long> statusMap = new HashMap<>();
        for (Object[] row : statusCounts) {
            statusMap.put((String) row[0], (Long) row[1]);
        }
        stats.put("statusCounts", statusMap);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime thirtyDaysAgo = now.minusDays(30);
        List<Object[]> typeCounts = exceptionRepository.countByTypeAndDateRange(thirtyDaysAgo, now);
        Map<String, Long> typeMap = new HashMap<>();
        for (Object[] row : typeCounts) {
            typeMap.put((String) row[0], (Long) row[1]);
        }
        stats.put("typeCounts", typeMap);

        List<Object[]> severityCounts = exceptionRepository.countBySeverityAndDateRange(thirtyDaysAgo, now);
        Map<String, Long> severityMap = new HashMap<>();
        for (Object[] row : severityCounts) {
            severityMap.put((String) row[0], (Long) row[1]);
        }
        stats.put("severityCounts", severityMap);

        List<Object[]> dateCounts = exceptionRepository.countByDate(thirtyDaysAgo, now);
        List<Map<String, Object>> trendData = new ArrayList<>();
        for (Object[] row : dateCounts) {
            Map<String, Object> item = new HashMap<>();
            item.put("date", row[0].toString());
            item.put("count", row[1]);
            trendData.add(item);
        }
        stats.put("trendData", trendData);

        long totalExceptions = statusMap.values().stream().mapToLong(Long::longValue).sum();
        long resolvedExceptions = statusMap.getOrDefault("resolved", 0L);
        double healthScore = totalExceptions > 0 ? (double) resolvedExceptions / totalExceptions * 100 : 100;
        stats.put("healthScore", Math.round(healthScore * 10.0) / 10.0);
        stats.put("totalExceptions", totalExceptions);
        stats.put("resolvedExceptions", resolvedExceptions);

        return stats;
    }

    public void recordOverdueException(Long userId, Long bookId, Long borrowRecordId, String userName, String bookName, int overdueDays) {
        SystemException exception = new SystemException();
        exception.setType("overdue");
        exception.setTitle("图书借阅逾期");
        exception.setDescription(String.format("用户 %s 借阅的《%s》已逾期 %d 天", userName, bookName, overdueDays));
        exception.setSeverity(overdueDays > 30 ? "high" : overdueDays > 7 ? "medium" : "low");
        exception.setModule("borrow");
        exception.setRelatedUserId(userId);
        exception.setRelatedBookId(bookId);
        exception.setRelatedRecordId(borrowRecordId);
        exception.setOccurredAt(LocalDateTime.now());
        exceptionRepository.save(exception);
    }

    public void recordNoShowException(Long userId, Long bookId, String userName, String bookName, LocalDateTime appointmentTime) {
        SystemException exception = new SystemException();
        exception.setType("no_show");
        exception.setTitle("预约未到");
        exception.setDescription(String.format("用户 %s 预约的《%s》(%s) 未按时到馆", userName, bookName, appointmentTime));
        exception.setSeverity("medium");
        exception.setModule("reservation");
        exception.setRelatedUserId(userId);
        exception.setRelatedBookId(bookId);
        exception.setOccurredAt(LocalDateTime.now());
        exceptionRepository.save(exception);
    }

    public void recordSystemException(String module, String title, String description, String stackTrace, String severity) {
        SystemException exception = new SystemException();
        exception.setType("system_error");
        exception.setTitle(title);
        exception.setDescription(description);
        exception.setStackTrace(stackTrace);
        exception.setSeverity(severity != null ? severity : "high");
        exception.setModule(module);
        exception.setOccurredAt(LocalDateTime.now());
        exceptionRepository.save(exception);
    }

    @Transactional
    public Map<String, Object> batchUpdateStatus(List<Long> ids, String status, String solution, String handledBy) {
        Map<String, Object> result = new HashMap<>();
        int successCount = 0;
        int failCount = 0;

        for (Long id : ids) {
            try {
                Optional<SystemException> optional = exceptionRepository.findById(id);
                if (optional.isPresent()) {
                    SystemException exception = optional.get();
                    exception.setStatus(status);
                    exception.setSolution(solution);
                    exception.setHandledBy(handledBy);
                    exception.setHandledAt("resolved".equals(status) || "ignored".equals(status) ? LocalDateTime.now() : null);
                    exception.setUpdatedAt(LocalDateTime.now());
                    exceptionRepository.save(exception);
                    successCount++;
                } else {
                    failCount++;
                }
            } catch (Exception e) {
                failCount++;
            }
        }

        result.put("success", true);
        result.put("message", String.format("批量操作完成：成功 %d 条，失败 %d 条", successCount, failCount));
        result.put("successCount", successCount);
        result.put("failCount", failCount);
        return result;
    }

    @Transactional
    public Map<String, Object> batchDelete(List<Long> ids) {
        Map<String, Object> result = new HashMap<>();
        int successCount = 0;
        int failCount = 0;

        for (Long id : ids) {
            try {
                if (exceptionRepository.existsById(id)) {
                    exceptionRepository.deleteById(id);
                    successCount++;
                } else {
                    failCount++;
                }
            } catch (Exception e) {
                failCount++;
            }
        }

        result.put("success", true);
        result.put("message", String.format("批量删除完成：成功 %d 条，失败 %d 条", successCount, failCount));
        result.put("successCount", successCount);
        result.put("failCount", failCount);
        return result;
    }
}
