package com.homestay.backend.controller;

import com.homestay.backend.entity.Profile;
import com.homestay.backend.service.ProfileService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    // GET /api/profiles/me
    @GetMapping("/me")
    public ResponseEntity<Profile> getMyProfile(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(profileService.getProfile(userId));
    }

    // PUT /api/profiles/me   (cap nhat ten, SDT, avatar)
    @PutMapping("/me")
    public ResponseEntity<Profile> updateProfile(
            @AuthenticationPrincipal String userId,
            @RequestBody Map<String, String> updates) {
        return ResponseEntity.ok(profileService.updateProfile(userId, updates));
    }

    // PUT /api/profiles/me/role   (chon role sau khi dang ky)
    @PutMapping("/me/role")
    public ResponseEntity<Profile> updateRole(
            @AuthenticationPrincipal String userId,
            @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(profileService.updateRole(userId, body.get("role")));
    }
}
