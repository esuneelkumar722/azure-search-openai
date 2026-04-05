# RAG chat: Deploying with minimal costs

This AI RAG chat application provisions Azure infrastructure using Terraform, defined in the `infra/terraform/` folder. Those files describe each of the Azure resources needed, and configure their SKU (pricing tier) and other parameters. Many Azure services offer a free tier, but the infrastructure files in this project do *not* default to the free tier as there are often limitations in that tier.

However, if your goal is to minimize costs while prototyping your application, follow the steps below *before* running `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars`. Once you've gone through these steps, return to the [deployment steps](../README.md#deploying).

[📺 Live stream: Deploying from a free account](https://www.youtube.com/watch?v=nlIyos0RXHw)

1. Log in to your Azure account using the Azure Developer CLI:

    ```shell
    az login
    ```

1. Create a `dev.tfvars` file from the example:

    ```shell
    cp infra/terraform/environments/dev.tfvars.example infra/terraform/environments/dev.tfvars
    ```

    Edit the file and set `resource_group_name` to the desired name for the resource group.

1. Switch from Azure Container Apps to the free tier of Azure App Service:

    Azure Container Apps has a consumption-based pricing model that is very low cost, but it is not free, plus Azure Container Registry costs a small amount each month.

    To deploy to App Service instead, edit `infra/terraform/environments/dev.tfvars` and set:

        ```hcl
        deployment_target     = "appservice"
        app_service_sku_name  = "F1"
        ```

    Then re-apply Terraform:

        ```shell
        terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars
        ```

    Limitation: You are only allowed a certain number of free App Service instances per region. If you have exceeded your limit in a region, you will get an error during the provisioning stage. If that happens, you can run `terraform -chdir=infra/terraform destroy -var-file=environments/dev.tfvars`, then `cp infra/terraform/environments/dev.tfvars.example infra/terraform/environments/dev.tfvars` to create a new environment with a new region.

1. Use the free tier of Azure AI Search:

    Edit `infra/terraform/environments/dev.tfvars` and set:

    ```hcl
    search_service_sku_name = "free"
    ```

    Limitations:
    1. You are only allowed one free search service across all regions.
    If you have one already, either delete that service or follow instructions to
    reuse your [existing search service](../README.md#existing-azure-ai-search-resource).
    2. The free tier does not support semantic ranker, so the app UI will no longer display
    the option to use the semantic ranker. Note that will generally result in [decreased search relevance](https://techcommunity.microsoft.com/blog/azure-ai-services-blog/azure-ai-search-outperforming-vector-search-with-hybrid-retrieval-and-ranking-ca/3929167).
    3. The free tier does not support managed identities. As a result, cloud ingestion and multimodal/vector features that require role assignments to the search service principal will have those role assignments skipped during provisioning. If you need those permissions, use a non-free tier (for example, `Basic`/`B1` or `Standard`).

1. Use the free tier of Azure Document Intelligence (used in analyzing files):

    Edit `infra/terraform/environments/dev.tfvars` and set:

    ```hcl
    document_intelligence_sku_name = "F0"
    ```

    **Limitation for PDF files:**

      The free tier will only scan the first two pages of each PDF.
      In our sample documents, those first two pages are just title pages,
      so you won't be able to get answers from the documents.
      You can either use your own documents that are only 2-pages long,
      or you can use a local Python package for PDF parsing by setting:

      Edit `infra/terraform/environments/dev.tfvars` and set:

      ```hcl
      use_local_pdf_parser = true
      ```

    **Limitation for HTML files:**

      The free tier will only scan the first two pages of each HTML file.
      So, you might not get very accurate answers from the files.
      You can either use your own files that are only 2-pages long,
      or you can use a local Python package for HTML parsing by setting:

      Edit `infra/terraform/environments/dev.tfvars` and set:

      ```hcl
      use_local_html_parser = true
      ```

1. Use the free tier of Azure Cosmos DB:

    Edit `infra/terraform/environments/dev.tfvars` and set:

    ```hcl
    cosmosdb_sku_name = "free"
    ```

    Limitation: You can have only one free Cosmos DB account. To keep your account free of charge, ensure that you do not exceed the free tier limits. For more information, see the [Azure Cosmos DB lifetime free tier](https://learn.microsoft.com/azure/cosmos-db/free-tier).

1. ⚠️ This step is currently only possible if you're deploying to App Service ([see issue 2281](https://github.com/Azure-Samples/azure-search-openai-demo/issues/2281)):

    Turn off Azure Monitor (Application Insights):

    Edit `infra/terraform/environments/dev.tfvars` and set:

    ```hcl
    use_application_insights = false
    ```

    Application Insights is quite inexpensive already, so turning this off may not be worth the costs saved,
    but it is an option for those who want to minimize costs.

1. Use OpenAI.com instead of Azure OpenAI: This should not be necessary, as the costs are same for both services, but you may need this step if your account does not have access to Azure OpenAI for some reason.

    Edit `infra/terraform/environments/dev.tfvars` and set:

    ```hcl
    openai_host         = "openai"
    openai_api_organization = "{Your OpenAI organization}"
    openai_api_key      = "{Your OpenAI API key}"
    ```

    Both Azure OpenAI and openai.com OpenAI accounts will incur costs, based on tokens used,
    but the costs are fairly low for the amount of sample data (less than $10).

1. Disable vector search:

    Edit `infra/terraform/environments/dev.tfvars` and set:

    ```hcl
    use_vectors = false
    ```

    By default, the application computes vector embeddings for documents during the data ingestion phase,
    and then computes a vector embedding for user questions asked in the application.
    Those computations require an embedding model, which incurs costs per tokens used. The costs are fairly low,
    so the benefits of vector search would typically outweigh the costs, but it is possible to disable vector support.
    If you do so, the application will fall back to a keyword search, which is less accurate.

1. Once you've made the desired customizations, follow the steps in the README [to run `terraform -chdir=infra/terraform apply -var-file=environments/dev.tfvars`](../README.md#deploying-from-scratch). We recommend using "eastus" as the region, for availability reasons.

## Reducing costs locally

To save costs for local development, you could use an OpenAI-compatible model.
Follow steps in [local development guide](localdev.md#using-a-local-openai-compatible-api).