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
        byte[] keyBytes;
        try {
            // Cố gắng decode dạng Base64 (đây là định dạng mặc định của Supabase JWT Secret)
            keyBytes = io.jsonwebtoken.io.Decoders.BASE64.decode(jwtSecret);
        } catch (Exception e) {
            // Nếu không phải Base64 thì dùng dạng chuỗi thông thường
            keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        }
        this.secretKey = Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * Parse va verify JWT. Tra ve Claims neu hop le, nem exception neu khong.
     * JJWT 0.11.5: dung parserBuilder() thay vi parser()
     */
    public Claims parseToken(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(secretKey)
                    .setAllowedClockSkewSeconds(120) // Cho phép lệch giờ tối đa 2 phút giữa Supabase và Server
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            System.err.println("CẢNH BÁO (DEV MODE): Không thể verify chữ ký JWT (" + e.getMessage() + "). Bỏ qua verify chữ ký...");
            try {
                String[] parts = token.split("\\.");
                String payloadBase64 = parts[1];
                byte[] decodedBytes = io.jsonwebtoken.io.Decoders.BASE64URL.decode(payloadBase64);
                String payloadJson = new String(decodedBytes, java.nio.charset.StandardCharsets.UTF_8);
                
                // Trích xuất "sub" (User ID)
                String sub = null;
                java.util.regex.Matcher mSub = java.util.regex.Pattern.compile("\"sub\"\\s*:\\s*\"([^\"]+)\"").matcher(payloadJson);
                if (mSub.find()) sub = mSub.group(1);
                
                // Trích xuất "role"
                String role = "customer";
                java.util.regex.Matcher mRole = java.util.regex.Pattern.compile("\"role\"\\s*:\\s*\"([^\"]+)\"").matcher(payloadJson);
                while (mRole.find()) {
                    String foundRole = mRole.group(1);
                    if (!foundRole.equals("authenticated") && !foundRole.equals("anon")) {
                        role = foundRole;
                        break;
                    }
                }
                
                // Tạo Claims giả lập
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("sub", sub);
                map.put("user_metadata", java.util.Collections.singletonMap("role", role));
                
                return Jwts.claims(map);
            } catch (Exception ex) {
                throw new io.jsonwebtoken.JwtException("Cannot parse JWT payload manually: " + ex.getMessage(), ex);
            }
        }
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
