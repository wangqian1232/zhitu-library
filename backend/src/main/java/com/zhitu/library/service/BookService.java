package com.zhitu.library.service;

import com.zhitu.library.entity.Book;
import com.zhitu.library.repository.BookRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class BookService {

    private final BookRepository bookRepository;

    public BookService(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    public List<Book> getAllBooks() {
        return bookRepository.findAll();
    }

    public List<Book> getTopBooks(int limit) {
        return bookRepository.findTopBooks(PageRequest.of(0, limit));
    }

    public Optional<Book> getBookById(Long id) {
        return bookRepository.findById(id);
    }

    public List<Book> getBooksByCategory(String category) {
        return bookRepository.findByCategory(category);
    }

    public List<Book> searchBooksByTitle(String title) {
        return bookRepository.findByTitleContainingIgnoreCase(title);
    }

    public List<Book> searchBooksByAuthor(String author) {
        return bookRepository.findByAuthorContainingIgnoreCase(author);
    }

    public List<Book> getAvailableBooks() {
        return bookRepository.findAvailableBooks();
    }

    public List<Book> getSharedBooks() {
        return bookRepository.findSharedBooks();
    }

    public Map<String, Object> borrowBook(Long id) {
        Map<String, Object> result = new HashMap<>();
        Optional<Book> optionalBook = bookRepository.findById(id);

        if (optionalBook.isEmpty()) {
            result.put("success", false);
            result.put("message", "图书不存在");
            return result;
        }

        Book book = optionalBook.get();

        if (book.getStatus() != 0) {
            result.put("success", false);
            result.put("message", "图书当前不可借阅");
            return result;
        }

        if (book.getAvailableCopies() <= 0) {
            result.put("success", false);
            result.put("message", "图书已全部借出");
            return result;
        }

        book.setAvailableCopies(book.getAvailableCopies() - 1);
        if (book.getAvailableCopies() == 0) {
            book.setStatus(1);
        }
        book.setBorrowCount(book.getBorrowCount() + 1);
        bookRepository.save(book);

        result.put("success", true);
        result.put("message", "借阅成功");
        result.put("book", book);
        return result;
    }

    public Map<String, Object> reserveBook(Long id) {
        Map<String, Object> result = new HashMap<>();
        Optional<Book> optionalBook = bookRepository.findById(id);

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

        book.setStatus(2);
        bookRepository.save(book);

        result.put("success", true);
        result.put("message", "预约成功");
        result.put("book", book);
        return result;
    }

    public Book saveBook(Book book) {
        return bookRepository.save(book);
    }

    public void deleteBook(Long id) {
        bookRepository.deleteById(id);
    }

    public Book updateBook(Long id, Book bookDetails) {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("图书不存在"));

        book.setTitle(bookDetails.getTitle());
        book.setAuthor(bookDetails.getAuthor());
        book.setCoverUrl(bookDetails.getCoverUrl());
        book.setCategory(bookDetails.getCategory());
        book.setIsbn(bookDetails.getIsbn());
        book.setPublisher(bookDetails.getPublisher());
        book.setDescription(bookDetails.getDescription());
        book.setTotalCopies(bookDetails.getTotalCopies());
        book.setAvailableCopies(bookDetails.getAvailableCopies());
        book.setStatus(bookDetails.getStatus());

        return bookRepository.save(book);
    }

    public List<String> getAllCategories() {
        return bookRepository.findAllCategories();
    }

    public List<String> getAllMajorCategories() {
        return bookRepository.findAllMajorCategories();
    }

    public List<Book> getBooksByMajorCategory(String majorCategory) {
        return bookRepository.findByMajorCategory(majorCategory);
    }

    public List<Book> getBooksWithCoverAssets() {
        return bookRepository.findBooksWithCoverAssets();
    }

    public List<Book> getRecommendedBooks(List<String> interests) {
        if (interests.isEmpty()) {
            List<Book> sorted = bookRepository.findAll();
            sorted.sort((a, b) -> b.getBorrowCount().compareTo(a.getBorrowCount()));
            return sorted.subList(0, Math.min(10, sorted.size()));
        }
        List<Book> matched = bookRepository.findAll().stream()
                .filter(b -> interests.contains(b.getCategory()))
                .toList();
        matched.sort((a, b) -> b.getBorrowCount().compareTo(a.getBorrowCount()));
        if (matched.size() >= 10) {
            return matched.subList(0, 10);
        }
        List<Book> remaining = bookRepository.findAll().stream()
                .filter(b -> !interests.contains(b.getCategory()))
                .toList();
        remaining.sort((a, b) -> b.getBorrowCount().compareTo(a.getBorrowCount()));
        List<Book> result = new java.util.ArrayList<>(matched);
        result.addAll(remaining.subList(0, Math.min(10 - matched.size(), remaining.size())));
        return result;
    }

    public List<Book> getNovelsWithCovers(int batchIndex) {
        List<Book> novels = bookRepository.findAll().stream()
                .filter(b -> "小说".equals(b.getCategory()) && b.getCoverAsset() != null)
                .toList();
        novels.sort((a, b) -> b.getBorrowCount().compareTo(a.getBorrowCount()));

        int pageSize = 9;
        int start = (batchIndex * pageSize) % novels.size();
        int end = start + pageSize;

        if (end <= novels.size()) {
            return novels.subList(start, end);
        } else {
            List<Book> firstPart = novels.subList(start, novels.size());
            List<Book> secondPart = novels.subList(0, end - novels.size());
            List<Book> result = new java.util.ArrayList<>(firstPart);
            result.addAll(secondPart);
            return result;
        }
    }
}
