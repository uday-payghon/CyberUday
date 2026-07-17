package com.cyberuday.verification.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;

@Component
public class HttpsRequiredFilter extends OncePerRequestFilter {

    private static final String VERIFICATION_PATH = "/api/v1/verify/bank-pan";
    private static final String ADMIN_API_KEYS_PATH = "/api/v1/admin/api-keys";
    private static final String SUPPORT_CHAT_PATH = "/api/v1/support/chat";

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !VERIFICATION_PATH.equals(request.getRequestURI())
                && !request.getRequestURI().startsWith(ADMIN_API_KEYS_PATH)
                && !SUPPORT_CHAT_PATH.equals(request.getRequestURI());
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String forwardedProto = request.getHeader("X-Forwarded-Proto");
        boolean tlsAtProxy = "https".equalsIgnoreCase(forwardedProto);
        if (!request.isSecure() && !tlsAtProxy) {
            response.setStatus(426);
            response.setContentType("application/json");
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.getWriter().write("""
                    {"timestamp":"%s","status":426,"code":"HTTPS_REQUIRED","message":"HTTPS is required","path":"%s"}
                    """.formatted(Instant.now(), request.getRequestURI()));
            return;
        }

        filterChain.doFilter(request, response);
    }
}
