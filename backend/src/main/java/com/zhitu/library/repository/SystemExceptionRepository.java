package com.zhitu.library.repository;

import com.zhitu.library.entity.SystemException;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface SystemExceptionRepository extends JpaRepository<SystemException, Long> {

    List<SystemException> findByStatusOrderByOccurredAtDesc(String status);

    List<SystemException> findByTypeOrderByOccurredAtDesc(String type);

    List<SystemException> findByStatusAndTypeOrderByOccurredAtDesc(String status, String type);

    @Query("SELECT e FROM SystemException e WHERE e.occurredAt BETWEEN :start AND :end ORDER BY e.occurredAt DESC")
    List<SystemException> findByDateRange(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("SELECT e.type, COUNT(e) FROM SystemException e WHERE e.occurredAt BETWEEN :start AND :end GROUP BY e.type")
    List<Object[]> countByTypeAndDateRange(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("SELECT e.severity, COUNT(e) FROM SystemException e WHERE e.occurredAt BETWEEN :start AND :end GROUP BY e.severity")
    List<Object[]> countBySeverityAndDateRange(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("SELECT e.status, COUNT(e) FROM SystemException e GROUP BY e.status")
    List<Object[]> countByStatus();

    @Query("SELECT DATE(e.occurredAt), COUNT(e) FROM SystemException e WHERE e.occurredAt BETWEEN :start AND :end GROUP BY DATE(e.occurredAt) ORDER BY DATE(e.occurredAt)")
    List<Object[]> countByDate(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
}
