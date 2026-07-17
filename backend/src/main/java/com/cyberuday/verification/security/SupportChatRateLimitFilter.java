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
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

@Component
public class SupportChatRateLimitFilter extends OncePerRequestFilter {

    private static final String SUPPORT_CHAT_PATH = "/api/v1/support/chat";
    private static final int CAPACITY = 5;
    private static final long REFILL_WINDOW_MILLIS = 60_000L;

    private final ConcurrentMap<String, TokenBucket> buckets = new ConcurrentHashMap<>();

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !SUPPORT_CHAT_PATH.equals(request.getRequestURI());
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String clientIp = clientIp(request);
        TokenBucket bucket = buckets.computeIfAbsent(clientIp, ignored -> new TokenBucket());
        if (!bucket.tryConsume()) {
            response.setStatus(429);
            response.setContentType("application/json");
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.setHeader("Retry-After", "60");
            response.getWriter().write("""
                    {"timestamp":"%s","status":429,"code":"RATE_LIMIT_EXCEEDED","message":"Too many requests. Please wait before trying again.","path":"%s"}
                    """.formatted(Instant.now(), request.getRequestURI()));
            return;
        }

        filterChain.doFilter(request, response);
    }

    private String clientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private static final class TokenBucket {
        private int tokens = CAPACITY;
        private long windowStartedAt = System.currentTimeMillis();

        private synchronized boolean tryConsume() {
            refillIfNeeded();
            if (tokens <= 0) {
                return false;
            }
            tokens--;
            return true;
        }

        private void refillIfNeeded() {
            long now = System.currentTimeMillis();
            if (now - windowStartedAt >= REFILL_WINDOW_MILLIS) {
                tokens = CAPACITY;
                windowStartedAt = now;
            }
        }
    }
}
