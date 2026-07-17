-- Bật quyền feedback và thêm dữ liệu test. Chạy trong Supabase SQL Editor.
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "reviews_are_publicly_readable" ON public.reviews;
CREATE POLICY "reviews_are_publicly_readable"
ON public.reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "authenticated_users_can_create_own_reviews" ON public.reviews;
CREATE POLICY "authenticated_users_can_create_own_reviews"
ON public.reviews FOR INSERT TO authenticated
WITH CHECK (customer_id = auth.uid());

DROP POLICY IF EXISTS "users_can_update_own_reviews" ON public.reviews;
CREATE POLICY "users_can_update_own_reviews"
ON public.reviews FOR UPDATE TO authenticated
USING (customer_id = auth.uid())
WITH CHECK (customer_id = auth.uid());

-- Feedback mẫu. customer_id NULL chỉ dùng cho dữ liệu demo từ SQL Editor.
INSERT INTO public.reviews (homestay_id, customer_id, rating, comment)
SELECT h.id, NULL, v.rating, v.comment
FROM (VALUES
  ('Mây Đà Lạt House', 5, 'Không gian đẹp, phòng sạch và rất yên tĩnh.'),
  ('Mây Đà Lạt House', 4, 'Vị trí hơi xa trung tâm nhưng dịch vụ rất tốt.'),
  ('Mây Đà Lạt House', 5, 'Chủ nhà nhiệt tình, mình sẽ quay lại.'),
  ('An Nhiên Apartment', 4, 'Căn hộ sạch sẽ và đầy đủ tiện nghi.'),
  ('An Nhiên Apartment', 3, 'Phòng ổn nhưng cách âm chưa tốt.'),
  ('An Nhiên Apartment', 5, 'Vị trí thuận tiện, giá cả hợp lý.'),
  ('Lá Thông Villa', 5, 'Villa rộng, hồ bơi sạch và sân vườn rất đẹp.'),
  ('Lá Thông Villa', 5, 'Phù hợp cho gia đình và nhóm đông người.'),
  ('Nhà Gỗ Ven Hồ', 4, 'Khung cảnh đẹp và không khí trong lành.'),
  ('Phòng Nắng Mai', 4, 'Phòng nhỏ nhưng sạch và gần phố cổ.'),
  ('Phòng Nắng Mai', 5, 'Nhân viên thân thiện, trải nghiệm rất tốt.')
) AS v(name, rating, comment)
JOIN public.homestays h ON h.name = v.name
WHERE NOT EXISTS (
  SELECT 1 FROM public.reviews r
  WHERE r.homestay_id = h.id AND r.comment = v.comment
);

-- Kiểm tra điểm trung bình của từng homestay.
SELECT h.id, h.name,
       COUNT(r.id) AS total_feedback,
       ROUND(AVG(r.rating)::numeric, 1) AS average_rating
FROM public.homestays h
LEFT JOIN public.reviews r ON r.homestay_id = h.id
GROUP BY h.id, h.name
ORDER BY average_rating DESC NULLS LAST, h.name;
