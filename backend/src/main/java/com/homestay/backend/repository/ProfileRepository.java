package com.homestay.backend.repository;

import com.homestay.backend.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProfileRepository extends JpaRepository<Profile, String> {
    // PK la UUID String nen extends JpaRepository<Profile, String>
}
