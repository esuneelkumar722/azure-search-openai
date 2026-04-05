import os
from unittest import mock

import pytest
from fastapi.testclient import TestClient

import app


@pytest.fixture
def minimal_env(monkeypatch):
    with mock.patch.dict(os.environ, clear=True):
        monkeypatch.setenv("AZURE_STORAGE_ACCOUNT", "test-storage-account")
        monkeypatch.setenv("AZURE_STORAGE_CONTAINER", "test-storage-container")
        monkeypatch.setenv("AZURE_SEARCH_INDEX", "test-search-index")
        monkeypatch.setenv("AZURE_SEARCH_SERVICE", "test-search-service")
        monkeypatch.setenv("AZURE_OPENAI_SERVICE", "test-openai-service")
        monkeypatch.setenv("AZURE_OPENAI_CHATGPT_MODEL", "gpt-4.1-mini")
        monkeypatch.setenv("AZURE_OPENAI_CHATGPT_DEPLOYMENT", "test-chat-deployment")
        monkeypatch.setenv("AZURE_OPENAI_EMB_MODEL_NAME", "text-embedding-3-large")
        monkeypatch.setenv("AZURE_OPENAI_EMB_DIMENSIONS", "3072")
        monkeypatch.setenv("AZURE_OPENAI_EMB_DEPLOYMENT", "test-emb-deployment")
        yield


def test_app_local_openai(monkeypatch, minimal_env):
    monkeypatch.setenv("OPENAI_HOST", "local")
    monkeypatch.setenv("OPENAI_BASE_URL", "http://localhost:5000")

    fastapi_app = app.create_app()
    with TestClient(fastapi_app):
        assert fastapi_app.state.config[app.CONFIG_OPENAI_CLIENT].api_key == "no-key-required"
        assert fastapi_app.state.config[app.CONFIG_OPENAI_CLIENT].base_url == "http://localhost:5000"


def test_app_azure_custom_key(monkeypatch, minimal_env):
    monkeypatch.setenv("OPENAI_HOST", "azure_custom")
    monkeypatch.setenv("AZURE_OPENAI_CUSTOM_URL", "http://azureapi.com/api/v1")
    monkeypatch.setenv("AZURE_OPENAI_API_KEY_OVERRIDE", "azure-api-key")

    fastapi_app = app.create_app()
    with TestClient(fastapi_app):
        assert fastapi_app.state.config[app.CONFIG_OPENAI_CLIENT].api_key == "azure-api-key"
        assert fastapi_app.state.config[app.CONFIG_OPENAI_CLIENT].base_url == "http://azureapi.com/api/v1/"


def test_app_azure_custom_identity(monkeypatch, minimal_env):
    monkeypatch.setenv("OPENAI_HOST", "azure_custom")
    monkeypatch.setenv("AZURE_OPENAI_CUSTOM_URL", "http://azureapi.com/api/v1")

    fastapi_app = app.create_app()
    with TestClient(fastapi_app):
        openai_client = fastapi_app.state.config[app.CONFIG_OPENAI_CLIENT]
        assert openai_client.api_key == ""
        # The AsyncOpenAI client stores the callable inside _api_key_provider
        assert getattr(openai_client, "_api_key_provider", None) is not None
        assert str(openai_client.base_url) == "http://azureapi.com/api/v1/"


