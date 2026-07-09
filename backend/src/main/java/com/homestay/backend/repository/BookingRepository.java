package com.homestay.backend.repository;

import com.homestay.backend.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {

    // Lay booking cua khach hang
    List<Booking> findByCustomerIdOrderByCreatedAtDesc(java.util.UUID customerId);

    // Lay booking den homestay cua host (theo list homestayId)
    List<Booking> findByHomestayIdInOrderByCreatedAtDesc(List<Long> homestayIds);

    // Kiem tra trung lich: tim cac booking co status hoat dong va ngay bi overlap
    @Query("""
        SELECT b FROM Booking b
        WHERE b.homestay.id = :homestayId
        AND b.status NOT IN ('cancelled', 'rejected', 'cancel_pending', 'refunded')
        AND b.checkIn < :checkOut
        AND b.checkOut > :checkIn
    """)
    List<Booking> findOverlappingBookings(
        @Param("homestayId") Long homestayId,
        @Param("checkIn") LocalDate checkIn,
        @Param("checkOut") LocalDate checkOut
    );

    // Lay tat ca booking cua homestay (khong bao gom cancelled/rejected) de hien thi lich biet
    @Query("""
        SELECT b FROM Booking b
        WHERE b.homestay.id = :homestayId
        AND b.status NOT IN ('cancelled', 'rejected', 'cancel_pending', 'refunded')
    """)
    List<Booking> findActiveBookingsByHomestay(@Param("homestayId") Long homestayId);
}
