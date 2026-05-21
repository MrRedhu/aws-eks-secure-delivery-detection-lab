import os
from fastapi import FastAPI

app = FastAPI(
    title="EKS Secure Demo API",
    version="0.1.0",
    description="A minimal FastAPI application for secure EKS delivery lab."
)

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/version")
def get_version():
    return {
        "service": "eks-secure-demo-api",
        "version": "0.1.0",
        "commit": os.getenv("GITHUB_SHA", "unknown"),
        "image": os.getenv("ECR_IMAGE_URI", "unknown")
    }

@app.get("/metadata")
def get_metadata():
    secret_value = os.getenv("DEMO_SECRET", "")
    return {
        "environment": os.getenv("ENVIRONMENT", "dev"),
        "region": os.getenv("AWS_REGION", "us-east-1"),
        "secret_loaded": bool(secret_value),
        "secret_value": "redacted" if secret_value else "none"
    }
