package com.zhitu.library.service;

import com.zhitu.library.entity.SystemSettings;
import com.zhitu.library.repository.SystemSettingsRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
public class SystemSettingsService {

    private final SystemSettingsRepository systemSettingsRepository;

    public SystemSettingsService(SystemSettingsRepository systemSettingsRepository) {
        this.systemSettingsRepository = systemSettingsRepository;
    }

    public SystemSettings getSettings() {
        Optional<SystemSettings> settings = systemSettingsRepository.findById(1L);
        if (settings.isEmpty()) {
            SystemSettings defaultSettings = new SystemSettings();
            defaultSettings.setId(1L);
            defaultSettings.setBorrowDays(30);
            defaultSettings.setRenewCount(1);
            defaultSettings.setOverdueFine(0.2);
            defaultSettings.setMaxBorrowCount(5);
            return systemSettingsRepository.save(defaultSettings);
        }
        return settings.get();
    }

    @Transactional
    public Map<String, Object> updateBorrowDays(Integer borrowDays) {
        Map<String, Object> result = new HashMap<>();
        SystemSettings settings = getSettings();
        settings.setBorrowDays(borrowDays);
        systemSettingsRepository.save(settings);
        result.put("success", true);
        result.put("message", "更新成功");
        return result;
    }

    @Transactional
    public Map<String, Object> updateRenewCount(Integer renewCount) {
        Map<String, Object> result = new HashMap<>();
        SystemSettings settings = getSettings();
        settings.setRenewCount(renewCount);
        systemSettingsRepository.save(settings);
        result.put("success", true);
        result.put("message", "更新成功");
        return result;
    }

    @Transactional
    public Map<String, Object> updateOverdueFine(Double overdueFine) {
        Map<String, Object> result = new HashMap<>();
        SystemSettings settings = getSettings();
        settings.setOverdueFine(overdueFine);
        systemSettingsRepository.save(settings);
        result.put("success", true);
        result.put("message", "更新成功");
        return result;
    }

    @Transactional
    public Map<String, Object> updateMaxBorrowCount(Integer maxBorrowCount) {
        Map<String, Object> result = new HashMap<>();
        SystemSettings settings = getSettings();
        settings.setMaxBorrowCount(maxBorrowCount);
        systemSettingsRepository.save(settings);
        result.put("success", true);
        result.put("message", "更新成功");
        return result;
    }
}
