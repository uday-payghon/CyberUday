package com.cyberuday.verification.controller;

import com.cyberuday.verification.dto.SupportChatRequest;
import com.cyberuday.verification.dto.SupportChatResponse;
import com.cyberuday.verification.service.SupportChatService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/api/v1/support", produces = MediaType.APPLICATION_JSON_VALUE)
public class SupportChatController {

    private static final Logger log = LoggerFactory.getLogger(SupportChatController.class);

    private final SupportChatService supportChatService;

    public SupportChatController(SupportChatService supportChatService) {
        this.supportChatService = supportChatService;
    }

    @PostMapping(path = "/chat", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<SupportChatResponse> chat(@Valid @RequestBody SupportChatRequest request) {
        log.info("Received support chat request sessionId={}", request.sessionId());
        return ResponseEntity.ok(supportChatService.reply(request));
    }
}
