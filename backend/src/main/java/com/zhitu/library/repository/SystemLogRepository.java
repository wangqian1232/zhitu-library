package com.zhitu.library.repository;

import com.zhitu.library.entity.SystemLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface SystemLogRepository extends JpaRepository<SystemLog, Long> {

    Page<SystemLog> findByLevelOrderByCreatedAtDesc(String level, Pageable pageable);

    Page<SystemLog> findByModuleOrderByCreatedAtDesc(String module, Pageable pageable);

    Page<SystemLog> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    Page<SystemLog> findAllByOrderByCreatedAtDesc(Pageable pageable);

    @Query("SELECT l FROM SystemLog l WHERE l.createdAt BETWEEN :start AND :end ORDER BY l.createdAt DESC")
    Page<SystemLog> findByDateRange(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end, Pageable pageable);

    @Query("SELECT l.level, COUNT(l) FROM SystemLog l GROUP BY l.level")
    List<Object[]> countByLevel();

    @Query("SELECT l.module, COUNT(l) FROM SystemLog l GROUP BY l.module")
    List<Object[]> countByModule();

    @Query("SELECT DATE(l.createdAt), COUNT(l) FROM SystemLog l WHERE l.createdAt BETWEEN :start AND :end GROUP BY DATE(l.createdAt) ORDER BY DATE(l.createdAt)")
    List<Object[]> countByDate(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
}
