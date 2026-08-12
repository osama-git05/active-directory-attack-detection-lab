# Active Directory Attack & Detection Lab

An isolated Active Directory detection-engineering lab built in VirtualBox using Windows Server 2022, Windows 11, Kali Linux, Sysmon, Wazuh SIEM and Sigma.

## Lab Objective

Build a small Active Directory environment, generate controlled security activity, collect Windows and endpoint telemetry, engineer detections, investigate alerts and apply hardening controls.

## Current Progress

### Day 1 — Domain Controller
- Created isolated VirtualBox network `AD-LAB`
- Configured `DC01` with static IP `10.10.10.10`
- Installed Active Directory Domain Services
- Installed DNS
- Created the `adlab.test` forest

### Day 2 — Domain Identities and Workstation
- Created dedicated Active Directory OUs
- Created normal user, helpdesk, service and canary identities
- Registered `HTTP/web.adlab.test` SPN for `svc_web`
- Created and configured `WIN11-CLIENT`
- Joined `WIN11-CLIENT` to `adlab.test`
- Successfully authenticated as `ADLAB\alice.user`

## Network

| Host | Role | IP |
|---|---|---|
| DC01 | Domain Controller / DNS | 10.10.10.10 |
| WIN11-CLIENT | Domain Workstation | 10.10.10.20 |
| WAZUH | SIEM | 10.10.10.30 |
| KALI | Controlled Test Host | 10.10.10.50 |

## Authorization

All testing is performed inside the isolated `AD-LAB` VirtualBox environment using deliberately created lab systems and accounts.