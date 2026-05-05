package com.zhitu.library.repository;

import com.zhitu.library.entity.Book;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BookRepository extends JpaRepository<Book, Long> {

    List<Book> findByCategory(String category);

    List<Book> findByTitleContainingIgnoreCase(String title);

    List<Book> findByAuthorContainingIgnoreCase(String author);

    @Query("SELECT b FROM Book b ORDER BY b.borrowCount DESC")
    List<Book> findTopBooks(Pageable pageable);

    @Query("SELECT b FROM Book b WHERE b.status = 0")
    List<Book> findAvailableBooks();

    @Query("SELECT b FROM Book b WHERE b.sharedBy IS NOT NULL")
    List<Book> findSharedBooks();

    @Query("SELECT b FROM Book b WHERE b.status = :status")
    List<Book> findByStatus(@Param("status") Integer status);

    @Query("SELECT b FROM Book b WHERE b.category = :category AND b.status = 0")
    List<Book> findByCategoryAndAvailable(@Param("category") String category);

    @Query("SELECT b FROM Book b WHERE b.majorCategory = :majorCategory")
    List<Book> findByMajorCategory(@Param("majorCategory") String majorCategory);

    @Query("SELECT DISTINCT b.category FROM Book b")
    List<String> findAllCategories();

    @Query("SELECT DISTINCT b.majorCategory FROM Book b")
    List<String> findAllMajorCategories();

    @Query("SELECT b FROM Book b WHERE b.coverAsset IS NOT NULL ORDER BY b.borrowCount DESC")
    List<Book> findBooksWithCoverAssets();
}
