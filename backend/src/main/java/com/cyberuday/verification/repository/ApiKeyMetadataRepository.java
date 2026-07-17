package com.cyberuday.verification.repository;

import com.cyberuday.verification.entity.ApiKeyMetadata;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ApiKeyMetadataRepository extends JpaRepository<ApiKeyMetadata, UUID> {

    Optional<ApiKeyMetadata> findByPrefix(String prefix);
}
