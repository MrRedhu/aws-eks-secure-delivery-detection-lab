import json
import os

import boto3


def format_finding(event):
    detail = event.get("detail", {})
    title = detail.get("title", "Unknown Threat")
    severity = detail.get("severity", 0)
    account_id = detail.get("accountId", "Unknown")
    region = detail.get("region", "Unknown")
    finding_type = detail.get("type", "Unknown")

    message = "GuardDuty EKS finding detected\n\n"
    message += f"Title: {title}\n"
    message += f"Type: {finding_type}\n"
    message += f"Severity: {severity}\n"
    message += f"Account: {account_id}\n"
    message += f"Region: {region}\n\n"
    message += f"Console: https://{region}.console.aws.amazon.com/guardduty/home?region={region}#/findings\n"
    message += "Runbook: runbooks/guardduty-eks-finding-triage.md"
    return title, message


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))

    topic_arn = os.environ["SNS_TOPIC_ARN"]
    title, message = format_finding(event)

    response = boto3.client("sns").publish(
        TopicArn=topic_arn,
        Subject=f"GuardDuty Alert: {title[:50]}",
        Message=message,
    )
    return {"status": "success", "messageId": response["MessageId"]}
