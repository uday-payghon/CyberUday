package com.cyberuday.verification.service;

import com.cyberuday.verification.dto.CyberNewsFeedResponse;
import com.cyberuday.verification.dto.CyberNewsItemResponse;
import com.cyberuday.verification.entity.CyberNewsItem;
import com.cyberuday.verification.model.NewsSeverityTag;
import com.cyberuday.verification.repository.CyberNewsItemRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
public class CyberNewsFeedService {

    private static final String INDIA_EDITION = "Cyber Uday India Cyber Watch";

    private final CyberNewsItemRepository cyberNewsItemRepository;

    public CyberNewsFeedService(CyberNewsItemRepository cyberNewsItemRepository) {
        this.cyberNewsItemRepository = cyberNewsItemRepository;
    }

    @PostConstruct
    @Transactional
    public void seedOnStartup() {
        seedMockFeedIfEmpty();
    }

    @Scheduled(cron = "0 0 */6 * * *")
    @Transactional
    public void refreshMockFeed() {
        seedMockFeedIfEmpty();
    }

    @Transactional(readOnly = true)
    public CyberNewsFeedResponse latestIndiaFeed() {
        List<CyberNewsItemResponse> items = cyberNewsItemRepository.findTop20ByOrderByPublishedDateDesc()
                .stream()
                .map(this::toResponse)
                .toList();
        return new CyberNewsFeedResponse(
                Instant.now(),
                "IN",
                INDIA_EDITION,
                items.size(),
                items
        );
    }

    private void seedMockFeedIfEmpty() {
        if (cyberNewsItemRepository.count() > 0) {
            return;
        }

        Instant now = Instant.now();
        cyberNewsItemRepository.saveAll(List.of(
                new CyberNewsItem(
                        UUID.fromString("0f69ff7c-c5ea-4d5d-9432-700519a7b3df"),
                        "Fake electricity bill APKs resurface on WhatsApp in metro cities",
                        "Cyber desks are seeing renewed complaints where users receive urgent power-disconnection messages with links to sideloaded Android APKs. The apps mimic utility payment flows, request SMS/accessibility permissions, and can capture UPI intent data or OTP notifications.",
                        "https://timesofindia.indiatimes.com/city/delhi/discoms-raise-awareness-against-cyber-frauds-using-power-bills/articleshow/128512983.cms",
                        "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=1200&q=80",
                        NewsSeverityTag.CRITICAL,
                        "Banking Fraud",
                        now.minus(2, ChronoUnit.HOURS)
                ),
                new CyberNewsItem(
                        UUID.fromString("a262c0d2-b598-4b2b-91a6-654c726b43b1"),
                        "UPI collect-request spoofing targets small merchants after QR scans",
                        "Fraud operators are combining spoofed payment screenshots, fake collect requests, and pressure calls to trick shop owners into approving debits while believing they are receiving money. Users should verify transaction direction inside the UPI app before entering a PIN.",
                        "https://www.upihelp.npci.org.in/",
                        "https://images.unsplash.com/photo-1563013544-824ae1b704d3?auto=format&fit=crop&w=1200&q=80",
                        NewsSeverityTag.WARNING,
                        "UPI Fraud",
                        now.minus(8, ChronoUnit.HOURS)
                ),
                new CyberNewsItem(
                        UUID.fromString("a622a0db-62bc-430b-beb6-5e266e8b7f8a"),
                        "Aadhaar update phishing pages imitate official identity workflows",
                        "Lookalike portals are being circulated through SMS and social posts, asking for Aadhaar, PAN, mobile numbers, and payment details under the pretext of re-verification. UIDAI guidance continues to emphasize not posting Aadhaar publicly and using official channels for identity services.",
                        "https://uidai.gov.in/en/contact-support/have-any-question/281-english-uk/faqs/your-aadhaar/use-aadhaar-freely.html",
                        "https://images.unsplash.com/photo-1614064641938-3bbee52942c7?auto=format&fit=crop&w=1200&q=80",
                        NewsSeverityTag.WARNING,
                        "Identity Theft",
                        now.minus(18, ChronoUnit.HOURS)
                ),
                new CyberNewsItem(
                        UUID.fromString("c8e5a0b6-8b51-4ea6-b646-bd73ab5e658e"),
                        "Digital arrest impersonation crews keep abusing video-call platforms",
                        "India-focused scam cells continue to impersonate police, courier, RBI, CBI, and narcotics officials, often moving victims to Skype or WhatsApp calls. Government advisories report large-scale blocking of accounts used in these campaigns and urge immediate reporting to cybercrime channels.",
                        "https://www.pib.gov.in/PressReleaseDetail.aspx?PRID=2112244",
                        "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80",
                        NewsSeverityTag.CRITICAL,
                        "Impersonation Scam",
                        now.minus(1, ChronoUnit.DAYS)
                )
        ));
    }

    private CyberNewsItemResponse toResponse(CyberNewsItem item) {
        return new CyberNewsItemResponse(
                item.getNewsId(),
                item.getHeadline(),
                item.getSummary(),
                item.getSourceUrl(),
                item.getImageUrl(),
                item.getSeverityTag(),
                item.getCategory(),
                item.getPublishedDate()
        );
    }
}
