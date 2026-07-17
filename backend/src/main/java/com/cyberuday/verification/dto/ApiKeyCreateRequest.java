package com.cyberuday.verification.dto;

import com.cyberuday.verification.model.OrganizationType;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;

public record ApiKeyCreateRequest(
        @JsonProperty("owner_name")
        @NotBlank(message = "owner_name is required")
        @Size(min = 2, max = 120, message = "owner_name must be between 2 and 120 characters")
        String ownerName,

        @JsonProperty("organization_type")
        @NotNull(message = "organization_type is required")
        OrganizationType organizationType,

        @JsonProperty("expires_at")
        @NotNull(message = "expires_at is required")
        @Future(message = "expires_at must be in the future")
        Instant expiresAt
) {
}
