package com.cyberuday.verification.model;

public record PanVerificationResult(
        PanStatus status,
        String registeredPanHolderName
) {
}
