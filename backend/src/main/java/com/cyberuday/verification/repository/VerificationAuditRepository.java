package com.cyberuday.verification.repository;

import com.cyberuday.verification.entity.VerificationAudit;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface VerificationAuditRepository extends JpaRepository<VerificationAudit, UUID> {
}
