/**
* # Module Properties
*
* This module is used to create the CosmosDB instance, Databases and collections for the [Helium](https://github.com/retaildevcrews/helium) application
*
* For this to work the system running the TF `apply` will need to have the docker runtime installed and working.
*
* Example usage and Testing
*
* ```hcl
* module "db" {
*  source         = "../modules/db"
*  NAME           = var.NAME
*  LOCATION       = var.LOCATION
*  COSMOS_RG_NAME = azurerm_resource_group.cosmos.name
*  COSMOS_RU      = var.COSMOS_RU
*  COSMOS_DB      = var.COSMOS_DB
*  COSMOS_COL     = var.COSMOS_COL
*  ACR_SP_ID      = var.ACR_SP_ID
*  ACR_SP_SECRET  = var.ACR_SP_SECRET
*}
* ```
*/

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = var.NAME
  location            = var.LOCATION
  resource_group_name = var.COSMOS_RG_NAME
  kind                = "GlobalDocumentDB"
  offer_type          = "Standard"
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = "5"
    max_staleness_prefix    = "100"
  }
  enable_automatic_failover = false
  geo_location {
    location          = var.LOCATION
    failover_priority = "0"
  }
}

output "ro_key" {
  value       = azurerm_cosmosdb_account.cosmosdb.primary_readonly_master_key
  sensitive   = true
  description = "The read Only key for the CosmosDB to be used by the Application. This is used to pass into the webapp module"
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb" {
  name                = var.COSMOS_DB
  resource_group_name = var.COSMOS_RG_NAME
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  throughput          = var.COSMOS_RU
}

resource "azurerm_cosmosdb_sql_container" "cosmosdbcontainer" {
  name                = var.COSMOS_COL
  resource_group_name = var.COSMOS_RG_NAME
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.cosmosdb.name
  partition_key_path  = "/partitionKey"
}

resource null_resource db-import {
  provisioner "local-exec" {
    command = "docker pull hello-world:latest && docker run --rm --name \"${var.NAME}\" hello-world:latest" 
  }
}

// was --name db-import   \"${azurerm_cosmosdb_account.cosmosdb.name}\" \"${azurerm_cosmosdb_account.cosmosdb.primary_master_key}\" \"${azurerm_cosmosdb_sql_database.cosmosdb.name}\" \"${azurerm_cosmosdb_sql_container.cosmosdbcontainer.name}\""

output "DB_IMPORT_DONE" {
  depends_on  = [null_resource.db-import]
  value       = true
  description = "db-import complete"
}

// data "docker_registry_image" "db-import" {
//   name        = var.REPO
//}
