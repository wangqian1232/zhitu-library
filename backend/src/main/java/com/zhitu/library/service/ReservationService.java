package com.zhitu.library.service;

import com.zhitu.library.entity.*;
import com.zhitu.library.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final BookRepository bookRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public ReservationService(ReservationRepository reservationRepository,
                              BookRepository bookRepository,
                              UserRepository userRepository,
                              NotificationService notificationService) {
        this.reservationRepository = reservationRepository;
        this.bookRepository = bookRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    @Transactional
    public Map<String, Object> reserveBook(Long userId, Long bookId) {
        Map<String, Object> result = new HashMap<>();

        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isEmpty()) {
            result.put("success", false);
            result.put("message", "用户不存在");
            return result;
        }

        Optional<Book> optionalBook = bookRepository.findById(bookId);
        if (optionalBook.isEmpty()) {
            result.put("success", false);
            result.put("message", "图书不存在");
            return result;
        }

        Book book = optionalBook.get();
        if (book.getStatus() == 0) {
            result.put("success", false);
            result.put("message", "图书当前可借，无需预约");
            return result;
        }

        User user = optionalUser.get();

        List<Reservation> existingReservations = reservationRepository.findByUserIdAndStatus(userId, "pending");
        for (Reservation existing : existingReservations) {
            if (existing.getBook() != null && existing.getBook().getId().equals(bookId)) {
                result.put("success", false);
                result.put("message", "您已预约过此图书，请勿重复预约");
                return result;
            }
        }

        Reservation reservation = new Reservation();
        reservation.setUser(user);
        reservation.setBook(book);
        reservation.setReservationDate(LocalDateTime.now().plusDays(1));
        reservation.setStatus("pending");
        reservation.setCreatedAt(LocalDateTime.now());
        reservation.setIsViolated(false);
        reservationRepository.save(reservation);

        book.setStatus(2);
        bookRepository.save(book);

        notificationService.createNotification(
                user.getId(),
                "预约成功",
                "您已成功预约《" + book.getTitle() + "》，请在图书到馆后及时前往借阅。",
                "reservation"
        );

        result.put("success", true);
        result.put("message", "预约成功");
        result.put("reservation", reservation);
        return result;
    }

    @Transactional
    public Map<String, Object> checkInReservation(Long reservationId) {
        Map<String, Object> result = new HashMap<>();

        Optional<Reservation> optionalReservation = reservationRepository.findById(reservationId);
        if (optionalReservation.isEmpty()) {
            result.put("success", false);
            result.put("message", "预约记录不存在");
            return result;
        }

        Reservation reservation = optionalReservation.get();
        if (!"pending".equals(reservation.getStatus())) {
            result.put("success", false);
            result.put("message", "预约状态异常");
            return result;
        }

        reservation.setStatus("checked_in");
        reservation.setCheckedInAt(LocalDateTime.now());
        reservationRepository.save(reservation);

        result.put("success", true);
        result.put("message", "签到成功");
        result.put("reservation", reservation);
        return result;
    }

    @Transactional
    public Map<String, Object> cancelReservation(Long reservationId) {
        Map<String, Object> result = new HashMap<>();

        Optional<Reservation> optionalReservation = reservationRepository.findById(reservationId);
        if (optionalReservation.isEmpty()) {
            result.put("success", false);
            result.put("message", "预约记录不存在");
            return result;
        }

        Reservation reservation = optionalReservation.get();
        Book book = reservation.getBook();
        
        reservation.setStatus("cancelled");
        reservationRepository.save(reservation);

        if (book != null) {
            List<Reservation> pendingReservations = reservationRepository.findByBookIdAndStatus(book.getId(), "pending");
            
            if (pendingReservations.isEmpty()) {
                if (book.getAvailableCopies() > 0) {
                    book.setStatus(0);
                } else {
                    book.setStatus(1);
                }
                bookRepository.save(book);
            }
        }

        result.put("success", true);
        result.put("message", "取消成功");
        return result;
    }

    @Transactional(readOnly = true)
    public List<Reservation> getUserReservations(Long userId) {
        return reservationRepository.findByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<Reservation> getUserPendingReservations(Long userId) {
        return reservationRepository.findByUserIdAndStatus(userId, "pending");
    }
}
