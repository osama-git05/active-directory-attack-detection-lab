# Test 01 - Network and Active Directory Reconnaissance

## Objective

Generate controlled network reconnaissance activity against the isolated AD-LAB environment and confirm that the activity produces useful network and SIEM telemetry.

## Lab Scope

- Source host: KALI
- Source IP: 10.10.10.50
- Destination host: DC01
- Destination IP: 10.10.10.10
- Network: AD-LAB
- Authorization: Local isolated lab only

## Technique / MITRE ATT&CK

- Discovery
- Network Service Scanning
- T1046 - Network Service Discovery

The objective was to simulate service enumeration that could occur after an attacker gains access to an internal network.

## Controlled Action

A service-version scan was performed from Kali against DC01:

```bash
nmap -sV -Pn 10.10.10.10
```

The scan was restricted to the private AD-LAB environment.

## Expected Telemetry

Expected evidence included:

- Repeated network connections toward DC01
- Multiple destination services
- Network activity originating from Kali
- Wazuh detection/correlation
- Supporting Sysmon or Windows network telemetry where available

## Actual Evidence

The Nmap scan successfully identified services exposed by DC01.

The activity produced repeated network connections that were successfully identified by custom Wazuh correlation logic.

## Detection Logic

Custom Wazuh rule:

```text
110130
```

Detection characteristics:

- Network service discovery behavior
- Frequency: 5
- Timeframe: 10 seconds
- Repeated activity from the same source

The frequency-based approach reduced the likelihood of treating an isolated legitimate connection as reconnaissance.

## Detection Validation

- Controlled reconnaissance generated: Yes
- Network telemetry observed: Yes
- Wazuh alert observed: Yes
- Custom rule observed: Yes
- Rule ID: 110130
- Final status: Detected

## Benign Noise Context

The ADLAB benign-noise automation was active during validation.

Background activity included:

- DNS lookups
- ICMP checks
- SYSVOL reads
- NETLOGON reads
- Normal PowerShell execution

Results:

- Nmap reconnaissance detected: Yes
- Benign activity triggered rule 110130: No observed false positive

## Analysis

Network reconnaissance often occurs before more targeted attack activity.

A single connection to a server is normally insufficient evidence of malicious behavior. Repeated connections to multiple services from the same source within a short timeframe provide stronger evidence of service enumeration.

The custom Wazuh rule used frequency and timeframe to improve detection confidence.

The benign-noise validation also demonstrated that routine workstation activity did not produce the same reconnaissance alert during the observed validation period.

## False Positives / Tuning

Potential legitimate sources include:

- Vulnerability scanners
- IT inventory systems
- Network monitoring platforms
- Administrative troubleshooting
- Asset discovery systems

Useful tuning fields include:

- Source IP
- Source host
- Destination services
- Number of ports
- Frequency
- Time window
- Whether the source is an approved scanner

## Security Risk

Reconnaissance may allow an attacker to identify:

- Active Directory services
- SMB
- Kerberos
- LDAP
- DNS
- Remote administration services

This information can be used to select later attack paths.

## Mitigation

Recommended controls include:

- Network segmentation
- Host firewalls
- Restrict unnecessary services
- Monitor internal scanning
- Identify approved vulnerability scanners
- Correlate reconnaissance with later authentication or privilege activity

## Evidence

- `../screenshots/test-01-recon.png`
- `../screenshots/day4-wazuh-network-scan-tuned-detection.png`
- `../screenshots/day4-wazuh-network-scan-benign-false-positive.png`

## Final Result

**Detected**

The controlled Nmap reconnaissance generated observable service-discovery behavior and successfully triggered custom Wazuh rule 110130.

The detection was also validated while benign background traffic was active without an observed false-positive alert from normal WIN11-CLIENT activity.
