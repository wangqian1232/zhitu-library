package com.zhitu.library.repository;

import com.zhitu.library.entity.SharedBook;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SharedBookRepository extends JpaRepository<SharedBook, Long> {

    List<SharedBook> findBySharerId(Long sharerId);

    List<SharedBook> findByStatus(String status);

    List<SharedBook> findByBorrowerId(Long borrowerId);

    @Query("SELECT sb FROM SharedBook sb WHERE sb.status = 'available' ORDER BY sb.createdAt DESC")
    List<SharedBook> findAvailableSharedBooks();

    @Query("SELECT sb FROM SharedBook sb WHERE sb.sharer.id = :sharerId AND sb.status = :status")
    List<SharedBook> findBySharerIdAndStatus(@Param("sharerId") Long sharerId, @Param("status") String status);
}
