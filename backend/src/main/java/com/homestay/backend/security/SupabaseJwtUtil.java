package com.homestay.backend.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;

/**
 * Verify JWT token phat hanh boi Supabase.
 * Supabase su dung HS256 voi JWT Secret lay tu: Project Settings > API > JWT Secret
 * Su dung JJWT 0.11.5 API
 */
@Component
public class SupabaseJwtUtil {

    private final SecretKey secretKey;

    public SupabaseJwtUtil(@Value("${supabase.jwt.secret}") String jwtSecret) {
        this.secretKey = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Parse va verify JWT. Tra ve Claims neu hop le, nem exception neu khong.
     * JJWT 0.11.5: dung parserBuilder() thay vi parser()
     */
    public Claims parseToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(secretKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    /**
     * Trich xuat user UUID tu claim "sub"
     */
    public String extractUserId(String token) {
        return parseToken(token).getSubject();
    }

    /**
     * Trich xuat role tu claim "user_metadata.role"
     * Supabase luu role o user_metadata (do user tu set qua updateProfileRole)
     */
    public String extractRole(String token) {
        Claims claims = parseToken(token);

        // Thu lay tu user_metadata truoc
        Object userMeta = claims.get("user_metadata");
        if (userMeta instanceof java.util.Map) {
            Object role = ((java.util.Map<?, ?>) userMeta).get("role");
            if (role != null) return role.toString();
        }

        // Fallback: lay tu app_metadata
        Object appMeta = claims.get("app_metadata");
        if (appMeta instanceof java.util.Map) {
            Object role = ((java.util.Map<?, ?>) appMeta).get("role");
            if (role != null) return role.toString();
        }

        return "customer"; // Default
    }
}
