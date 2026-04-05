import os
import time
from typing import Any

from azure.cosmos.aio import ContainerProxy, CosmosClient
from azure.identity.aio import AzureDeveloperCliCredential, ManagedIdentityCredential
from fastapi import APIRouter, Depends, Request
from fastapi.responses import JSONResponse, Response

from config import (
    CONFIG_CHAT_HISTORY_COSMOS_ENABLED,
    CONFIG_COSMOS_HISTORY_CLIENT,
    CONFIG_COSMOS_HISTORY_CONTAINER,
    CONFIG_COSMOS_HISTORY_VERSION,
    CONFIG_CREDENTIAL,
)
from decorators import get_auth_claims
from error import error_response

chat_history_cosmosdb_router = APIRouter()


@chat_history_cosmosdb_router.post("/chat_history")
async def post_chat_history(request: Request, auth_claims: dict[str, Any] = Depends(get_auth_claims)):
    cfg = request.app.state.config
    if not cfg[CONFIG_CHAT_HISTORY_COSMOS_ENABLED]:
        return JSONResponse({"error": "Chat history not enabled"}, status_code=400)

    container: ContainerProxy = cfg[CONFIG_COSMOS_HISTORY_CONTAINER]
    if not container:
        return JSONResponse({"error": "Chat history not enabled"}, status_code=400)

    entra_oid = auth_claims.get("oid")
    if not entra_oid:
        return JSONResponse({"error": "User OID not found"}, status_code=401)

    try:
        request_json = await request.json()
        session_id = request_json.get("id")
        message_pairs = request_json.get("answers")
        first_question = message_pairs[0][0]
        title = first_question + "..." if len(first_question) > 50 else first_question
        timestamp = int(time.time() * 1000)

        # Insert the session item:
        session_item = {
            "id": session_id,
            "version": cfg[CONFIG_COSMOS_HISTORY_VERSION],
            "session_id": session_id,
            "entra_oid": entra_oid,
            "type": "session",
            "title": title,
            "timestamp": timestamp,
        }

        message_pair_items = []
        # Now insert a message item for each question/response pair:
        for ind, message_pair in enumerate(message_pairs):
            message_pair_items.append(
                {
                    "id": f"{session_id}-{ind}",
                    "version": cfg[CONFIG_COSMOS_HISTORY_VERSION],
                    "session_id": session_id,
                    "entra_oid": entra_oid,
                    "type": "message_pair",
                    "question": message_pair[0],
                    "response": message_pair[1],
                }
            )

        batch_operations = [("upsert", (session_item,))] + [
            ("upsert", (message_pair_item,)) for message_pair_item in message_pair_items
        ]
        await container.execute_item_batch(batch_operations=batch_operations, partition_key=[entra_oid, session_id])
        return JSONResponse({}, status_code=201)
    except Exception as error:
        return error_response(error, "/chat_history")


@chat_history_cosmosdb_router.get("/chat_history/sessions")
async def get_chat_history_sessions(request: Request, auth_claims: dict[str, Any] = Depends(get_auth_claims)):
    cfg = request.app.state.config
    if not cfg[CONFIG_CHAT_HISTORY_COSMOS_ENABLED]:
        return JSONResponse({"error": "Chat history not enabled"}, status_code=400)

    container: ContainerProxy = cfg[CONFIG_COSMOS_HISTORY_CONTAINER]
    if not container:
        return JSONResponse({"error": "Chat history not enabled"}, status_code=400)

    entra_oid = auth_claims.get("oid")
    if not entra_oid:
        return JSONResponse({"error": "User OID not found"}, status_code=401)

    try:
        count = int(request.query_params.get("count", 10))
        continuation_token = request.query_params.get("continuation_token")

        res = container.query_items(
            query="SELECT c.id, c.entra_oid, c.title, c.timestamp FROM c WHERE c.entra_oid = @entra_oid AND c.type = @type ORDER BY c.timestamp DESC",
            parameters=[dict(name="@entra_oid", value=entra_oid), dict(name="@type", value="session")],
            partition_key=[entra_oid],
            max_item_count=count,
        )

        pager = res.by_page(continuation_token)

        # Get the first page, and the continuation token
        sessions = []
        try:
            page = await pager.__anext__()
            continuation_token = pager.continuation_token

            async for item in page:
                sessions.append(
                    {
                        "id": item.get("id"),
                        "entra_oid": item.get("entra_oid"),
                        "title": item.get("title", "untitled"),
                        "timestamp": item.get("timestamp"),
                    }
                )

        # If there are no more pages, StopAsyncIteration is raised
        except StopAsyncIteration:
            continuation_token = None

        return JSONResponse({"sessions": sessions, "continuation_token": continuation_token}, status_code=200)

    except Exception as error:
        return error_response(error, "/chat_history/sessions")


