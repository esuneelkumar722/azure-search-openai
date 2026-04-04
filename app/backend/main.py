import os

from app import create_app
from load_env import load_env

# RUNNING_IN_PRODUCTION is set in Terraform as a Container App env var
RUNNING_ON_AZURE = os.getenv("WEBSITE_HOSTNAME") is not None or os.getenv("RUNNING_IN_PRODUCTION") is not None

if not RUNNING_ON_AZURE:
    load_env()

app = create_app()
