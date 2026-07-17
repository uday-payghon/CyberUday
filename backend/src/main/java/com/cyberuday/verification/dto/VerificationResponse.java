package com.cyberuday.verification.dto;

import com.cyberuday.verification.model.AccountStatus;
import com.cyberuday.verification.model.PanStatus;
import com.cyberuday.verification.model.VerificationStatus;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.UUID;

public record VerificationResponse(
        @JsonProperty("verification_id")
        UUID verificationId,

        @JsonProperty("status")
        VerificationStatus status,

        @JsonProperty("match_score")
        double matchScore,

        @JsonProperty("bank_match_score")
        double bankMatchScore,

        @JsonProperty("pan_match_score")
        double panMatchScore,

        @JsonProperty("bank_status")
        AccountStatus bankStatus,

        @JsonProperty("pan_status")
        PanStatus panStatus,

        @JsonProperty("timestamp")
        Instant timestamp
) {
}
