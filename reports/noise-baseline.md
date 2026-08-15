# Benign Noise Baseline and False-Positive Validation

## Objective

The purpose of this test was to generate routine enterprise-like background traffic while validating custom detections.

A detection tested only in a silent lab may appear more accurate than it would be in a real environment.

The benign-noise workflow was therefore used to introduce normal activity while controlled malicious-like behavior was generated.

## Benign Noise Script

The project includes:

`automation/benign-noise.ps1`

The script generated low-rate normal activity such as:

- DNS lookups
- ICMP connectivity checks
- SYSVOL access
- NETLOGON access
- Normal PowerShell activity

The script was executed on WIN11-CLIENT.

## Baseline Objective

The baseline was used to determine whether routine workstation activity caused unexpected alerts in the custom detection rules.

The test did not attempt to reproduce a complete enterprise environment.

Instead, it introduced enough legitimate activity to prevent the detection tests from being performed in a completely silent network.

## Validation 1 - Network Reconnaissance Detection

Custom detection:

`110130 - Network Service Discovery / Reconnaissance`

A controlled Nmap scan was generated while benign workstation traffic was active.

### Result

- Controlled Nmap activity detected: Yes
- Rule 110130 triggered: Yes
- Benign workstation activity triggered rule 110130: No observed false positive

The frequency-based detection remained effective while normal DNS, PowerShell, and network activity was present.

## Validation 2 - Canary Authentication Detection

Custom detection:

`110150 - Canary Authentication`

The benign-noise script was active while a controlled authentication attempt was generated against:

`canary.admin`

Windows generated Event ID 4776.

Custom Wazuh rule 110150 fired at Level 12.

### Result

- Canary authentication detected: Yes
- Rule 110150 triggered: Yes
- Benign background activity triggered rule 110150: No observed false positive

## Detection Engineering Findings

The benign-noise test demonstrated that the two evaluated detections were not dependent on a completely silent environment.

The network reconnaissance detection used repeated activity and correlation rather than alerting on every connection.

The canary detection remained high confidence because the monitored identity had no legitimate authentication workflow.

## Important Limitation

The test used a small local lab and therefore cannot prove a zero false-positive rate in a production enterprise environment.

The correct conclusion is:

**No false positive was observed during the controlled benign-noise validation period.**

It should not be interpreted as a claim that false positives are impossible.

## Evidence

Relevant screenshots include:

- `day4-benign-baseline-script.png`
- `day4-benign-baseline-event-distribution.png`
- `day4-wazuh-network-scan-benign-false-positive.png`
- `day4-wazuh-network-scan-tuned-detection.png`
- `day7-canary-noise-validation.png`

## Final Result

The benign-noise workflow improved the quality of the detection validation by testing custom rules against both suspicious and normal activity.

Both tested detections remained operational without an observed benign false positive during the validation windows.