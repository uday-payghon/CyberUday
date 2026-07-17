package com.cyberuday.verification.repository;

import com.cyberuday.verification.entity.CyberNewsItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface CyberNewsItemRepository extends JpaRepository<CyberNewsItem, UUID> {

    List<CyberNewsItem> findTop20ByOrderByPublishedDateDesc();
}
