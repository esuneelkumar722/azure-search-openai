# =============================================================================
# RBAC Role Assignments
# Consolidated from ~25 individual role.bicep calls in main.bicep
# =============================================================================

# Well-known role definition IDs
locals {
  roles = {
    cognitive_services_openai_user   = "5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
    cognitive_services_user          = "a97b65f3-24c7-4388-baec-2e87135dc908"
    cognitive_services_speech_user   = "f2dc8367-1007-4938-bd23-fe263f013447"
    storage_blob_data_reader        = "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"
    storage_blob_data_contributor   = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    storage_blob_data_owner         = "b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
    search_index_data_reader        = "1407120a-92aa-4202-b7e9-c0e197c71c8f"
    search_index_data_contributor   = "8ebe5a00-799e-43f5-93ac-243d3dce84a7"
    search_service_contributor      = "7ca78c08-252a-4471-8644-bb5ff32d4ba0"
    reader                          = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
    documentdb_account_contributor  = "5bd9cd88-fe45-4216-938b-f97437e15450"
  }

  # Build the role assignments list dynamically based on feature flags
  role_assignments = concat(
    # ========== USER ROLES ==========
    var.deploy_azure_openai && var.principal_id != "" ? [
      { name = "openai-role-user", scope = var.resource_group_id, role_id = local.roles.cognitive_services_openai_user, principal_id = var.principal_id, principal_type = var.principal_type },
    ] : [],

    var.principal_id != "" ? [
      { name = "cognitiveservices-role-user", scope = var.resource_group_id, role_id = local.roles.cognitive_services_user, principal_id = var.principal_id, principal_type = var.principal_type },
      { name = "speech-role-user", scope = var.resource_group_id, role_id = local.roles.cognitive_services_speech_user, principal_id = var.principal_id, principal_type = var.principal_type },
      { name = "storage-role-user", scope = var.resource_group_id, role_id = local.roles.storage_blob_data_reader, principal_id = var.principal_id, principal_type = var.principal_type },
      { name = "storage-contrib-role-user", scope = var.resource_group_id, role_id = local.roles.storage_blob_data_contributor, principal_id = var.principal_id, principal_type = var.principal_type },
      { name = "search-role-user", scope = var.resource_group_id, role_id = local.roles.search_index_data_reader, principal_id = var.principal_id, principal_type = var.principal_type },
      { name = "search-contrib-role-user", scope = var.resource_group_id, role_id = local.roles.search_index_data_contributor, principal_id = var.principal_id, principal_type = var.principal_type },
      { name = "search-svccontrib-role-user", scope = var.resource_group_id, role_id = local.roles.search_service_contributor, principal_id = var.principal_id, principal_type = var.principal_type },
    ] : [],

    var.use_user_upload && var.principal_id != "" ? [
      { name = "storage-owner-role-user", scope = var.resource_group_id, role_id = local.roles.storage_blob_data_owner, principal_id = var.principal_id, principal_type = var.principal_type },
    ] : [],

    var.use_authentication && var.use_chat_history_cosmos && var.principal_id != "" ? [
      { name = "cosmosdb-account-contrib-role-user", scope = var.resource_group_id, role_id = local.roles.documentdb_account_contributor, principal_id = var.principal_id, principal_type = var.principal_type },
    ] : [],

    # ========== BACKEND (Container App) ROLES ==========
    var.deploy_azure_openai ? [
      { name = "openai-role-backend", scope = var.resource_group_id, role_id = local.roles.cognitive_services_openai_user, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
    ] : [],

    [
      { name = "storage-role-backend", scope = var.resource_group_id, role_id = local.roles.storage_blob_data_reader, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
      { name = "search-role-backend", scope = var.resource_group_id, role_id = local.roles.search_index_data_reader, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
      { name = "speech-role-backend", scope = var.resource_group_id, role_id = local.roles.cognitive_services_speech_user, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
    ],

    var.use_user_upload ? [
      { name = "storage-owner-role-backend", scope = var.resource_group_id, role_id = local.roles.storage_blob_data_owner, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
      { name = "search-contrib-role-backend", scope = var.resource_group_id, role_id = local.roles.search_index_data_contributor, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
      { name = "documentintelligence-role-backend", scope = var.resource_group_id, role_id = local.roles.cognitive_services_user, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
    ] : [],

    var.use_authentication ? [
      { name = "search-reader-role-backend", scope = var.resource_group_id, role_id = local.roles.reader, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
    ] : [],

    var.use_multimodal ? [
      { name = "vision-role-backend", scope = var.resource_group_id, role_id = local.roles.cognitive_services_user, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
    ] : [],

    var.client_app_id != "" ? [
      { name = "storage-contrib-aca-backend", scope = var.resource_group_id, role_id = local.roles.storage_blob_data_contributor, principal_id = var.backend_principal_id, principal_type = "ServicePrincipal" },
    ] : [],

    # ========== SEARCH SERVICE ROLES ==========
    var.deploy_azure_openai && var.search_service_sku_name != "free" ? [
      { name = "openai-role-searchservice", scope = var.resource_group_id, role_id = local.roles.cognitive_services_openai_user, principal_id = var.search_principal_id, principal_type = "ServicePrincipal" },
    ] : [],

    var.use_multimodal && var.search_service_sku_name != "free" ? [
      { name = "vision-role-searchservice", scope = var.resource_group_id, role_id = local.roles.cognitive_services_user, principal_id = var.search_principal_id, principal_type = "ServicePrincipal" },
    ] : [],

    (var.use_integrated_vectorization || var.use_cloud_ingestion) && var.search_service_sku_name != "free" ? [
      { name = "storage-role-searchservice", scope = var.resource_group_id, role_id = local.roles.storage_blob_data_reader, principal_id = var.search_principal_id, principal_type = "ServicePrincipal" },
    ] : [],

    var.use_integrated_vectorization && var.use_multimodal && var.search_service_sku_name != "free" ? [
      { name = "storage-contrib-searchservice", scope = var.resource_group_id, role_id = local.roles.storage_blob_data_contributor, principal_id = var.search_principal_id, principal_type = "ServicePrincipal" },
    ] : [],
  )
}

resource "azurerm_role_assignment" "this" {
  for_each = { for ra in local.role_assignments : ra.name => ra }

  scope              = each.value.scope
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/${each.value.role_id}"
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
}

# =============================================================================
# Cosmos DB SQL Role (data plane — separate from ARM RBAC)
# =============================================================================

resource "azurerm_cosmosdb_sql_role_assignment" "user" {
  count               = var.use_authentication && var.use_chat_history_cosmos && var.principal_id != "" ? 1 : 0
  resource_group_name = split("/", var.cosmosdb_id)[4]
  account_name        = var.cosmosdb_account_name
  role_definition_id  = "${var.cosmosdb_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = var.principal_id
  scope               = var.cosmosdb_id
}

resource "azurerm_cosmosdb_sql_role_assignment" "backend" {
  count               = var.use_authentication && var.use_chat_history_cosmos ? 1 : 0
  resource_group_name = split("/", var.cosmosdb_id)[4]
  account_name        = var.cosmosdb_account_name
  role_definition_id  = "${var.cosmosdb_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = var.backend_principal_id
  scope               = var.cosmosdb_id
}
