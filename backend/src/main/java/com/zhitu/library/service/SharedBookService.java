package com.zhitu.library.service;

import com.zhitu.library.entity.SharedBook;
import com.zhitu.library.entity.User;
import com.zhitu.library.repository.SharedBookRepository;
import com.zhitu.library.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class SharedBookService {

    private final SharedBookRepository sharedBookRepository;
    private final UserRepository userRepository;

    public SharedBookService(SharedBookRepository sharedBookRepository,
                             UserRepository userRepository) {
        this.sharedBookRepository = sharedBookRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Map<String, Object> publishSharedBook(Long userId, Map<String, String> bookData) {
        Map<String, Object> result = new HashMap<>();

        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isEmpty()) {
            result.put("success", false);
            result.put("message", "用户不存在");
            return result;
        }

        User user = optionalUser.get();

        SharedBook sharedBook = new SharedBook();
        sharedBook.setSharer(user);
        sharedBook.setSharerName(user.getUsername());
        sharedBook.setTitle(bookData.get("title"));
        sharedBook.setAuthor(bookData.get("author"));
        sharedBook.setPublisher(bookData.get("publisher"));
        sharedBook.setIsbn(bookData.get("isbn"));
        sharedBook.setCoverUrl(bookData.get("coverUrl"));
        sharedBook.setCoverAsset(bookData.get("coverAsset"));
        sharedBook.setConditionLevel(bookData.get("conditionLevel"));
        sharedBook.setShareType(bookData.get("shareType"));
        sharedBook.setRemark(bookData.get("remark"));
        sharedBook.setShelfNumber(bookData.get("shelfNumber"));
        sharedBook.setSharerGrade(bookData.getOrDefault("sharerGrade", ""));
        sharedBook.setSharerDepartment(bookData.getOrDefault("sharerDepartment", ""));
        sharedBook.setStatus("pending");
        sharedBook.setCreatedAt(LocalDateTime.now());

        sharedBookRepository.save(sharedBook);

        result.put("success", true);
        result.put("message", "共享图书发布成功");
        result.put("sharedBook", sharedBook);
        return result;
    }

    public List<SharedBook> getAvailableSharedBooks() {
        return sharedBookRepository.findAvailableSharedBooks();
    }

    public List<SharedBook> getAllSharedBooks() {
        return sharedBookRepository.findAll();
    }

    public Optional<SharedBook> getSharedBookById(Long id) {
        return sharedBookRepository.findById(id);
    }

    public List<SharedBook> getUserSharedBooks(Long userId) {
        return sharedBookRepository.findBySharerId(userId);
    }

    @Transactional
    public Map<String, Object> borrowSharedBook(Long sharedBookId, Long borrowerId) {
        Map<String, Object> result = new HashMap<>();

        Optional<SharedBook> optionalBook = sharedBookRepository.findById(sharedBookId);
        if (optionalBook.isEmpty()) {
            result.put("success", false);
            result.put("message", "共享图书不存在");
            return result;
        }

        SharedBook sharedBook = optionalBook.get();
        if (!"available".equals(sharedBook.getStatus())) {
            result.put("success", false);
            result.put("message", "该图书当前不可借阅");
            return result;
        }

        Optional<User> optionalBorrower = userRepository.findById(borrowerId);
        if (optionalBorrower.isEmpty()) {
            result.put("success", false);
            result.put("message", "借阅用户不存在");
            return result;
        }

        sharedBook.setBorrower(optionalBorrower.get());
        sharedBook.setStatus("borrowed");
        sharedBook.setBorrowedAt(LocalDateTime.now());
        sharedBook.setDueDate(LocalDateTime.now().plusDays(30));
        sharedBookRepository.save(sharedBook);

        result.put("success", true);
        result.put("message", "借阅成功");
        result.put("sharedBook", sharedBook);
        return result;
    }

    @Transactional
    public Map<String, Object> returnSharedBook(Long sharedBookId) {
        Map<String, Object> result = new HashMap<>();

        Optional<SharedBook> optionalBook = sharedBookRepository.findById(sharedBookId);
        if (optionalBook.isEmpty()) {
            result.put("success", false);
            result.put("message", "共享图书不存在");
            return result;
        }

        SharedBook sharedBook = optionalBook.get();
        if (!"borrowed".equals(sharedBook.getStatus())) {
            result.put("success", false);
            result.put("message", "该图书当前未借出");
            return result;
        }

        if ("temporary".equals(sharedBook.getShareType())) {
            sharedBook.setStatus("available");
        } else {
            sharedBook.setStatus("available");
        }

        sharedBook.setBorrower(null);
        sharedBook.setBorrowedAt(null);
        sharedBook.setDueDate(null);
        sharedBookRepository.save(sharedBook);

        result.put("success", true);
        result.put("message", "归还成功");
        return result;
    }

    @Transactional
    public Map<String, Object> approveSharedBook(Long sharedBookId) {
        Map<String, Object> result = new HashMap<>();

        Optional<SharedBook> optionalBook = sharedBookRepository.findById(sharedBookId);
        if (optionalBook.isEmpty()) {
            result.put("success", false);
            result.put("message", "共享图书不存在");
            return result;
        }

        SharedBook sharedBook = optionalBook.get();
        if (!"pending".equals(sharedBook.getStatus())) {
            result.put("success", false);
            result.put("message", "该图书当前状态不允许审核");
            return result;
        }

        sharedBook.setStatus("available");
        sharedBookRepository.save(sharedBook);

        result.put("success", true);
        result.put("message", "审核通过");
        result.put("sharedBook", sharedBook);
        return result;
    }

    @Transactional
    public Map<String, Object> rejectSharedBook(Long sharedBookId, String reason) {
        Map<String, Object> result = new HashMap<>();

        Optional<SharedBook> optionalBook = sharedBookRepository.findById(sharedBookId);
        if (optionalBook.isEmpty()) {
            result.put("success", false);
            result.put("message", "共享图书不存在");
            return result;
        }

        SharedBook sharedBook = optionalBook.get();
        if (!"pending".equals(sharedBook.getStatus())) {
            result.put("success", false);
            result.put("message", "该图书当前状态不允许审核");
            return result;
        }

        sharedBook.setStatus("rejected");
        sharedBook.setRemark(reason);
        sharedBookRepository.save(sharedBook);

        result.put("success", true);
        result.put("message", "已拒绝");
        result.put("sharedBook", sharedBook);
        return result;
    }
}
