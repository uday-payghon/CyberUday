package com.cyberuday.verification.util;

import org.springframework.util.StringUtils;

public final class PiiMasking {

    private PiiMasking() {
    }

    public static String maskAccount(String accountNumber) {
        if (!StringUtils.hasText(accountNumber) || accountNumber.length() < 4) {
            return "****";
        }
        return "*".repeat(Math.max(0, accountNumber.length() - 4))
                + accountNumber.substring(accountNumber.length() - 4);
    }

    public static String maskPan(String pan) {
        if (!StringUtils.hasText(pan) || pan.length() != 10) {
            return "**********";
        }
        return pan.substring(0, 2) + "*****" + pan.substring(7);
    }

    public static String maskUserId(String userId) {
        if (!StringUtils.hasText(userId) || userId.length() <= 4) {
            return "****";
        }
        return userId.substring(0, 2) + "***" + userId.substring(userId.length() - 2);
    }

    public static String ifscBankCode(String ifsc) {
        if (!StringUtils.hasText(ifsc) || ifsc.length() < 4) {
            return "UNKNOWN";
        }
        return ifsc.substring(0, 4);
    }

    public static String lastFour(String value) {
        if (!StringUtils.hasText(value) || value.length() < 4) {
            return "0000";
        }
        return value.substring(value.length() - 4);
    }
}
