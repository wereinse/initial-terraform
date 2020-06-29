# Infrastructure as Code for `helium`

> This repository is used to automatically deploy [helium](https://github.com/retaildevcrews/helium) using [terraform](https://www.hashicorp.com/products/terraform)
>
> TODO - this isn't really the purpose of helium-iac for our customers. This is our internal purpose. I think we need both.

![License](https://img.shields.io/badge/license-MIT-green.svg)
![Terraform Plan](https://github.com/retaildevcrews/helium-iac/workflows/Terraform%20Plan/badge.svg)

## TODO

- Web Deploy
  - the image is pulled from docker hub
    - should be loaded into ACR (done)
    - will need an additional SP (done)
    - will need ACR pull permissions on the SP (done)
    - pull image from ACR using Key Vault credentials
  - ACR ci-cd webhook isn't setup
  - docker container logging isn't enabled

- Should we add webv deployment to manual instructions for consistency?

- need to test dashboard and alerts to make sure they are the same between manual setup and terraform setup

- option to deploy to AKS is missing (I think this is OK - especially for this release)

## Fixed in this branch

- I had to run imdb-import manually to get webv to pass
  - this now runs syncronously and blocks web
- web app throws errors due to timing
  - waits for imdb-import
  - this blocks smoker
- smoker throws errors due to timing
  - waits for imdb-import and web deploy

- the image is pulled from docker hub
  - should be loaded into ACR (done)
  - will need an additional SP (done)
  - will need ACR pull permissions on the SP (done)

- now uses standard TF_NAME url
  - how do you access / test the web api
    - need to output the URL
    - should we include instructions for running webv?
    - webv works as expected
      - where to put test files?

- standardized names to manual install
  - can we name the DB imdb instead of imdb-helium-language?
  - can we name app TF_NAME without the helium-language?
  - same for KV
  - app insights is named helium-csharp-appinsights
  - can we add -plan to the app service plan name?
  - container instances is named helium-csharp
  - availability test is named Healthz-helium-csharp-appinsights
  - dashboard is named Helium-dashboard-csharp

## Features

- one ACR
- one docker hub repo
- one app service plan
- 3 web apps (API)
- one AKS Cluster
- smoker instances running in ACI to test AKS and AppService endpoints
- one CosmosDB
- 3 Databases
- 1 Db will need 4 collections to support java
- 1 Db with 1 collection for .Net and 1 Db for TypeScript
- 3 app insights
- 3 key vaults
- standardize endpoints
  - AppSvc endpoints: bluebell, gelato, sherbert .azurewebsites.net
  - AKS Endpoints: bluebell, gelato, sherbert .cloudapp.centralus.azure.net
- standardize dashboards
- standardize Azure health checks
- standardize alerting

> Visual Studio Codespaces is the easiest way to evaluate helium as all of the prerequisites are automatically installed
>
> Follow the setup steps in the [Helium readme](https://github.com/retaildevcrews/helium) to setup Codespaces

## Prerequisites

- Azure subscription and a Service Principal permissions to create:
  - Resource Groups, Service Principals, Role Assignment, Key Vault, Cosmos DB, Azure Container Registry, Azure Monitor, App Service or AKS (Subscription Owner Role)
- Bash shell (tested on Visual Studio Codespaces, Mac, Ubuntu, Windows with WSL2)
  - Will not work in Cloud Shell or WSL1
- Azure CLI ([download](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest))
- Terraform 0.12+ ([download](https://www.terraform.io/downloads.html))
- Docker must be installed and running ([download](https://docs.docker.com/get-docker/))

## Setup

```bash

# Clone the Helium-IAC repo if not using Codespaces
git clone https://github.com/retaildevcrews/helium-iac.git

cd helium-iac/src/root

```

### Login to Azure and select subscription

```bash

az login

# show your Azure accounts
az account list -o table

# select the Azure subscription if necessary
az account set -s {subscription name or Id}

```

### Prepare your `terraform.tfvars` file to roll out resources in the subscription of your choice

> All commands require you to be in `helium-iac/src/root`

```bash

### TODO - do we need a warning here to make sure TF_NAME doesn't exist?
### BAD things happen if it does ...
### should we check RG names? Cosmos DB? Other?
### probably easiest to do the first few steps from helium and then do these steps
### we could use the same He_* names and the check vs. having to maintain in two places
### right now, we don't clone helium, we clone helium-language
### maybe we put the shipping version in helium with instructions?
### would need two repos in codespaces, but shouldn't be an issue - will need a design review

# set an env var with the name you want to use
# replace the two values below
# TF_NAME must contain only alphanumeric characters and is a prefix for other resources

export TF_NAME=replaceWithYourUniqueName
export TF_EMAIL=replaceWithYourEmail

# create terraform.tfvars and replace placeholder values
# replace TF_NAME
cat ../example.tfvars | sed "s/<<TF_NAME>>/$TF_NAME/g" > terraform.tfvars

# replace email
sed -i "s/<<TF_EMAIL>>/$TF_EMAIL/g" terraform.tfvars

# replace TF_TENANT_ID
sed -i "s/<<TF_TENANT_ID>>/$(az account show -o tsv --query tenantId)/g" terraform.tfvars

# replace TF_SUB_ID
sed -i "s/<<TF_SUB_ID>>/$(az account show -o tsv --query id)/g" terraform.tfvars

# create a service principle
# replace TF_CLIENT_SECRET
sed -i "s/<<TF_CLIENT_SECRET>>/$(az ad sp create-for-rbac -n http://${TF_NAME}-tf-sp --query password -o tsv)/g" terraform.tfvars

# replace TF_CLIENT_ID
sed -i "s/<<TF_CLIENT_ID>>/$(az ad sp show --id http://${TF_NAME}-tf-sp --query appId -o tsv)/g" terraform.tfvars

# create a service principle
# replace ACR_SP_SECRET
sed -i "s/<<ACR_SP_SECRET>>/$(az ad sp create-for-rbac -n http://${TF_NAME}-acr-sp --query password -o tsv)/g" terraform.tfvars

# replace ACR_SP_ID
sed -i "s/<<ACR_SP_ID>>/$(az ad sp show --id http://${TF_NAME}-acr-sp --query objectId -o tsv)/g" terraform.tfvars

# validate the substitutions
cat terraform.tfvars

```

## Location

Optionally edit terraform.tfvars and replace `centralus` with a different location

## Instances

Optionally edit terraform.tfvars and replace the value of instances with the environment(s) you want to deploy

TODO - for the customer version of helium-iac, I think we need to get rid of instances since they will only deploy one language.

There was a comment that they might want to deploy dev, test, prod, etc. but I don't think instances is how they would do that. I think they would have different TF scripts / values for each version. Likely in different subscriptions. Likely different permissions.

## Deploy `helium`

``` bash

# Initialize your terraform providers:
terraform init

# Format your terraform files:
terraform fmt -recursive

# Validate the terraform code is ready to apply:
terraform validate

# If you have no errors you can create the resources
# You must answer "yes" to 'Enter a value:' to create the resources
terraform apply

```

## Verify the deployment

Log into the Azure portal and browse your four new resource groups, application insights instances and dashboard created for each of the container instances you created

> TODO - should we have CLI commands for this? like curl, http, webv
>
> TODO - docs on the `terraform.tfstate` file - security, where to store, etc.
>
> If the terraform plan command is redirected to a file, there will be secrets stored in that file!
>
> Be sure to not to remove the ignore *tfplan* in the .gitignore file

## Module Documentation

Each module has a `README.md` file in the module directory under [`./src/modules/`](./src/modules/). You can reference the module documentation for the specific requirements of each module.

The main calling Terraform script can be found at [`./src/root/main.tf`](./src/root/main.tf)

Customizations are found in the /src/root/terraform.tfvars file.  This file should never be added to github and is included by default in the .gitignore file.

## Removing the deployment

>
> WARNING - this will delete everything with only one prompt
>

```bash

# this takes several minutes to run
terraform destroy

# delete the service principals
az ad sp delete --id http://${TF_NAME}-acr-sp
az ad sp delete --id http://${TF_NAME}-tf-sp

# remove state and vars files
rm terraform.tfstate*
rm terraform.tfvars

```

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit [Microsoft Contributor License Agreement](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
