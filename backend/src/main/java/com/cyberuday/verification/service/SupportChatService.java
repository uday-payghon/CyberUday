package com.cyberuday.verification.service;

import com.cyberuday.verification.config.SupportBotProperties;
import com.cyberuday.verification.dto.SupportChatRequest;
import com.cyberuday.verification.dto.SupportChatResponse;
import com.cyberuday.verification.exception.SupportBotUnavailableException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;

@Service
public class SupportChatService {

    private static final Logger log = LoggerFactory.getLogger(SupportChatService.class);

    private final SupportBotProperties properties;
    private final SupportBotPromptPolicy promptPolicy;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public SupportChatService(
            SupportBotProperties properties,
            SupportBotPromptPolicy promptPolicy,
            ObjectMapper objectMapper
    ) {
        this.properties = properties;
        this.promptPolicy = promptPolicy;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(Math.max(3, properties.timeoutSeconds())))
                .build();
    }

    public SupportChatResponse reply(SupportChatRequest request) {
        if (!StringUtils.hasText(properties.apiKey())) {
            throw new SupportBotUnavailableException("Support bot API key is not configured");
        }

        try {
            String requestBody = objectMapper.writeValueAsString(Map.of(
                    "model", properties.model(),
                    "instructions", promptPolicy.systemInstruction(),
                    "input", List.of(Map.of(
                            "role", "user",
                            "content", List.of(Map.of(
                                    "type", "input_text",
                                    "text", buildUserInput(request)
                            ))
                    )),
                    "max_output_tokens", 420
            ));

            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(properties.endpointUrl()))
                    .timeout(Duration.ofSeconds(Math.max(5, properties.timeoutSeconds())))
                    .header("Authorization", "Bearer " + properties.apiKey())
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                log.warn("Support bot provider returned status={}", response.statusCode());
                throw new SupportBotUnavailableException("Support bot provider rejected the request");
            }

            String answer = extractAnswer(response.body());
            return new SupportChatResponse(request.sessionId(), answer, properties.model(), Instant.now());
        } catch (IOException ex) {
            log.warn("Support bot provider response could not be processed: {}", ex.getMessage());
            throw new SupportBotUnavailableException("Support bot provider response could not be processed");
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new SupportBotUnavailableException("Support bot request was interrupted");
        } catch (IllegalArgumentException ex) {
            throw new SupportBotUnavailableException("Support bot provider endpoint is invalid");
        }
    }

    private String buildUserInput(SupportChatRequest request) {
        return """
                Session: %s
                User message: %s
                """.formatted(request.sessionId(), request.message());
    }

    private String extractAnswer(String responseBody) throws IOException {
        JsonNode root = objectMapper.readTree(responseBody);

        JsonNode outputText = root.path("output_text");
        if (outputText.isTextual() && StringUtils.hasText(outputText.asText())) {
            return outputText.asText().trim();
        }

        JsonNode output = root.path("output");
        if (output.isArray()) {
            for (JsonNode item : output) {
                JsonNode content = item.path("content");
                if (!content.isArray()) {
                    continue;
                }
                for (JsonNode contentItem : content) {
                    JsonNode text = contentItem.path("text");
                    if (text.isTextual() && StringUtils.hasText(text.asText())) {
                        return text.asText().trim();
                    }
                }
            }
        }

        throw new SupportBotUnavailableException("Support bot provider returned an empty answer");
    }
}
