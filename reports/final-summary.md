# Active Directory Attack & Detection Lab - Final Summary

## Project Overview

This project created an isolated Active Directory attack-and-detection environment using:

- Windows Server 2022
- Windows 11
- Kali Linux
- Sysmon
- PowerShell Script Block Logging
- Wazuh SIEM
- Sigma detection-as-code
- Oracle VirtualBox

The primary objective was to build an end-to-end detection-engineering workflow rather than simply execute offensive techniques.

The workflow used throughout the project was:

`Generate -> Observe -> Ingest -> Detect -> Investigate -> Tune -> Validate -> Harden -> Retest`

## Lab Architecture

| System | Role | IP |
|---|---|---|
| DC01 | Active Directory Domain Controller / DNS | 10.10.10.10 |
| WIN11-CLIENT | Windows 11 domain workstation | 10.10.10.20 |
| WAZUH | Wazuh SIEM | 10.10.10.30 |
| KALI | Controlled security testing | 10.10.10.50 |

Domain:

`adlab.test`

Network:

`10.10.10.0/24`

## Telemetry Implemented

The project collected and investigated telemetry from:

### Windows Security

Important events included:

- 4624 - Successful logon
- 4625 - Failed logon
- 4662 - Active Directory object access
- 4728 - Member added to global security group
- 4769 - Kerberos service ticket request
- 4771 - Kerberos pre-authentication failure
- 4776 - Credential validation
- 5136 - Directory object modification

### PowerShell

PowerShell Script Block Logging was enabled.

Primary event:

`4104`

### Sysmon

Important events included:

- Event 1 - Process creation
- Event 3 - Network connection
- Event 11 - File creation
- Event 22 - DNS query

### Directory Service

Targeted auditing was configured for:

- Event 4662
- Event 1644 diagnostic testing

## Detection Scenarios

### Network Reconnaissance

Controlled Nmap reconnaissance was generated from Kali against DC01.

Custom Wazuh rule:

`110130`

Result:

**Detected**

### Password Spraying

Controlled failed authentication attempts were generated against lab identities.

Custom Wazuh rule:

`110110`

Result:

**Detected**

### Kerberoasting

A controlled Kerberos service-ticket request was generated against:

`svc_web`

SPN:

`HTTP/web.adlab.test`

Custom Wazuh rule:

`110100`

Result:

**Detected**

### PowerShell Active Directory Reconnaissance

Controlled Active Directory discovery commands were executed using PowerShell.

Custom Wazuh rule:

`110120`

Result:

**Detected**

### Remote Administrative Logon

PowerShell Remoting from WIN11-CLIENT to DC01 generated:

- Event 4624
- Logon Type 3
- Administrator
- Source IP 10.10.10.20
- Kerberos authentication

Result:

**Logged but not alerted**

The raw event was confirmed locally, but no exact dedicated Wazuh alert was confirmed.

### Privileged Group Membership Change

`helpdesk.test` was temporarily added to Domain Admins.

Windows generated Event ID 4728.

Wazuh generated:

- Rule 60159
- Level 12

Result:

**Detected**

The account was removed from Domain Admins after testing.

## Canary Identity

A dedicated canary identity was configured:

`canary.admin`

The account remained:

- Disabled
- Non-privileged
- Unused for legitimate authentication

A controlled authentication attempt generated Event ID 4776.

Custom Wazuh rule:

`110150`

Severity:

`Level 12`

Result:

**Detected**

The detection was also revalidated after hardening and while benign background traffic was active.

## Active Directory Object Auditing

Directory Service Access auditing and an object-level SACL were applied to the `Test-Lab` OU.

A controlled object operation generated Event ID 4662.

Result:

**Telemetry validated**

This demonstrated that useful 4662 auditing requires both:

`Audit Policy + Object-Level SACL`

## LDAP Diagnostic Visibility

Temporary NTDS Field Engineering logging generated Event ID 1644 locally.

Result:

**Local telemetry validated**

However, Event 1644 was not successfully confirmed in Wazuh.

This remains documented as an ingestion gap.

