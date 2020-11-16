/**
* # Parent Template Properties
*
* This is the parent Terraform Template used to call the component modules to create the infrastructure and deploy the application.
*
* The only resources created in the template are the resource groups that each Service will go into. It is advised to create a terraform.tfvars file to assign values to the variables in the `variables.tf` file.
*
* To keep sensitive keys from being stored on disk or source control you can set local environment variables that start with **NameOfVariable**. This can be used with the Terraform Service Principal Variables
*
* tfstate usage (not real values)
*
* ```shell
* export TF_SUB_ID="gy6tgh5t-9876-3uud-87y3-r5ygytd6uuyr"
* export TF_TENANT_ID="frf34ft5-gtfv-wr34-343fw-hfgtry657uk8"
* export TF_CLIENT_ID="ju76y5h8-98uh-oin8-n7ui-ger43k87d5nl"
* export TF_CLIENT_SECRET="kjbh89098hhiuovvdh6j8uiop="
* ```
*/

provider "azurerm" {
  version = "2.36.0"
  features {}

  subscription_id = var.TF_SUB_ID
  client_id       = var.TF_CLIENT_ID
  client_secret   = var.TF_CLIENT_SECRET
  tenant_id       = var.TF_TENANT_ID
}

provider "azuread" {
  subscription_id = var.TF_SUB_ID
  client_id       = var.TF_CLIENT_ID
  client_secret   = var.TF_CLIENT_SECRET
  tenant_id       = var.TF_TENANT_ID
}

resource "azurerm_resource_group" "acr" {
  name     = "${var.NAME}-rg-acr"
  location = var.LOCATION
}

resource "azurerm_resource_group" "cosmos" {
  name     = "${var.NAME}-rg-cosmos"
  location = var.LOCATION
}

resource "azurerm_resource_group" "app" {
  name     = "${var.NAME}-rg-app"
  location = var.LOCATION
}

resource "azurerm_resource_group" "aci" {
  name     = "${var.NAME}-rg-webv"
  location = var.LOCATION
}

resource "azurerm_resource_group" "aks" {
  name     = "${var.NAME}-rg-aks"
  location = var.LOCATION
}

resource "azurerm_resource_group" "aml" {
  name     = "${var.NAME}-rg-aml"
  location = var.LOCATION
}

resource "azurerm_resource_group" "tfstate" {
  name     = "${var.NAME}-rg-tf"
  location = var.LOCATION
}

module "acr" {
  source        = "../modules/acr"
  NAME          = var.NAME
  LOCATION      = var.LOCATION
  REPO          = var.REPO
  ACR_RG_NAME   = azurerm_resource_group.acr.name
  ACR_SP_ID     = var.ACR_SP_ID
  ACR_SP_SECRET = var.ACR_SP_SECRET
}

module "db" {
  source         = "../modules/db"
  NAME           = var.NAME
  LOCATION       = var.LOCATION
  COSMOS_RG_NAME = azurerm_resource_group.cosmos.name
  COSMOS_RU      = var.COSMOS_RU
  COSMOS_DB      = var.COSMOS_DB
  COSMOS_COL     = var.COSMOS_COL
  ACR_SP_ID      = var.ACR_SP_ID
  ACR_SP_SECRET  = var.ACR_SP_SECRET
}

module "web" {
  source = "../modules/webapp"

  NAME              = var.NAME
  LOCATION          = var.LOCATION
  REPO              = var.REPO
  ACR_SP_ID         = var.ACR_SP_ID
  ACR_SP_SECRET     = var.ACR_SP_SECRET
  APP_RG_NAME       = azurerm_resource_group.app.name
  TFSTATE_RG_NAME   = azurerm_resource_group.tfstate.name
  TENANT_ID         = var.TF_TENANT_ID
  COSMOS_RG_NAME    = azurerm_resource_group.cosmos.name
  COSMOS_URL        = "https://${var.NAME}.documents.azure.com:443/"
  COSMOS_KEY        = module.db.ro_key
  COSMOS_DB         = var.COSMOS_DB
  COSMOS_COL        = var.COSMOS_COL
  DB_IMPORT_DONE    = module.db.DB_IMPORT_DONE
  APP_SERVICE_DONE  = module.web.APP_SERVICE_DONE
  ACI_DONE          = module.aci.ACI_DONE
  TF_SUB_ID         = var.TF_SUB_ID
  EMAIL_FOR_ALERTS  = var.EMAIL_FOR_ALERTS
  RT_THRESHOLD      = var.RT_THRESHOLD
  RT_OPERATOR       = var.RT_OPERATOR
  RT_SEVERITY       = var.RT_SEVERITY
  RT_FREQUENCY      = var.RT_FREQUENCY
  RT_WINDOW_SIZE    = var.RT_WINDOW_SIZE
  MR_THRESHOLD      = var.MR_THRESHOLD
  MR_OPERATOR       = var.MR_OPERATOR
  MR_SEVERITY       = var.MR_SEVERITY
  MR_FREQUENCY      = var.MR_FREQUENCY
  MR_WINDOW_SIZE    = var.MR_WINDOW_SIZE
  WT_FREQUENCY      = var.WT_FREQUENCY
  WT_WINDOW_SIZE    = var.WT_WINDOW_SIZE
  WT_SEVERITY       = var.WT_SEVERITY
  WT_THRESHOLD      = var.WT_THRESHOLD
  WT_OPERATOR       = var.WT_OPERATOR
  WV_FREQUENCY      = var.WV_FREQUENCY
  WV_WINDOW_SIZE    = var.WV_WINDOW_SIZE
  WV_SEVERITY       = var.WV_SEVERITY
  WV_THRESHOLD      = var.WV_THRESHOLD
  WV_OPERATOR       = var.WV_OPERATOR
}

module "aci" {
  source              = "../modules/aci"
  NAME                = var.NAME
  LOCATION            = var.LOCATION
  IMAGE_NAME          = var.IMAGE_NAME
  INSTANCE            = var.INSTANCE
  REPO                = var.REPO
  CONTAINER_FILE_NAME = var.CONTAINER_FILE_NAME
  ACI_RG_NAME         = azurerm_resource_group.aci.name
  APP_SERVICE_DONE    = module.web.APP_SERVICE_DONE
}

module "aks" {
  source              = "../modules/aks"
  NAME                = var.NAME
  LOCATION            = var.LOCATION
  AKS_RG_NAME         = azurerm_resource_group.aks.name
  TF_CLIENT_ID        = var.TF_CLIENT_ID
  TF_CLIENT_SECRET    = var.TF_CLIENT_SECRET
  REPO                = var.REPO
}

module "aml" {
  source              = "../modules/aml"
  NAME                = var.NAME
  LOCATION            = var.LOCATION
  AMLWKSPC_NAME       = var.AMLWKSPC_NAME
  AML_RG_NAME         = azurerm_resource_group.aml.name
}