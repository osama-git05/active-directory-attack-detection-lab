# AD-LAB Detection Validation Matrix

This matrix records the final validation state of the detections and telemetry tested in the Active Directory Attack & Detection Lab.

| ID | Scenario | Expected Telemetry | Wazuh / Detection Result | Final Status |
|---|---|---|---|---|
| ADLAB-001 | Failed authentication / password spray | 4625 / 4771 / 4776 | Custom Wazuh rule 110110 | Detected |
| ADLAB-002 | Kerberoasting | 4769 | Custom Wazuh rule 110100 | Detected |
| ADLAB-003 | PowerShell Active Directory reconnaissance | 4104 / Sysmon Event 1 | Custom Wazuh rule 110120 | Detected |
| ADLAB-004 | Privileged group membership change | 4728 | Wazuh rule 60159, Level 12 | Detected |
| ADLAB-005 | Canary authentication | 4776 | Custom Wazuh rule 110150, Level 12 | Detected |
| ADLAB-006 | Remote administrative logon | 4624, Logon Type 3 | Exact dedicated Wazuh alert not confirmed | Logged but not alerted |
| ADLAB-007 | Active Directory object access | 4662 | Searchable in Wazuh | Telemetry validated |
| ADLAB-008 | LDAP diagnostic query | 1644 | Local DC01 event observed; Wazuh ingestion not confirmed | Telemetry gap |

## Validation Notes

### ADLAB-001 - Password Spray

A controlled sequence of failed authentication attempts generated the expected authentication telemetry.

Custom Wazuh rule 110110 used frequency and timeframe correlation to distinguish repeated failures from isolated password mistakes.

Result:

**Detected**

---

### ADLAB-002 - Kerberoasting

The `svc_web` account was configured with the SPN:

`HTTP/web.adlab.test`

A controlled Kerberos service ticket request generated Event ID 4769 and matched custom Wazuh rule 110100.

Result:

**Detected**

---

### ADLAB-003 - PowerShell Active Directory Reconnaissance

Controlled Active Directory enumeration commands generated PowerShell Script Block Logging Event ID 4104 and supporting Sysmon telemetry.

Custom Wazuh rule 110120 successfully detected the reconnaissance behavior.

Result:

**Detected**

---

### ADLAB-004 - Privileged Group Membership Change

`helpdesk.test` was temporarily added to `Domain Admins`.

Windows generated Event ID 4728.

Wazuh generated built-in rule:

- Rule ID: 60159
- Description: Domain Admins Group Changed
- Level: 12

The account was removed from Domain Admins after evidence collection.

Result:

**Detected**

---

### ADLAB-005 - Canary Authentication

A controlled authentication attempt was made against the disabled `canary.admin` account.

Windows generated Event ID 4776.

Custom Wazuh rule 110150 fired at Level 12.

The rule was also revalidated while benign background traffic was active.

Result:

**Detected**

---

### ADLAB-006 - Remote Administrative Logon

PowerShell Remoting from WIN11-CLIENT to DC01 generated:

- Event ID: 4624
- Logon Type: 3
- Account: Administrator
- Source IP: 10.10.10.20
- Authentication: Kerberos

The raw Windows event was confirmed locally.

An exact dedicated Wazuh alert for this specific event was not confirmed.

Result:

**Logged but not alerted**

---

### ADLAB-007 - Active Directory Object Auditing

Directory Service Access auditing and an object-level SACL were applied to the `Test-Lab` OU.

A controlled object operation generated Event ID 4662.

The telemetry was also searchable through Wazuh.

Result:

**Telemetry validated**

---

### ADLAB-008 - LDAP Diagnostic Visibility

Temporary NTDS Field Engineering diagnostic logging was enabled.

A controlled LDAP query successfully generated Event ID 1644 locally on DC01.

The event was not successfully confirmed in Wazuh.

Verbose LDAP diagnostics were disabled again after testing.

Result:

**Telemetry gap**

---

## Overall Result

The project successfully validated the primary detection pipeline for:

- Authentication attacks
- Kerberos service-ticket abuse
- PowerShell reconnaissance
- Network reconnaissance
- Privileged group changes
- Canary-account authentication
- Active Directory object auditing

Two monitoring gaps remain documented:

1. Remote Type-3 administrative logon was logged but no exact dedicated Wazuh alert was confirmed.
2. LDAP Event ID 1644 was observed locally but not confirmed in Wazuh.