package com.cyberuday.verification.service;

import com.cyberuday.verification.dto.VerificationRequest;
import com.cyberuday.verification.dto.VerificationResponse;
import com.cyberuday.verification.entity.VerificationAudit;
import com.cyberuday.verification.model.AccountStatus;
import com.cyberuday.verification.model.BankVerificationCommand;
import com.cyberuday.verification.model.BankVerificationResult;
import com.cyberuday.verification.model.PanStatus;
import com.cyberuday.verification.model.PanVerificationCommand;
import com.cyberuday.verification.model.PanVerificationResult;
import com.cyberuday.verification.model.VerificationStatus;
import com.cyberuday.verification.repository.VerificationAuditRepository;
import com.cyberuday.verification.util.PiiMasking;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
public class VerificationOrchestratorService {

    private static final Logger log = LoggerFactory.getLogger(VerificationOrchestratorService.class);

    private final EncryptionService encryptionService;
    private final BankingVerificationService bankingVerificationService;
    private final PanVerificationService panVerificationService;
    private final NameMatchingService nameMatchingService;
    private final VerificationAuditRepository verificationAuditRepository;

    public VerificationOrchestratorService(
            EncryptionService encryptionService,
            BankingVerificationService bankingVerificationService,
            PanVerificationService panVerificationService,
            NameMatchingService nameMatchingService,
            VerificationAuditRepository verificationAuditRepository
    ) {
        this.encryptionService = encryptionService;
        this.bankingVerificationService = bankingVerificationService;
        this.panVerificationService = panVerificationService;
        this.nameMatchingService = nameMatchingService;
        this.verificationAuditRepository = verificationAuditRepository;
    }

    @Transactional
    public VerificationResponse verify(VerificationRequest request) {
        UUID verificationId = UUID.randomUUID();
        Instant now = Instant.now();

        String encryptedAccount = encryptionService.encrypt(request.accountNumber());
        String encryptedPan = encryptionService.encrypt(request.panNumber());

        BankVerificationResult bankResult = bankingVerificationService.verifyAccount(new BankVerificationCommand(
                encryptedAccount,
                request.ifscCode(),
                PiiMasking.lastFour(request.accountNumber())
        ));
        PanVerificationResult panResult = panVerificationService.verifyPan(new PanVerificationCommand(
                encryptedPan,
                request.panNumber().substring(request.panNumber().length() - 1)
        ));

        double bankScore = bankResult.status() == AccountStatus.ACTIVE
                ? nameMatchingService.confidence(request.fullName(), bankResult.registeredAccountHolderName())
                : 0.0d;
        double panScore = panResult.status() == PanStatus.VALID
                ? nameMatchingService.confidence(request.fullName(), panResult.registeredPanHolderName())
                : 0.0d;
        double aggregateScore = round(Math.min(bankScore, panScore));
        VerificationStatus status = decideStatus(bankResult.status(), panResult.status(), aggregateScore);

        VerificationAudit audit = new VerificationAudit(
                verificationId,
                request.userId(),
                encryptedAccount,
                encryptedPan,
                bankScore,
                panScore,
                aggregateScore,
                status,
                bankResult.status(),
                panResult.status(),
                now
        );
        verificationAuditRepository.save(audit);

        log.info(
                "Completed bank/PAN verification verificationId={} userId={} status={} matchScore={}",
                verificationId,
                PiiMasking.maskUserId(request.userId()),
                status,
                aggregateScore
        );

        return new VerificationResponse(
                verificationId,
                status,
                aggregateScore,
                bankScore,
                panScore,
                bankResult.status(),
                panResult.status(),
                now
        );
    }

    private VerificationStatus decideStatus(AccountStatus accountStatus, PanStatus panStatus, double score) {
        if (accountStatus != AccountStatus.ACTIVE || panStatus != PanStatus.VALID || score < 60.0d) {
            return VerificationStatus.REJECTED;
        }
        if (score >= 85.0d) {
            return VerificationStatus.APPROVED;
        }
        return VerificationStatus.FLAGGED_FOR_REVIEW;
    }

    private double round(double value) {
        return Math.round(value * 100.0d) / 100.0d;
    }
}
