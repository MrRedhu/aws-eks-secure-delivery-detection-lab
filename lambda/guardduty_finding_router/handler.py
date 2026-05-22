import importlib.util
from pathlib import Path


def _load_router():
    repo_root = Path(__file__).resolve().parents[2]
    router_path = repo_root / "terraform" / "modules" / "detection" / "src" / "router.py"
    spec = importlib.util.spec_from_file_location("deployed_router", router_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


_router = _load_router()
boto3 = _router.boto3
format_finding = _router.format_finding
lambda_handler = _router.lambda_handler
