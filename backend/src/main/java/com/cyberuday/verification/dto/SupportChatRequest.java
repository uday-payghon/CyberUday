package com.cyberuday.verification.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record SupportChatRequest(
        @JsonProperty("session_id")
        @NotBlank(message = "session_id is required")
        @Size(min = 8, max = 80, message = "session_id must be between 8 and 80 characters")
        @Pattern(regexp = "^[A-Za-z0-9_.:-]+$", message = "session_id contains unsupported characters")
        String sessionId,

        @JsonProperty("message")
        @NotBlank(message = "message is required")
        @Size(min = 2, max = 1200, message = "message must be between 2 and 1200 characters")
        String message
) {
}
