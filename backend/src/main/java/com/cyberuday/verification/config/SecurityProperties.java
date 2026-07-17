package com.cyberuday.verification.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "cyber-uday.security")
public record SecurityProperties(String adminSecret) {
}
