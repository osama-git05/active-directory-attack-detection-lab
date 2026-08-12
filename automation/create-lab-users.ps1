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