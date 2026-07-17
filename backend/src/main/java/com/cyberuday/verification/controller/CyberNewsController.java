package com.cyberuday.verification.controller;

import com.cyberuday.verification.dto.CyberNewsFeedResponse;
import com.cyberuday.verification.service.CyberNewsFeedService;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping(path = "/api/v1/news", produces = MediaType.APPLICATION_JSON_VALUE)
public class CyberNewsController {

    private final CyberNewsFeedService cyberNewsFeedService;

    public CyberNewsController(CyberNewsFeedService cyberNewsFeedService) {
        this.cyberNewsFeedService = cyberNewsFeedService;
    }

    @GetMapping("/cyber-india")
    public ResponseEntity<CyberNewsFeedResponse> cyberIndiaFeed() {
        return ResponseEntity.ok()
                .cacheControl(CacheControl.maxAge(5, TimeUnit.MINUTES).cachePublic())
                .body(cyberNewsFeedService.latestIndiaFeed());
    }
}
