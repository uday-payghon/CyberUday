package com.cyberuday.verification.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record VerificationRequest(
        @JsonProperty("user_id")
        @NotBlank(message = "user_id is required")
        @Size(min = 3, max = 80, message = "user_id must be between 3 and 80 characters")
        @Pattern(regexp = "^[A-Za-z0-9_.@-]+$", message = "user_id contains unsupported characters")
        String userId,

        @JsonProperty("account_number")
        @NotBlank(message = "account_number is required")
        @Pattern(regexp = "^[0-9]{9,18}$", message = "account_number must contain 9 to 18 digits")
        String accountNumber,

        @JsonProperty("ifsc_code")
        @NotBlank(message = "ifsc_code is required")
        @Pattern(regexp = "^[A-Z]{4}0[A-Z0-9]{6}$", message = "ifsc_code must be a valid IFSC code")
        String ifscCode,

        @JsonProperty("pan_number")
        @NotBlank(message = "pan_number is required")
        @Pattern(regexp = "^[A-Z]{5}[0-9]{4}[A-Z]{1}$", message = "pan_number must be a valid PAN")
        String panNumber,

        @JsonProperty("full_name")
        @NotBlank(message = "full_name is required")
        @Size(min = 2, max = 100, message = "full_name must be between 2 and 100 characters")
        @Pattern(regexp = "^[A-Za-z][A-Za-z .'-]*[A-Za-z.]$", message = "full_name contains unsupported characters")
        String fullName
) {
}
