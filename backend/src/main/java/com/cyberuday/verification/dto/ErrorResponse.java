package com.cyberuday.verification.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_EMPTY)
public record ErrorResponse(
        @JsonProperty("timestamp")
        Instant timestamp,

        @JsonProperty("status")
        int status,

        @JsonProperty("code")
        String code,

        @JsonProperty("message")
        String message,

        @JsonProperty("path")
        String path,

        @JsonProperty("field_errors")
        Map<String, String> fieldErrors
) {
}
