package com.homestay.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "homestays")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Homestay {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    private String address;
    private String city;
    
    private Double latitude;
    private Double longitude;

    @Column(name = "price_per_night")
    private Double pricePerNight;

    @Column(name = "max_guests")
    private Integer maxGuests;

    @Column(name = "num_bedrooms")
    private Integer numBedrooms;

    @Column(name = "num_bathrooms")
    private Integer numBathrooms;
    
    @Transient
    private Double rating;
    private String status;

    @Column(name = "created_at")
    private java.time.LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "host_id")
    private Profile host;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @OneToMany(mappedBy = "homestay", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<HomestayImage> images;

    @ManyToMany
    @JoinTable(
        name = "homestay_amenities_link",
        joinColumns = @JoinColumn(name = "homestay_id"),
        inverseJoinColumns = @JoinColumn(name = "amenity_id")
    )
    @com.fasterxml.jackson.annotation.JsonIgnore
    private List<Amenity> amenities;
}
