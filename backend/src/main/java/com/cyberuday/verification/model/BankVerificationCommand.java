package com.cyberuday.verification.model;

public record BankVerificationCommand(
        String encryptedAccountNumber,
        String ifscCode,
        String accountLastFour
) {
}
