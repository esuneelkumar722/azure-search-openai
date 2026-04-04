import logging
import os

from dotenv import load_dotenv

logger = logging.getLogger("scripts")


def load_azd_env():
    """Load environment variables from .env file.

    Replaces the azd-based loader for Terraform deployments.
    Looks for .env in project root (one level above scripts/).
    """
    env_paths = [
        os.path.join(os.path.dirname(__file__), "..", ".env"),
        os.path.join(os.getcwd(), ".env"),
    ]
    for env_path in env_paths:
        abs_path = os.path.abspath(env_path)
        if os.path.exists(abs_path):
            logger.info(f"Loading env from {abs_path}")
            load_dotenv(abs_path, override=True)
            return
    logger.info("No .env file found, using existing environment variables")
