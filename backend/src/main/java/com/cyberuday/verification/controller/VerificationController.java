package com.cyberuday.verification.controller;

import com.cyberuday.verification.dto.VerificationRequest;
import com.cyberuday.verification.dto.VerificationResponse;
import com.cyberuday.verification.exception.InsecureTransportException;
import com.cyberuday.verification.service.VerificationOrchestratorService;
import com.cyberuday.verification.util.PiiMasking;
import jakarta.servlet.http.HttpServletRequest;
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
@RequestMapping(path = "/api/v1/verify", produces = MediaType.APPLICATION_JSON_VALUE)
public class VerificationController {

    private static final Logger log = LoggerFactory.getLogger(VerificationController.class);
    private final VerificationOrchestratorService verificationOrchestratorService;

    public VerificationController(VerificationOrchestratorService verificationOrchestratorService) {
        this.verificationOrchestratorService = verificationOrchestratorService;
    }

    @PostMapping(path = "/bank-pan", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<VerificationResponse> verifyBankAndPan(
            @Valid @RequestBody VerificationRequest request,
            HttpServletRequest servletRequest
    ) {
        enforceHttps(servletRequest);
        log.info(
                "Received bank/PAN verification request userId={} account={} pan={} ifscBank={}",
                PiiMasking.maskUserId(request.userId()),
                PiiMasking.maskAccount(request.accountNumber()),
                PiiMasking.maskPan(request.panNumber()),
                PiiMasking.ifscBankCode(request.ifscCode())
        );

        return ResponseEntity.ok(verificationOrchestratorService.verify(request));
    }

    private void enforceHttps(HttpServletRequest request) {
        String forwardedProto = request.getHeader("X-Forwarded-Proto");
        boolean tlsAtProxy = "https".equalsIgnoreCase(forwardedProto);
        if (!request.isSecure() && !tlsAtProxy) {
            throw new InsecureTransportException("HTTPS is required for verification requests");
        }
    }
}
