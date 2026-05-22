import json
import os
import boto3

sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))
    
    try:
        detail = event.get('detail', {})
        title = detail.get('title', 'Unknown Threat')
        severity = detail.get('severity', 0)
        account_id = detail.get('accountId', 'Unknown')
        region = detail.get('region', 'Unknown')
        
        # Format the alert
        message = f"🚨 URGENT: GuardDuty Finding Detected 🚨\n\n"
        message += f"Threat: {title}\n"
        message += f"Severity: {severity}\n"
        message += f"Account: {account_id}\n"
        message += f"Region: {region}\n\n"
        message += f"View in Console: https://{region}.console.aws.amazon.com/guardduty/home?region={region}#/findings\n"
        message += f"\nPlease follow the incident response runbook for this threat type."
        
        # Publish to SNS
        response = sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=f"GuardDuty Alert: {title[:50]}",
            Message=message
        )
        print(f"Alert published to SNS: {response['MessageId']}")
        return {"status": "success", "messageId": response['MessageId']}
        
    except Exception as e:
        print(f"Error parsing or sending alert: {str(e)}")
        raise e
