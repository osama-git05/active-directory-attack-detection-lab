# Test 03 - Controlled Kerberoasting Detection

## Objective

Generate a controlled Kerberos service-ticket request against a deliberately configured lab service account and investigate the resulting Active Directory telemetry.

## Lab Scope

- Domain: adlab.test
- Domain Controller: DC01
- Service account: svc_web
- Test SPN: HTTP/web.adlab.test
- Environment: AD-LAB only
- Authorization: Local isolated lab only

## Technique / MITRE ATT&CK

- Credential Access
- T1558.003 - Steal or Forge Kerberos Tickets: Kerberoasting

The scenario demonstrated the security risk associated with SPN-bearing service accounts and weak passwords.

## Prerequisites

The lab service account:

```text
svc_web
```

was configured with the SPN:

```text
HTTP/web.adlab.test
```

The account initially used a deliberately weak lab-only password solely for the controlled test.

## Controlled Action

A Kerberos service-ticket request was generated against the intentionally configured service account.

Example test method:

```bash
impacket-GetUserSPNs adlab.test/alice.user -dc-ip 10.10.10.10 -request
```

Passwords were not stored in GitHub or screenshots.

## Expected Telemetry

Primary Windows telemetry:

```text
4769 - A Kerberos service ticket was requested
```

Important investigation fields included:

- Requesting account
- Service name
- Service account
- Client address
- Ticket encryption type
- Timestamp

## Actual Evidence

DC01 successfully generated Event ID 4769 during the controlled service-ticket request.

Normal Event ID 4769 activity was also observed during routine domain operation.

This demonstrated that Event 4769 alone should not automatically be treated as Kerberoasting.

## Detection Logic

Custom Wazuh rule:

```text
110100
```

A corresponding Sigma detection was created:

```text
detections/sigma/kerberoasting.yml
```

The detection focused on contextual Kerberos service-ticket characteristics instead of alerting on every 4769 event.

## Detection Validation

- Service account configured with SPN: Yes
- Event ID 4769 observed: Yes
- Wazuh ingestion confirmed: Yes
- Custom Wazuh rule observed: Yes
- Rule ID: 110100
- Sigma detection created: Yes
- Final status: Detected

## Analysis

Kerberoasting targets Active Directory service accounts with Service Principal Names.

An authenticated domain identity may request a Kerberos service ticket for an SPN-backed service. If the service-account password is weak, ticket material may potentially be attacked offline.

Normal Active Directory operation also generates large numbers of 4769 events.

Useful detection therefore requires contextual information such as:

- Service account
- Service name
- Requesting identity
- Source host
- Encryption type
- Frequency
- Expected service activity

## False Positives / Tuning

Legitimate applications routinely request service tickets.

Possible benign sources include:

- Web servers
- File servers
- SQL services
- Domain computers
- Administrative applications

Machine-account tickets and expected service activity should be considered when tuning detections.

## Security Risk

Weak SPN-bearing service-account passwords increase risk because suitable Kerberos ticket material may be subjected to offline password guessing.

Service accounts may also:

- Use long-lived passwords
- Be shared between services
- Have excessive permissions
- Receive less frequent credential rotation

## Mitigation

After testing:

- The deliberately weak `svc_web` password was replaced.
- A strong unique lab-only password was configured.
- `svc_web` remained non-privileged.
- Group membership was verified.

Additional enterprise mitigations include:

- Strong service-account passwords
- Group Managed Service Accounts
- Least privilege
- Monitoring unusual 4769 activity
- Reducing legacy Kerberos encryption
- Auditing SPN-bearing identities

## Evidence

- `../screenshots/test-03-kerberoasting.png`
- `../screenshots/day3-wazuh-hunting-kerberos.png`
- `../screenshots/day7-hardening-account-state.png`

## Final Result

**Detected**

The controlled Kerberos service-ticket request generated Event ID 4769 and successfully matched custom Wazuh rule 110100.

Normal 4769 activity was also observed, demonstrating why Kerberoasting detection requires contextual filtering rather than alerting on every service ticket.
