package com.zhitu.library.repository;

import com.zhitu.library.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    List<Reservation> findByUserId(Long userId);

    List<Reservation> findByUserIdAndStatus(Long userId, String status);

    List<Reservation> findByBookIdAndStatus(Long bookId, String status);

    @Query("SELECT r FROM Reservation r WHERE r.book.id = :bookId AND r.status = 'pending'")
    List<Reservation> findPendingByBookId(@Param("bookId") Long bookId);

    @Query("SELECT COUNT(r) FROM Reservation r WHERE r.reservationDate = :date AND r.status = 'pending'")
    long countByDateAndPending(@Param("date") LocalDateTime date);

    long countByUserIdAndStatus(Long userId, String status);
}
