# Wazuh Saved Searches and Hunting Views

## Purpose

This document records the repeatable Wazuh hunting searches used throughout the Active Directory Attack & Detection Lab.

The goal was to make the investigation workflow reproducible instead of relying only on one-time screenshots.

These searches were used to review:

- Authentication activity
- Kerberos service-ticket activity
- PowerShell execution
- Privileged-group changes
- Active Directory object access
- Canary-account authentication
- Network reconnaissance

The exact field names may vary slightly depending on the decoded Wazuh event, but the searches below reflect the fields used during this lab.

---

# 1. Authentication Activity

## Purpose

Review successful and failed authentication activity across the monitored Windows systems.

## Event IDs

```text
4624
4625
4771
4776
```

## Example Search

```text
data.win.system.eventID:(4624 OR 4625 OR 4771 OR 4776)
```

## Useful Fields

- `agent.name`
- `data.win.system.computer`
- `data.win.system.eventID`
- `data.win.eventdata.targetUserName`
- `data.win.eventdata.subjectUserName`
- `data.win.eventdata.ipAddress`
- `data.win.eventdata.workstation`
- `data.win.eventdata.logonType`
- `data.win.eventdata.status`
- `rule.id`
- `rule.level`

## Investigation Use

This view supports investigation of:

- Failed authentication
- Password-spray behavior
- Successful logons
- Remote logons
- Credential validation
- Canary-account activity

## Evidence

Relevant screenshot:

```text
screenshots/day3-wazuh-hunting-authentication.png
```

---

# 2. Kerberos Service Ticket Activity

## Purpose

Review Kerberos service-ticket requests and investigate potential Kerberoasting behavior.

## Event ID

```text
4769
```

## Example Search

```text
data.win.system.eventID:4769
```

## Useful Fields

- `agent.name`
- `data.win.system.computer`
- `data.win.eventdata.targetUserName`
- `data.win.eventdata.serviceName`
- `data.win.eventdata.ipAddress`
- `data.win.eventdata.ticketEncryptionType`
- `rule.id`
- `rule.level`

## Detection Context

Event ID 4769 is common in Active Directory environments.

A useful Kerberoasting investigation should consider:

- Service account
- Service Principal Name
- Requesting user
- Source address
- Ticket encryption type
- Frequency of requests
- Whether the service is expected

The custom Kerberoasting detection used:

```text
rule.id:110100
```

## Example Custom Rule Search

```text
rule.id:110100
```

## Evidence

Relevant screenshot:

```text
screenshots/day3-wazuh-hunting-kerberos.png
```

---

# 3. PowerShell Activity

## Purpose

Review PowerShell Script Block Logging events for administrative or suspicious command execution.

## Event ID

```text
4104
```

## Example Search

```text
data.win.system.eventID:4104
```

## Useful Fields

- `agent.name`
- `data.win.system.computer`
- `data.win.system.eventID`
- `data.win.eventdata.scriptBlockText`
- `data.win.eventdata.messageNumber`
- `data.win.eventdata.messageTotal`
- `rule.id`
- `rule.level`

## Detection Context

The Active Directory reconnaissance scenario used commands such as:

```text
Get-ADDomain
Get-ADUser
Get-ADGroup
Get-ADGroupMember
```

The custom detection used:

```text
rule.id:110120
```

## Example Custom Rule Search

```text
rule.id:110120
```

## Evidence

Relevant screenshot:

```text
screenshots/day3-wazuh-hunting-powershell.png
```

---

# 4. Privileged Group Membership Changes

## Purpose

Review additions to security-enabled Active Directory and Windows groups.

## Event IDs

```text
4728
4732
4756
```

## Example Search

```text
data.win.system.eventID:(4728 OR 4732 OR 4756)
```

## Useful Fields

- `agent.name`
- `data.win.system.computer`
- `data.win.eventdata.memberName`
- `data.win.eventdata.memberSid`
- `data.win.eventdata.targetUserName`
- `data.win.eventdata.subjectUserName`
- `rule.id`
- `rule.level`

## Detection Context

During the controlled privilege-change scenario:

```text
helpdesk.test
```

was temporarily added to:

```text
Domain Admins
```

Windows generated Event ID:

```text
4728
```

Wazuh generated:

```text
Rule ID: 60159
Description: Domain Admins Group Changed
Level: 12
```

## Example High-Severity Search

```text
rule.id:60159
```

## Evidence

Relevant screenshot:

```text
screenshots/day3-wazuh-hunting-privilege-changes.png
```

---

# 5. Active Directory Object Activity

## Purpose

Review Active Directory object access and modification telemetry.

## Event IDs

```text
4662
5136
```

## Example Search