@chat_history_cosmosdb_router.get("/chat_history/sessions/{session_id}")
async def get_chat_history_session(
    session_id: str, request: Request, auth_claims: dict[str, Any] = Depends(get_auth_claims)
):
    cfg = request.app.state.config
    if not cfg[CONFIG_CHAT_HISTORY_COSMOS_ENABLED]:
        return JSONResponse({"error": "Chat history not enabled"}, status_code=400)

    container: ContainerProxy = cfg[CONFIG_COSMOS_HISTORY_CONTAINER]
    if not container:
        return JSONResponse({"error": "Chat history not enabled"}, status_code=400)

    entra_oid = auth_claims.get("oid")
    if not entra_oid:
        return JSONResponse({"error": "User OID not found"}, status_code=401)

    try:
        res = container.query_items(
            query="SELECT * FROM c WHERE c.session_id = @session_id AND c.type = @type",
            parameters=[dict(name="@session_id", value=session_id), dict(name="@type", value="message_pair")],
            partition_key=[entra_oid, session_id],
        )

        message_pairs = []
        async for page in res.by_page():
            async for item in page:
                message_pairs.append([item["question"], item["response"]])

        return JSONResponse(
            {
                "id": session_id,
                "entra_oid": entra_oid,
                "answers": message_pairs,
            },
            status_code=200,
        )
    except Exception as error:
        return error_response(error, f"/chat_history/sessions/{session_id}")


@chat_history_cosmosdb_router.delete("/chat_history/sessions/{session_id}")
async def delete_chat_history_session(
    session_id: str, request: Request, auth_claims: dict[str, Any] = Depends(get_auth_claims)
):
    cfg = request.app.state.config
    if not cfg[CONFIG_CHAT_HISTORY_COSMOS_ENABLED]:
        return JSONResponse({"error": "Chat history not enabled"}, status_code=400)

    container: ContainerProxy = cfg[CONFIG_COSMOS_HISTORY_CONTAINER]
    if not container:
        return JSONResponse({"error": "Chat history not enabled"}, status_code=400)

    entra_oid = auth_claims.get("oid")
    if not entra_oid:
        return JSONResponse({"error": "User OID not found"}, status_code=401)

    try:
        res = container.query_items(
            query="SELECT c.id FROM c WHERE c.session_id = @session_id",
            parameters=[dict(name="@session_id", value=session_id)],
            partition_key=[entra_oid, session_id],
        )

        ids_to_delete = []
        async for page in res.by_page():
            async for item in page:
                ids_to_delete.append(item["id"])

        batch_operations = [("delete", (id,)) for id in ids_to_delete]
        await container.execute_item_batch(batch_operations=batch_operations, partition_key=[entra_oid, session_id])
        return Response(content=b"", status_code=204)
    except Exception as error:
        return error_response(error, f"/chat_history/sessions/{session_id}")


async def setup_cosmos_clients(app_state_config: dict) -> None:
    """Setup Cosmos DB clients. Called from the main app lifespan."""
    import logging

    cosmos_logger = logging.getLogger("app")
    USE_CHAT_HISTORY_COSMOS = os.getenv("USE_CHAT_HISTORY_COSMOS", "").lower() == "true"
    AZURE_COSMOSDB_ACCOUNT = os.getenv("AZURE_COSMOSDB_ACCOUNT")
    AZURE_CHAT_HISTORY_DATABASE = os.getenv("AZURE_CHAT_HISTORY_DATABASE")
    AZURE_CHAT_HISTORY_CONTAINER = os.getenv("AZURE_CHAT_HISTORY_CONTAINER")

    azure_credential: AzureDeveloperCliCredential | ManagedIdentityCredential = app_state_config[CONFIG_CREDENTIAL]

    if USE_CHAT_HISTORY_COSMOS:
        cosmos_logger.info("USE_CHAT_HISTORY_COSMOS is true, setting up CosmosDB client")
        if not AZURE_COSMOSDB_ACCOUNT:
            raise ValueError("AZURE_COSMOSDB_ACCOUNT must be set when USE_CHAT_HISTORY_COSMOS is true")
        if not AZURE_CHAT_HISTORY_DATABASE:
            raise ValueError("AZURE_CHAT_HISTORY_DATABASE must be set when USE_CHAT_HISTORY_COSMOS is true")
        if not AZURE_CHAT_HISTORY_CONTAINER:
            raise ValueError("AZURE_CHAT_HISTORY_CONTAINER must be set when USE_CHAT_HISTORY_COSMOS is true")
        cosmos_client = CosmosClient(
            url=f"https://{AZURE_COSMOSDB_ACCOUNT}.documents.azure.com:443/", credential=azure_credential
        )
        cosmos_db = cosmos_client.get_database_client(AZURE_CHAT_HISTORY_DATABASE)
        cosmos_container = cosmos_db.get_container_client(AZURE_CHAT_HISTORY_CONTAINER)

        app_state_config[CONFIG_COSMOS_HISTORY_CLIENT] = cosmos_client
        app_state_config[CONFIG_COSMOS_HISTORY_CONTAINER] = cosmos_container
        app_state_config[CONFIG_COSMOS_HISTORY_VERSION] = os.environ["AZURE_CHAT_HISTORY_VERSION"]


async def close_cosmos_clients(app_state_config: dict) -> None:
    """Close Cosmos DB clients. Called from the main app lifespan."""
    if app_state_config.get(CONFIG_COSMOS_HISTORY_CLIENT):
        cosmos_client: CosmosClient = app_state_config[CONFIG_COSMOS_HISTORY_CLIENT]
        await cosmos_client.close()
