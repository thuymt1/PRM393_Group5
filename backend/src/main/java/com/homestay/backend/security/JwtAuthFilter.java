package com.homestay.backend.security;

import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Filter chay truoc moi request.
 * Doc JWT tu header "Authorization: Bearer <token>", verify, va dua thong tin user vao SecurityContext.
 */
@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final SupabaseJwtUtil jwtUtil;

    public JwtAuthFilter(SupabaseJwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            // Khong co token — tiep tuc filter chain (cac endpoint public van duoc phep)
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);

        try {
            String userId = jwtUtil.extractUserId(token);
            String role = jwtUtil.extractRole(token);

            // Tao Authentication object voi userId la principal, role la authority
            var auth = new UsernamePasswordAuthenticationToken(
                    userId,
                    null,
                    List.of(new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()))
            );

            SecurityContextHolder.getContext().setAuthentication(auth);
        } catch (JwtException e) {
            // Token khong hop le — tra ve 401
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Invalid or expired token\"}");
            return;
        }

        filterChain.doFilter(request, response);
    }
}
