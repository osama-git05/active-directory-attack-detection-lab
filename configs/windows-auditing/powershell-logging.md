# PowerShell Logging Configuration

## Purpose

This document records the PowerShell logging configuration used in the isolated `AD-LAB` environment.

PowerShell logging was enabled to provide visibility into script and command execution during controlled Active Directory reconnaissance and detection testing.

The primary telemetry source used in this project was:

```text
Event ID 4104 — PowerShell Script Block Logging
```

PowerShell was treated as a legitimate administration tool.

Detection logic focused on the content and context of executed commands rather than simply alerting whenever `powershell.exe` was launched.

---

## Systems

PowerShell logging was configured on the Windows systems used in the lab, including:

- `DC01`
- `WIN11-CLIENT`

---

## Script Block Logging

PowerShell Script Block Logging was enabled through Group Policy.

Typical policy location:

```text
Computer Configuration
  -> Administrative Templates
  -> Windows Components
  -> Windows PowerShell
  -> Turn on PowerShell Script Block Logging
```

The policy was set to:

```text
Enabled
```

This allowed PowerShell script content to be recorded in:

```text
Microsoft-Windows-PowerShell/Operational
```

The primary event generated was:

```text
4104
```

---

## Event ID 4104

Event ID `4104` records PowerShell script-block content.

This provided visibility into commands used during Active Directory reconnaissance.

Examples used during controlled validation included:

```powershell
Get-ADDomain
Get-ADUser -Filter *
Get-ADGroup -Filter *
Get-ADGroupMember "Domain Admins"
```

These commands can be legitimate in administrative workflows, so the detection logic considered the context of their execution.

---

## Detection Engineering Use

The project implemented custom Wazuh rule:

```text
110120
```

The rule was designed to detect Active Directory reconnaissance keywords in PowerShell Script Block Logging.

The corresponding Sigma rule is stored at:

```text
detections/sigma/powershell-ad-recon.yml
```

The Sigma detection searches for commands including:

```text
Get-ADDomain
Get-ADUser
Get-ADGroup
Get-ADGroupMember
```

---

## Example Detection Context

Commands such as:

```powershell
Get-ADUser -Filter *
Get-ADGroup -Filter *
Get-ADGroupMember "Domain Admins"
```

may indicate discovery of:

- Domain users
- Domain groups
- Privileged identities
- Administrative group membership
- Potential high-value accounts

However, these commands can also be used by legitimate administrators.

The detection therefore requires investigation context such as:

- User account
- Source host
- Time of execution
- Number of commands
- Command sequence
- Whether the user normally performs Active Directory administration

---

## Additional Process Visibility

PowerShell activity was also supported by:

### Windows Security

```text
4688 — Process creation
```

when process-creation auditing was enabled.

### Sysmon

```text
Event ID 1 — Process creation
```

Sysmon provided additional process information that could be correlated with PowerShell Script Block Logging.

---

## Validation

A controlled PowerShell command was executed after logging was enabled.

PowerShell Operational logs successfully generated Event ID `4104`.

The event was observed locally and later ingested into Wazuh.

Custom Wazuh rule `110120` was successfully validated during the PowerShell Active Directory reconnaissance scenario.

---

## Wazuh Hunting

PowerShell activity was investigated using Wazuh searches based on:

```text
data.win.system.eventID:4104
```

The hunting workflow allowed analysts to inspect script-block content, host information, account context, and timestamps.

---

## False-Positive Considerations

Legitimate sources of similar PowerShell activity include:

- Active Directory administrators
- Helpdesk staff
- Inventory scripts
- Identity-management scripts
- Security auditing
- Domain troubleshooting
- Automated administration

Useful tuning fields include:

- Username
- Endpoint
- Script content
- Parent process
- Execution frequency
- Administrative role
- Time of day

---

## Evidence

Relevant screenshots include:

- `../../screenshots/day3-powershell-test-command.png`
- `../../screenshots/day3-powershell-4104-event.png`
- `../../screenshots/day3-win11-powershell-4104.png`
- `../../screenshots/day3-win11-workstation-logging-gpo.png`
- `../../screenshots/day3-wazuh-suspicious-powershell-dashboard-alert.png`
- `../../screenshots/day3-wazuh-hunting-powershell.png`

---

## Final Status

**Validated**

PowerShell Script Block Logging successfully generated Event ID `4104`, was ingested into Wazuh, and supported detection of controlled Active Directory reconnaissance through custom rule `110120`.
