package com.cyberuday.verification.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "cyber-uday.crypto")
public record CryptoProperties(String aes256Key) {
}
