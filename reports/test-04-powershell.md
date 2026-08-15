# Test 04 - Suspicious PowerShell Active Directory Reconnaissance

## Objective

Generate controlled Active Directory discovery activity using PowerShell and determine whether PowerShell logging, Sysmon, and Wazuh provide sufficient visibility for investigation.

## Lab Scope

- Environment: AD-LAB
- Windows systems: DC01 / WIN11-CLIENT
- Accounts: Lab domain identities only
- Authorization: Local isolated lab only

## Technique / MITRE ATT&CK

Relevant techniques include:

- T1059.001 - PowerShell
- T1087.002 - Domain Account Discovery
- T1069.002 - Domain Groups

## Controlled Action

Controlled Active Directory enumeration commands included:

```powershell
Get-ADDomain
Get-ADUser -Filter * | Select-Object SamAccountName
Get-ADGroup -Filter * | Select-Object Name
Get-ADGroupMember "Domain Admins"
```

The commands were executed only against the private AD-LAB domain.

## Expected Telemetry

Expected telemetry included:

- PowerShell Event ID 4104
- Windows process creation telemetry
- Security Event ID 4688 where configured
- Sysmon Event ID 1
- Wazuh PowerShell and process telemetry

Important investigation fields included:

- User
- Host
- Script block
- Command line
- Process
- Parent process
- Timestamp

## Actual Evidence

PowerShell Script Block Logging successfully generated Event ID 4104.

Wazuh successfully ingested PowerShell telemetry.

Sysmon process telemetry was also available for investigation.

The controlled Active Directory reconnaissance commands produced sufficient context to investigate the enumeration behavior.

## Detection Logic

Custom Wazuh rule:

```text
110120
```

A corresponding Sigma detection was created:

```text
detections/sigma/powershell-ad-recon.yml
```

The detection focused on Active Directory reconnaissance commands rather than treating every PowerShell process as malicious.

## Detection Validation

- PowerShell logging enabled: Yes
- Event ID 4104 observed: Yes
- Sysmon telemetry available: Yes
- Wazuh ingestion confirmed: Yes
- Custom Wazuh detection observed: Yes
- Rule ID: 110120
- Sigma rule created: Yes
- Final status: Detected

## Analysis

PowerShell is a legitimate Windows administration tool.

The presence of `powershell.exe` alone does not indicate malicious behavior.

Suspicion came from the commands and their context.

Commands such as:

```text
Get-ADUser
Get-ADGroup
Get-ADGroupMember
```

may be legitimate when used by administrators but may also allow attackers to identify:

- Domain users
- Group memberships
- Privileged identities
- Administrative structure
- Potential targets

Detection quality therefore depends on correlation between:

- Account
- Host
- Command content
- Execution frequency
- Administrative role
- Surrounding authentication activity

## False Positives / Tuning

Possible legitimate sources include:

- Helpdesk administration
- Inventory scripts
- Identity-management automation
- Security auditing
- Domain troubleshooting

Useful tuning considerations include:

- Expected administrator accounts
- Approved management hosts
- Number of discovery commands
- Command breadth
- Execution frequency
- Time of day
- Related authentication behavior

## Security Risk

Active Directory reconnaissance allows an attacker to map the domain before attempting later privilege escalation or lateral movement.

Discovery may reveal:

- Domain administrators
- Service accounts
- Group memberships
- High-value users
- Potential attack paths

## Mitigation

Recommended controls include:

- PowerShell Script Block Logging
- Process creation auditing
- Sysmon
- SIEM monitoring
- Least privilege
- Separate administrative accounts
- Administrative workstation controls
- Monitoring unusual AD enumeration
- Correlating discovery activity with authentication anomalies

## Evidence

- `../screenshots/test-04-powershell.png`
- `../screenshots/day3-powershell-4104-event.png`
- `../screenshots/day3-wazuh-hunting-powershell.png`

## Final Result

**Detected**

Controlled Active Directory reconnaissance generated PowerShell Script Block telemetry and was successfully identified using custom Wazuh rule 110120.

The scenario demonstrated that PowerShell detection should focus on behavior and context rather than treating PowerShell itself as malicious.
