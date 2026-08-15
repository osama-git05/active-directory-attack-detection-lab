# Test 06 - Privileged Group Membership Change

## Objective

Generate a controlled Active Directory privileged-group membership change and validate whether the activity produces high-value Windows and Wazuh telemetry.

## Scope

Environment:

- Domain: `adlab.test`
- Domain Controller: `DC01`
- Test identity: `helpdesk.test`
- Privileged group: `Domain Admins`
- Authorization: isolated AD-LAB environment only

## Controlled Action

The lab user:

`helpdesk.test`

was temporarily added to:

`Domain Admins`

Example command:

```powershell
Add-ADGroupMember -Identity "Domain Admins" -Members "helpdesk.test"
```

After evidence collection, the account was immediately removed:

```powershell
Remove-ADGroupMember -Identity "Domain Admins" -Members "helpdesk.test" -Confirm:$false
```

## Expected Telemetry

The expected Windows Security event was:

`4728 - A member was added to a security-enabled global group`

Important fields included:

- Member Name
- Member ID
- Target Group
- Subject Account
- Computer
- Timestamp

## Actual Evidence

DC01 successfully generated Event ID 4728 when `helpdesk.test` was added to Domain Admins.

Wazuh ingested the event and produced:

- Rule ID: `60159`
- Description: `Domain Admins Group Changed`
- Level: `12`

## Detection Result

**Detected**

The privileged-group membership change generated a high-severity Wazuh alert.

## Important Detection Note

The confirmed detection evidence for this scenario is the Wazuh built-in rule:

`60159`

A separate custom privilege-change rule is not claimed as validated unless it is independently tested and observed.

## Analysis

Changes to highly privileged Active Directory groups are security-sensitive because they can provide immediate administrative control over the domain.

Groups requiring close monitoring include:

- Domain Admins
- Enterprise Admins
- Administrators
- Other delegated privileged groups

Legitimate administrative changes may occur, but they should normally be:

- Authorized
- Documented
- Associated with a known administrator
- Performed from an expected management system

Unexpected privileged-group changes should be investigated immediately.

## False Positives / Tuning

Potential legitimate causes include:

- Approved administrator provisioning
- Emergency administrative access
- Scheduled maintenance
- Identity-management automation
- Temporary support escalation

Useful investigation context includes:

- Who performed the change
- Which user was added
- Which group was modified
- Source system
- Change-management authorization
- Time of change

## Security Risk

Unauthorized Domain Admin membership may allow an attacker to:

- Control domain systems
- Modify security policy
- Access sensitive data
- Create additional privileged accounts
- Disable security controls
- Perform lateral movement
- Establish persistence

## Mitigation

Recommended controls include:

- Apply least privilege
- Use Privileged Access Management where available
- Separate normal and administrative identities
- Monitor privileged-group membership
- Periodically review privileged groups
- Alert on additions and removals
- Use approval workflows where available
- Remove temporary privilege immediately after use

## Cleanup Validation

After evidence collection:

`helpdesk.test`

was removed from:

`Domain Admins`

Final verification confirmed that the temporary test privilege was no longer present.

## Evidence

Relevant screenshots:

- `../screenshots/test-06-group-change-4728.png`
- `../screenshots/test-06-group-change-wazuh.png`
- `../screenshots/test-06-domain-admins-wazuh-rule-60159.png`
- `../screenshots/day3-wazuh-hunting-privilege-changes.png`
- `../screenshots/day7-hardening-account-state.png`

## Final Result

**Detected**

The controlled Domain Admins membership change generated Event ID 4728 and was detected by Wazuh rule 60159 at Level 12.

The privileged membership was removed after testing.
