package com.zhitu.library.service;

import com.zhitu.library.entity.SystemLog;
import com.zhitu.library.repository.SystemLogRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SystemLogService {

    private final SystemLogRepository logRepository;

    public SystemLogService(SystemLogRepository logRepository) {
        this.logRepository = logRepository;
    }

    public Page<SystemLog> getLogs(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return logRepository.findAllByOrderByCreatedAtDesc(pageable);
    }

    public Page<SystemLog> getLogsByLevel(String level, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return logRepository.findByLevelOrderByCreatedAtDesc(level, pageable);
    }

    public Page<SystemLog> getLogsByModule(String module, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return logRepository.findByModuleOrderByCreatedAtDesc(module, pageable);
    }

    public Page<SystemLog> getLogsByUserId(Long userId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return logRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    }

    public Page<SystemLog> getLogsByDateRange(LocalDateTime start, LocalDateTime end, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return logRepository.findByDateRange(start, end, pageable);
    }

    public Map<String, Object> getLogStatistics() {
        Map<String, Object> stats = new HashMap<>();

        List<Object[]> levelCounts = logRepository.countByLevel();
        Map<String, Long> levelMap = new HashMap<>();
        for (Object[] row : levelCounts) {
            levelMap.put((String) row[0], (Long) row[1]);
        }
        stats.put("levelCounts", levelMap);

        List<Object[]> moduleCounts = logRepository.countByModule();
        Map<String, Long> moduleMap = new HashMap<>();
        for (Object[] row : moduleCounts) {
            moduleMap.put((String) row[0], (Long) row[1]);
        }
        stats.put("moduleCounts", moduleMap);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime thirtyDaysAgo = now.minusDays(30);
        List<Object[]> dateCounts = logRepository.countByDate(thirtyDaysAgo, now);
        List<Map<String, Object>> trendData = new java.util.ArrayList<>();
        for (Object[] row : dateCounts) {
            Map<String, Object> item = new HashMap<>();
            item.put("date", row[0].toString());
            item.put("count", row[1]);
            trendData.add(item);
        }
        stats.put("trendData", trendData);

        return stats;
    }

    @Transactional
    public SystemLog createLog(SystemLog log) {
        return logRepository.save(log);
    }

    public SystemLog getLogById(Long id) {
        return logRepository.findById(id).orElse(null);
    }

    @Transactional
    public void deleteLogsOlderThan(LocalDateTime date) {
        Page<SystemLog> oldLogs = logRepository.findByDateRange(LocalDateTime.of(2000, 1, 1, 0, 0), date, PageRequest.of(0, 10000));
        logRepository.deleteAll(oldLogs.getContent());
    }
}
