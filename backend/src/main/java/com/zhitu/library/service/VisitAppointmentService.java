package com.zhitu.library.service;

import com.zhitu.library.entity.*;
import com.zhitu.library.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class VisitAppointmentService {

    private final VisitAppointmentRepository appointmentRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public VisitAppointmentService(VisitAppointmentRepository appointmentRepository,
                                   TimeSlotRepository timeSlotRepository,
                                   UserRepository userRepository,
                                   NotificationService notificationService) {
        this.appointmentRepository = appointmentRepository;
        this.timeSlotRepository = timeSlotRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getTimeSlotsForDate(LocalDate date) {
        List<TimeSlot> allSlots = timeSlotRepository.findAll();
        LocalDate today = LocalDate.now();

        return allSlots.stream().map(slot -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", slot.getId());
            map.put("label", slot.getLabel());
            map.put("startTime", slot.getStartTime());
            map.put("endTime", slot.getEndTime());
            map.put("maxCapacity", slot.getMaxCapacity());

            long count = appointmentRepository.countByTimeSlotIdAndAppointmentDate(slot.getId(), date);
            map.put("currentReservations", (int) count);
            map.put("remainingSlots", slot.getMaxCapacity() - (int) count);
            map.put("isAvailable", slot.getIsAvailable() && count < slot.getMaxCapacity());
            map.put("isFull", count >= slot.getMaxCapacity());
            map.put("isUnavailable", !slot.getIsAvailable());
            map.put("unavailableReason", slot.getUnavailableReason());

            if (date.isBefore(today)) {
                map.put("isAvailable", false);
                map.put("isUnavailable", true);
                map.put("unavailableReason", "日期已过");
            }

            return map;
        }).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> createAppointment(Long userId, Long timeSlotId, LocalDate date) {
        Map<String, Object> result = new HashMap<>();

        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isEmpty()) {
            result.put("success", false);
            result.put("message", "用户不存在");
            return result;
        }

        Optional<TimeSlot> optionalSlot = timeSlotRepository.findById(timeSlotId);
        if (optionalSlot.isEmpty()) {
            result.put("success", false);
            result.put("message", "时段不存在");
            return result;
        }

        User user = optionalUser.get();
        TimeSlot slot = optionalSlot.get();
        LocalDate today = LocalDate.now();

        if (date.isBefore(today)) {
            result.put("success", false);
            result.put("message", "不能预约过去的日期");
            return result;
        }

        if (date.isAfter(today.plusDays(7))) {
            result.put("success", false);
            result.put("message", "最多可提前7天预约");
            return result;
        }

        long pendingToday = appointmentRepository.countPendingByUserAndDate(userId, date);
        if (pendingToday > 0) {
            result.put("success", false);
            result.put("message", "您在该日期已有预约，每日限预约1次");
            return result;
        }

        long violations = appointmentRepository.countViolationsByUser(userId);
        if (violations >= 3) {
            result.put("success", false);
            result.put("message", "您有" + violations + "次违约记录，已被限制预约");
            return result;
        }

        long count = appointmentRepository.countByTimeSlotIdAndAppointmentDate(timeSlotId, date);
        if (count >= slot.getMaxCapacity()) {
            result.put("success", false);
            result.put("message", "该时段已满");
            return result;
        }

        if (!slot.getIsAvailable()) {
            result.put("success", false);
            result.put("message", slot.getUnavailableReason() != null ? slot.getUnavailableReason() : "该时段不可预约");
            return result;
        }

        VisitAppointment appointment = new VisitAppointment();
        appointment.setUser(user);
        appointment.setTimeSlot(slot);
        appointment.setAppointmentDate(date);
        appointment.setStatus("pending");
        appointment.setCreatedAt(LocalDateTime.now());
        appointment.setIsViolated(false);
        appointmentRepository.save(appointment);

        notificationService.createNotification(
                user.getId(),
                "预约成功",
                "您已成功预约 " + date + " " + slot.getLabel() + " 时段，请按时签到。",
                "visit_appointment"
        );

        Map<String, Object> data = new HashMap<>();
        data.put("id", appointment.getId());
        data.put("date", appointment.getAppointmentDate());
        data.put("timeSlot", slot.getLabel());
        data.put("status", appointment.getStatus());

        result.put("success", true);
        result.put("message", "预约成功");
        result.put("data", data);
        return result;
    }

    @Transactional
    public Map<String, Object> checkInAppointment(Long appointmentId) {
        Map<String, Object> result = new HashMap<>();

        Optional<VisitAppointment> optional = appointmentRepository.findById(appointmentId);
        if (optional.isEmpty()) {
            result.put("success", false);
            result.put("message", "预约记录不存在");
            return result;
        }

        VisitAppointment appointment = optional.get();
        if (!"pending".equals(appointment.getStatus())) {
            result.put("success", false);
            result.put("message", "预约状态异常");
            return result;
        }

        appointment.setStatus("checked_in");
        appointment.setCheckedInAt(LocalDateTime.now());
        appointmentRepository.save(appointment);

        result.put("success", true);
        result.put("message", "签到成功");
        return result;
    }

    @Transactional
    public Map<String, Object> cancelAppointment(Long appointmentId) {
        Map<String, Object> result = new HashMap<>();

        Optional<VisitAppointment> optional = appointmentRepository.findById(appointmentId);
        if (optional.isEmpty()) {
            result.put("success", false);
            result.put("message", "预约记录不存在");
            return result;
        }

        VisitAppointment appointment = optional.get();
        appointment.setStatus("cancelled");
        appointmentRepository.save(appointment);

        result.put("success", true);
        result.put("message", "取消成功");
        return result;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getUserAppointments(Long userId) {
        List<VisitAppointment> appointments = appointmentRepository.findByUserId(userId);
        return appointments.stream().map(this::convertToMap).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getUserPendingAppointments(Long userId) {
        List<VisitAppointment> appointments = appointmentRepository.findByUserIdAndStatus(userId, "pending");
        return appointments.stream().map(this::convertToMap).collect(Collectors.toList());
    }

    private Map<String, Object> convertToMap(VisitAppointment appointment) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", appointment.getId());
        map.put("userId", appointment.getUser().getId());
        map.put("timeSlotId", appointment.getTimeSlot().getId());
        map.put("timeSlotLabel", appointment.getTimeSlot().getLabel());
        map.put("appointmentDate", appointment.getAppointmentDate());
        map.put("status", appointment.getStatus());
        map.put("createdAt", appointment.getCreatedAt());
        map.put("checkedInAt", appointment.getCheckedInAt());
        map.put("isViolated", appointment.getIsViolated());
        map.put("violationReason", appointment.getViolationReason());
        return map;
    }
}
