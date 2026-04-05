# RAG chat: Terraform deployment and CI/CD

This guide covers advanced deployment topics. If you are new to the project, start with the main [README](../README.md#deploying).

* [How does the Terraform deployment work?](#how-does-the-terraform-deployment-work)
* [Tearing down resources (cost clean-up)](#tearing-down-resources-cost-clean-up)
* [Re-deploying from scratch after a destroy](#re-deploying-from-scratch-after-a-destroy)
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

## Tearing down resources (cost clean-up)

To delete all Azure resources provisioned by Terraform and stop all billing, run:

```powershell
terraform -chdir=infra/terraform destroy -var-file=environments/dev.tfvars
```

This removes every resource in the deployment — Azure OpenAI, AI Search, Storage, Cosmos DB, Container Apps, Container Registry, and all role assignments.

> **What is preserved locally:** Your `infra/terraform/environments/dev.tfvars` and your `.env` file are not deleted. All your source code stays intact. You can re-deploy at any time by following the steps below.

> **Soft-delete warning:** Azure soft-deletes Cognitive Services (OpenAI, Document Intelligence, Vision) resources for 48 days after destroy. If you re-deploy with the same `environment_name` within that window you may hit a `Conflict (HTTP 409)` error. The Terraform templates include `restore = true` to handle this automatically. If you still hit the error, see [deploy_troubleshooting.md](deploy_troubleshooting.md) for manual purge steps.

## Re-deploying from scratch after a destroy

Follow these steps in order to fully restore the application:

### Step 1 — Re-provision all Azure resources

```powershell
terraform -chdir=infra/terraform init        # only needed if .terraform folder was deleted
terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars
```

This recreates everything: OpenAI, AI Search, Storage, Cosmos DB, Container Apps, Container Registry. It typically takes 10–20 minutes.

### Step 2 — Regenerate the .env file

After `apply` completes, regenerate the `.env` file from Terraform outputs so local dev and scripts pick up the new resource names:

```powershell
./scripts/load_python_env.ps1
```

### Step 3 — Re-index documents into AI Search

The Storage and Search index are new and empty after a fresh deploy. Re-upload and index your documents:

```powershell
./scripts/prepdocs.ps1
```

### Step 4 — Rebuild and push the Docker image

The Container Registry is new, so it has no image. Rebuild and push:

```powershell
$ACR = terraform -chdir=infra/terraform output -raw container_registry_name
az acr build --registry $ACR --file app/backend/Dockerfile --image azure-search-openai:latest app/backend/
```

### Step 5 — Update the Container App with the new image

```powershell
$RG  = terraform -chdir=infra/terraform output -raw azure_resource_group
$APP = terraform -chdir=infra/terraform output -raw backend_service_name

az containerapp update --name $APP --resource-group $RG --image "$ACR.azurecr.io/azure-search-openai:latest"
```

### Step 6 — Verify

Open the Container App URL (from `terraform output backend_uri`) in your browser and send a test chat message. Check the container logs to confirm uvicorn started cleanly:

```powershell
az containerapp logs show --name $APP --resource-group $RG --tail 20
```

Look for `Uvicorn running on http://0.0.0.0:8000` and `Application startup complete.`

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

