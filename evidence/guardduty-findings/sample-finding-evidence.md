# GuardDuty Sample Finding Evidence

Collected: 2026-05-22

## Detector

- Region: `us-east-1`
- Detector ID: `<redacted-detector-id>`

## High-Severity Sample Finding

```text
Type: Backdoor:EC2/DenialOfService.Tcp
Severity: 8.0
Title: The EC2 instance i-99999999 is behaving in a manner that may indicate it is being used to perform a Denial of Service (DoS) attack using the TCP protocol.
UpdatedAt: 2026-05-22T21:11:03.970Z
```

## Validation

The finding was generated with the GuardDuty sample finding API and matched the high-severity EventBridge rule because the severity was greater than or equal to 7.
