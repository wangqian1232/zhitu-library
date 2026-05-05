package com.zhitu.library.config;

import com.zhitu.library.entity.TimeSlot;
import com.zhitu.library.repository.TimeSlotRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;

import java.time.LocalTime;

@Configuration
public class TimeSlotInitializer {

    private final TimeSlotRepository timeSlotRepository;

    public TimeSlotInitializer(TimeSlotRepository timeSlotRepository) {
        this.timeSlotRepository = timeSlotRepository;
    }

    @PostConstruct
    public void initTimeSlots() {
        if (timeSlotRepository.count() > 0) {
            return;
        }

        createTimeSlot("上午 08:00-10:00", LocalTime.of(8, 0), LocalTime.of(10, 0), 20);
        createTimeSlot("上午 10:00-12:00", LocalTime.of(10, 0), LocalTime.of(12, 0), 20);
        createTimeSlot("下午 14:00-16:00", LocalTime.of(14, 0), LocalTime.of(16, 0), 20);
        createTimeSlot("下午 16:00-18:00", LocalTime.of(16, 0), LocalTime.of(18, 0), 20);
        createTimeSlot("晚上 18:00-20:00", LocalTime.of(18, 0), LocalTime.of(20, 0), 20);
        createTimeSlot("晚上 20:00-22:00", LocalTime.of(20, 0), LocalTime.of(22, 0), 20);
    }

    private void createTimeSlot(String label, LocalTime start, LocalTime end, int capacity) {
        TimeSlot slot = new TimeSlot();
        slot.setLabel(label);
        slot.setStartTime(start);
        slot.setEndTime(end);
        slot.setMaxCapacity(capacity);
        slot.setCurrentReservations(0);
        slot.setIsAvailable(true);
        timeSlotRepository.save(slot);
    }
}
