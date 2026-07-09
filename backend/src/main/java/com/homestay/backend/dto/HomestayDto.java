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
    private Long categoryId;
    private String name;
    private String description;
    private String address;
    private String city;
    private Double latitude;
    private Double longitude;
    private Double pricePerNight;
    private Integer maxGuests;
    private Integer numBedrooms;
    private Integer numBathrooms;
    private Double rating;          // average rating tu reviews
    private String status;
    private String category;        // ten category
    private List<String> images;
    
    // Host info
    private String hostId;
    private String hostName;
    private String hostAvatar;

    public static HomestayDto fromEntity(Homestay h) {
        return HomestayDto.builder()
                .id(h.getId())
                .categoryId(h.getCategory() != null ? h.getCategory().getId() : null)
                .name(h.getName())
                .description(h.getDescription())
                .address(h.getAddress())
                .city(h.getCity())
                .latitude(h.getLatitude())
                .longitude(h.getLongitude())
                .pricePerNight(h.getPricePerNight())
                .maxGuests(h.getMaxGuests())
                .numBedrooms(h.getNumBedrooms())
                .numBathrooms(h.getNumBathrooms())
                .rating(h.getRating())   // duoc set tu service sau khi query AVG
                .status(h.getStatus())
                .category(h.getCategory() != null ? h.getCategory().getName() : null)
                .images(h.getImages() != null
                        ? h.getImages().stream().map(img -> img.getUrl()).toList()
                        : List.of())
                .hostId(h.getHost() != null ? h.getHost().getId().toString() : null)
                .hostName(h.getHost() != null ? h.getHost().getFullName() : null)
                .hostAvatar(h.getHost() != null ? h.getHost().getAvatarUrl() : null)
                .build();
    }
}
