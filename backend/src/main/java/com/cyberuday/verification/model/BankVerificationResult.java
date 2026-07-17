package com.cyberuday.verification.model;

public record BankVerificationResult(
        AccountStatus status,
        String registeredAccountHolderName
) {
}
