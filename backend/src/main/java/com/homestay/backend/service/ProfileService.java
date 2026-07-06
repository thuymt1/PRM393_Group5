package com.homestay.backend.service;

import com.homestay.backend.entity.Profile;
import com.homestay.backend.repository.ProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
public class ProfileService {

    private final ProfileRepository profileRepository;

    public ProfileService(ProfileRepository profileRepository) {
        this.profileRepository = profileRepository;
    }

    @Transactional(readOnly = true)
    public Profile getProfile(String userId) {
        return profileRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Profile not found"));
    }

    @Transactional
    public Profile updateProfile(String userId, Map<String, String> updates) {
        Profile profile = getProfile(userId);

        if (updates.containsKey("full_name")) profile.setFullName(updates.get("full_name"));
        if (updates.containsKey("phone")) profile.setPhone(updates.get("phone"));
        if (updates.containsKey("avatar_url")) profile.setAvatarUrl(updates.get("avatar_url"));

        return profileRepository.save(profile);
    }

    @Transactional
    public Profile updateRole(String userId, String role) {
        Profile profile = profileRepository.findById(userId).orElseGet(() -> {
            // Profile chua ton tai (user moi dang nhap qua magic link)
            Profile p = new Profile();
            p.setId(userId);
            return p;
        });
        profile.setRole(role);
        return profileRepository.save(profile);
    }
}
