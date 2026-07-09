package com.homestay.backend.service;

import com.homestay.backend.dto.BookingDto;
import com.homestay.backend.entity.Booking;
import com.homestay.backend.entity.Homestay;
import com.homestay.backend.entity.Profile;
import com.homestay.backend.repository.BookingRepository;
import com.homestay.backend.repository.HomestayRepository;
import com.homestay.backend.repository.ProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;
    private final HomestayRepository homestayRepository;
    private final ProfileRepository profileRepository;

    public BookingService(BookingRepository bookingRepository,
                          HomestayRepository homestayRepository,
                          ProfileRepository profileRepository) {
        this.bookingRepository = bookingRepository;
        this.homestayRepository = homestayRepository;
        this.profileRepository = profileRepository;
    }

    // Lay booking cua khach hang
    @Transactional(readOnly = true)
    public List<BookingDto> getMyBookings(String customerId) {
        return bookingRepository.findByCustomerIdOrderByCreatedAtDesc(java.util.UUID.fromString(customerId))
                .stream().map(BookingDto::fromEntity).toList();
    }

    // Lay booking den homestay cua host
    @Transactional(readOnly = true)
    public List<BookingDto> getHostBookingRequests(String hostId) {
        List<Long> homestayIds = homestayRepository.findByHostIdOrderByIdDesc(java.util.UUID.fromString(hostId))
                .stream().map(Homestay::getId).toList();

        if (homestayIds.isEmpty()) return List.of();

        return bookingRepository.findByHomestayIdInOrderByCreatedAtDesc(homestayIds)
                .stream().map(BookingDto::fromEntity).toList();
    }

    /**
     * Tao booking moi.
     * Dung @Transactional + check overlap de dam bao khong bi dat trung lich
     * Neu co overlap, throw Exception (Spring se rollback transaction)
     */
    @Transactional
    public BookingDto createBooking(String customerId, Map<String, Object> data) {
        Long homestayId = Long.parseLong(data.get("homestay_id").toString());
        LocalDate checkIn = LocalDate.parse(data.get("check_in").toString());
        LocalDate checkOut = LocalDate.parse(data.get("check_out").toString());
        Double totalPrice = ((Number) data.get("total_price")).doubleValue();

        // Kiem tra trung lich (overlap) trong cung transaction
        List<Booking> conflicts = bookingRepository.findOverlappingBookings(homestayId, checkIn, checkOut);
        if (!conflicts.isEmpty()) {
            throw new IllegalStateException("Homestay đã có người đặt trong khoảng thời gian này. Vui lòng chọn ngày khác.");
        }

        Homestay homestay = homestayRepository.findById(homestayId)
                .orElseThrow(() -> new IllegalArgumentException("Homestay not found"));
        Profile customer = profileRepository.findById(java.util.UUID.fromString(customerId))
                .orElseThrow(() -> new IllegalArgumentException("Customer profile not found"));

        Booking booking = new Booking();
        booking.setHomestay(homestay);
        booking.setCustomer(customer);
        booking.setCheckIn(checkIn);
        booking.setCheckOut(checkOut);
        booking.setTotalPrice(totalPrice);
        booking.setStatus("pending");
        booking.setCreatedAt(LocalDateTime.now());

        return BookingDto.fromEntity(bookingRepository.save(booking));
    }

    // Cap nhat trang thai booking (Host duyet/huy)
    @Transactional
    public BookingDto updateStatus(Long bookingId, String hostId, String newStatus) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));

        // Kiem tra quyen: host phai la chu cua homestay do
        if (!booking.getHomestay().getHost().getId().equals(java.util.UUID.fromString(hostId))) {
            throw new SecurityException("Bạn không có quyền cập nhật booking này.");
        }

        booking.setStatus(newStatus);
        return BookingDto.fromEntity(bookingRepository.save(booking));
    }

    // Lay danh sach ngay da dat (de hien thi tren calendar)
    @Transactional(readOnly = true)
    public List<Map<String, String>> getBookedDates(Long homestayId) {
        return bookingRepository.findActiveBookingsByHomestay(homestayId)
                .stream()
                .map(b -> Map.of(
                        "check_in", b.getCheckIn().toString(),
                        "check_out", b.getCheckOut().toString()
                ))
                .toList();
    }
}
