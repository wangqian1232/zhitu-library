package com.zhitu.library.repository;

import com.zhitu.library.entity.BorrowRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import org.springframework.data.domain.Pageable;

public interface BorrowRecordRepository extends JpaRepository<BorrowRecord, Long> {

    List<BorrowRecord> findByUserId(Long userId);

    @Query("SELECT br FROM BorrowRecord br JOIN FETCH br.book JOIN FETCH br.user ORDER BY br.borrowDate DESC")
    List<BorrowRecord> findRecentBorrowRecords(Pageable pageable);

    @Query("SELECT br FROM BorrowRecord br JOIN FETCH br.book WHERE br.user.id = :userId")
    List<BorrowRecord> findByUserIdWithBook(@Param("userId") Long userId);

    List<BorrowRecord> findByUserIdAndStatus(Long userId, String status);

    @Query("SELECT br FROM BorrowRecord br WHERE br.user.id = :userId AND br.status = 'active' AND br.dueDate < CURRENT_TIMESTAMP")
    List<BorrowRecord> findOverdueByUserId(@Param("userId") Long userId);

    @Query("SELECT br FROM BorrowRecord br WHERE br.status = 'active' AND br.dueDate < CURRENT_TIMESTAMP")
    List<BorrowRecord> findAllOverdue();

    long countByUserIdAndStatus(Long userId, String status);

    @Query("SELECT COALESCE(SUM(br.fine), 0) FROM BorrowRecord br WHERE br.user.id = :userId AND br.fine IS NOT NULL AND br.fine > 0 AND br.finePaid = false")
    double getTotalUnpaidFine(@Param("userId") Long userId);
}
