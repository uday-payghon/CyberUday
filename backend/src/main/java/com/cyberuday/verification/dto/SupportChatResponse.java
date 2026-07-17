package com.cyberuday.verification.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;

public record SupportChatResponse(
        @JsonProperty("session_id")
        String sessionId,

        @JsonProperty("reply")
        String reply,

        @JsonProperty("model")
        String model,

        @JsonProperty("created_at")
        Instant createdAt
) {
}
