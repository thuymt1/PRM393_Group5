package com.homestay.backend.repository;

import com.homestay.backend.entity.Homestay;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface HomestayRepository extends JpaRepository<Homestay, Long> {

    // Tim kiem homestay active - ho tro ca search text va filter theo category
    @Query(value = """
        SELECT DISTINCT h.* FROM homestays h
        WHERE h.status = 'active'
        AND (:categoryId IS NULL OR h.category_id = :categoryId)
        AND (
            :search IS NULL
            OR h.name ILIKE CONCAT('%', :search, '%')
            OR h.address ILIKE CONCAT('%', :search, '%')
            OR h.city ILIKE CONCAT('%', :search, '%')
        )
        ORDER BY h.id DESC
    """, nativeQuery = true)
    List<Homestay> findActiveHomestays(
            @Param("search") String search,
            @Param("categoryId") Long categoryId);

    // Lay homestay theo host
    @Query(value = """
        SELECT DISTINCT h.* FROM homestays h
        WHERE h.host_id = :hostId
        ORDER BY h.id DESC
    """, nativeQuery = true)
    List<Homestay> findByHostIdOrderByIdDesc(@Param("hostId") UUID hostId);

    // Average rating cua mot homestay (tinh tu bang reviews)
    @Query(value = """
        SELECT COALESCE(AVG(r.rating), 0) FROM reviews r WHERE r.homestay_id = :homestayId
    """, nativeQuery = true)
    Double getAverageRating(@Param("homestayId") Long homestayId);
}
