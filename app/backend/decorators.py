import logging
from typing import Any

from fastapi import HTTPException, Request

from config import CONFIG_AUTH_CLIENT, CONFIG_SEARCH_CLIENT
from core.authentication import AuthError


async def get_auth_claims(request: Request) -> dict[str, Any]:
    """
    FastAPI dependency for routes that require authentication.
    Extracts auth claims from the Authorization header.
    """
    auth_helper = request.app.state.config[CONFIG_AUTH_CLIENT]
    try:
        return await auth_helper.get_auth_claims_if_enabled(request.headers)
    except AuthError:
        raise HTTPException(status_code=403)


async def get_path_auth_claims(request: Request, path: str) -> dict[str, Any]:
    """
    Validates path-level access control and returns auth claims.
    Called directly from route handlers (not via Depends) because it needs the path route parameter.
    """
    auth_helper = request.app.state.config[CONFIG_AUTH_CLIENT]
    search_client = request.app.state.config[CONFIG_SEARCH_CLIENT]
    try:
        auth_claims = await auth_helper.get_auth_claims_if_enabled(request.headers)
        authorized = await auth_helper.check_path_auth(path, auth_claims, search_client)
    except AuthError:
        raise HTTPException(status_code=403)
    except Exception as error:
        logging.exception("Problem checking path auth %s", error)
        raise HTTPException(status_code=500)

    if not authorized:
        raise HTTPException(status_code=403)

    return auth_claims
