package com.homestay.backend.controller;

import com.homestay.backend.dto.BookingDto;
import com.homestay.backend.service.BookingService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    private final BookingService bookingService;

    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    // GET /api/bookings/my   (Customer xem lich su dat cua minh)
    @GetMapping("/my")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<List<BookingDto>> getMyBookings(
            @AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(bookingService.getMyBookings(userId));
    }

    // GET /api/bookings/host-requests   (Host xem cac don den homestay cua minh)
    @GetMapping("/host-requests")
    @PreAuthorize("hasRole('HOST')")
    public ResponseEntity<List<BookingDto>> getHostRequests(
            @AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(bookingService.getHostBookingRequests(userId));
    }

    // POST /api/bookings   (Customer dat phong)
    @PostMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<BookingDto> createBooking(
            @AuthenticationPrincipal String userId,
            @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(bookingService.createBooking(userId, body));
    }

    // PATCH /api/bookings/{id}/status   (Host duyet hoac huy don)
    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('HOST')")
    public ResponseEntity<BookingDto> updateStatus(
            @PathVariable Long id,
            @AuthenticationPrincipal String userId,
            @RequestBody Map<String, String> body) {
        String newStatus = body.get("status");
        return ResponseEntity.ok(bookingService.updateStatus(id, userId, newStatus));
    }

    // GET /api/bookings/homestay/{homestayId}/booked-dates   (public — hien thi lich biet)
    @GetMapping("/homestay/{homestayId}/booked-dates")
    public ResponseEntity<List<Map<String, String>>> getBookedDates(
            @PathVariable Long homestayId) {
        return ResponseEntity.ok(bookingService.getBookedDates(homestayId));
    }
}
