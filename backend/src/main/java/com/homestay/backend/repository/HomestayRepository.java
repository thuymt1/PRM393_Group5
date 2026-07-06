package com.homestay.backend.repository;

import com.homestay.backend.entity.Homestay;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HomestayRepository extends JpaRepository<Homestay, Long> {

    // Lay danh sach homestay dang active, co the tim kiem theo ten/dia chi/thanh pho
    @Query("""
        SELECT h FROM Homestay h
        WHERE h.status = 'active'
        AND (:search IS NULL OR LOWER(h.name) LIKE LOWER(CONCAT('%', :search, '%'))
             OR LOWER(h.address) LIKE LOWER(CONCAT('%', :search, '%'))
             OR LOWER(h.city) LIKE LOWER(CONCAT('%', :search, '%')))
        ORDER BY h.id DESC
    """)
    List<Homestay> findActiveHomestays(@Param("search") String search);

    // Lay danh sach homestay theo host
    List<Homestay> findByHostIdOrderByIdDesc(String hostId);
}