```text
data.win.system.eventID:(4662 OR 5136)
```

## Event 4662

Event ID 4662 indicates that an operation was performed on an Active Directory object.

Useful context includes:

- Object name
- Object type
- Subject account
- Access mask
- Properties accessed
- Domain Controller

The project generated Event ID 4662 by combining:

```text
Directory Service Access auditing
+
Object-level SACL
```

## Event 5136

Event ID 5136 records Active Directory object modifications and can be useful when investigating changes to directory objects.

## Evidence

Relevant screenshot:

```text
screenshots/day3-wazuh-hunting-ad-object-activity.png
```

---

# 6. Canary Authentication

## Purpose

Identify any authentication attempt involving the dedicated canary identity.

## Canary Account

```text
canary.admin
```

The account is intentionally:

- Disabled
- Non-privileged
- Not used for legitimate authentication

## Custom Detection

```text
rule.id:110150
```

## Example Search

```text
rule.id:110150
```

Alternative event-based search:

```text
data.win.system.eventID:4776 AND data.win.eventdata.targetUserName:"canary.admin"
```

## Expected Context

The controlled validation generated:

```text
Event ID: 4776
Target User: canary.admin
Source Workstation: WIN11-CLIENT
```

Custom Wazuh rule 110150 fired at Level 12.

## Useful Fields

- `agent.name`
- `data.win.system.eventID`
- `data.win.eventdata.targetUserName`
- `data.win.eventdata.workstation`
- `data.win.eventdata.status`
- `rule.id`
- `rule.level`

## Detection Value

Because the account has no legitimate authentication workflow, activity involving this identity should receive high investigation priority.

---

# 7. Network Reconnaissance

## Purpose

Review the custom Wazuh detection for repeated network service discovery activity.

## Custom Detection

```text
rule.id:110130
```

## Example Search

```text
rule.id:110130
```

## Detection Context

The controlled network reconnaissance scenario was generated from Kali against DC01.

The custom Wazuh rule used correlation:

```text
Frequency: 5
Timeframe: 10 seconds
```

This allowed repeated service-discovery activity to be treated differently from isolated normal network connections.

## Investigation Fields

Useful context includes:

- Source IP
- Source host
- Destination IP
- Destination port
- Process
- Agent
- Event frequency
- Rule ID
- Rule level

## False-Positive Validation

The detection was also tested while benign background activity was active.

Result:

```text
Controlled Nmap reconnaissance: Detected
Observed benign false positive: None during validation window
```

---

# 8. LDAP Event 1644

## Purpose

Review LDAP diagnostic search-performance telemetry when available.

## Event ID

```text
1644
```

## Example Search

```text
data.win.system.eventID:1644
```

## Project Status

Event ID 1644 was successfully generated locally on DC01 after temporary NTDS Field Engineering diagnostic logging was enabled.

However:

```text
Wazuh ingestion was not successfully confirmed.
```

Therefore this search is documented as a planned hunting view rather than an operational Wazuh view validated by the project.

The project does not claim successful Wazuh detection for Event ID 1644.

---

# 9. Recommended Analyst Workflow

When investigating an alert or suspicious event:

1. Confirm the correct endpoint or Domain Controller.
2. Confirm the Windows Event ID.
3. Review the username or target account.
4. Review source workstation and IP address.
5. Review the Wazuh rule ID and severity.
6. Check surrounding events in the same timeframe.
7. Determine whether the activity is expected.
8. Correlate with PowerShell, Sysmon, authentication, or directory-service telemetry.
9. Record the detection result.
10. Document any telemetry or alerting gap.

---

# 10. Detection Summary

| Hunting View | Primary Event / Rule | Status |
|---|---|---|
| Authentication Activity | 4624 / 4625 / 4771 / 4776 | Validated |
| Kerberos Service Tickets | 4769 | Validated |
| Kerberoasting Detection | Rule 110100 | Validated |
| PowerShell Activity | 4104 | Validated |
| PowerShell Recon Detection | Rule 110120 | Validated |
| Privileged Group Changes | 4728 / 4732 / 4756 | Validated |
| Domain Admins Change | Rule 60159 | Validated |
| AD Object Activity | 4662 / 5136 | Validated |
| Canary Authentication | Rule 110150 | Validated |
| Network Reconnaissance | Rule 110130 | Validated |
| LDAP Diagnostic Activity | 1644 | Local only / Wazuh gap |

---

# Final Status

The Wazuh hunting views provide repeatable analyst workflows for the major telemetry and detection scenarios implemented in the AD-LAB project.

The only documented hunting gap is LDAP Event ID 1644, which was generated locally but was not successfully confirmed in Wazuh.
