import os
import sys

# Add the parent directory to sys.path so we can import src
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_get_version():
    response = client.get("/version")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "eks-secure-demo-api"
    assert data["version"] == "0.1.0"
    assert "commit" in data
    assert "image" in data

def test_get_metadata():
    # Set environment variables for the test
    os.environ["ENVIRONMENT"] = "test"
    os.environ["AWS_REGION"] = "us-west-2"
    os.environ["DEMO_SECRET"] = "supersecret"
    
    response = client.get("/metadata")
    assert response.status_code == 200
    data = response.json()
    
    assert data["environment"] == "test"
    assert data["region"] == "us-west-2"
    assert data["secret_loaded"] is True
    assert data["secret_value"] == "redacted"
