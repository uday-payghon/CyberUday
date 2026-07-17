package com.cyberuday.verification.controller;

import com.cyberuday.verification.config.SecurityProperties;
import com.cyberuday.verification.dto.ApiKeyCreateRequest;
import com.cyberuday.verification.dto.ApiKeyCreateResponse;
import com.cyberuday.verification.dto.ApiKeyMetadataResponse;
import com.cyberuday.verification.exception.AdminAuthorizationException;
import com.cyberuday.verification.service.ApiKeyManagementService;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;

@RestController
@RequestMapping(path = "/api/v1/admin/api-keys", produces = MediaType.APPLICATION_JSON_VALUE)
public class ApiKeyManagementController {

    private static final String ADMIN_SECRET_HEADER = "X-CyberUday-Admin-Secret";

    private final ApiKeyManagementService apiKeyManagementService;
    private final SecurityProperties securityProperties;

    public ApiKeyManagementController(
            ApiKeyManagementService apiKeyManagementService,
            SecurityProperties securityProperties
    ) {
        this.apiKeyManagementService = apiKeyManagementService;
        this.securityProperties = securityProperties;
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiKeyCreateResponse> createApiKey(
            @RequestHeader(value = ADMIN_SECRET_HEADER, required = false) String adminSecret,
            @Valid @RequestBody ApiKeyCreateRequest request
    ) {
        authorize(adminSecret);
        return ResponseEntity.ok(apiKeyManagementService.createApiKey(request));
    }

    @PostMapping("/{id}/revoke")
    public ResponseEntity<ApiKeyMetadataResponse> revokeApiKey(
            @RequestHeader(value = ADMIN_SECRET_HEADER, required = false) String adminSecret,
            @PathVariable UUID id
    ) {
        authorize(adminSecret);
        return apiKeyManagementService.revoke(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    private void authorize(String providedSecret) {
        String configuredSecret = securityProperties.adminSecret();
        if (!StringUtils.hasText(configuredSecret)
                || !StringUtils.hasText(providedSecret)
                || !MessageDigest.isEqual(
                configuredSecret.getBytes(StandardCharsets.UTF_8),
                providedSecret.getBytes(StandardCharsets.UTF_8))) {
            throw new AdminAuthorizationException("Admin secret is invalid");
        }
    }
}
