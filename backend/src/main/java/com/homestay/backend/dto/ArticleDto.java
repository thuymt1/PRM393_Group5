package com.homestay.backend.dto;

import com.homestay.backend.entity.Article;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class ArticleDto {
    private Long id;
    private String title;
    private String content;
    private String authorId;
    private String authorName;
    private String status;
    private LocalDateTime createdAt;

    public static ArticleDto fromEntity(Article a) {
        return ArticleDto.builder()
                .id(a.getId())
                .title(a.getTitle())
                .content(a.getContent())
                .authorId(a.getAuthor() != null ? a.getAuthor().getId() : null)
                .authorName(a.getAuthor() != null ? a.getAuthor().getFullName() : null)
                .status(a.getStatus())
                .createdAt(a.getCreatedAt())
                .build();
    }
}
