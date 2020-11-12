/**
* # Module Properties
*
* This module is used to create the Azure Machine Learning workspace to use in this test environment
* 
* seven usage
*
* ```hcl
* module "aml" {
*  source        = "../modules/aml"
*  NAME          = var.NAME
*  LOCATION      = var.LOCATION
*  APP_INS_ID    = var.APP_INS_ID
*  KEY_VAULT_ID  = var.KEY_VAULT_ID
*  AML_RG_NAME   = azurerm_resource_group.aml.name
* }
* ```
*/

data "azurerm_client_config" "tfstatecurrent" {}

resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
  number  = false
  keepers = {
    rg_id = "${var.AML_RG_NAME}"
  }
}

resource "azurerm_storage_account" "seven-storage" {
  name                    = substr("${var.NAME}amlstorage${random_string.unique.result}", 0, 24)
  resource_group_name     = var.AML_RG_NAME
  location                = var.LOCATION
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

output "amlwkspc_storage_primary_key" {
  value       = azurerm_storage_account.seven-storage.primary_access_key
  sensitive   = true
  description = "The primary read Only key for the aml workspace storage account."
}

output "amlwkspc_storage_secondary_key" {
  value       = azurerm_storage_account.seven-storage.secondary_access_key
  sensitive   = true
  description = "The secondary read Only key for the aml workspace storage account."
}

// resource "azurerm_machine_learning_workspace" "seven" {
//   name                    = "${var.NAME}"-amlwkspc
//   location                = var.LOCATION
//   resource_group_name     = var.AML_RG_NAME
//   application_insights_id = var.APP_INS_ID
//   key_vault_id            = var.KEY_VAULT_ID
//   storage_account_id      = azurerm_storage_account.seven-storage.id

//   identity {
//     type = "SystemAssigned"
//   }
// }

