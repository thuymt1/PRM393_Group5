package com.homestay.backend.service;

import com.homestay.backend.dto.ArticleDto;
import com.homestay.backend.entity.Article;
import com.homestay.backend.entity.Profile;
import com.homestay.backend.repository.ArticleRepository;
import com.homestay.backend.repository.ProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ArticleService {

    private final ArticleRepository articleRepository;
    private final ProfileRepository profileRepository;

    public ArticleService(ArticleRepository articleRepository,
                          ProfileRepository profileRepository) {
        this.articleRepository = articleRepository;
        this.profileRepository = profileRepository;
    }

    @Transactional(readOnly = true)
    public List<ArticleDto> getAllArticles() {
        return articleRepository.findAllByOrderByCreatedAtDesc()
                .stream().map(ArticleDto::fromEntity).toList();
    }

    @Transactional(readOnly = true)
    public List<ArticleDto> getMyArticles(String authorId) {
        return articleRepository.findByAuthorIdOrderByCreatedAtDesc(authorId)
                .stream().map(ArticleDto::fromEntity).toList();
    }

    @Transactional
    public ArticleDto createArticle(String authorId, String title, String content) {
        Profile author = profileRepository.findById(authorId)
                .orElseThrow(() -> new IllegalArgumentException("Author profile not found"));

        Article article = new Article();
        article.setTitle(title);
        article.setContent(content);
        article.setAuthor(author);
        article.setStatus("published");
        article.setCreatedAt(LocalDateTime.now());

        return ArticleDto.fromEntity(articleRepository.save(article));
    }
}
