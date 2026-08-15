# Test 05 - Controlled Remote Administrative Logon

## Objective

Generate a controlled remote administrative authentication event from WIN11-CLIENT to DC01 and determine whether Windows and Wazuh provide sufficient visibility for investigation.

## Scope

Source:

- Host: WIN11-CLIENT
- IP: 10.10.10.20

Destination:

- Host: DC01
- IP: 10.10.10.10

Environment:

- Domain: adlab.test
- Network: AD-LAB
- Authorized isolated laboratory only

## Controlled Action

PowerShell Remoting / WinRM was used from WIN11-CLIENT to DC01 using a lab administrative account.

Example validation steps included:

```powershell
Test-NetConnection DC01 -Port 5985

$cred = Get-Credential ADLAB\Administrator

Enter-PSSession -ComputerName DC01 -Credential $cred