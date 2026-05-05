package com.zhitu.library.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "system_settings")
public class SystemSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "borrow_days", nullable = false)
    private Integer borrowDays = 30;

    @Column(name = "renew_count", nullable = false)
    private Integer renewCount = 1;

    @Column(name = "overdue_fine", nullable = false)
    private Double overdueFine = 0.2;

    @Column(name = "max_borrow_count", nullable = false)
    private Integer maxBorrowCount = 5;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getBorrowDays() {
        return borrowDays;
    }

    public void setBorrowDays(Integer borrowDays) {
        this.borrowDays = borrowDays;
    }

    public Integer getRenewCount() {
        return renewCount;
    }

    public void setRenewCount(Integer renewCount) {
        this.renewCount = renewCount;
    }

    public Double getOverdueFine() {
        return overdueFine;
    }

    public void setOverdueFine(Double overdueFine) {
        this.overdueFine = overdueFine;
    }

    public Integer getMaxBorrowCount() {
        return maxBorrowCount;
    }

    public void setMaxBorrowCount(Integer maxBorrowCount) {
        this.maxBorrowCount = maxBorrowCount;
    }
}
