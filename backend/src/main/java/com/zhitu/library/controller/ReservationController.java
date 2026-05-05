package com.zhitu.library.controller;

import com.zhitu.library.entity.Reservation;
import com.zhitu.library.service.ReservationService;
import com.zhitu.library.service.VisitAppointmentService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "*")
public class ReservationController {

    private final ReservationService reservationService;
    private final VisitAppointmentService visitAppointmentService;

    public ReservationController(ReservationService reservationService,
                                 VisitAppointmentService visitAppointmentService) {
        this.reservationService = reservationService;
        this.visitAppointmentService = visitAppointmentService;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> reserveBook(
            @RequestParam Long userId,
            @RequestParam Long bookId) {
        return ResponseEntity.ok(reservationService.reserveBook(userId, bookId));
    }

    @PostMapping("/{reservationId}/checkin")
    public ResponseEntity<Map<String, Object>> checkInReservation(@PathVariable Long reservationId) {
        return ResponseEntity.ok(reservationService.checkInReservation(reservationId));
    }

    @PostMapping("/{reservationId}/cancel")
    public ResponseEntity<Map<String, Object>> cancelReservation(@PathVariable Long reservationId) {
        return ResponseEntity.ok(reservationService.cancelReservation(reservationId));
    }

    @GetMapping("/timeslots")
    public ResponseEntity<Map<String, Object>> getTimeSlots(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("data", visitAppointmentService.getTimeSlotsForDate(date));
        return ResponseEntity.ok(result);
    }

    @Transactional(readOnly = true)
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Map<String, Object>>> getUserReservations(@PathVariable Long userId) {
        List<Reservation> reservations = reservationService.getUserReservations(userId);
        List<Map<String, Object>> result = reservations.stream().map(r -> {
            Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", r.getId());
            map.put("userId", r.getUser() != null ? r.getUser().getId() : null);
            map.put("bookId", r.getBook() != null ? r.getBook().getId() : null);
            map.put("bookTitle", r.getBook() != null ? r.getBook().getTitle() : null);
            map.put("bookCoverUrl", r.getBook() != null ? r.getBook().getCoverUrl() : null);
            map.put("bookCoverAsset", r.getBook() != null ? r.getBook().getCoverAsset() : null);
            map.put("bookAuthor", r.getBook() != null ? r.getBook().getAuthor() : null);
            map.put("reservationDate", r.getReservationDate());
            map.put("status", r.getStatus());
            map.put("checkedInAt", r.getCheckedInAt());
            map.put("createdAt", r.getCreatedAt());
            map.put("isViolated", r.getIsViolated());
            map.put("violationReason", r.getViolationReason());
            return map;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @Transactional(readOnly = true)
    @GetMapping("/user/{userId}/pending")
    public ResponseEntity<List<Map<String, Object>>> getUserPendingReservations(@PathVariable Long userId) {
        List<Reservation> reservations = reservationService.getUserPendingReservations(userId);
        List<Map<String, Object>> result = reservations.stream().map(r -> {
            Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", r.getId());
            map.put("userId", r.getUser() != null ? r.getUser().getId() : null);
            map.put("bookId", r.getBook() != null ? r.getBook().getId() : null);
            map.put("bookTitle", r.getBook() != null ? r.getBook().getTitle() : null);
            map.put("bookCoverUrl", r.getBook() != null ? r.getBook().getCoverUrl() : null);
            map.put("bookCoverAsset", r.getBook() != null ? r.getBook().getCoverAsset() : null);
            map.put("bookAuthor", r.getBook() != null ? r.getBook().getAuthor() : null);
            map.put("reservationDate", r.getReservationDate());
            map.put("status", r.getStatus());
            map.put("checkedInAt", r.getCheckedInAt());
            map.put("createdAt", r.getCreatedAt());
            map.put("isViolated", r.getIsViolated());
            map.put("violationReason", r.getViolationReason());
            return map;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }
}
