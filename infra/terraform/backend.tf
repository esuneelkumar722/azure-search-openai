# Remote state backend using Azure Storage
# Before first use, run: scripts/bootstrap-state.sh
#
# Update storage_account_name with the output from bootstrap-state.sh
# For local development without remote state, comment out this block
# and Terraform will use local state instead.

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "<YOUR_STATE_STORAGE_ACCOUNT>"  # From bootstrap-state.sh output
    container_name       = "tfstate"
    key                  = "azure-search-openai.tfstate"
    use_oidc             = false      # Set to true when using WIF in CI/CD pipeline
    use_azuread_auth     = true       # Uses your az login session for local dev
  }
}
