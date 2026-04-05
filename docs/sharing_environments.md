# RAG chat: Sharing deployment environments

If you've deployed the RAG chat solution already following the steps in the [deployment guide](../README.md#deploying), you may want to share the environment with a colleague.
Either you or they can follow these steps:

1. Install the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
1. Clone this repository.
1. Copy the `dev.tfvars` from the person who originally deployed:
   Share your `infra/terraform/environments/dev.tfvars` file with your colleague (it contains the resource group name, subscription ID, and all variable values). They can place it at the same path.
1. Set the environment variable `AZURE_PRINCIPAL_ID` either in a `.env` file or in the active shell to their Azure ID, which they can get with `az ad signed-in-user show`.
1. Run `./scripts/roles.ps1` or `.scripts/roles.sh` to assign all of the necessary roles to the user.  If they do not have the necessary permission to create roles in the subscription, then you may need to run this script for them. Once the script runs, they should be able to run the app locally.
