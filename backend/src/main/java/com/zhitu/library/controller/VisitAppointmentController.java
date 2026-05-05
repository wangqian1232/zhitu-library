package com.zhitu.library.controller;

import com.zhitu.library.service.VisitAppointmentService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/visit-appointments")
public class VisitAppointmentController {

    private final VisitAppointmentService visitAppointmentService;

    public VisitAppointmentController(VisitAppointmentService visitAppointmentService) {
        this.visitAppointmentService = visitAppointmentService;
    }

    @GetMapping("/timeslots")
    public ResponseEntity<Map<String, Object>> getTimeSlots(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("data", visitAppointmentService.getTimeSlotsForDate(date));
        return ResponseEntity.ok(result);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createAppointment(
            @RequestParam Long userId,
            @RequestParam Long timeSlotId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(visitAppointmentService.createAppointment(userId, timeSlotId, date));
    }

    @PostMapping("/{id}/check-in")
    public ResponseEntity<Map<String, Object>> checkIn(@PathVariable Long id) {
        return ResponseEntity.ok(visitAppointmentService.checkInAppointment(id));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<Map<String, Object>> cancel(@PathVariable Long id) {
        return ResponseEntity.ok(visitAppointmentService.cancelAppointment(id));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getUserAppointments(@PathVariable Long userId) {
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("data", visitAppointmentService.getUserAppointments(userId));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/user/{userId}/pending")
    public ResponseEntity<Map<String, Object>> getUserPendingAppointments(@PathVariable Long userId) {
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("data", visitAppointmentService.getUserPendingAppointments(userId));
        return ResponseEntity.ok(result);
    }
}
