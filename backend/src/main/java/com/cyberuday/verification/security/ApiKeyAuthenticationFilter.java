package com.cyberuday.verification.security;

import com.cyberuday.verification.entity.ApiKeyMetadata;
import com.cyberuday.verification.service.ApiKeyManagementService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;

@Component
public class ApiKeyAuthenticationFilter extends OncePerRequestFilter {

    public static final String API_KEY_HEADER = "X-CyberUday-Api-Key";
    private static final String VERIFICATION_PATH = "/api/v1/verify/bank-pan";

    private final ApiKeyManagementService apiKeyManagementService;

    public ApiKeyAuthenticationFilter(ApiKeyManagementService apiKeyManagementService) {
        this.apiKeyManagementService = apiKeyManagementService;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !VERIFICATION_PATH.equals(request.getRequestURI());
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String providedKey = request.getHeader(API_KEY_HEADER);
        ApiKeyMetadata metadata = apiKeyManagementService.authenticate(providedKey).orElse(null);
        if (metadata == null) {
            writeUnauthorized(response, request.getRequestURI());
            return;
        }

        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                metadata.getOwnerName(),
                "N/A",
                AuthorityUtils.createAuthorityList("ROLE_VERIFICATION_CLIENT")
        );
        authentication.setDetails(metadata.getId());
        SecurityContextHolder.getContext().setAuthentication(authentication);
        filterChain.doFilter(request, response);
    }

    private void writeUnauthorized(HttpServletResponse response, String path) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.getWriter().write("""
                {"timestamp":"%s","status":401,"code":"UNAUTHORIZED","message":"Authentication failed","path":"%s"}
                """.formatted(Instant.now(), path));
    }
}
