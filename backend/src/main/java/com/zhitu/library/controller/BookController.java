package com.zhitu.library.controller;

import com.zhitu.library.entity.Book;
import com.zhitu.library.service.BookService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*")
public class BookController {

    private static final Logger log = LoggerFactory.getLogger(BookController.class);

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping
    public ResponseEntity<List<Book>> getAllBooks() {
        return ResponseEntity.ok(bookService.getAllBooks());
    }

    @GetMapping("/top")
    public ResponseEntity<List<Book>> getTopBooks(@RequestParam(defaultValue = "5") int limit) {
        return ResponseEntity.ok(bookService.getTopBooks(limit));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getBookById(@PathVariable Long id) {
        return bookService.getBookById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<List<Book>> getBooksByCategory(@PathVariable String category) {
        return ResponseEntity.ok(bookService.getBooksByCategory(category));
    }

    @GetMapping("/search")
    public ResponseEntity<List<Book>> searchBooks(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String author) {
        if (title != null && !title.isEmpty()) {
            return ResponseEntity.ok(bookService.searchBooksByTitle(title));
        }
        if (author != null && !author.isEmpty()) {
            return ResponseEntity.ok(bookService.searchBooksByAuthor(author));
        }
        return ResponseEntity.ok(bookService.getAllBooks());
    }

    @GetMapping("/available")
    public ResponseEntity<List<Book>> getAvailableBooks() {
        return ResponseEntity.ok(bookService.getAvailableBooks());
    }

    @GetMapping("/shared")
    public ResponseEntity<List<Book>> getSharedBooks() {
        return ResponseEntity.ok(bookService.getSharedBooks());
    }

    @PostMapping("/{id}/borrow")
    public ResponseEntity<Map<String, Object>> borrowBook(@PathVariable Long id) {
        return ResponseEntity.ok(bookService.borrowBook(id));
    }

    @PostMapping("/{id}/reserve")
    public ResponseEntity<Map<String, Object>> reserveBook(@PathVariable Long id) {
        return ResponseEntity.ok(bookService.reserveBook(id));
    }

    @PostMapping
    public ResponseEntity<Book> createBook(@RequestBody Book book) {
        return ResponseEntity.ok(bookService.saveBook(book));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Book> updateBook(@PathVariable Long id, @RequestBody Book book) {
        return ResponseEntity.ok(bookService.updateBook(id, book));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBook(@PathVariable Long id) {
        bookService.deleteBook(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/batch")
    public ResponseEntity<Map<String, Object>> batchImportBooks(@RequestBody List<Map<String, Object>> books) {
        int successCount = 0;
        int failCount = 0;
        
        for (Map<String, Object> bookData : books) {
            try {
                Book book = new Book();
                
                if (bookData.get("title") != null) book.setTitle(bookData.get("title").toString());
                if (bookData.get("author") != null) book.setAuthor(bookData.get("author").toString());
                if (bookData.get("publisher") != null) book.setPublisher(bookData.get("publisher").toString());
                if (bookData.get("isbn") != null) book.setIsbn(bookData.get("isbn").toString());
                if (bookData.get("description") != null) book.setDescription(bookData.get("description").toString());
                if (bookData.get("coverUrl") != null) book.setCoverUrl(bookData.get("coverUrl").toString());
                if (bookData.get("coverAsset") != null) book.setCoverAsset(bookData.get("coverAsset").toString());
                if (bookData.get("category") != null) book.setCategory(bookData.get("category").toString());
                if (bookData.get("majorCategory") != null) book.setMajorCategory(bookData.get("majorCategory").toString());
                
                if (bookData.get("totalCopies") != null) {
                    book.setTotalCopies(Integer.parseInt(bookData.get("totalCopies").toString()));
                }
                if (bookData.get("availableCopies") != null) {
                    book.setAvailableCopies(Integer.parseInt(bookData.get("availableCopies").toString()));
                }
                if (bookData.get("borrowCount") != null) {
                    book.setBorrowCount(Integer.parseInt(bookData.get("borrowCount").toString()));
                }
                if (bookData.get("status") != null) {
                    book.setStatus(Integer.parseInt(bookData.get("status").toString()));
                }
                
                bookService.saveBook(book);
                successCount++;
            } catch (Exception e) {
                log.error("导入图书失败: {}", e.getMessage(), e);
                failCount++;
            }
        }
        
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("successCount", successCount);
        result.put("failCount", failCount);
        result.put("totalCount", books.size());
        result.put("message", "导入完成：成功 " + successCount + " 本，失败 " + failCount + " 本");
        
        return ResponseEntity.ok(result);
    }

    @GetMapping("/categories")
    public ResponseEntity<Map<String, Object>> getCategories() {
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("categories", bookService.getAllCategories());
        result.put("majorCategories", bookService.getAllMajorCategories());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/major-category/{majorCategory}")
    public ResponseEntity<List<Book>> getBooksByMajorCategory(@PathVariable String majorCategory) {
        return ResponseEntity.ok(bookService.getBooksByMajorCategory(majorCategory));
    }

    @GetMapping("/with-covers")
    public ResponseEntity<List<Book>> getBooksWithCovers() {
        return ResponseEntity.ok(bookService.getBooksWithCoverAssets());
    }

    @GetMapping("/recommended")
    public ResponseEntity<List<Book>> getRecommendedBooks(
            @RequestParam(required = false) String interests) {
        List<String> interestList = interests != null ? 
                java.util.Arrays.asList(interests.split(",")) : 
                java.util.Collections.emptyList();
        return ResponseEntity.ok(bookService.getRecommendedBooks(interestList));
    }

    @GetMapping("/novels-with-covers")
    public ResponseEntity<List<Book>> getNovelsWithCovers(
            @RequestParam(defaultValue = "0") int batchIndex) {
        return ResponseEntity.ok(bookService.getNovelsWithCovers(batchIndex));
    }
}
