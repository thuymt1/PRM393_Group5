-- Dữ liệu mẫu cho ứng dụng đặt homestay.
-- Chạy file này trong Supabase SQL Editor sau khi schema đã tồn tại.

-- 1) Danh mục
INSERT INTO public.categories (name, icon, slug) VALUES
  ('Phòng riêng', 'bed', 'phong-rieng'),
  ('Căn hộ', 'apartment', 'can-ho'),
  ('Nhà nguyên căn', 'home', 'nha-nguyen-can'),
  ('Villa', 'villa', 'villa')
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, icon = EXCLUDED.icon;

-- 2) Tiện nghi
INSERT INTO public.amenities (name, icon)
SELECT v.name, v.icon
FROM (VALUES
  ('Wi-Fi', 'wifi'),
  ('Máy lạnh', 'ac_unit'),
  ('Hồ bơi', 'pool'),
  ('Bếp', 'kitchen'),
  ('Chỗ đậu xe', 'local_parking')
) AS v(name, icon)
WHERE NOT EXISTS (
  SELECT 1 FROM public.amenities a WHERE lower(a.name) = lower(v.name)
);

-- 3) Homestay mẫu
INSERT INTO public.homestays
  (name, description, address, city, latitude, longitude, price_per_night,
   max_guests, num_bedrooms, num_bathrooms, category_id, status)
SELECT v.name, v.description, v.address, v.city, v.latitude, v.longitude,
       v.price, v.guests, v.bedrooms, v.bathrooms, c.id, 'active'
FROM (VALUES
  ('Mây Đà Lạt House', 'Không gian ấm cúng giữa đồi thông, thích hợp cho cặp đôi và gia đình nhỏ.', '15 Đặng Thùy Trâm', 'Đà Lạt', 11.9404, 108.4583, 650000, 4, 2, 1, 'Nhà nguyên căn'),
  ('An Nhiên Apartment', 'Căn hộ hiện đại gần trung tâm, có bếp và ban công nhìn thành phố.', '82 Nguyễn Văn Trỗi', 'Đà Nẵng', 16.0678, 108.2208, 800000, 4, 2, 2, 'Căn hộ'),
  ('Lá Thông Villa', 'Villa riêng tư có hồ bơi, sân vườn rộng và khu BBQ ngoài trời.', '28 Trần Quốc Toản', 'Đà Lạt', 11.9465, 108.4419, 2200000, 8, 4, 3, 'Villa'),
  ('Nhà Gỗ Ven Hồ', 'Nhà gỗ yên tĩnh bên hồ, phù hợp nhóm bạn muốn nghỉ dưỡng cuối tuần.', 'Thôn Tà Nung', 'Đà Lạt', 11.8842, 108.3321, 1200000, 6, 3, 2, 'Nhà nguyên căn'),
  ('Phòng Nắng Mai', 'Phòng riêng sáng thoáng, sạch sẽ, gần các điểm tham quan nổi tiếng.', '10 Võ Thị Sáu', 'Hội An', 15.8801, 108.3380, 450000, 2, 1, 1, 'Phòng riêng')
) AS v(name, description, address, city, latitude, longitude, price, guests, bedrooms, bathrooms, category)
JOIN public.categories c ON c.name = v.category
WHERE NOT EXISTS (SELECT 1 FROM public.homestays h WHERE h.name = v.name AND h.city = v.city);

