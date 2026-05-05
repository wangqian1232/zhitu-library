-- 初始化时间段数据
-- 插入图书馆可用的预约时间段

INSERT INTO time_slots (label, start_time, end_time, max_capacity, current_reservations, is_available, unavailable_reason) VALUES
('上午 08:00-10:00', '08:00:00', '10:00:00', 20, 0, true, NULL),
('上午 10:00-12:00', '10:00:00', '12:00:00', 20, 0, true, NULL),
('下午 14:00-16:00', '14:00:00', '16:00:00', 20, 0, true, NULL),
('下午 16:00-18:00', '16:00:00', '18:00:00', 20, 0, true, NULL),
('晚上 19:00-21:00', '19:00:00', '21:00:00', 20, 0, true, NULL);
