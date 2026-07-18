-- Chạy một lần trong Supabase SQL Editor để lưu lý do và ảnh QR hoàn tiền.
alter table public.bookings add column if not exists cancellation_reason text;
alter table public.bookings add column if not exists refund_qr_url text;
alter table public.bookings add column if not exists cancellation_requested_at timestamptz;
