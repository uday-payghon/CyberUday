package com.cyberuday.verification.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.List;

public record CyberNewsFeedResponse(
        @JsonProperty("generated_at")
        Instant generatedAt,

        @JsonProperty("country")
        String country,

        @JsonProperty("edition")
        String edition,

        @JsonProperty("count")
        int count,

        @JsonProperty("items")
        List<CyberNewsItemResponse> items
) {
}
