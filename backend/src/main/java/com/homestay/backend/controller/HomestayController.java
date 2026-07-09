package com.homestay.backend.controller;

import com.homestay.backend.dto.HomestayDto;
import com.homestay.backend.entity.Category;
import com.homestay.backend.repository.CategoryRepository;
import com.homestay.backend.service.HomestayService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HomestayController {

    private final HomestayService homestayService;
    private final CategoryRepository categoryRepository;

    public HomestayController(HomestayService homestayService,
                               CategoryRepository categoryRepository) {
        this.homestayService = homestayService;
        this.categoryRepository = categoryRepository;
    }

    // GET /api/homestays?search=dalat&categoryId=1  (public)
    @GetMapping("/homestays")
    public ResponseEntity<List<HomestayDto>> getHomestays(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long categoryId) {
        return ResponseEntity.ok(homestayService.getHomestays(search, categoryId));
    }

    // GET /api/homestays/{id}  (public)
    @GetMapping("/homestays/{id}")
    public ResponseEntity<HomestayDto> getHomestayById(@PathVariable Long id) {
        return homestayService.getHomestayById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // GET /api/homestays/mine   (chi Host)
    @GetMapping("/homestays/mine")
    @PreAuthorize("hasRole('HOST')")
    public ResponseEntity<List<HomestayDto>> getMyHomestays(
            @AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(homestayService.getMyHomestays(userId));
    }

    // POST /api/homestays   (chi Host)
    @PostMapping("/homestays")
    @PreAuthorize("hasRole('HOST')")
    public ResponseEntity<HomestayDto> createHomestay(
            @AuthenticationPrincipal String userId,
            @RequestBody Map<String, Object> body) {
        String imageUrl = body.containsKey("image_url") ? body.get("image_url").toString() : null;
        return ResponseEntity.ok(homestayService.createHomestay(userId, body, imageUrl));
    }

    // GET /api/categories   (public)
    @GetMapping("/categories")
    public ResponseEntity<List<Category>> getCategories() {
        return ResponseEntity.ok(categoryRepository.findAll());
    }
}