-- 4) Ảnh homestay mẫu (ảnh Unsplash công khai)
INSERT INTO public.homestay_images (homestay_id, url, is_primary)
SELECT h.id, v.url, true
FROM (VALUES
  ('Mây Đà Lạt House', 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=1200'),
  ('An Nhiên Apartment', 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1200'),
  ('Lá Thông Villa', 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=1200'),
  ('Nhà Gỗ Ven Hồ', 'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?w=1200'),
  ('Phòng Nắng Mai', 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=1200')
) AS v(name, url)
JOIN public.homestays h ON h.name = v.name
WHERE NOT EXISTS (SELECT 1 FROM public.homestay_images i WHERE i.homestay_id = h.id AND i.url = v.url);

-- 5) Gắn tiện nghi cho các homestay mẫu
INSERT INTO public.homestay_amenities_link (homestay_id, amenity_id)
SELECT h.id, a.id
FROM public.homestays h
JOIN public.amenities a ON a.name IN ('Wi-Fi', 'Máy lạnh', 'Bếp', 'Chỗ đậu xe')
WHERE h.name IN ('Mây Đà Lạt House', 'An Nhiên Apartment', 'Nhà Gỗ Ven Hồ', 'Phòng Nắng Mai')
ON CONFLICT DO NOTHING;

INSERT INTO public.homestay_amenities_link (homestay_id, amenity_id)
SELECT h.id, a.id
FROM public.homestays h
JOIN public.amenities a ON a.name IN ('Wi-Fi', 'Máy lạnh', 'Hồ bơi', 'Bếp', 'Chỗ đậu xe')
WHERE h.name = 'Lá Thông Villa'
ON CONFLICT DO NOTHING;

-- 6) Bài viết mẫu
INSERT INTO public.articles (title, content, thumbnail_url, status)
SELECT v.title, v.content, v.thumbnail_url, 'published'
FROM (VALUES
  ('5 trải nghiệm không thể bỏ lỡ ở Đà Lạt', 'Khám phá đồi thông, chợ đêm, quán cà phê và những cung đường đẹp nhất Đà Lạt.', 'https://images.unsplash.com/photo-1555921015-5536c6f7f3f7?w=1200'),
  ('Cẩm nang du lịch Hội An cuối tuần', 'Lịch trình gợi ý để tận hưởng phố cổ, ẩm thực địa phương và biển An Bàng.', 'https://images.unsplash.com/photo-1528181304800-259b08848526?w=1200'),
  ('Kinh nghiệm chọn homestay cho gia đình', 'Những tiêu chí nên kiểm tra: vị trí, số phòng ngủ, bếp, chỗ đậu xe và chính sách huỷ.', 'https://images.unsplash.com/photo-1560185008-b033106af5c3?w=1200')
) AS v(title, content, thumbnail_url)
WHERE NOT EXISTS (SELECT 1 FROM public.articles a WHERE a.title = v.title);

-- 7) Feedback/đánh giá mẫu. customer_id để NULL vì đây là dữ liệu demo.
INSERT INTO public.reviews (homestay_id, customer_id, rating, comment)
SELECT h.id, NULL, v.rating, v.comment
FROM (VALUES
  ('Mây Đà Lạt House', 5, 'Phòng sạch, không gian rất chill và chủ nhà thân thiện.'),
  ('An Nhiên Apartment', 4, 'Căn hộ đúng hình, vị trí thuận tiện, sẽ quay lại.'),
  ('Lá Thông Villa', 5, 'Villa rộng và hồ bơi sạch, phù hợp nhóm gia đình.'),
  ('Nhà Gỗ Ven Hồ', 4, 'Không khí yên tĩnh, buổi sáng nhìn hồ rất đẹp.'),
  ('Phòng Nắng Mai', 5, 'Phòng nhỏ nhưng đầy đủ tiện nghi và rất sạch sẽ.')
) AS v(name, rating, comment)
JOIN public.homestays h ON h.name = v.name
WHERE NOT EXISTS (
  SELECT 1 FROM public.reviews r WHERE r.homestay_id = h.id AND r.comment = v.comment
);

-- 8) Đặt phòng mẫu. customer_id để NULL vì chưa gắn với tài khoản cụ thể.
INSERT INTO public.bookings
  (customer_id, homestay_id, check_in, check_out, total_guests,
   total_price, status, payment_status, notes)
SELECT NULL, h.id, v.check_in::date, v.check_out::date, v.guests,
       v.total_price, v.status, v.payment_status, v.notes
FROM (VALUES
  ('Mây Đà Lạt House', '2026-08-12', '2026-08-14', 2, 1300000, 'confirmed', 'paid', 'Khách muốn nhận phòng sau 14:00'),
  ('An Nhiên Apartment', '2026-08-20', '2026-08-23', 3, 2400000, 'pending', 'unpaid', 'Cần chuẩn bị thêm một chăn đôi'),
  ('Lá Thông Villa', '2026-09-05', '2026-09-07', 6, 4400000, 'confirmed', 'paid', 'Nhóm gia đình có trẻ nhỏ')
) AS v(name, check_in, check_out, guests, total_price, status, payment_status, notes)
JOIN public.homestays h ON h.name = v.name;

-- 9) Lịch sử đặt phòng và feedback để test bằng tài khoản cụ thể.
-- Nếu email chưa có trong public.profiles, các câu lệnh này sẽ không thêm dòng.
INSERT INTO public.bookings
  (customer_id, homestay_id, check_in, check_out, total_guests,
   total_price, status, payment_status, notes)
SELECT p.id, h.id, v.check_in::date, v.check_out::date, v.guests,
       v.total_price, 'confirmed', 'paid', 'Dữ liệu test cho lịch sử đặt phòng'
FROM (VALUES
  ('Mây Đà Lạt House', '2026-06-10', '2026-06-12', 2, 1300000),
  ('An Nhiên Apartment', '2026-06-20', '2026-06-23', 3, 2400000),
  ('Phòng Nắng Mai', '2026-07-01', '2026-07-03', 2, 900000)
) AS v(name, check_in, check_out, guests, total_price)
JOIN public.profiles p ON lower(p.email) = lower('maithithuy0205@gmail.com')
JOIN public.homestays h ON h.name = v.name
WHERE NOT EXISTS (
    SELECT 1 FROM public.bookings b
    WHERE b.customer_id = p.id AND b.homestay_id = h.id
      AND b.check_in = v.check_in::date
  );

INSERT INTO public.reviews (homestay_id, customer_id, rating, comment)
SELECT h.id, p.id, v.rating, v.comment
FROM (VALUES
  ('Mây Đà Lạt House', 5, 'Không gian rất đẹp, sạch sẽ và chủ nhà hỗ trợ nhiệt tình.'),
  ('An Nhiên Apartment', 4, 'Vị trí thuận tiện, căn hộ đúng như mô tả.'),
  ('Phòng Nắng Mai', 5, 'Phòng thoải mái, giá hợp lý, mình rất hài lòng.')
) AS v(name, rating, comment)
JOIN public.profiles p ON lower(p.email) = lower('maithithuy0205@gmail.com')
JOIN public.homestays h ON h.name = v.name
WHERE NOT EXISTS (
    SELECT 1 FROM public.reviews r
    WHERE r.customer_id = p.id AND r.homestay_id = h.id
      AND r.comment = v.comment
  );
