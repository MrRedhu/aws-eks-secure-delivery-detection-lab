import importlib.util
from pathlib import Path


class FakeSNS:
    def publish(self, **kwargs):
        assert kwargs["TopicArn"] == "arn:aws:sns:us-east-1:123456789012:test"
        assert kwargs["Subject"].startswith("GuardDuty Alert:")
        assert "Suspicious pod execution" in kwargs["Message"]
        return {"MessageId": "message-456"}


def load_deployed_router():
    repo_root = Path(__file__).resolve().parents[3]
    router_path = repo_root / "terraform" / "modules" / "detection" / "src" / "router.py"
    spec = importlib.util.spec_from_file_location("deployed_router", router_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_deployed_router_publishes_guardduty_alert(monkeypatch):
    router = load_deployed_router()
    monkeypatch.setenv("SNS_TOPIC_ARN", "arn:aws:sns:us-east-1:123456789012:test")
    monkeypatch.setattr(router.boto3, "client", lambda service: FakeSNS())

    response = router.lambda_handler({
        "detail": {
            "title": "Suspicious pod execution",
            "type": "Backdoor:Kubernetes/ReverseShell",
            "severity": 8.0,
            "accountId": "123456789012",
            "region": "us-east-1",
        }
    }, None)

    assert response == {"status": "success", "messageId": "message-456"}
