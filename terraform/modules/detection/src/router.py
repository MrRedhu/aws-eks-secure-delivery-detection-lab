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

    try:
        sns_topic_arn = os.environ.get("SNS_TOPIC_ARN")
        if not sns_topic_arn:
            raise ValueError("SNS_TOPIC_ARN is not configured")

        title, message = format_finding(event)

        response = boto3.client("sns").publish(
            TopicArn=sns_topic_arn,
            Subject=f"GuardDuty Alert: {title[:50]}",
            Message=message,
        )
        print(f"Alert published to SNS: {response['MessageId']}")
        return {"status": "success", "messageId": response["MessageId"]}

    except Exception as e:
        print(f"Error parsing or sending alert: {str(e)}")
        raise e
