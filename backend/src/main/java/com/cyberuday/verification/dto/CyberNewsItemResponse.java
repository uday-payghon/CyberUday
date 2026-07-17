package com.cyberuday.verification.dto;

import com.cyberuday.verification.model.NewsSeverityTag;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.UUID;

public record CyberNewsItemResponse(
        @JsonProperty("news_id")
        UUID newsId,

        @JsonProperty("headline")
        String headline,

        @JsonProperty("summary")
        String summary,

        @JsonProperty("source_url")
        String sourceUrl,

        @JsonProperty("image_url")
        String imageUrl,

        @JsonProperty("severity_tag")
        NewsSeverityTag severityTag,

        @JsonProperty("category")
        String category,

        @JsonProperty("published_date")
        Instant publishedDate
) {
}
