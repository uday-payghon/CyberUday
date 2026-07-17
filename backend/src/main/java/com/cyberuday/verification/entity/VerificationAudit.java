package com.cyberuday.verification.entity;

import com.cyberuday.verification.model.AccountStatus;
import com.cyberuday.verification.model.PanStatus;
import com.cyberuday.verification.model.VerificationStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "verification_audit_trail")
public class VerificationAudit {

    @Id
    @Column(name = "verification_id", nullable = false, updatable = false)
    private UUID verificationId;

    @Column(name = "user_id", nullable = false, length = 80)
    private String userId;

    @Column(name = "encrypted_account", nullable = false, columnDefinition = "text")
    private String encryptedAccount;

    @Column(name = "encrypted_pan", nullable = false, columnDefinition = "text")
    private String encryptedPan;

    @Column(name = "bank_match_score", nullable = false)
    private double bankMatchScore;

    @Column(name = "pan_match_score", nullable = false)
    private double panMatchScore;

    @Column(name = "match_score", nullable = false)
    private double matchScore;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    private VerificationStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "bank_status", nullable = false, length = 16)
    private AccountStatus bankStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "pan_status", nullable = false, length = 16)
    private PanStatus panStatus;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected VerificationAudit() {
    }

    public VerificationAudit(
            UUID verificationId,
            String userId,
            String encryptedAccount,
            String encryptedPan,
            double bankMatchScore,
            double panMatchScore,
            double matchScore,
            VerificationStatus status,
            AccountStatus bankStatus,
            PanStatus panStatus,
            Instant createdAt
    ) {
        this.verificationId = verificationId;
        this.userId = userId;
        this.encryptedAccount = encryptedAccount;
        this.encryptedPan = encryptedPan;
        this.bankMatchScore = bankMatchScore;
        this.panMatchScore = panMatchScore;
        this.matchScore = matchScore;
        this.status = status;
        this.bankStatus = bankStatus;
        this.panStatus = panStatus;
        this.createdAt = createdAt;
    }

    public UUID getVerificationId() {
        return verificationId;
    }

    public String getUserId() {
        return userId;
    }

    public String getEncryptedAccount() {
        return encryptedAccount;
    }

    public String getEncryptedPan() {
        return encryptedPan;
    }

    public double getBankMatchScore() {
        return bankMatchScore;
    }

    public double getPanMatchScore() {
        return panMatchScore;
    }

    public double getMatchScore() {
        return matchScore;
    }

    public VerificationStatus getStatus() {
        return status;
    }

    public AccountStatus getBankStatus() {
        return bankStatus;
    }

    public PanStatus getPanStatus() {
        return panStatus;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
