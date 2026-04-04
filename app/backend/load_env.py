import logging
import os

from dotenv import load_dotenv

logger = logging.getLogger("scripts")


def load_env():
    """Load environment variables from a .env file if it exists.

    For Terraform-based deployments, env vars are set directly via:
    - PowerShell $env: commands (local development)
    - CI/CD pipeline variables (production)
    - Container App environment variables (runtime)

    The .env file is optional and used for local development convenience.
    """
    # Check for .env file in project root or current directory
    env_paths = [
        os.path.join(os.path.dirname(__file__), "..", "..", ".env"),
        os.path.join(os.getcwd(), ".env"),
    ]

    for env_path in env_paths:
        if os.path.exists(env_path):
            loading_mode = os.getenv("LOADING_MODE_FOR_ENV_VARS") or "override"
            if loading_mode == "no-override":
                logger.info("Loading env from %s, not overriding existing variables", env_path)
                load_dotenv(env_path, override=False)
            else:
                logger.info("Loading env from %s, which may override existing variables", env_path)
                load_dotenv(env_path, override=True)
            return

    logger.info("No .env file found, using existing environment variables")
