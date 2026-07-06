package com.homestay.backend.dto;

import com.homestay.backend.entity.Homestay;
import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * DTO tra ve cho client. Khong expose truc tiep Entity JPA.
 */
@Data
@Builder
public class HomestayDto {
    private Long id;
    private String name;
    private String description;
    private String address;
    private String city;
    private Double pricePerNight;
    private Double rating;
    private String status;
    private String category;
    private List<String> images;

    public static HomestayDto fromEntity(Homestay h) {
        return HomestayDto.builder()
                .id(h.getId())
                .name(h.getName())
                .description(h.getDescription())
                .address(h.getAddress())
                .city(h.getCity())
                .pricePerNight(h.getPricePerNight())
                .rating(h.getRating())
                .status(h.getStatus())
                .category(h.getCategory() != null ? h.getCategory().getName() : null)
                .images(h.getImages() != null
                        ? h.getImages().stream().map(img -> img.getUrl()).toList()
                        : List.of())
                .build();
    }
}
