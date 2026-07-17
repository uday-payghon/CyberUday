package com.cyberuday.verification.service;

import com.cyberuday.verification.dto.ApiKeyCreateRequest;
import com.cyberuday.verification.dto.ApiKeyCreateResponse;
import com.cyberuday.verification.dto.ApiKeyMetadataResponse;
import com.cyberuday.verification.entity.ApiKeyMetadata;
import com.cyberuday.verification.model.ApiKeyStatus;
import com.cyberuday.verification.repository.ApiKeyMetadataRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;

@Service
public class ApiKeyManagementService {

    private static final String LIVE_KEY_PREFIX = "cu_live_";
    private static final int PREFIX_RANDOM_BYTES = 6;
    private static final int SECRET_RANDOM_BYTES = 32;

    private final SecureRandom secureRandom = new SecureRandom();
    private final ApiKeyMetadataRepository apiKeyMetadataRepository;

    public ApiKeyManagementService(ApiKeyMetadataRepository apiKeyMetadataRepository) {
        this.apiKeyMetadataRepository = apiKeyMetadataRepository;
    }

    @Transactional
    public ApiKeyCreateResponse createApiKey(ApiKeyCreateRequest request) {
        Instant now = Instant.now();
        String shortPrefix = randomHex(PREFIX_RANDOM_BYTES);
        String prefix = LIVE_KEY_PREFIX + shortPrefix;
        String rawKey = prefix + "_" + randomUrlSafe(SECRET_RANDOM_BYTES);
        String hashedKey = sha256(rawKey);

        ApiKeyMetadata metadata = new ApiKeyMetadata(
                UUID.randomUUID(),
                request.ownerName(),
                request.organizationType(),
                hashedKey,
                prefix,
                ApiKeyStatus.ACTIVE,
                now,
                request.expiresAt()
        );
        ApiKeyMetadata saved = apiKeyMetadataRepository.save(metadata);

        return new ApiKeyCreateResponse(
                saved.getId(),
                saved.getOwnerName(),
                saved.getOrganizationType(),
                rawKey,
                saved.getPrefix(),
                saved.getStatus(),
                saved.getCreatedAt(),
                saved.getExpiresAt()
        );
    }

    @Transactional(readOnly = true)
    public Optional<ApiKeyMetadata> authenticate(String rawKey) {
        if (!StringUtils.hasText(rawKey)) {
            return Optional.empty();
        }

        String prefix = extractPrefix(rawKey);
        if (!StringUtils.hasText(prefix)) {
            return Optional.empty();
        }

        String incomingHash = sha256(rawKey);
        return apiKeyMetadataRepository.findByPrefix(prefix)
                .filter(metadata -> metadata.getStatus() == ApiKeyStatus.ACTIVE)
                .filter(metadata -> metadata.getExpiresAt().isAfter(Instant.now()))
                .filter(metadata -> constantTimeEquals(metadata.getHashedKey(), incomingHash));
    }

    @Transactional
    public Optional<ApiKeyMetadataResponse> revoke(UUID id) {
        return apiKeyMetadataRepository.findById(id)
                .map(metadata -> {
                    metadata.revoke();
                    return toResponse(metadata);
                });
    }

    public String extractPrefix(String rawKey) {
        if (!StringUtils.hasText(rawKey) || !rawKey.startsWith(LIVE_KEY_PREFIX)) {
            return "";
        }
        int separatorIndex = rawKey.indexOf('_', LIVE_KEY_PREFIX.length());
        if (separatorIndex <= LIVE_KEY_PREFIX.length()) {
            return "";
        }
        return rawKey.substring(0, separatorIndex);
    }

    private ApiKeyMetadataResponse toResponse(ApiKeyMetadata metadata) {
        return new ApiKeyMetadataResponse(
                metadata.getId(),
                metadata.getOwnerName(),
                metadata.getOrganizationType(),
                metadata.getPrefix(),
                metadata.getStatus(),
                metadata.getCreatedAt(),
                metadata.getExpiresAt()
        );
    }

    private String randomUrlSafe(int byteLength) {
        byte[] randomBytes = new byte[byteLength];
        secureRandom.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }

    private String randomHex(int byteLength) {
        byte[] randomBytes = new byte[byteLength];
        secureRandom.nextBytes(randomBytes);
        return HexFormat.of().formatHex(randomBytes);
    }

    private String sha256(String rawKey) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawKey.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is not available", ex);
        }
    }

    private boolean constantTimeEquals(String expected, String actual) {
        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                actual.getBytes(StandardCharsets.UTF_8)
        );
    }
}
