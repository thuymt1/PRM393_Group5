package com.homestay.backend.controller;

import com.homestay.backend.dto.HomestayDto;
import com.homestay.backend.repository.HomestayImageRepository;
import com.homestay.backend.repository.HomestayRepository;
import com.homestay.backend.entity.Homestay;
import com.homestay.backend.entity.HomestayImage;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Favorites — luu vao Supabase bang favorites qua Supabase client tren Flutter.
 * Backend chi cung cap endpoint de lay danh sach homestay theo id list.
 */
@RestController
@RequestMapping("/api/homestays")
public class FavoriteController {

    private final HomestayRepository homestayRepository;
    private final HomestayImageRepository homestayImageRepository;

    public FavoriteController(HomestayRepository homestayRepository,
                               HomestayImageRepository homestayImageRepository) {
        this.homestayRepository = homestayRepository;
        this.homestayImageRepository = homestayImageRepository;
    }

    /**
     * POST /api/homestays/by-ids
     * Body: { "ids": [1, 2, 3] }
     * Lay thong tin nhieu homestay theo danh sach ID (dung cho tab Yeu thich)
     */
    @PostMapping("/by-ids")
    public ResponseEntity<List<HomestayDto>> getHomestaysByIds(
            @RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        List<Integer> rawIds = (List<Integer>) body.get("ids");
        if (rawIds == null || rawIds.isEmpty()) return ResponseEntity.ok(List.of());

        List<Long> ids = rawIds.stream().map(Integer::longValue).toList();
        List<HomestayDto> result = ids.stream()
                .map(homestayRepository::findById)
                .filter(opt -> opt.isPresent())
                .map(opt -> {
                    Homestay h = opt.get();
                    List<HomestayImage> images = homestayImageRepository.findByHomestayId(h.getId());
                    h.setImages(images);
                    return HomestayDto.fromEntity(h);
                })
                .toList();
        return ResponseEntity.ok(result);
    }
}
