package com.homestay.backend.dto;

import com.homestay.backend.entity.Booking;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class BookingDto {
    private Long id;
    private Long homestayId;
    private String homestayName;
    private String customerId;
    private String customerName;
    private LocalDate checkIn;
    private LocalDate checkOut;
    private Double totalPrice;
    private String status;
    private LocalDateTime createdAt;

    public static BookingDto fromEntity(Booking b) {
        return BookingDto.builder()
                .id(b.getId())
                .homestayId(b.getHomestay() != null ? b.getHomestay().getId() : null)
                .homestayName(b.getHomestay() != null ? b.getHomestay().getName() : null)
                .customerId(b.getCustomer() != null && b.getCustomer().getId() != null ? b.getCustomer().getId().toString() : null)
                .customerName(b.getCustomer() != null ? b.getCustomer().getFullName() : null)
                .checkIn(b.getCheckIn())
                .checkOut(b.getCheckOut())
                .totalPrice(b.getTotalPrice())
                .status(b.getStatus())
                .createdAt(b.getCreatedAt())
                .build();
    }
}
