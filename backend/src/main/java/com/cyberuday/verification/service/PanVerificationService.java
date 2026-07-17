package com.cyberuday.verification.service;

import com.cyberuday.verification.model.PanStatus;
import com.cyberuday.verification.model.PanVerificationCommand;
import com.cyberuday.verification.model.PanVerificationResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class PanVerificationService {

    private static final Logger log = LoggerFactory.getLogger(PanVerificationService.class);
    private static final String[] MOCK_NAMES = {
            "UDAY PAYGHON",
            "CYBER UDAY",
            "RAHUL SHARMA",
            "PRIYA PATIL",
            "ANANYA SINGH"
    };

    public PanVerificationResult verifyPan(PanVerificationCommand command) {
        log.info("Calling mocked Protean/NSDL verifier panSuffix={}", command.panLastCharacter());

        if ("Z".equals(command.panLastCharacter())) {
            return new PanVerificationResult(PanStatus.INVALID, "");
        }

        int index = Math.floorMod(command.panLastCharacter().charAt(0) - 'A', MOCK_NAMES.length);
        return new PanVerificationResult(PanStatus.VALID, MOCK_NAMES[index]);
    }
}
