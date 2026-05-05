package com.zhitu.library.repository;

import com.zhitu.library.entity.VisitAppointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface VisitAppointmentRepository extends JpaRepository<VisitAppointment, Long> {

    List<VisitAppointment> findByUserId(Long userId);

    List<VisitAppointment> findByUserIdAndStatus(Long userId, String status);

    List<VisitAppointment> findByAppointmentDate(LocalDate date);

    List<VisitAppointment> findByTimeSlotIdAndAppointmentDate(Long timeSlotId, LocalDate date);

    long countByTimeSlotIdAndAppointmentDate(Long timeSlotId, LocalDate date);

    @Query("SELECT COUNT(a) FROM VisitAppointment a WHERE a.user.id = :userId AND a.appointmentDate = :date AND a.status = 'pending'")
    long countPendingByUserAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);

    @Query("SELECT COUNT(a) FROM VisitAppointment a WHERE a.user.id = :userId AND a.isViolated = true")
    long countViolationsByUser(@Param("userId") Long userId);
}
