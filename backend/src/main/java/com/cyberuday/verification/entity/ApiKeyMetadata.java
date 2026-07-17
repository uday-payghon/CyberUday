package com.cyberuday.verification.entity;

import com.cyberuday.verification.model.ApiKeyStatus;
import com.cyberuday.verification.model.OrganizationType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "api_key_metadata")
public class ApiKeyMetadata {

    @Id
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "owner_name", nullable = false, length = 120)
    private String ownerName;

    @Enumerated(EnumType.STRING)
    @Column(name = "organization_type", nullable = false, length = 24)
    private OrganizationType organizationType;

    @Column(name = "hashed_key", nullable = false, unique = true, length = 64)
    private String hashedKey;

    @Column(name = "prefix", nullable = false, unique = true, length = 24)
    private String prefix;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 16)
    private ApiKeyStatus status;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    protected ApiKeyMetadata() {
    }

    public ApiKeyMetadata(
            UUID id,
            String ownerName,
            OrganizationType organizationType,
            String hashedKey,
            String prefix,
            ApiKeyStatus status,
            Instant createdAt,
            Instant expiresAt
    ) {
        this.id = id;
        this.ownerName = ownerName;
        this.organizationType = organizationType;
        this.hashedKey = hashedKey;
        this.prefix = prefix;
        this.status = status;
        this.createdAt = createdAt;
        this.expiresAt = expiresAt;
    }

    public UUID getId() {
        return id;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public OrganizationType getOrganizationType() {
        return organizationType;
    }

    public String getHashedKey() {
        return hashedKey;
    }

    public String getPrefix() {
        return prefix;
    }

    public ApiKeyStatus getStatus() {
        return status;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getExpiresAt() {
        return expiresAt;
    }

    public void revoke() {
        status = ApiKeyStatus.REVOKED;
    }
}
