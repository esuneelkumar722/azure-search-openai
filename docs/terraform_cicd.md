# RAG chat: Terraform deployment and CI/CD

This guide covers advanced deployment topics. If you are new to the project, start with the main [README](../README.md#deploying).

* [How does the Terraform deployment work?](#how-does-the-terraform-deployment-work)
* [Configuring continuous deployment](#configuring-continuous-deployment)
  * [GitHub Actions](#github-actions)
  * [Azure Pipelines](#azure-pipelines)

## How does the Terraform deployment work?

All Azure infrastructure for this project is defined in `infra/terraform/`. A single `terraform apply` provisions every resource — OpenAI, AI Search, Storage, Cosmos DB, Container Apps, Container Registry, and all RBAC role assignments.

The deployment workflow (summarized from the [README](../README.md#deploying)):

1. **`az login`** — authenticate to Azure
2. **Edit `infra/terraform/environments/dev.tfvars`** — set your location, principal ID, and any feature flags
3. **`terraform -chdir=infra/terraform init`** — download providers (first time only)
4. **`terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars`** — provision everything
5. **Run prepdocs** — upload documents and trigger AI Search indexing
6. **Build and push Docker image, deploy to Container App** — using `az acr build` / `az containerapp update`

Re-deploying after infrastructure changes:
```shell
terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars
```

Re-deploying after app code changes only:
```powershell
$ACR = terraform -chdir=infra/terraform output -raw container_registry_name
$RG  = terraform -chdir=infra/terraform output -raw azure_resource_group
$APP = terraform -chdir=infra/terraform output -raw backend_service_name

az acr build --registry $ACR --image azure-search-openai:latest app/ --no-logs
az containerapp update --name $APP --resource-group $RG --image "$ACR.azurecr.io/azure-search-openai:latest"
```

## Configuring continuous deployment

### GitHub Actions

A GitHub Actions workflow is provided at `.github/workflows/` for CI/CD.

The workflow uses [Workload Identity Federation](https://learn.microsoft.com/azure/active-directory/workload-identities/workload-identity-federation) (no stored secrets) or a Service Principal to authenticate to Azure and run `terraform apply` followed by a Docker build and Container App update.

To set up:

1. Create a Service Principal or configure Workload Identity Federation for your repository.
2. Add the following secrets to your GitHub repository settings:
   - `AZURE_CLIENT_ID` (or `AZURE_CREDENTIALS` for SP)
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
3. Add a `dev.tfvars` as a GitHub Actions secret or committed environment file.
4. The `deploy` job in the workflow runs:
   ```shell
   terraform -chdir=infra/terraform init
   terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars -auto-approve
   ```
   followed by the `az acr build` / `az containerapp update` commands.

See `.github/workflows/` for the full workflow definition.

### Azure Pipelines

An Azure Pipelines definition is provided at `infra/terraform/pipelines/azure-pipelines.yml`.

To set up:

1. Run `infra/terraform/pipelines/setup-wif.sh` to configure Workload Identity Federation for your pipeline service connection.
2. Create a variable group in Azure DevOps with the same variables as above.
3. The pipeline runs `terraform apply` and deploys the app on every push to `main`.

See `infra/terraform/pipelines/` for the full pipeline definition.

