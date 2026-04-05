
# RAG chat: Deploying with existing Azure resources

If you already have existing Azure resources, or if you want to specify the exact name of new Azure Resource, you can do so by setting `terraform` environment values.
You should set these values before running `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars`. Once you've set them, return to the [deployment steps](../README.md#deploying).

* [Resource group](#resource-group)
* [OpenAI resource](#openai-resource)
* [Azure AI Search resource](#azure-ai-search-resource)
* [Azure App Service Plan and App Service resources](#azure-app-service-plan-and-app-service-resources)
* [Azure AI Vision resources](#azure-ai-vision-resources)
* [Azure Document Intelligence resource](#azure-document-intelligence-resource)
* [Azure Speech resource](#azure-speech-resource)
* [Azure Storage Account](#azure-storage-account)

> [!NOTE]
> When you specify an existing resource, the Bicep templates will still attempt to re-provision or update the service. This means some service parameters may be overridden with the default values from the templates. If you need to preserve specific configurations, review the Bicep files in `infra/` and adjust the parameters accordingly.
>
> **RBAC considerations**: This project uses managed identity and RBAC role assignments for authentication between services. If your existing resources are in a different resource group than the main deployment, the RBAC role assignments may not be created correctly, and you may need to manually assign the required roles. For the simplest setup, we recommend keeping all resources in the same resource group.

## Resource group

1. Run 
1. Run 

## OpenAI resource

### Azure OpenAI

1. Run 
1. Run 
1. Run 
1. Run . Only needed if your chat deployment name is not the default 'gpt-4.1-mini'.
1. Run . Only needed if your chat model is not the default 'gpt-4.1-mini'.
1. Run . Only needed if your chat deployment model version is not the default '2024-07-18'. You definitely need to change this if you changed the model.
1. Run . Only needed if your chat deployment SKU is not the default 'Standard', like if it is 'GlobalStandard' instead.
1. Run . Only needed if your embeddings deployment is not the default 'embedding'.
1. Run . Only needed if your embeddings model is not the default 'text-embedding-3-large'.
1. Run . Only needed if your embeddings model is not the default 'text-embedding-3-large'.
1. Run . If your embeddings deployment is one of the 'text-embedding-3' models, set this to the number 1.
1. This project does *not* use keys when authenticating to Azure OpenAI. However, if your Azure OpenAI service must have key access enabled for some reason (like for use by other projects), then run . The default value is `true` so you should only run the command if you need key access.

When you run `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars` after and are prompted to select a value for `openAiResourceGroupLocation`, make sure to select the same location as the existing OpenAI resource group.

> [!WARNING]
> If using a different resource group, the following RBAC roles may not be assigned correctly: `Cognitive Services OpenAI User` for the backend and search service. You may need to manually assign these roles.

### Openai.com OpenAI

1. Run 
2. Run 
3. Run 
4. Run `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars`

You can retrieve your OpenAI key by checking [your user page](https://platform.openai.com/account/api-keys) and your organization by navigating to [your organization page](https://platform.openai.com/account/org-settings).
Learn more about creating an OpenAI free trial at [this link](https://openai.com/pricing).
Do *not* check your key into source control.

When you run `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars` after and are prompted to select a value for `openAiResourceGroupLocation`, you can select any location as it will not be used.

## Azure AI Search resource

1. Run 
1. Run 
1. If that resource group is in a different location than the one you'll pick for the `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars` step,
  then run 
1. If the search service's SKU is not standard, then run . If you specify the free tier, then your app will no longer be able to use semantic ranker. You can [switch between Basic, S1, S2, and S3 tiers](https://learn.microsoft.com/azure/search/search-capacity-planning#change-your-pricing-tier), but you can't switch to or from Free, S3HD, L1, or L2. ([See other possible SKU values](https://learn.microsoft.com/azure/templates/microsoft.search/searchservices?pivots=deployment-language-bicep#sku))
1. If you have an existing index that is set up with all the expected fields, then run . Otherwise, the `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars` command will create a new index.

You can also customize the search service (new or existing) for non-English searches:

1. To configure the language of the search query to a value other than "en-US", run . ([See other possible values](https://learn.microsoft.com/rest/api/searchservice/preview-api/search-documents#queryLanguage))
1. To turn off the spell checker, run . Consult [this table](https://learn.microsoft.com/rest/api/searchservice/preview-api/search-documents#queryLanguage) to determine if spell checker is supported for your query language.
1. To configure the name of the analyzer to use for a searchable text field to a value other than "en.microsoft", run . ([See other possible values](https://learn.microsoft.com/dotnet/api/microsoft.azure.search.models.field.analyzer?view=azure-dotnet-legacy&viewFallbackFrom=azure-dotnet))

> [!WARNING]
> If using a different resource group, the following RBAC roles may not be assigned correctly and may need to be manually assigned:
>
> * Backend identity: `Search Index Data Reader`, `Search Index Data Contributor`
> * Signed-in user (`principalId`): `Search Index Data Reader`, `Search Index Data Contributor`, `Search Service Contributor`

## Azure App Service Plan and App Service resources

1. Run 
1. Run .
1. Run .

## Azure AI Vision resources

1. Run 
1. Run 
1. Run 
1. Run 

> [!WARNING]
> If using a different resource group, the following RBAC roles may not be assigned correctly: `Cognitive Services User` for the backend and search service. You may need to manually assign these roles.

## Azure Document Intelligence resource

In order to support analysis of many document formats, this repository uses a preview version of Azure Document Intelligence (formerly Form Recognizer) that is only available in [limited regions](https://learn.microsoft.com/azure/ai-services/document-intelligence/concept-layout).
If your existing resource is in one of those regions, then you can re-use it by setting the following environment variables:

1. Run 
1. Run 
1. Run 
1. Run 

> [!WARNING]
> If using a different resource group, the following RBAC roles may not be assigned correctly: `Cognitive Services User` for the backend (required for user upload feature). You may need to manually assign these roles.

## Azure Speech resource

1. Run 
1. Run 
1. If that resource group is in a different location than the one you'll pick for the `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars` step,
  then run 
1. If the speech service's SKU is not "S0", then run .

> [!WARNING]
> If using a different resource group, the following RBAC roles may not be assigned correctly: `Cognitive Services Speech User` for the backend and user. You may need to manually assign these roles.

## Azure Storage Account

1. Run 
1. Run 
1. If that resource group is in a different location than the one you'll pick for the `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars` step,
  then run 
1. To change the storage SKU from the default `Standard_LRS`, run . For production, we recommend `Standard_ZRS` for improved resiliency.

> [!WARNING]
> If using a different resource group, the following RBAC roles may not be assigned correctly: `Storage Blob Data Reader`, `Storage Blob Data Contributor`, and `Storage Blob Data Owner` for the backend, user, and search service. You may need to manually assign these roles.