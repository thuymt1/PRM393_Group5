package com.homestay.backend.service;

import com.homestay.backend.dto.HomestayDto;
import com.homestay.backend.entity.Category;
import com.homestay.backend.entity.Homestay;
import com.homestay.backend.entity.HomestayImage;
import com.homestay.backend.entity.Profile;
import com.homestay.backend.repository.CategoryRepository;
import com.homestay.backend.repository.HomestayImageRepository;
import com.homestay.backend.repository.HomestayRepository;
import com.homestay.backend.repository.ProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class HomestayService {

    private final HomestayRepository homestayRepository;
    private final ProfileRepository profileRepository;
    private final CategoryRepository categoryRepository;
    private final HomestayImageRepository homestayImageRepository;

    public HomestayService(HomestayRepository homestayRepository,
                           ProfileRepository profileRepository,
                           CategoryRepository categoryRepository,
                           HomestayImageRepository homestayImageRepository) {
        this.homestayRepository = homestayRepository;
        this.profileRepository = profileRepository;
        this.categoryRepository = categoryRepository;
        this.homestayImageRepository = homestayImageRepository;
    }

    // Lay danh sach homestay active (ho tro search + filter theo category)
    @Transactional(readOnly = true)
    public List<HomestayDto> getHomestays(String search, Long categoryId) {
        String searchParam = (search == null || search.isBlank()) ? null : search.trim();
        List<Homestay> homestays = homestayRepository.findActiveHomestays(searchParam, categoryId);
        return homestays.stream()
                .map(h -> {
                    List<HomestayImage> images = homestayImageRepository.findByHomestayId(h.getId());
                    h.setImages(images);
                    // Lay average rating
                    Double avgRating = homestayRepository.getAverageRating(h.getId());
                    h.setRating(avgRating != null ? avgRating : 0.0);
                    return HomestayDto.fromEntity(h);
                })
                .toList();
    }

    // Lay chi tiet mot homestay theo ID
    @Transactional(readOnly = true)
    public Optional<HomestayDto> getHomestayById(Long id) {
        return homestayRepository.findById(id).map(h -> {
            List<HomestayImage> images = homestayImageRepository.findByHomestayId(h.getId());
            h.setImages(images);
            Double avgRating = homestayRepository.getAverageRating(h.getId());
            h.setRating(avgRating != null ? avgRating : 0.0);
            return HomestayDto.fromEntity(h);
        });
    }

    // Lay homestay cua Host dang nhap
    @Transactional(readOnly = true)
    public List<HomestayDto> getMyHomestays(String hostId) {
        List<Homestay> homestays = homestayRepository.findByHostIdOrderByIdDesc(UUID.fromString(hostId));
        return homestays.stream()
                .map(h -> {
                    List<HomestayImage> images = homestayImageRepository.findByHomestayId(h.getId());
                    h.setImages(images);
                    Double avgRating = homestayRepository.getAverageRating(h.getId());
                    h.setRating(avgRating != null ? avgRating : 0.0);
                    return HomestayDto.fromEntity(h);
                })
                .toList();
    }

    // Tao homestay moi
    @Transactional
    public HomestayDto createHomestay(String hostId, Map<String, Object> data, String imageUrl) {
        Profile host = profileRepository.findById(UUID.fromString(hostId))
                .orElseThrow(() -> new IllegalArgumentException("Host profile not found"));

        Homestay homestay = new Homestay();
        homestay.setHost(host);
        homestay.setName((String) data.get("name"));
        homestay.setDescription((String) data.get("description"));
        homestay.setAddress((String) data.get("address"));
        homestay.setCity((String) data.get("city"));
        homestay.setPricePerNight(data.get("price_per_night") != null
                ? ((Number) data.get("price_per_night")).doubleValue() : null);
        if (data.get("max_guests") != null)
            homestay.setMaxGuests(((Number) data.get("max_guests")).intValue());
        if (data.get("num_bedrooms") != null)
            homestay.setNumBedrooms(((Number) data.get("num_bedrooms")).intValue());
        if (data.get("num_bathrooms") != null)
            homestay.setNumBathrooms(((Number) data.get("num_bathrooms")).intValue());
        if (data.get("latitude") != null)
            homestay.setLatitude(((Number) data.get("latitude")).doubleValue());
        if (data.get("longitude") != null)
            homestay.setLongitude(((Number) data.get("longitude")).doubleValue());
        homestay.setStatus("active");
        homestay.setCreatedAt(java.time.LocalDateTime.now());

        if (data.get("category_id") != null) {
            Category cat = categoryRepository.findById(((Number) data.get("category_id")).longValue())
                    .orElseThrow(() -> new IllegalArgumentException("Category not found"));
            homestay.setCategory(cat);
        }

        Homestay saved = homestayRepository.save(homestay);

        if (imageUrl != null && !imageUrl.isBlank()) {
            HomestayImage img = new HomestayImage();
            img.setHomestay(saved);
            img.setUrl(imageUrl);
            img.setIsPrimary(true);
            homestayImageRepository.save(img);
            saved.setImages(List.of(img));
        }

        return HomestayDto.fromEntity(saved);
    }
}
