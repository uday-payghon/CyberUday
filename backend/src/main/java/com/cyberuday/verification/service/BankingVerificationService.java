package com.cyberuday.verification.service;

import com.cyberuday.verification.model.AccountStatus;
import com.cyberuday.verification.model.BankVerificationCommand;
import com.cyberuday.verification.model.BankVerificationResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class BankingVerificationService {

    private static final Logger log = LoggerFactory.getLogger(BankingVerificationService.class);
    private static final String[] MOCK_NAMES = {
            "UDAY PAYGHON",
            "CYBER UDAY",
            "RAHUL SHARMA",
            "PRIYA PATIL",
            "ANANYA SINGH"
    };

    public BankVerificationResult verifyAccount(BankVerificationCommand command) {
        log.info(
                "Calling mocked open banking verifier accountLast4={} ifscBank={}",
                command.accountLastFour(),
                command.ifscCode().substring(0, 4)
        );

        if (command.accountLastFour().equals("0000")) {
            return new BankVerificationResult(AccountStatus.INVALID, "");
        }

        int index = Character.digit(command.accountLastFour().charAt(command.accountLastFour().length() - 1), 10)
                % MOCK_NAMES.length;
        return new BankVerificationResult(AccountStatus.ACTIVE, MOCK_NAMES[index]);
    }
}
