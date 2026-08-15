# Active Directory Attack & Detection Lab

> An isolated Active Directory detection-engineering lab built with Windows Server 2022, Windows 11, Kali Linux, Sysmon, PowerShell logging, Wazuh SIEM, and Sigma. The project demonstrates the complete defensive workflow from telemetry generation and collection through custom detection engineering, threat hunting, false-positive validation, hardening, and post-remediation retesting.

![Architecture](active-directtory-attack-detection-lab/diagrams/architecture-detailed.png)

---

## Table of Contents

- [Architecture & Overview](#-architecture--overview)
- [Tech Stack & Tools](#-tech-stack--tools)
- [Key Features & Capabilities](#-key-features--capabilities)
- [Installation & Deployment](#-installation--deployment)
- [Telemetry, Logging & Detection](#-telemetry-logging--detection)
- [Detection Scenarios](#-detection-scenarios)
- [Detection Validation Matrix](#-detection-validation-matrix)
- [Threat Hunting](#-threat-hunting)
- [Benign Noise & False-Positive Validation](#-benign-noise--false-positive-validation)
- [Hardening & Retest](#-hardening--retest)
- [Repository Structure](#-repository-structure)
- [Source Code & Configuration Reference](#-source-code--configuration-reference)
- [Evidence Inventory](#-evidence-inventory)
- [Known Gaps & Repository Notes](#-known-gaps--repository-notes)
- [Security Scope](#-security-scope)
- [Future Improvements](#-future-improvements)
- [Portfolio Skills Demonstrated](#-portfolio-skills-demonstrated)

---

## 📌 Architecture & Overview

### Project Goal

This repository documents a controlled Active Directory attack-and-detection environment designed for defensive security and detection engineering.

The lab follows this workflow:

```text
Build
  ↓
Generate Controlled Activity
  ↓
Observe Windows / Sysmon Telemetry
  ↓
Ingest into Wazuh
  ↓
Detect / Correlate
  ↓
Investigate
  ↓
Tune
  ↓
Validate Against Benign Noise
  ↓
Harden
  ↓
Retest
  ↓
Document
```

The project deliberately goes beyond basic attack simulation by validating whether the expected endpoint events were generated, whether Wazuh received and correlated them, whether custom detections fired, and whether the same controls remained effective after hardening.

### Lab Systems

| System | Role | IP Address |
|---|---|---:|
| `DC01` | Windows Server 2022 Domain Controller / DNS | `10.10.10.10` |
| `WIN11-CLIENT` | Windows 11 domain workstation | `10.10.10.20` |
| `WAZUH` | Wazuh Manager / SIEM | `10.10.10.30` |
| `KALI` | Controlled security-testing workstation | `10.10.10.50` |

### Active Directory

```text
DNS Domain:       adlab.test
NetBIOS Domain:   ADLAB
Domain Controller: DC01
Lab Network:      AD-LAB
Subnet:           10.10.10.0/24
```

### Detection Pipeline

```text
KALI / WIN11-CLIENT
        │
        │ Controlled lab activity
        ▼
┌──────────────────────────────────┐
│ Windows Endpoints                │
│                                  │
│ • Windows Security Log           │
│ • PowerShell Operational Log     │
│ • Sysmon Operational Log         │
│ • Directory Service Log          │
└────────────────┬─────────────────┘
                 │
                 │ Wazuh agents / EventChannel
                 ▼
┌──────────────────────────────────┐
│ Wazuh                            │
│                                  │
│ • Event decoding                 │
│ • Built-in rules                 │
│ • Custom XML rules               │
│ • Correlation                    │
│ • Hunting / dashboard searches   │
└────────────────┬─────────────────┘
                 │
                 ▼
        Detection Validation
                 │
                 ├── Custom Wazuh detections
                 ├── Sigma detection-as-code
                 ├── Threat hunting
                 ├── False-positive checks
                 └── Hardening / retest
```

### Detailed Architecture

![Detailed Architecture](diagrams/architecture-detailed.png)

### Primary Identities Used

| Identity | Purpose | Final State |
|---|---|---|
| `bob.user` | Standard domain user | Enabled |
| `helpdesk.test` | Controlled privilege-change testing | Removed from `Domain Admins` after testing |
| `svc_web` | SPN-bearing service account for Kerberos testing | Strong unique lab password; non-administrative |
| `canary.admin` | High-signal authentication tripwire | Disabled; non-privileged |

The service account uses the SPN:

```text
HTTP/web.adlab.test
```

---

## 🛠 Tech Stack & Tools

### Infrastructure

- Oracle VirtualBox
- Windows Server 2022
- Windows 11
- Kali Linux
- Active Directory Domain Services
- DNS
- Group Policy

### Windows Telemetry

- Windows Security Event Log
- PowerShell Script Block Logging
- Sysmon
- Directory Service auditing
- NTDS Field Engineering diagnostics for temporary LDAP Event `1644` testing

### Detection & Analytics

- Wazuh Manager
- Wazuh Windows agents
- Wazuh custom XML rules
- Wazuh correlation rules
- Wazuh dashboard / Discover-style hunting workflows
- `wazuh-logtest`
- Sigma YAML detection rules

### Automation & Administration

- PowerShell
- ActiveDirectory PowerShell module
- `setspn`
- Windows Scheduled Tasks
- Git / GitHub

### Controlled Security Testing

- Kali Linux
- Nmap
- Kerberos service-ticket request testing
- PowerShell Remoting / WinRM
- Native Active Directory PowerShell cmdlets

---

## 🚀 Key Features & Capabilities

### Active Directory Infrastructure

- Windows Server 2022 Domain Controller
- `adlab.test` domain
- Windows 11 domain workstation
- Dedicated organizational structure for users and service accounts
- Lab service account with SPN
- Disabled canary identity
- Controlled privileged-group modification testing

### Endpoint Telemetry

- Windows authentication auditing
- Kerberos auditing
- Account-management auditing
- Directory Service Access auditing
- PowerShell Event `4104`
- Sysmon process, network, file, and DNS telemetry

### Custom Wazuh Rules

| Rule | Current XML Purpose | ATT&CK |
|---:|---|---|
| `110100` | RC4 Kerberos service ticket for a non-machine account | `T1558.003` |
| `110110` | Password spraying correlation from one source IP across different users | `T1110.003` |
| `110120` | Suspicious PowerShell script block containing execution/download/encoding patterns | `T1059.001` |
| `110129` | Hidden helper rule for inbound Sysmon Event `3` scan candidates | Supporting rule |
| `110130` | Network service scanning correlation across different destination ports | `T1046` |
| `110150` | Authentication attempt against `canary.admin` | `T1078` |

### Sigma Detection-as-Code

| File | Purpose | ATT&CK |
|---|---|---|
| `kerberoasting.yml` | RC4 Kerberos service-ticket behavior | `T1558.003` |
| `powershell-ad-recon.yml` | AD discovery via `Get-AD*` cmdlets | `T1087.002`, `T1069.002` |
| `privileged-group-change.yml` | Additions to privileged Windows / AD groups | `T1098` |

### Detection Validation

The repository includes a dedicated detection-validation matrix that distinguishes:

- Detected activity
- Telemetry-only validation
- Logged-but-not-alerted behavior
- Known ingestion gaps

### Benign Noise Validation

The project documents validation of two detections while normal background traffic was present:

- Network reconnaissance rule `110130`
- Canary authentication rule `110150`

The documented result is **no observed benign false positive during the controlled validation window**, not a claim of zero false positives in production.

### Hardening & Retest

After attack simulation and evidence collection:

- The weak `svc_web` lab password was replaced.
- `helpdesk.test` was removed from `Domain Admins`.
- `canary.admin` remained disabled.
- Temporary LDAP diagnostic verbosity was disabled.
- Sysmon and Wazuh monitoring remained active.
- Canary rule `110150` was successfully retested after hardening.

---

## 🔧 Installation & Deployment

> This repository contains configuration artifacts and documentation for the completed lab. It does **not** contain unattended installers for Windows Server, Windows 11, VirtualBox, Kali, or Wazuh.

### Prerequisites

Required infrastructure:

- Oracle VirtualBox
- Windows Server 2022 installation media
- Windows 11 installation media
- Kali Linux
- Wazuh server installation
- Sysmon
- PowerShell 5+ on Windows
- Active Directory PowerShell module on the Domain Controller
- Administrative access to the isolated lab VMs

### 1. Create the VirtualBox Lab Network

Create an isolated network named:

```text
AD-LAB
```

Use:

```text
10.10.10.0/24
```

Recommended static addressing used by this project:

```text
DC01          10.10.10.10
WIN11-CLIENT  10.10.10.20
WAZUH         10.10.10.30
KALI          10.10.10.50
```

### 2. Deploy DC01

Install Windows Server 2022 and configure:

```text
Hostname: DC01
IPv4:     10.10.10.10
DNS:      10.10.10.10
```

Install Active Directory Domain Services and DNS, then create:

```text
adlab.test
```

### 3. Create Lab Identities

The repository contains:

```text
automation/create-lab-users.ps1
```

It creates:

- `bob.user`
- `helpdesk.test`
- `svc_web`
- `canary.admin`

Passwords are requested interactively with `Read-Host -AsSecureString` and are not embedded in the script.

The script also configures:

```text
HTTP/web.adlab.test
```

on:

```text
ADLAB\svc_web
```

### 4. Deploy WIN11-CLIENT

Configure:

```text
Hostname: WIN11-CLIENT
IPv4:     10.10.10.20
DNS:      10.10.10.10
```

Join:

```text
adlab.test
```

### 5. Apply Windows Audit Configuration

Reference:

```text
configs/windows-auditing/advanced-audit-policy.md
```

The documented configuration covers:

- Credential Validation
- Kerberos Authentication Service
- Kerberos Service Ticket Operations
- Logon
- Special Logon
- Account Management
- Process Creation
- Directory Service Access
- Directory Service Changes

Validate policy with:

```powershell
auditpol /get /category:*
```

For Directory Service Access specifically:

```powershell
auditpol /get /subcategory:"Directory Service Access"
```

### 6. Enable PowerShell Script Block Logging

Reference:

```text
configs/windows-auditing/powershell-logging.md
```

Policy path:

```text
Computer Configuration
  -> Administrative Templates
  -> Windows Components
  -> Windows PowerShell
  -> Turn on PowerShell Script Block Logging
```

Expected event channel:

```text
Microsoft-Windows-PowerShell/Operational
```

Primary event:

```text
4104
```

### 7. Install Sysmon

Use:

```text
configs/sysmon/sysmon-config.xml
```

The current configuration enables collection for:

```text
1  - Process Create
3  - Network Connection
11 - File Create
22 - DNS Query
```

The current config is intentionally broad for the isolated lab.

### 8. Deploy Wazuh Agents

The repository-specific Wazuh agent configuration is:

```text
configs/wazuh/agent.conf
```

It explicitly adds EventChannel collection for:

```text
Microsoft-Windows-PowerShell/Operational
Microsoft-Windows-Sysmon/Operational
```

The project evidence also demonstrates Windows Security event ingestion, although that Security-channel configuration is not explicitly defined in the current repository `agent.conf`.

### 9. Deploy Custom Wazuh Rules

Use:

```text
detections/wazuh/local_rules.xml
```

Validate Wazuh rules using the manager-side testing utility documented in the project:

```text
/var/ossec/bin/wazuh-logtest
```

Live EventChannel events were also used as the primary validation method for several custom rules.

### 10. Add Sigma Rules

Portable rules are stored under:

```text
detections/sigma/
```

These YAML files document portable detection logic.

They are **not** represented as automatically executable Wazuh rules.

### 11. Configure Hunting Views

Use:

```text
dashboards/wazuh-saved-searches.md
```

to recreate searches for:

- Authentication
- Kerberos
- PowerShell
- Privileged-group changes
- AD object activity
- Canary authentication
- Network reconnaissance
- LDAP `1644` as a documented but unvalidated Wazuh hunt

---

## 📊 Telemetry, Logging & Detection

### Windows Security Events

| Event ID | Purpose in the Lab |
|---:|---|
| `4624` | Successful logon |
| `4625` | Failed logon |
| `4648` | Explicit credential use |
| `4662` | Audited Active Directory object access |
| `4672` | Special privileges assigned |
| `4688` | Process creation |
| `4728` | Member added to global security group |
| `4732` | Member added to local security group |
| `4756` | Member added to universal security group |
| `4768` | Kerberos TGT request |
| `4769` | Kerberos service-ticket request |
| `4771` | Kerberos pre-authentication failure |
| `4776` | Credential validation |
| `5136` | Directory service object modification |
| `5140` / `5145` | SMB / share activity |

### PowerShell

Primary event:

```text
4104 - Script Block Logging
```

The PowerShell configuration documentation includes controlled AD commands such as:

```powershell
Get-ADDomain
Get-ADUser -Filter *
Get-ADGroup -Filter *
Get-ADGroupMember "Domain Admins"
```

### Sysmon

The current configuration is intentionally broad and collects:

```text
Event 1  - Process Create
Event 3  - Network Connection
Event 11 - File Create
Event 22 - DNS Query
```

### Directory Service Auditing

#### Event 4662

The project demonstrates that `4662` requires both:

```text
Directory Service Access audit policy
+
Object-level SACL
```

The documented test object was:

```text
OU=Test-Lab,DC=adlab,DC=test
```

A harmless validation change was:

```powershell
Set-ADOrganizationalUnit `
  -Identity "OU=Test-Lab,DC=adlab,DC=test" `
  -Description "4662 audit validation"
```

Result:

```text
Event 4662 generated locally and searchable in Wazuh.
```

#### Event 1644

Temporary NTDS Field Engineering logging was used to generate:

```text
1644
```

Result:

```text
Local DC01 event: validated
Wazuh ingestion: not confirmed
```

Verbose diagnostics were disabled again after the test.

---

## 🎯 Detection Scenarios

### Test 01 — Network Reconnaissance

**Source**

```text
KALI - 10.10.10.50
```

**Target**

```text
DC01 - 10.10.10.10
```

Example controlled scan:

```bash
nmap -sV -Pn 10.10.10.10
```

Custom correlation:

```text
110129 -> helper candidate
110130 -> network scan correlation
```

Current rule `110130` requires:

```text
frequency = 5
timeframe = 10 seconds
same source IP
same destination IP
different destination ports
```

**Result:** ✅ Detected

Full report:

```text
reports/test-01-reconnaissance.md
```

---

### Test 02 — Password Spraying / Failed Authentication

Relevant telemetry:

```text
4625
4771
4776
```

Current Wazuh correlation rule:

```text
Rule: 110110
Frequency: 4
Timeframe: 120 seconds
Same source IP
Different target usernames
```

MITRE ATT&CK:

```text
T1110.003 - Password Spraying
```

**Result:** ✅ Detected

Full report:

```text
reports/test-02-password-spray.md
```

---

### Test 03 — Kerberoasting

Service account:

```text
svc_web
```

SPN:

```text
HTTP/web.adlab.test
```

Primary event:

```text
4769
```

Current Wazuh rule `110100` requires:

```text
Event ID: 4769
Ticket Encryption Type: 0x17
Target user must not end in $
```

MITRE ATT&CK:

```text
T1558.003 - Kerberoasting
```

**Result:** ✅ Detected

After testing, the intentionally weak lab password was replaced.

Full report:

```text
reports/test-03-kerberoasting.md
```

---

### Test 04 — PowerShell Activity

PowerShell Script Block Logging generated:

```text
4104
```

There are **two different PowerShell detection implementations in the current repository**:

#### Wazuh Rule `110120`

The live XML rule matches suspicious script-block patterns including:

```text
Invoke-Expression
IEX
DownloadString
Net.WebClient
FromBase64String
```

MITRE ATT&CK:

```text
T1059.001 - PowerShell
```

#### Sigma `powershell-ad-recon.yml`

The Sigma rule instead matches Active Directory discovery cmdlets:

```text
Get-ADDomain
Get-ADUser
Get-ADGroup
Get-ADGroupMember
```

MITRE ATT&CK:

```text
T1087.002 - Domain Account Discovery
T1069.002 - Domain Groups
```

This means the current Wazuh XML and Sigma YAML represent related but **not equivalent** PowerShell detections.

Project reports describe the PowerShell AD-recon scenario as detected.

Full report:

```text
reports/test-04-powershell.md
```

---

### Test 05 — Remote Administrative Logon

Controlled PowerShell Remoting / WinRM session:

```text
WIN11-CLIENT 10.10.10.20
        ->
DC01 10.10.10.10
```

Observed event:

```text
Event ID:       4624
Logon Type:     3
Account:        Administrator
Source IP:      10.10.10.20
Authentication: Kerberos
```

**Result:** 🟡 Logged but not alerted

The correct raw Windows event was confirmed locally.

The exact dedicated Wazuh alert for this specific event was **not** confirmed.

Full report:

```text
reports/test-05-lateral-movement.md
```

---

### Test 06 — Privileged Group Membership Change

Controlled change:

```text
helpdesk.test
    ->
Domain Admins
```

Windows event:

```text
4728
```

Confirmed Wazuh alert:

```text
Rule ID:     60159
Description: Domain Admins Group Changed
Level:       12
```

**Result:** ✅ Detected

The test account was removed from `Domain Admins` after evidence collection.

Full report:

```text
reports/test-06-privilege-change.md
```

---

### Canary Identity Tripwire

Canary account:

```text
canary.admin
```

Security state:

```text
Disabled
Non-privileged
No legitimate authentication workflow
```

Controlled event:

```text
Event ID: 4776
Target:   canary.admin
Source:   WIN11-CLIENT
```

Custom Wazuh detection:

```text
Rule ID: 110150
Level:   12
MITRE:   T1078
```

**Result:** ✅ Detected

The same rule was successfully retested after hardening and while benign background traffic was active.

---

## 📈 Detection Validation Matrix

| ID | Scenario | Expected / Observed Telemetry | Detection Result | Final Status |
|---|---|---|---|---|
| `ADLAB-001` | Failed authentication / password spray | `4625` / `4771` / `4776` | Wazuh `110110` | ✅ Detected |
| `ADLAB-002` | Kerberoasting | `4769` | Wazuh `110100` | ✅ Detected |
| `ADLAB-003` | PowerShell scenario | `4104` / Sysmon | Wazuh `110120` documented in reports | ✅ Detected in project validation |
| `ADLAB-004` | Privileged group change | `4728` | Wazuh `60159`, Level 12 | ✅ Detected |
| `ADLAB-005` | Canary authentication | `4776` | Wazuh `110150`, Level 12 | ✅ Detected |
| `ADLAB-006` | Remote administrative logon | `4624`, Type 3 | Exact dedicated alert not confirmed | 🟡 Logged but not alerted |
| `ADLAB-007` | AD object access | `4662` | Searchable in Wazuh | ✅ Telemetry validated |
| `ADLAB-008` | LDAP diagnostic query | `1644` | Local event only | 🟡 Wazuh ingestion gap |

Source:

```text
reports/detection-validation-matrix.md
```

---

## 🔎 Threat Hunting

The repository contains:

```text
dashboards/wazuh-saved-searches.md
```

### Authentication

```text
data.win.system.eventID:(4624 OR 4625 OR 4771 OR 4776)
```

Useful fields include:

```text
agent.name
data.win.system.computer
data.win.system.eventID
data.win.eventdata.targetUserName
data.win.eventdata.subjectUserName
data.win.eventdata.ipAddress
data.win.eventdata.workstation
data.win.eventdata.logonType
data.win.eventdata.status
rule.id
rule.level
```

### Kerberos

```text
data.win.system.eventID:4769
```

Custom rule search:

```text
rule.id:110100
```

### PowerShell

```text
data.win.system.eventID:4104
```

Custom rule search:

```text
rule.id:110120
```

### Privileged Group Changes

```text
data.win.system.eventID:(4728 OR 4732 OR 4756)
```

High-severity Domain Admins change:

```text
rule.id:60159
```

### Active Directory Object Activity

```text
data.win.system.eventID:(4662 OR 5136)
```

### Canary Authentication

```text
rule.id:110150
```

Alternative:

```text
data.win.system.eventID:4776 AND data.win.eventdata.targetUserName:"canary.admin"
```

### Network Reconnaissance

```text
rule.id:110130
```

### LDAP 1644

Documented search:

```text
data.win.system.eventID:1644
```

This search is documented as a planned hunt because Wazuh ingestion of the event was not successfully confirmed.

---

## 🌐 Benign Noise & False-Positive Validation

The project reports document a benign-noise workflow executed from `WIN11-CLIENT`.

Documented background activity included:

- DNS lookups
- ICMP reachability
- SYSVOL reads
- NETLOGON reads
- Normal PowerShell activity

### Validation Results

| Detection | Controlled Activity | Observed Benign False Positive |
|---|---|---|
| Network reconnaissance `110130` | Detected | None observed |
| Canary authentication `110150` | Detected | None observed |

The correct interpretation is:

> No false positive was observed during the controlled validation period.

This does **not** prove a zero false-positive rate in a real enterprise.

Detailed report:

```text
reports/noise-baseline.md
```

---

## 🛡 Hardening & Retest

### `svc_web`

Before:

```text
SPN-bearing lab service account
Deliberately weak test password
```

After:

```text
Strong unique lab password
Non-administrative
Domain Users membership
```

### `helpdesk.test`

Temporary state:

```text
Domain Admins
```

Final state:

```text
Removed from Domain Admins
```

### `canary.admin`

Final state:

```text
Enabled: False
Non-privileged
```

### LDAP Diagnostics

Temporary state:

```text
15 Field Engineering = 5
```

Final state:

```text
15 Field Engineering = 0
```

The temporary LDAP search threshold was also removed.

### Monitoring

The project documentation records that, after hardening:

```text
Sysmon DC01          Running
Sysmon WIN11-CLIENT  Running
Wazuh DC01           Running
Wazuh WIN11-CLIENT   Running
```

### Post-Hardening Retest

Rule:

```text
110150
```

was triggered again after hardening.

**Result:** ✅ Detection pipeline remained operational.

---

## 📁 Repository Structure

The current repository contains the following major artifacts:

```text
active-directory-attack-detection-lab/
│
├── README.md
├── .gitignore
│
├── automation/
│   ├── benign-noise.ps1
│   ├── create-lab-users.ps1
│   └── scheduled-task-setup.ps1
│
├── configs/
│   ├── sysmon/
│   │   └── sysmon-config.xml
│   │
│   ├── windows-auditing/
│   │   ├── advanced-audit-policy.md
│   │   └── powershell-logging.md
│   │
│   └── wazuh/
│       └── agent.conf
│
├── detections/
│   ├── wazuh/
│   │   └── local_rules.xml
│   │
│   └── sigma/
│       ├── kerberoasting.yml
│       ├── powershell-ad-recon.yml
│       └── privileged-group-change.yml
│
├── dashboards/
│   └── wazuh-saved-searches.md
│
├── diagrams/
│   ├── architecture.png
│   └── architecture-detailed.png
│
├── reports/
│   ├── detection-validation-matrix.md
│   ├── final-summary.md
│   ├── noise-baseline.md
│   ├── test-01-reconnaissance.md
│   ├── test-02-password-spray.md
│   ├── test-03-kerberoasting.md
│   ├── test-04-powershell.md
│   ├── test-05-lateral-movement.md
│   └── test-06-privilege-change.md
│
└── screenshots/
    └── evidence from setup, telemetry, detections,
        hunting, tuning, hardening, and retesting
```

### File Purpose Reference

| Path | Purpose |
|---|---|
| `automation/create-lab-users.ps1` | Creates core AD lab users, the service account, SPN, and disabled canary account |
| `automation/benign-noise.ps1` | Present in repository, currently empty on `main` |
| `automation/scheduled-task-setup.ps1` | Present in repository, currently empty on `main` |
| `configs/sysmon/sysmon-config.xml` | Broad Sysmon process/network/file/DNS collection |
| `configs/windows-auditing/advanced-audit-policy.md` | Advanced audit-policy design and 4662 SACL validation |
| `configs/windows-auditing/powershell-logging.md` | PowerShell Script Block Logging configuration |
| `configs/wazuh/agent.conf` | Explicit PowerShell and Sysmon EventChannel collection |
| `detections/wazuh/local_rules.xml` | Custom operational Wazuh rules |
| `detections/sigma/kerberoasting.yml` | Portable Kerberoasting detection |
| `detections/sigma/powershell-ad-recon.yml` | Portable PowerShell AD discovery detection |
| `detections/sigma/privileged-group-change.yml` | Portable privileged-group change detection |
| `dashboards/wazuh-saved-searches.md` | Repeatable threat-hunting queries |
| `reports/*.md` | Detection test reports, validation matrix, noise analysis, and final summary |
| `diagrams/*.png` | Architecture diagrams |
| `screenshots/*.png` | Evidence archive |

---

## 💻 Source Code & Configuration Reference

### `automation/create-lab-users.ps1`

```powershell
Import-Module ActiveDirectory

$domain = "DC=adlab,DC=test"

# Bob
$BobPassword = Read-Host "Enter password for bob.user" -AsSecureString

New-ADUser `
    -Name "Bob User" `
    -GivenName "Bob" `
    -Surname "User" `
    -SamAccountName "bob.user" `
    -UserPrincipalName "bob.user@adlab.test" `
    -Path "OU=Lab Users,$domain" `
    -AccountPassword $BobPassword `
    -Enabled $true `
    -PasswordNeverExpires $true

# Helpdesk
$HelpdeskPassword = Read-Host "Enter password for helpdesk.test" -AsSecureString

New-ADUser `
    -Name "Helpdesk Test" `
    -SamAccountName "helpdesk.test" `
    -UserPrincipalName "helpdesk.test@adlab.test" `
    -Path "OU=Lab Users,$domain" `
    -AccountPassword $HelpdeskPassword `
    -Enabled $true `
    -PasswordNeverExpires $true

# Service account
$SvcPassword = Read-Host "Enter LAB-ONLY password for svc_web" -AsSecureString

New-ADUser `
    -Name "svc_web" `
    -SamAccountName "svc_web" `
    -UserPrincipalName "svc_web@adlab.test" `
    -Path "OU=Service Accounts,$domain" `
    -AccountPassword $SvcPassword `
    -Enabled $true `
    -PasswordNeverExpires $true

# Kerberoasting test SPN
setspn -S HTTP/web.adlab.test ADLAB\svc_web

# Canary identity
$CanaryPassword = Read-Host "Enter strong password for canary.admin" -AsSecureString

New-ADUser `
    -Name "Canary Admin" `
    -SamAccountName "canary.admin" `
    -UserPrincipalName "canary.admin@adlab.test" `
    -Path "OU=Lab Users,$domain" `
    -AccountPassword $CanaryPassword `
    -Enabled $false
```

### `automation/benign-noise.ps1`

Current repository state:

```text
0 bytes / no source code currently stored on main
```

The reports and screenshots document that a benign-noise workflow was used during validation, but the executable script content is not currently present in the repository.

### `automation/scheduled-task-setup.ps1`

Current repository state:

```text
0 bytes / no source code currently stored on main
```

Screenshots document scheduled benign-noise execution, but the task-creation script content is not currently present in the repository.

### `configs/sysmon/sysmon-config.xml`

```xml
<Sysmon schemaversion="4.90">
  <!--
    AD-LAB Sysmon Configuration
    Purpose:
      - Process creation telemetry (Event ID 1)
      - Network connection telemetry (Event ID 3)
      - File creation telemetry (Event ID 11)
      - DNS query telemetry (Event ID 22)

    This configuration is intentionally broad for an isolated detection-engineering lab.
  -->

  <HashAlgorithms>sha256,imphash</HashAlgorithms>

  <EventFiltering>

    <!-- Event ID 1: Process creation -->
    <ProcessCreate onmatch="exclude" />

    <!-- Event ID 3: Network connections -->
    <NetworkConnect onmatch="exclude" />

    <!-- Event ID 11: File creation -->
    <FileCreate onmatch="exclude" />

    <!-- Event ID 22: DNS queries -->
    <DnsQuery onmatch="exclude" />

  </EventFiltering>
</Sysmon>
```

### `configs/wazuh/agent.conf`

```xml
<agent_config os="Windows">

  <localfile>
    <location>Microsoft-Windows-PowerShell/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>

  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>

</agent_config>
```

### `detections/wazuh/local_rules.xml`

```xml
<group name="adlab,windows,kerberos,">

  <rule id="110100" level="10">

    <if_group>authentication_success</if_group>

    <field name="win.system.eventID">^4769$</field>

    <field name="win.eventdata.ticketEncryptionType">^0x17$</field>

    <field name="win.eventdata.targetUserName"
           type="pcre2">^[^$]+$</field>

    <description>ADLAB: Possible Kerberoasting - RC4 Kerberos service ticket requested by non-machine account $(win.eventdata.targetUserName)</description>
    <mitre>
      <id>T1558.003</id>
    </mitre>

    <group>kerberoasting,credential_access,</group>

  </rule>

</group>

<group name="adlab,windows,authentication,">

  <rule id="110110" level="12" frequency="4" timeframe="120">
    <if_matched_sid>60122</if_matched_sid>

    <same_field>win.eventdata.ipAddress</same_field>
    <different_field>win.eventdata.targetUserName</different_field>
    <description>ADLAB: Possible password spraying - multiple user accounts failed authentication from the same source IP</description>

    <mitre>
      <id>T1110.003</id>
    </mitre>

    <group>password_spray,authentication_failed,credential_access,</group>
  </rule>

</group>

<group name="adlab,powershell,windows,">

  <rule id="110120" level="10">

    <if_sid>91802</if_sid>
    <field name="win.eventdata.scriptBlockText"
           type="pcre2">(?i)(Invoke-Expression|\bIEX\b|DownloadString|Net\.WebClient|FromBase64String)</field>

    <description>ADLAB: Suspicious PowerShell script block execution detected</description>

    <mitre>
      <id>T1059.001</id>
    </mitre>

    <group>powershell,suspicious_script,execution,</group>

  </rule>

</group>

<group name="adlab,windows,sysmon,reconnaissance,">

  <!--
    Helper rule:
    Track inbound Sysmon Event ID 3 network connections.
    Level 1 is required so the event can be used for correlation.
    no_log prevents these individual helper events from cluttering alerts.
  -->
  <rule id="110129" level="1">
    <if_group>sysmon_event3</if_group>

    <field name="win.system.eventID">^3$</field>
    <field name="win.eventdata.initiated">^false$</field>

    <description>ADLAB: Sysmon inbound connection candidate for network scan correlation</description>
    <options>no_log</options>

    <group>network_scan_candidate,</group>
  </rule>

  <!--
    Correlation rule:
    Same source scans the same destination across multiple different ports.
  -->
  <rule id="110130" level="10" frequency="5" timeframe="10">

    <if_matched_sid>110129</if_matched_sid>

    <same_field>win.eventdata.sourceIp</same_field>
    <same_field>win.eventdata.destinationIp</same_field>
    <different_field>win.eventdata.destinationPort</different_field>
    <description>ADLAB: Possible network service scanning from $(win.eventdata.sourceIp) against $(win.eventdata.destinationIp)</description>

    <mitre>
      <id>T1046</id>
    </mitre>

    <group>network_service_discovery,reconnaissance,discovery,</group>

  </rule>

</group>

<group name="windows,authentication,adlab,canary,">

  <rule id="110150" level="12">
    <if_sid>60104</if_sid>
    <field name="win.system.eventID">^4776$</field>
    <field name="win.eventdata.targetUserName" type="pcre2">(?i)^canary\.admin$</field>
    <description>ADLAB: Authentication attempt against canary account $(win.eventdata.targetUserName) from $(win.eventdata.workstation)</description>
    <mitre>
      <id>T1078</id>
    </mitre>
  </rule>

</group>
```

### `detections/sigma/kerberoasting.yml`

```yaml
title: ADLAB Suspicious Kerberos Service Ticket Request
id: 872cd075-73bb-42e4-9e84-a2fa5ea05f42
status: experimental
description: Detects a Kerberos service ticket request using RC4 encryption for a non-machine account in the AD-LAB environment.

logsource:
  product: windows
  service: security

detection:
  selection:
    EventID: 4769
    TicketEncryptionType: '0x17'

  filter_machine_accounts:
    TargetUserName|endswith: '$'

  condition: selection and not filter_machine_accounts

falsepositives:
  - Legacy applications or service accounts that legitimately use RC4 Kerberos tickets

level: high

tags:
  - attack.credential-access
  - attack.t1558.003
```

### `detections/sigma/powershell-ad-recon.yml`

```yaml
title: ADLAB PowerShell Active Directory Reconnaissance
id: 5b21c53a-6db1-4bf9-95fa-74b92bcdd102
status: experimental
description: Detects PowerShell Active Directory discovery commands used during the controlled AD-LAB reconnaissance scenario.

logsource:
  product: windows
  service: powershell

detection:
  selection:
    ScriptBlockText|contains:
      - 'Get-ADDomain'
      - 'Get-ADUser'
      - 'Get-ADGroup'
      - 'Get-ADGroupMember'

  condition: selection

falsepositives:
  - Legitimate Active Directory administration or inventory scripts

level: medium

tags:
  - attack.discovery
  - attack.t1087.002
  - attack.t1069.002
```

### `detections/sigma/privileged-group-change.yml`

```yaml
title: ADLAB Privileged Group Membership Change
id: 3dd9d429-bbe3-4b9f-b3b4-24eb0cfec04a
status: experimental
description: Detects a user being added to a privileged Windows or Active Directory security group in the AD-LAB environment.

logsource:
  product: windows
  service: security

detection:
  selection_event:
    EventID:
      - 4728
      - 4732
      - 4756

  selection_group:
    TargetUserName|contains:
      - 'Domain Admins'
      - 'Enterprise Admins'
      - 'Administrators'

  condition: selection_event and selection_group

falsepositives:
  - Authorized administrative group membership changes
  - Planned account provisioning or maintenance

level: high

tags:
  - attack.persistence
  - attack.privilege-escalation
  - attack.t1098
```

### `.gitignore`

```gitignore
# Credentials / secrets
.env
*.key
*.pem
credentials*
passwords*
secrets*

# VirtualBox / VM files
*.vdi
*.vmdk
*.ova
*.iso

# Logs / temporary
*.log
*.tmp
Thumbs.db
.DS_Storedesktop.ini
desktop.ini
```

---

## 🖼 Evidence Inventory

### Canary

```text
advanced-canary-account-4776.png
advanced-canary-account-event-details.png
advanced-canary-account-wazuh-4776.png
advanced-canary-attempt.png
advanced-canary-custom-rule-110150.png
canary-account-disabled.png
```

### Day 1 — Domain Controller

```text
day1-ad-ds-installed.png
day1-dc01-ip-hostname.png
day1-domain-controller.png
day1-virtualbox-ad-lab-network.png
```

### Day 2 — Domain & Identity Setup

```text
day2-domain-join.png
day2-domain-user-login.png
day2-ou-structure.png
day2-svc-web-spn.png
day2-workstation-ou.png
```

### Day 3 — Windows Auditing & Telemetry

```text
day3-advanced-ad-auditing-4662.png
day3-audit-policy-1.png
day3-audit-policy-2.png
day3-dc01-gpo-result.png
day3-directory-service-audit-policy.png
day3-directory-service-event4662.png
day3-encoded-powershell-test-command.png
day3-kerberoasting-event4769-rc4.png
day3-kerberos-service-ticket.png
day3-ldap-1644.png
day3-powershell-4104-event.png
day3-powershell-test-command.png
day3-sysmon-dc01-config-validation.png
day3-sysmon-dc01-event1.png
day3-sysmon-win11-dns-event22.png
day3-sysmon-win11-event1.png
day3-sysmon-win11-running.png
day3-win11-powershell-4104.png
day3-win11-workstation-logging-gpo.png
```

### Day 3 — Wazuh

```text
day3-wazuh-adlab-connectivity.png
day3-wazuh-agents-status.png
day3-wazuh-all-agents-active.png
day3-wazuh-dashboard.png
day3-wazuh-dc01-agent-active.png
day3-wazuh-dc01-agent-deployment.png
day3-wazuh-dc01-agent-running.png
day3-wazuh-directory-service-event4662.png
day3-wazuh-encoded-powershell-dashboard-alert.png
day3-wazuh-failed-logon-detection.png
day3-wazuh-hunting-ad-object-activity.png
day3-wazuh-hunting-authentication.png
day3-wazuh-hunting-kerberos.png
day3-wazuh-hunting-powershell.png
day3-wazuh-hunting-privilege-changes.png
day3-wazuh-kerberoasting-dashboard-alert.png
day3-wazuh-kerberoasting-live-detection.png
day3-wazuh-kerberoasting-rule-logtest.png
day3-wazuh-networking.png
day3-wazuh-password-spray-dashboard-alert.png
day3-wazuh-suspicious-powershell-dashboard-alert.png
```

### Day 4 — Reconnaissance & Noise

```text
day4-benign-baseline-event-distribution.png
day4-benign-baseline-script.png
day4-benign-noise-automated-run.png
day4-benign-noise-scheduled-task.png
day4-dc01-kali-multiport-recon.png
day4-dc01-sysmon-kali-recon.png
day4-kali-dc01-connectivity.png
day4-kali-dc01-service-recon.png
day4-kali-dns-route.png
day4-wazuh-kali-recon-telemetry.png
day4-wazuh-network-scan-benign-false-positive.png
day4-wazuh-network-scan-false-positive-check.png
day4-wazuh-network-scan-tuned-detection.png
day4-wazuh-network-service-scan-dashboard-alert.png
```

### Day 7 — Hardening & Retest

```text
day7-canary-noise-validation.png
day7-hardening-account-state.png
day7-retest-canary-detection.png
```

### Tests 05 & 06

```text
test-05-remote-logon-4624.png
test-06-domain-admins-wazuh-rule-60159.png
test-06-group-change-4728.png
test-06-group-change-wazuh.png
```

### Rule Testing

```text
wazuh-logtest-validation-tool.png
```

---

## ⚠ Known Gaps & Repository Notes

### 1. Remote Type-3 Logon

The controlled remote administrative session generated:

```text
4624 / Logon Type 3
```

locally on DC01.

The exact corresponding dedicated Wazuh alert was not confirmed.

Status:

```text
Logged but not alerted
```

### 2. LDAP Event 1644

LDAP Field Engineering diagnostics successfully generated:

```text
1644
```

locally.

Wazuh ingestion was not successfully confirmed.

Status:

```text
Local telemetry validated / Wazuh ingestion gap
```

### 3. PowerShell Detection Logic Mismatch

The current repository contains two different PowerShell detection concepts:

```text
Wazuh 110120:
Invoke-Expression / IEX / DownloadString /
Net.WebClient / FromBase64String
```

versus:

```text
Sigma powershell-ad-recon.yml:
Get-ADDomain / Get-ADUser /
Get-ADGroup / Get-ADGroupMember
```

They should therefore be treated as separate detections unless the XML rule is updated to match the Sigma logic.

### 4. Empty Automation Files

At the time this document was generated, the live `main` branch contains:

```text
automation/benign-noise.ps1
automation/scheduled-task-setup.ps1
```

as zero-byte files.

The repository reports and screenshots provide evidence that benign-noise automation and a scheduled task were used during testing, but the corresponding script source is not currently preserved in those two files.

### 5. Wazuh Agent Configuration Scope

The current repository `configs/wazuh/agent.conf` explicitly configures:

```text
PowerShell Operational
Sysmon Operational
```

Windows Security telemetry is clearly present in project evidence, but its collection configuration is not explicitly documented in the current `agent.conf`.

### 6. Dedicated LDAP / SACL Files

The current repository contains:

```text
advanced-audit-policy.md
powershell-logging.md
```

under `configs/windows-auditing/`.

The 4662 SACL procedure is included inside `advanced-audit-policy.md`.

A separate current `directory-service-sacl.md` or `ldap-1644.md` file is not required by this document and is not represented as present.

### 7. Detection Latency

The project does not claim precise detection latency because exact timing measurements were not recorded consistently.

This is intentionally left as a future improvement rather than inventing values.

---

## 🔐 Security Scope

All activity was performed inside an isolated, authorized lab environment.

The project deliberately excludes:

- LSASS credential dumping
- DCSync
- Golden Ticket
- Silver Ticket
- Ransomware
- Destructive payloads
- Persistence against real systems
- Evasion against real systems
- Public targets
- Production networks
- Real credentials

Credentials used in the lab are not stored in the repository.

The `.gitignore` excludes common:

```text
.env
*.key
*.pem
credentials*
passwords*
secrets*
```

files, as well as VirtualBox VM images and temporary logs.

---

## 🧭 Future Improvements

Potential next steps include:

- Add a second Domain Controller.
- Add Windows Event Forwarding.
- Preserve the benign-noise script source in `automation/benign-noise.ps1`.
- Preserve the scheduled-task setup source in `automation/scheduled-task-setup.ps1`.
- Align Wazuh rule `110120` with the Sigma AD-recon detection or document them as separate detections.
- Add CI validation for Wazuh XML.
- Add CI validation for Sigma YAML.
- Improve LDAP Event `1644` Wazuh ingestion.
- Engineer a dedicated privileged Type-3 remote-logon detection.
- Add measured alert latency.
- Add more repeatable detection regression tests.
- Add a Group Managed Service Account comparison.
- Add a second SIEM backend for Sigma translation.
- Add EDR or identity-focused telemetry.

---

## 🎓 Portfolio Skills Demonstrated

This project demonstrates hands-on experience with:

- Active Directory administration
- Windows Server 2022
- Windows 11 domain integration
- DNS
- Group Policy
- Windows Advanced Audit Policy
- Windows Security Event Logs
- Kerberos
- Service Principal Names
- LDAP diagnostic logging
- Object-level SACL auditing
- Sysmon
- PowerShell Script Block Logging
- Wazuh SIEM
- Wazuh EventChannel collection
- Custom Wazuh XML rules
- Correlation rules
- Sigma detection-as-code
- MITRE ATT&CK mapping
- Threat hunting
- Authentication investigation
- Privileged-group monitoring
- Canary identities
- False-positive validation
- Benign-noise testing
- Detection tuning
- Security hardening
- Post-remediation validation
- Git / GitHub
- Technical documentation
- Evidence-based security reporting

---

## Final Project Outcome

The strongest outcome of this lab is not any individual simulated attack.

It is the complete detection-engineering lifecycle:

```text
Infrastructure
     +
Telemetry
     +
Controlled Security Activity
     +
SIEM Ingestion
     +
Custom Detection
     +
Threat Hunting
     +
False-Positive Testing
     +
Hardening
     +
Retesting
     +
Transparent Documentation
```

The repository documents both successful detections and unsuccessful monitoring paths.

That distinction is important: the project does not present every generated Windows event as a successful SIEM detection.

The remote Type-3 logon and LDAP `1644` ingestion gaps remain visible, while the validated Wazuh rules, canary tripwire, 4662 auditing, benign-noise testing, and post-hardening retest demonstrate the successful portions of the detection pipeline.

---

## Disclaimer

This repository is intended solely for educational, defensive-security, detection-engineering, and authorized laboratory use.

All testing was performed against systems deliberately created for the isolated `AD-LAB` environment.
