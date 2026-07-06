package com.homestay.backend.controller;

import com.homestay.backend.dto.ArticleDto;
import com.homestay.backend.service.ArticleService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/articles")
public class ArticleController {

    private final ArticleService articleService;

    public ArticleController(ArticleService articleService) {
        this.articleService = articleService;
    }

    // GET /api/articles   (public)
    @GetMapping
    public ResponseEntity<List<ArticleDto>> getAllArticles() {
        return ResponseEntity.ok(articleService.getAllArticles());
    }

    // GET /api/articles/mine   (Author)
    @GetMapping("/mine")
    @PreAuthorize("hasRole('AUTHOR')")
    public ResponseEntity<List<ArticleDto>> getMyArticles(
            @AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(articleService.getMyArticles(userId));
    }

    // POST /api/articles   (Author)
    @PostMapping
    @PreAuthorize("hasRole('AUTHOR')")
    public ResponseEntity<ArticleDto> createArticle(
            @AuthenticationPrincipal String userId,
            @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(articleService.createArticle(userId, body.get("title"), body.get("content")));
    }
}
