package com.cyberuday.verification.exception;

import com.cyberuday.verification.dto.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authorization.AuthorizationDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            MethodArgumentNotValidException ex,
            HttpServletRequest request
    ) {
        Map<String, String> errors = new LinkedHashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
                errors.put(error.getField(), error.getDefaultMessage()));

        return build(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED",
                "Request validation failed", request.getRequestURI(), errors);
    }

    @ExceptionHandler({ConstraintViolationException.class, HttpMessageNotReadableException.class})
    public ResponseEntity<ErrorResponse> handleBadRequest(Exception ex, HttpServletRequest request) {
        return build(HttpStatus.BAD_REQUEST, "BAD_REQUEST",
                "Malformed or invalid request", request.getRequestURI(), Map.of());
    }

    @ExceptionHandler(InsecureTransportException.class)
    public ResponseEntity<ErrorResponse> handleInsecureTransport(
            InsecureTransportException ex,
            HttpServletRequest request
    ) {
        return build(HttpStatus.UPGRADE_REQUIRED, "HTTPS_REQUIRED",
                "HTTPS is required", request.getRequestURI(), Map.of());
    }

    @ExceptionHandler({BadCredentialsException.class, AuthorizationDeniedException.class})
    public ResponseEntity<ErrorResponse> handleUnauthorized(Exception ex, HttpServletRequest request) {
        return build(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED",
                "Authentication failed", request.getRequestURI(), Map.of());
    }

    @ExceptionHandler(AdminAuthorizationException.class)
    public ResponseEntity<ErrorResponse> handleAdminUnauthorized(
            AdminAuthorizationException ex,
            HttpServletRequest request
    ) {
        return build(HttpStatus.UNAUTHORIZED, "ADMIN_UNAUTHORIZED",
                "Admin authorization failed", request.getRequestURI(), Map.of());
    }

    @ExceptionHandler(CryptoOperationException.class)
    public ResponseEntity<ErrorResponse> handleCrypto(CryptoOperationException ex, HttpServletRequest request) {
        log.error("Cryptographic operation failed: {}", ex.getMessage());
        return build(HttpStatus.INTERNAL_SERVER_ERROR, "SECURITY_PROCESSING_ERROR",
                "Unable to process verification securely", request.getRequestURI(), Map.of());
    }

    @ExceptionHandler(RateLimitExceededException.class)
    public ResponseEntity<ErrorResponse> handleRateLimit(RateLimitExceededException ex, HttpServletRequest request) {
        return build(HttpStatus.TOO_MANY_REQUESTS, "RATE_LIMIT_EXCEEDED",
                "Too many requests. Please wait before trying again.", request.getRequestURI(), Map.of());
    }

    @ExceptionHandler(SupportBotUnavailableException.class)
    public ResponseEntity<ErrorResponse> handleSupportBot(
            SupportBotUnavailableException ex,
            HttpServletRequest request
    ) {
        log.warn("Support bot unavailable: {}", ex.getMessage());
        return build(HttpStatus.SERVICE_UNAVAILABLE, "SUPPORT_BOT_UNAVAILABLE",
                "Support assistant is temporarily unavailable", request.getRequestURI(), Map.of());
    }

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ErrorResponse> handleDatabase(DataAccessException ex, HttpServletRequest request) {
        log.error("Database operation failed while processing verification", ex);
        return build(HttpStatus.INTERNAL_SERVER_ERROR, "PERSISTENCE_ERROR",
                "Unable to complete verification at this time", request.getRequestURI(), Map.of());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleUnexpected(Exception ex, HttpServletRequest request) {
        log.error("Unexpected verification service failure", ex);
        return build(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR",
                "Unable to complete verification at this time", request.getRequestURI(), Map.of());
    }

    private ResponseEntity<ErrorResponse> build(
            HttpStatus status,
            String code,
            String message,
            String path,
            Map<String, String> fieldErrors
    ) {
        return ResponseEntity.status(status).body(new ErrorResponse(
                Instant.now(),
                status.value(),
                code,
                message,
                path,
                fieldErrors
        ));
    }
}
