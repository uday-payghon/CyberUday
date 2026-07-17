package com.cyberuday.verification.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "cyber-uday.support-bot")
public record SupportBotProperties(
        String apiKey,
        String endpointUrl,
        String model,
        int timeoutSeconds
) {
}
