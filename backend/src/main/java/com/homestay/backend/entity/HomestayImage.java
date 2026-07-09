package com.homestay.backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "homestay_images")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HomestayImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "homestay_id", nullable = false)
    private Homestay homestay;

    @Column(name = "url", nullable = false)
    private String url;

    @Column(name = "is_primary")
    private Boolean isPrimary;
}
