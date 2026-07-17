package com.cyberuday.verification.entity;

import com.cyberuday.verification.model.NewsSeverityTag;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "cyber_news_items")
public class CyberNewsItem {

    @Id
    @Column(name = "news_id", nullable = false, updatable = false)
    private UUID newsId;

    @Column(name = "headline", nullable = false, length = 180)
    private String headline;

    @Column(name = "summary", nullable = false, length = 1200)
    private String summary;

    @Column(name = "source_url", nullable = false, length = 500)
    private String sourceUrl;

    @Column(name = "image_url", nullable = false, length = 500)
    private String imageUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "severity_tag", nullable = false, length = 16)
    private NewsSeverityTag severityTag;

    @Column(name = "category", nullable = false, length = 80)
    private String category;

    @Column(name = "published_date", nullable = false)
    private Instant publishedDate;

    protected CyberNewsItem() {
    }

    public CyberNewsItem(
            UUID newsId,
            String headline,
            String summary,
            String sourceUrl,
            String imageUrl,
            NewsSeverityTag severityTag,
            String category,
            Instant publishedDate
    ) {
        this.newsId = newsId;
        this.headline = headline;
        this.summary = summary;
        this.sourceUrl = sourceUrl;
        this.imageUrl = imageUrl;
        this.severityTag = severityTag;
        this.category = category;
        this.publishedDate = publishedDate;
    }

    public UUID getNewsId() {
        return newsId;
    }

    public String getHeadline() {
        return headline;
    }

    public String getSummary() {
        return summary;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public NewsSeverityTag getSeverityTag() {
        return severityTag;
    }

    public String getCategory() {
        return category;
    }

    public Instant getPublishedDate() {
        return publishedDate;
    }
}
