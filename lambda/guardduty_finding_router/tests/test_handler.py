import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import handler


class FakeSNS:
    def publish(self, **kwargs):
        assert kwargs["TopicArn"] == "arn:aws:sns:us-east-1:123456789012:test"
        assert "GuardDuty Alert" in kwargs["Subject"]
        assert "Backdoor:Kubernetes" in kwargs["Message"]
        return {"MessageId": "message-123"}


def test_format_finding_includes_core_fields():
    _, message = handler.format_finding({
        "detail": {
            "title": "Suspicious pod execution",
            "type": "Backdoor:Kubernetes/ReverseShell",
            "severity": 8.0,
            "accountId": "123456789012",
            "region": "us-east-1",
        }
    })

    assert "Suspicious pod execution" in message
    assert "Backdoor:Kubernetes/ReverseShell" in message
    assert "123456789012" in message


def test_lambda_handler_publishes_to_sns(monkeypatch):
    monkeypatch.setenv("SNS_TOPIC_ARN", "arn:aws:sns:us-east-1:123456789012:test")
    monkeypatch.setattr(handler.boto3, "client", lambda service: FakeSNS())

    response = handler.lambda_handler({
        "detail": {
            "title": "Suspicious pod execution",
            "type": "Backdoor:Kubernetes/ReverseShell",
            "severity": 8.0,
            "accountId": "123456789012",
            "region": "us-east-1",
        }
    }, None)

    assert response == {"status": "success", "messageId": "message-123"}
