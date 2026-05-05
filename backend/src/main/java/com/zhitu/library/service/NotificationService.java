package com.zhitu.library.service;

import com.zhitu.library.entity.Notification;
import com.zhitu.library.entity.User;
import com.zhitu.library.repository.NotificationRepository;
import com.zhitu.library.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public NotificationService(NotificationRepository notificationRepository,
                               UserRepository userRepository) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    public Notification createNotification(Long userId, String title, String content, String type) {
        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isEmpty()) {
            return null;
        }

        Notification notification = new Notification();
        notification.setUser(optionalUser.get());
        notification.setTitle(title);
        notification.setContent(content);
        notification.setType(type);
        notification.setIsRead(false);
        notification.setCreatedAt(LocalDateTime.now());
        return notificationRepository.save(notification);
    }

    @Transactional(readOnly = true)
    public List<Notification> getUserNotifications(Long userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Transactional(readOnly = true)
    public List<Notification> getUnreadNotifications(Long userId) {
        return notificationRepository.findByUserIdAndIsReadFalse(userId);
    }

    public long getUnreadCount(Long userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    @Transactional
    public Map<String, Object> markAsRead(Long notificationId) {
        Map<String, Object> result = new HashMap<>();

        Optional<Notification> optionalNotification = notificationRepository.findById(notificationId);
        if (optionalNotification.isEmpty()) {
            result.put("success", false);
            result.put("message", "通知不存在");
            return result;
        }

        Notification notification = optionalNotification.get();
        notification.setIsRead(true);
        notificationRepository.save(notification);

        result.put("success", true);
        result.put("message", "已标记为已读");
        return result;
    }

    @Transactional
    public Map<String, Object> markAllAsRead(Long userId) {
        List<Notification> unreadNotifications = notificationRepository.findByUserIdAndIsReadFalse(userId);
        for (Notification notification : unreadNotifications) {
            notification.setIsRead(true);
        }
        notificationRepository.saveAll(unreadNotifications);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "全部标记为已读");
        result.put("count", unreadNotifications.size());
        return result;
    }

    @Transactional
    public Map<String, Object> deleteNotification(Long notificationId) {
        Map<String, Object> result = new HashMap<>();

        if (!notificationRepository.existsById(notificationId)) {
            result.put("success", false);
            result.put("message", "通知不存在");
            return result;
        }

        notificationRepository.deleteById(notificationId);
        result.put("success", true);
        result.put("message", "删除成功");
        return result;
    }
}
