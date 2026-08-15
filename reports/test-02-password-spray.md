# Test 02 - Controlled Password Spraying and Failed Authentication

## Objective

Generate a small controlled pattern of failed authentication attempts against dummy AD-LAB accounts and determine whether Windows and Wazuh can identify suspicious authentication behavior.

## Lab Scope

- Environment: AD-LAB
- Target: Domain authentication
- Accounts: Dummy lab users only
- Attempts: Deliberately limited
- Authorization: Local isolated lab only

The test was designed to create recognizable authentication failures without causing unnecessary account lockouts.

## Technique / MITRE ATT&CK

- Credential Access
- T1110 - Brute Force / Password Guessing

The scenario simulated password-spray-like behavior using controlled failed authentication attempts.

## Controlled Action

A small number of dummy AD-LAB identities were tested using an intentionally incorrect lab-only password.

Attempts were kept below the configured account-lockout threshold.

No real credentials were used.

## Expected Telemetry

Relevant authentication telemetry included:

- 4625 - Failed account logon
- 4771 - Kerberos pre-authentication failure
- 4776 - Credential validation

The exact event depends on the authentication protocol used.

## Actual Evidence

Failed authentication events were successfully generated and observed.

The activity produced a recognizable cluster of authentication failures during the controlled test window.

The events were ingested by Wazuh and matched custom failed-authentication correlation logic.

## Detection Logic

Custom Wazuh rule:

```text
110110
```

Configuration included:

- Frequency: 4
- Timeframe: 120 seconds

This allowed repeated failures to be treated as more suspicious than a single isolated login mistake.

## Detection Validation

- Failed authentication generated: Yes
- Windows authentication telemetry observed: Yes
- Wazuh ingestion confirmed: Yes
- Custom Wazuh alert observed: Yes
- Rule ID: 110110
- Unintentional account lockout: No
- Final status: Detected

## Analysis

Individual login failures are common and can occur because of:

- Typing mistakes
- Expired passwords
- Cached credentials
- Saved network credentials
- Misconfigured services

A cluster of failures becomes more suspicious when several attempts occur within a short timeframe and share characteristics such as source host, source IP, or affected accounts.

The custom Wazuh rule used correlation to improve detection quality.

## False Positives / Tuning

Potential benign sources include:

- User password mistakes
- Password changes not updated in services
- Scheduled tasks using old credentials
- Mapped drives
- Automated applications

Useful tuning fields include:

- Source IP
- Workstation
- Target account
- Number of affected users
- Frequency
- Authentication protocol
- Account lockout policy

## Security Risk

Password spraying attempts to discover valid credentials while reducing the likelihood of triggering per-account lockout thresholds.

Successful compromise may enable:

- Domain access
- Network service access
- Reconnaissance
- Lateral movement
- Privilege escalation attempts

## Mitigation

Recommended controls include:

- Strong password policies
- MFA where available
- Account lockout or smart-lockout controls
- Authentication monitoring
- Disable unused accounts
- Investigate repeated failures across several accounts
- Identity risk controls where available

## Evidence

- `../screenshots/test-02-password-failures.png`

Additional evidence includes Wazuh custom rule 110110.

## Final Result

**Detected**

Controlled authentication failures generated the expected Windows telemetry and successfully triggered custom Wazuh rule 110110.

The test demonstrated the value of correlation-based authentication monitoring rather than treating every failed login as malicious.
