package com.cyberuday.verification.service;

import com.cyberuday.verification.config.CryptoProperties;
import com.cyberuday.verification.exception.CryptoOperationException;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Base64;

@Service
public class EncryptionService {

    private static final String CIPHER_TRANSFORMATION = "AES/GCM/NoPadding";
    private static final String KEY_ALGORITHM = "AES";
    private static final int GCM_TAG_BITS = 128;
    private static final int IV_BYTES = 12;
    private static final String ENVELOPE_PREFIX = "v1:gcm";
    private static final byte[] AAD = "CyberUday:KYC:BankPAN:v1".getBytes(StandardCharsets.UTF_8);

    private final CryptoProperties cryptoProperties;
    private final SecureRandom secureRandom = new SecureRandom();
    private SecretKeySpec keySpec;

    public EncryptionService(CryptoProperties cryptoProperties) {
        this.cryptoProperties = cryptoProperties;
    }

    @PostConstruct
    void initializeKey() {
        if (!StringUtils.hasText(cryptoProperties.aes256Key())) {
            throw new CryptoOperationException("AES-256 key is not configured");
        }

        byte[] keyBytes;
        try {
            keyBytes = Base64.getDecoder().decode(cryptoProperties.aes256Key());
        } catch (IllegalArgumentException ex) {
            throw new CryptoOperationException("AES-256 key must be Base64 encoded");
        }

        if (keyBytes.length != 32) {
            throw new CryptoOperationException("AES-256 key must be exactly 32 bytes");
        }
        keySpec = new SecretKeySpec(keyBytes, KEY_ALGORITHM);
    }

    public String encrypt(String plaintext) {
        try {
            byte[] iv = new byte[IV_BYTES];
            secureRandom.nextBytes(iv);

            Cipher cipher = Cipher.getInstance(CIPHER_TRANSFORMATION);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, new GCMParameterSpec(GCM_TAG_BITS, iv));
            cipher.updateAAD(AAD);
            byte[] ciphertext = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));

            return "%s:%s:%s".formatted(
                    ENVELOPE_PREFIX,
                    Base64.getEncoder().encodeToString(iv),
                    Base64.getEncoder().encodeToString(ciphertext)
            );
        } catch (GeneralSecurityException ex) {
            throw new CryptoOperationException("Unable to encrypt sensitive data");
        }
    }
}
