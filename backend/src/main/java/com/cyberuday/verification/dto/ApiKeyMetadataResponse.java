package com.cyberuday.verification.dto;

import com.cyberuday.verification.model.ApiKeyStatus;
import com.cyberuday.verification.model.OrganizationType;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.UUID;

public record ApiKeyMetadataResponse(
        @JsonProperty("id")
        UUID id,

        @JsonProperty("owner_name")
        String ownerName,

        @JsonProperty("organization_type")
        OrganizationType organizationType,

        @JsonProperty("prefix")
        String prefix,

        @JsonProperty("status")
        ApiKeyStatus status,

        @JsonProperty("created_at")
        Instant createdAt,

        @JsonProperty("expires_at")
        Instant expiresAt
) {
}
