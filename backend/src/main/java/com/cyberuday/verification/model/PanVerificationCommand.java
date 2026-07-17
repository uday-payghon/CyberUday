package com.cyberuday.verification.model;

public record PanVerificationCommand(
        String encryptedPanNumber,
        String panLastCharacter
) {
}
