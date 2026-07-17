package com.cyberuday.verification.service;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.text.Normalizer;
import java.util.Arrays;
import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class NameMatchingService {

    private static final Pattern NON_NAME_CHARACTER = Pattern.compile("[^A-Z0-9 ]");
    private static final Pattern MULTIPLE_SPACES = Pattern.compile("\\s+");
    private static final Set<String> HONORIFICS = Set.of("MR", "MRS", "MS", "MISS", "DR", "SHRI", "SMT");

    public double confidence(String providedName, String registryName) {
        String left = normalize(providedName);
        String right = normalize(registryName);
        if (!StringUtils.hasText(left) || !StringUtils.hasText(right)) {
            return 0.0d;
        }

        double jaroWinkler = jaroWinkler(left, right);
        double levenshtein = normalizedLevenshtein(left, right);
        double tokenSet = tokenSetScore(left, right);
        double weighted = (jaroWinkler * 0.50d) + (levenshtein * 0.25d) + (tokenSet * 0.25d);
        return round(weighted * 100.0d);
    }

    private String normalize(String value) {
        if (!StringUtils.hasText(value)) {
            return "";
        }
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toUpperCase(Locale.ROOT);
        normalized = NON_NAME_CHARACTER.matcher(normalized).replaceAll(" ");
        normalized = MULTIPLE_SPACES.matcher(normalized).replaceAll(" ").trim();
        return Arrays.stream(normalized.split(" "))
                .filter(StringUtils::hasText)
                .filter(token -> !HONORIFICS.contains(token))
                .collect(Collectors.joining(" "));
    }

    private double tokenSetScore(String left, String right) {
        TreeSet<String> leftTokens = new TreeSet<>(Arrays.asList(left.split(" ")));
        TreeSet<String> rightTokens = new TreeSet<>(Arrays.asList(right.split(" ")));
        long common = leftTokens.stream().filter(rightTokens::contains).count();
        int total = Math.max(leftTokens.size(), rightTokens.size());
        if (total == 0) {
            return 0.0d;
        }
        return (double) common / total;
    }

    private double normalizedLevenshtein(String left, String right) {
        int max = Math.max(left.length(), right.length());
        if (max == 0) {
            return 1.0d;
        }
        return 1.0d - ((double) levenshteinDistance(left, right) / max);
    }

    private int levenshteinDistance(String left, String right) {
        int[] previous = new int[right.length() + 1];
        int[] current = new int[right.length() + 1];
        for (int j = 0; j <= right.length(); j++) {
            previous[j] = j;
        }

        for (int i = 1; i <= left.length(); i++) {
            current[0] = i;
            for (int j = 1; j <= right.length(); j++) {
                int substitutionCost = left.charAt(i - 1) == right.charAt(j - 1) ? 0 : 1;
                current[j] = Math.min(
                        Math.min(current[j - 1] + 1, previous[j] + 1),
                        previous[j - 1] + substitutionCost
                );
            }
            int[] temporary = previous;
            previous = current;
            current = temporary;
        }
        return previous[right.length()];
    }

    private double jaroWinkler(String left, String right) {
        if (left.equals(right)) {
            return 1.0d;
        }

        int[] mtp = matches(left, right);
        double matches = mtp[0];
        if (matches == 0) {
            return 0.0d;
        }
        double jaro = ((matches / left.length())
                + (matches / right.length())
                + ((matches - mtp[1]) / matches)) / 3.0d;

        return jaro < 0.7d ? jaro : jaro + Math.min(0.1d, 1.0d / mtp[3]) * mtp[2] * (1.0d - jaro);
    }

    private int[] matches(String first, String second) {
        String max;
        String min;
        if (first.length() > second.length()) {
            max = first;
            min = second;
        } else {
            max = second;
            min = first;
        }

        int range = Math.max(max.length() / 2 - 1, 0);
        int[] matchIndexes = new int[min.length()];
        Arrays.fill(matchIndexes, -1);
        boolean[] matchFlags = new boolean[max.length()];
        int matches = 0;

        for (int mi = 0; mi < min.length(); mi++) {
            char c1 = min.charAt(mi);
            for (int xi = Math.max(mi - range, 0), xn = Math.min(mi + range + 1, max.length()); xi < xn; xi++) {
                if (!matchFlags[xi] && c1 == max.charAt(xi)) {
                    matchIndexes[mi] = xi;
                    matchFlags[xi] = true;
                    matches++;
                    break;
                }
            }
        }

        char[] ms1 = new char[matches];
        char[] ms2 = new char[matches];
        for (int i = 0, si = 0; i < min.length(); i++) {
            if (matchIndexes[i] != -1) {
                ms1[si++] = min.charAt(i);
            }
        }
        for (int i = 0, si = 0; i < max.length(); i++) {
            if (matchFlags[i]) {
                ms2[si++] = max.charAt(i);
            }
        }

        int transpositions = 0;
        for (int mi = 0; mi < ms1.length; mi++) {
            if (ms1[mi] != ms2[mi]) {
                transpositions++;
            }
        }

        int prefix = 0;
        for (int mi = 0; mi < Math.min(4, Math.min(first.length(), second.length())); mi++) {
            if (first.charAt(mi) == second.charAt(mi)) {
                prefix++;
            } else {
                break;
            }
        }
        return new int[]{matches, transpositions / 2, prefix, max.length()};
    }

    private double round(double value) {
        return Math.round(value * 100.0d) / 100.0d;
    }
}