Verbose diagnostic logging was disabled after testing.

## Custom Wazuh Rules

Validated custom Wazuh detections include:

| Rule | Detection |
|---|---|
| 110100 | Kerberoasting |
| 110110 | Password spraying |
| 110120 | PowerShell AD reconnaissance |
| 110130 | Network service discovery |
| 110150 | Canary authentication |

The privileged-group scenario was confirmed using built-in Wazuh rule 60159.

## Sigma Detection-as-Code

The project includes three Sigma detections:

- `kerberoasting.yml`
- `powershell-ad-recon.yml`
- `privileged-group-change.yml`

Sigma provides portable detection logic.

The Wazuh XML rules remain the operational SIEM implementation.

## Threat Hunting

Repeatable Wazuh hunting workflows were documented for:

- Authentication activity
- Kerberos service tickets
- PowerShell activity
- Privileged group changes
- Active Directory object activity
- Canary authentication
- Network reconnaissance

## Benign Noise and False-Positive Testing

A PowerShell automation script generated enterprise-like background activity including:

- DNS queries
- ICMP checks
- SYSVOL access
- NETLOGON access
- Routine PowerShell activity

Two custom detections were validated while benign activity was running:

### Network Reconnaissance - Rule 110130

Controlled reconnaissance:

**Detected**

Observed benign false positive:

**None observed**

### Canary Authentication - Rule 110150

Controlled authentication:

**Detected**

Observed benign false positive:

**None observed**

The result is limited to the controlled validation period and is not a claim of a zero false-positive rate in production environments.

## Hardening

After testing:

- The deliberately weak `svc_web` password was replaced.
- `svc_web` remained non-administrative.
- `helpdesk.test` was removed from Domain Admins.
- `canary.admin` remained disabled.
- LDAP diagnostic verbosity was disabled.
- The temporary LDAP threshold was removed.
- Sysmon remained operational.
- Wazuh agents remained operational.
- Benign-noise testing was stopped after validation.

## Post-Hardening Retest

Custom canary rule 110150 was triggered again after hardening.

Result:

**Detection remained operational**

This demonstrated that remediation did not remove defensive visibility.

## Detection Engineering Findings

### Raw Telemetry Is Not the Same as an Alert

The remote administration scenario generated the expected Windows event but no exact dedicated Wazuh alert was confirmed.

### Event Context Matters

Event ID 4769 occurs frequently during legitimate Active Directory activity.

Kerberoasting detection therefore requires additional context.

### Canary Accounts Provide High Signal

Because `canary.admin` is disabled and unused, authentication attempts against it are highly unusual.

### Event 4662 Requires a SACL

Audit policy alone did not provide useful object-access visibility.

An object-level SACL was also required.

### Telemetry Gaps Should Be Documented

Event 1644 was generated locally but not successfully ingested into Wazuh.

The project documents the gap rather than overstating detection coverage.

## Limitations

Current limitations include:

- Single Domain Controller
- Small endpoint population
- Local VirtualBox environment
- No enterprise EDR
- No SOAR
- No production identity governance platform
- No destructive attack testing
- Remote Type-3 logon alert gap
- LDAP 1644 Wazuh ingestion gap
- Detection latency was not precisely measured

## Future Improvements

Potential improvements include:

- Add a second Domain Controller
- Add Windows Event Forwarding
- Add CI validation for Sigma YAML
- Add CI validation for Wazuh XML
- Implement a Group Managed Service Account
- Add EDR telemetry
- Add Microsoft Defender for Identity
- Create a dedicated privileged Type-3 logon detection
- Improve Event 1644 ingestion
- Expand benign-noise profiles
- Add measured detection latency

## Final Outcome

The completed project demonstrates practical experience with:

- Active Directory
- Windows security auditing
- Kerberos
- Sysmon
- PowerShell logging
- Wazuh SIEM
- Detection engineering
- Sigma
- Threat hunting
- False-positive testing
- Active Directory hardening
- Post-remediation validation
- GitHub documentation

The final project represents an end-to-end Active Directory Detection Engineering portfolio lab rather than a basic attack-simulation environment.
