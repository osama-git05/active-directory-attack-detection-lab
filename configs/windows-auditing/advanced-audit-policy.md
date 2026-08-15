# Advanced Audit Policy Configuration

## Purpose

This document records the Windows Advanced Audit Policy settings used in the isolated `AD-LAB` environment to generate security telemetry for Wazuh, Windows Event Viewer, and detection validation.

The policy was applied primarily to:

- `DC01`
- `WIN11-CLIENT`

The goal was to ensure that authentication, account-management, process, Kerberos, and Active Directory events were generated during the controlled lab scenarios.

---

## Key Audit Categories

The following audit subcategories were enabled where required.

### Account Logon

- Credential Validation — Success and Failure
- Kerberos Authentication Service — Success and Failure
- Kerberos Service Ticket Operations — Success and Failure

These settings support events such as:

- `4768` — Kerberos authentication ticket requested
- `4769` — Kerberos service ticket requested
- `4771` — Kerberos pre-authentication failed
- `4776` — Credential validation

---

### Logon / Logoff

- Logon — Success and Failure
- Special Logon — Success

These settings support events such as:

- `4624` — Successful logon
- `4625` — Failed logon
- `4672` — Special privileges assigned to new logon

---

### Account Management

Relevant account and security-group auditing was enabled to monitor changes to Active Directory identities and privileged groups.

Important events include:

- `4720` — User account created
- `4722` — User account enabled
- `4725` — User account disabled
- `4726` — User account deleted
- `4728` — Member added to a security-enabled global group
- `4732` — Member added to a security-enabled local group
- `4756` — Member added to a security-enabled universal group

The privileged-group test in this project generated Event ID `4728` when `helpdesk.test` was temporarily added to `Domain Admins`.

---

### Detailed Tracking

- Process Creation — Success

This provides Windows process-creation visibility through:

- `4688` — A new process has been created

Sysmon Event ID `1` was also used for richer process-creation telemetry.

---

### Directory Service Access

- Directory Service Access — Success and Failure
- Directory Service Changes — Success

These settings support Active Directory object monitoring.

Important events include:

- `4662` — An operation was performed on an Active Directory object
- `5136` — A directory service object was modified

---

## Event ID 4662 Requirement

Enabling `Directory Service Access` auditing alone is not sufficient to generate useful Event ID `4662` telemetry.

An object-level System Access Control List (SACL) must also be configured on the Active Directory object being monitored.

For this project, a dedicated OU was created:

```text
OU=Test-Lab,DC=adlab,DC=test
```

The following auditing configuration was applied through Active Directory Users and Computers:

1. Enable **Advanced Features**.
2. Open the properties of the `Test-Lab` OU.
3. Open **Security**.
4. Select **Advanced**.
5. Open the **Auditing** tab.
6. Add the required principal.
7. Configure successful auditing for relevant read/write property operations.

A harmless OU modification was then used to validate auditing.

Example:

```powershell
Set-ADOrganizationalUnit `
  -Identity "OU=Test-Lab,DC=adlab,DC=test" `
  -Description "4662 audit validation"
```

The operation successfully generated Event ID `4662`.

The event was later confirmed in Wazuh and used in the Active Directory object hunting workflow.

---

## Validation Commands

Audit policy can be reviewed with:

```powershell
auditpol /get /category:*
```

Specific Directory Service Access configuration can be checked with:

```powershell
auditpol /get /subcategory:"Directory Service Access"
```

During validation, `Directory Service Access` showed:

```text
Success and Failure
```

---

## Relevant Event IDs Used in the Project

| Event ID | Description |
|---:|---|
| 4624 | Successful logon |
| 4625 | Failed logon |
| 4662 | Active Directory object access |
| 4672 | Special privileges assigned |
| 4688 | Process creation |
| 4728 | Member added to global security group |
| 4732 | Member added to local security group |
| 4756 | Member added to universal security group |
| 4768 | Kerberos TGT requested |
| 4769 | Kerberos service ticket requested |
| 4771 | Kerberos pre-authentication failure |
| 4776 | Credential validation |
| 5136 | Directory service object modified |

---

## Detection Scenarios Supported

The Advanced Audit Policy configuration supported the following project scenarios:

- Password spraying
- Kerberoasting
- Remote administrative logon
- Privileged group membership change
- Canary-account authentication
- Active Directory object auditing
- General authentication hunting

---

## Evidence

Relevant screenshots include:

- `../../screenshots/day3-audit-policy-1.png`
- `../../screenshots/day3-audit-policy-2.png`
- `../../screenshots/day3-directory-service-audit-policy.png`
- `../../screenshots/day3-directory-service-event4662.png`
- `../../screenshots/day3-advanced-ad-auditing-4662.png`
- `../../screenshots/day3-wazuh-directory-service-event4662.png`
- `../../screenshots/day3-wazuh-hunting-ad-object-activity.png`

---

## Final Status

**Validated**

The Advanced Audit Policy configuration successfully generated the Windows Security telemetry required for the lab's authentication, Kerberos, privilege-change, and Active Directory object-access detection scenarios.
