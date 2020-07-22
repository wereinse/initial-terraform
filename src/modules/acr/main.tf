/**
* # Module Properties
*
* This module is used to create the azure container registry to store private copies of the application containers to use in this test environment
* 
* For this to work you will need to assign `AcrPull` rights to the Application Insights service to the ACR post deployment. 
*
* Example usage
*
* ```hcl
* module "acr" {
*  source        = "../modules/acr"
*  NAME          = var.NAME
*  LOCATION      = var.LOCATION
*  REPO          = var.REPO
*  ACR_RG_NAME   = azurerm_resource_group.acr.name
*  ACR_SP_ID     = var.ACR_SP_ID
*  ACR_SP_SECRET = var.ACR_SP_SECRET
* }
* ```
*/

resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_container_registry" "acr" {
  name                = var.NAME
  location            = var.LOCATION
  resource_group_name = var.ACR_RG_NAME
  admin_enabled       = false
  sku                 = "Standard"
}

resource null_resource acr-access {
  provisioner "local-exec" {
    command = "az role assignment create --scope ${azurerm_container_registry.acr.id} --role acrpull --assignee ${var.ACR_SP_ID}"
  }
}

resource null_resource acr-import {
  provisioner "local-exec" {
    command = "az acr import -n ${azurerm_container_registry.acr.name} --source ${var.REPO}"
  }
}
resource "azurerm_container_registry_webhook" "webhook" {
  name                = var.NAME
  location            = var.LOCATION
  resource_group_name = var.ACR_RG_NAME
  registry_name       = azurerm_container_registry.acr.name
  service_uri         = "https://${var.NAME}-aci.scm.azurewebsites.net/docker/hook"
  status              = "enabled"
  scope               = "${var.REPO}:latest"
  actions             = ["push"]
  custom_headers = {
    "Content-Type" = "application/json"
  }
}
