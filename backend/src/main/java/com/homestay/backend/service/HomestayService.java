package com.homestay.backend.service;

import com.homestay.backend.dto.HomestayDto;
import com.homestay.backend.entity.Category;
import com.homestay.backend.entity.Homestay;
import com.homestay.backend.entity.HomestayImage;
import com.homestay.backend.entity.Profile;
import com.homestay.backend.repository.CategoryRepository;
import com.homestay.backend.repository.HomestayRepository;
import com.homestay.backend.repository.ProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class HomestayService {

    private final HomestayRepository homestayRepository;
    private final ProfileRepository profileRepository;
    private final CategoryRepository categoryRepository;

    public HomestayService(HomestayRepository homestayRepository,
                           ProfileRepository profileRepository,
                           CategoryRepository categoryRepository) {
        this.homestayRepository = homestayRepository;
        this.profileRepository = profileRepository;
        this.categoryRepository = categoryRepository;
    }

    // Lay danh sach homestay active (co tim kiem)
    @Transactional(readOnly = true)
    public List<HomestayDto> getHomestays(String search) {
        String searchParam = (search == null || search.isBlank()) ? null : search.trim();
        return homestayRepository.findActiveHomestays(searchParam)
                .stream()
                .map(HomestayDto::fromEntity)
                .toList();
    }

    // Lay homestay cua Host dang nhap
    @Transactional(readOnly = true)
    public List<HomestayDto> getMyHomestays(String hostId) {
        return homestayRepository.findByHostIdOrderByIdDesc(hostId)
                .stream()
                .map(HomestayDto::fromEntity)
                .toList();
    }

    // Tao homestay moi
    @Transactional
    public HomestayDto createHomestay(String hostId, Map<String, Object> data, String imageUrl) {
        Profile host = profileRepository.findById(hostId)
                .orElseThrow(() -> new IllegalArgumentException("Host profile not found"));

        Homestay homestay = new Homestay();
        homestay.setHost(host);
        homestay.setName((String) data.get("name"));
        homestay.setDescription((String) data.get("description"));
        homestay.setAddress((String) data.get("address"));
        homestay.setCity((String) data.get("city"));
        homestay.setPricePerNight(data.get("price_per_night") != null
                ? ((Number) data.get("price_per_night")).doubleValue() : null);
        homestay.setStatus("active");

        if (data.get("category_id") != null) {
            Category cat = categoryRepository.findById(((Number) data.get("category_id")).longValue())
                    .orElseThrow(() -> new IllegalArgumentException("Category not found"));
            homestay.setCategory(cat);
        }

        Homestay saved = homestayRepository.save(homestay);

        // Them anh
        if (imageUrl != null && !imageUrl.isBlank()) {
            HomestayImage img = new HomestayImage();
            img.setHomestay(saved);
            img.setUrl(imageUrl);
            saved.setImages(List.of(img));
            homestayRepository.save(saved);
        }

        return HomestayDto.fromEntity(saved);
    }
}
