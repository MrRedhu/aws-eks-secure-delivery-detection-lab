# EventBridge to Lambda to SNS Routing Evidence

Collected: 2026-05-22

## Route

```text
GuardDuty sample finding
  -> EventBridge rule aws-eks-secure-delivery-detection-lab-dev-gd-high
  -> Lambda aws-eks-secure-delivery-detection-lab-dev-gd-router
  -> SNS topic aws-eks-secure-delivery-detection-lab-dev-security-alerts
```

## Lambda Log Evidence

CloudWatch Logs showed the Lambda router receiving GuardDuty events from `source: aws.guardduty` and publishing alerts to SNS.

```text
Received event: detail-type=GuardDuty Finding, source=aws.guardduty, severity=8
Alert published to SNS: 65358317-7280-50fa-a687-e19dbaef4215
Alert published to SNS: a9ab5b07-b978-57a4-a894-398d71176ac8
Alert published to SNS: 630ea337-37dc-5558-b4a2-c1bdffadec56
Alert published to SNS: cac68ebe-665c-5a9d-85e0-ec34ae2df4c8
Alert published to SNS: ab3a5414-2fed-51ad-ba82-369ee79ff2dc
```

## SNS Subscription Status

The email endpoint is confirmed. A direct SNS publish test returned:

```text
MessageId: 017018d8-bbce-55ca-8e2f-7a52719ddbaa
```