def test_app_user_upload_processors(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")
    monkeypatch.setenv("AZURE_ENFORCE_ACCESS_CONTROL", "true")
    monkeypatch.setenv("USE_USER_UPLOAD", "true")

    fastapi_app = app.create_app()
    with TestClient(fastapi_app):
        ingester = fastapi_app.state.config[app.CONFIG_INGESTER]
        assert ingester is not None
        assert len(ingester.file_processors.keys()) == 6


def test_app_user_upload_requires_storage_configuration(monkeypatch, minimal_env):
    monkeypatch.setenv("USE_USER_UPLOAD", "true")

    fastapi_app = app.create_app()
    with pytest.raises(
        Exception,
        match="AZURE_USERSTORAGE_ACCOUNT and AZURE_USERSTORAGE_CONTAINER must be set when USE_USER_UPLOAD is true",
    ):
        with TestClient(fastapi_app):
            pass


def test_app_user_upload_requires_enforce_access_control(monkeypatch, minimal_env):
    monkeypatch.setenv("USE_USER_UPLOAD", "true")
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")

    fastapi_app = app.create_app()
    with pytest.raises(
        Exception,
        match="AZURE_ENFORCE_ACCESS_CONTROL must be true when USE_USER_UPLOAD is true",
    ):
        with TestClient(fastapi_app):
            pass


def test_app_user_upload_processors_docint(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")
    monkeypatch.setenv("AZURE_ENFORCE_ACCESS_CONTROL", "true")
    monkeypatch.setenv("USE_USER_UPLOAD", "true")
    monkeypatch.setenv("AZURE_DOCUMENTINTELLIGENCE_SERVICE", "test-docint-service")

    fastapi_app = app.create_app()
    with TestClient(fastapi_app):
        ingester = fastapi_app.state.config[app.CONFIG_INGESTER]
        assert ingester is not None
        assert len(ingester.file_processors.keys()) == 15


def test_app_user_upload_processors_docint_localpdf(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")
    monkeypatch.setenv("AZURE_ENFORCE_ACCESS_CONTROL", "true")
    monkeypatch.setenv("USE_USER_UPLOAD", "true")
    monkeypatch.setenv("AZURE_DOCUMENTINTELLIGENCE_SERVICE", "test-docint-service")
    monkeypatch.setenv("USE_LOCAL_PDF_PARSER", "true")

    fastapi_app = app.create_app()
    with TestClient(fastapi_app):
        ingester = fastapi_app.state.config[app.CONFIG_INGESTER]
        assert ingester is not None
        assert len(ingester.file_processors.keys()) == 15
        assert ingester.file_processors[".pdf"] is not ingester.file_processors[".pptx"]


def test_app_user_upload_processors_docint_localhtml(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")
    monkeypatch.setenv("AZURE_ENFORCE_ACCESS_CONTROL", "true")
    monkeypatch.setenv("USE_USER_UPLOAD", "true")
    monkeypatch.setenv("AZURE_DOCUMENTINTELLIGENCE_SERVICE", "test-docint-service")
    monkeypatch.setenv("USE_LOCAL_HTML_PARSER", "true")

    fastapi_app = app.create_app()
    with TestClient(fastapi_app):
        ingester = fastapi_app.state.config[app.CONFIG_INGESTER]
        assert ingester is not None
        assert len(ingester.file_processors.keys()) == 15
        assert ingester.file_processors[".html"] is not ingester.file_processors[".pptx"]


def test_app_config_default(monkeypatch, minimal_env):
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["showMultimodalOptions"] is False
        assert result["showSemanticRankerOption"] is True
        assert result["showVectorOption"] is True
        assert result["defaultRetrievalReasoningEffort"] == "low"


def test_app_config_use_vectors_true(monkeypatch, minimal_env):
    monkeypatch.setenv("USE_VECTORS", "true")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["showMultimodalOptions"] is False
        assert result["showSemanticRankerOption"] is True
        assert result["showVectorOption"] is True


def test_app_config_use_vectors_false(monkeypatch, minimal_env):
    monkeypatch.setenv("USE_VECTORS", "false")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["showMultimodalOptions"] is False
        assert result["showSemanticRankerOption"] is True
        assert result["showVectorOption"] is False


def test_app_config_semanticranker_free(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_SEARCH_SEMANTIC_RANKER", "free")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["showMultimodalOptions"] is False
        assert result["showSemanticRankerOption"] is True
        assert result["showVectorOption"] is True
        assert result["showUserUpload"] is False


def test_app_config_semanticranker_disabled(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_SEARCH_SEMANTIC_RANKER", "disabled")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["showMultimodalOptions"] is False
        assert result["showSemanticRankerOption"] is False
        assert result["showVectorOption"] is True
        assert result["showUserUpload"] is False


def test_app_config_user_upload(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")
    monkeypatch.setenv("AZURE_ENFORCE_ACCESS_CONTROL", "true")
    monkeypatch.setenv("USE_USER_UPLOAD", "true")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["showMultimodalOptions"] is False
        assert result["showSemanticRankerOption"] is True
        assert result["showVectorOption"] is True
        assert result["showUserUpload"] is True


def test_app_config_user_upload_novectors(monkeypatch, minimal_env):
    """Check that this combo works correctly with prepdocs.py embedding service."""
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")
    monkeypatch.setenv("AZURE_ENFORCE_ACCESS_CONTROL", "true")
    monkeypatch.setenv("USE_USER_UPLOAD", "true")
    monkeypatch.setenv("USE_VECTORS", "false")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["showMultimodalOptions"] is False
        assert result["showSemanticRankerOption"] is True
        assert result["showVectorOption"] is False
        assert result["showUserUpload"] is True


def test_app_config_user_upload_bad_openai_config(monkeypatch, minimal_env):
    """Check that this combo works correctly with prepdocs.py embedding service."""
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")
    monkeypatch.setenv("AZURE_ENFORCE_ACCESS_CONTROL", "true")
    monkeypatch.setenv("USE_USER_UPLOAD", "true")
    monkeypatch.setenv("OPENAI_HOST", "openai")
    fastapi_app = app.create_app()
    with pytest.raises(Exception, match="OpenAI key is required when using the non-Azure OpenAI API"):
        with TestClient(fastapi_app):
            pass


def test_app_config_user_upload_openaicom(monkeypatch, minimal_env):
    """Check that this combo works correctly with prepdocs.py embedding service."""
    monkeypatch.setenv("AZURE_USERSTORAGE_ACCOUNT", "test-user-storage-account")
    monkeypatch.setenv("AZURE_USERSTORAGE_CONTAINER", "test-user-storage-container")
    monkeypatch.setenv("AZURE_ENFORCE_ACCESS_CONTROL", "true")
    monkeypatch.setenv("USE_USER_UPLOAD", "true")
    monkeypatch.setenv("OPENAI_HOST", "openai")
    monkeypatch.setenv("OPENAI_API_KEY", "pretendkey")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["showUserUpload"] is True


@pytest.mark.asyncio
async def test_app_config_for_client(client):
    response = await client.get("/config")
    assert response.status_code == 200
    result = await response.get_json()
    assert result["showMultimodalOptions"] == (os.getenv("USE_MULTIMODAL") == "true")
    assert result["showSemanticRankerOption"] is True
    assert result["showVectorOption"] is True
    assert result["streamingEnabled"] is True
    assert result["showReasoningEffortOption"] is False


def test_app_config_for_reasoning(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_OPENAI_CHATGPT_MODEL", "o3-mini")
    monkeypatch.setenv("AZURE_OPENAI_CHATGPT_DEPLOYMENT", "o3-mini")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["streamingEnabled"] is True
        assert result["showReasoningEffortOption"] is True


def test_app_config_for_reasoning_without_streaming(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_OPENAI_CHATGPT_MODEL", "o1")
    monkeypatch.setenv("AZURE_OPENAI_CHATGPT_DEPLOYMENT", "o1")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["streamingEnabled"] is False
        assert result["showReasoningEffortOption"] is True


def test_app_config_for_reasoning_override_effort(monkeypatch, minimal_env):
    monkeypatch.setenv("AZURE_OPENAI_REASONING_EFFORT", "low")
    monkeypatch.setenv("AZURE_OPENAI_CHATGPT_MODEL", "o3-mini")
    monkeypatch.setenv("AZURE_OPENAI_CHATGPT_DEPLOYMENT", "o3-mini")
    fastapi_app = app.create_app()
    with TestClient(fastapi_app) as client:
        response = client.get("/config")
        assert response.status_code == 200
        result = response.json()
        assert result["streamingEnabled"] is True
        assert result["showReasoningEffortOption"] is True
        assert result["defaultReasoningEffort"] == "low"


def test_app_enables_azure_monitor_when_connection_string_set(monkeypatch):
    mock_connection_string = "InstrumentationKey=12345678-1234-1234-1234-123456789012"
    monkeypatch.setenv("APPLICATIONINSIGHTS_CONNECTION_STRING", mock_connection_string)
    app.create_app()
