package com.cyberuday.verification.config;

import com.cyberuday.verification.security.ApiKeyAuthenticationFilter;
import com.cyberuday.verification.security.HttpsRequiredFilter;
import com.cyberuday.verification.security.SupportChatRateLimitFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.access.channel.ChannelProcessingFilter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.filter.ForwardedHeaderFilter;

@Configuration
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            HttpsRequiredFilter httpsRequiredFilter,
            SupportChatRateLimitFilter supportChatRateLimitFilter,
            ApiKeyAuthenticationFilter apiKeyAuthenticationFilter
    ) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .headers(headers -> headers
                        .httpStrictTransportSecurity(hsts -> hsts
                                .includeSubDomains(true)
                                .preload(true)
                                .maxAgeInSeconds(31536000)))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/actuator/health/**", "/actuator/info").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/news/cyber-india").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/support/chat").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/admin/api-keys", "/api/v1/admin/api-keys/*/revoke").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/verify/bank-pan").authenticated()
                        .anyRequest().denyAll())
                .addFilterBefore(httpsRequiredFilter, ChannelProcessingFilter.class)
                .addFilterBefore(supportChatRateLimitFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(apiKeyAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    @Bean
    ForwardedHeaderFilter forwardedHeaderFilter() {
        return new ForwardedHeaderFilter();
    }

    @Bean
    FilterRegistrationBean<ApiKeyAuthenticationFilter> apiKeyAuthenticationFilterRegistration(
            ApiKeyAuthenticationFilter filter
    ) {
        FilterRegistrationBean<ApiKeyAuthenticationFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }

    @Bean
    FilterRegistrationBean<HttpsRequiredFilter> httpsRequiredFilterRegistration(HttpsRequiredFilter filter) {
        FilterRegistrationBean<HttpsRequiredFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }

    @Bean
    FilterRegistrationBean<SupportChatRateLimitFilter> supportChatRateLimitFilterRegistration(
            SupportChatRateLimitFilter filter
    ) {
        FilterRegistrationBean<SupportChatRateLimitFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }
}
