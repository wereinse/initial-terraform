/**
* # Module Properties
*
* This module is used to create the Azure Function application INSTANCE.  
* 
*
* function-storage-account usage and testing
*
* ```hcl
* module "functions" {
* source              = "../modules/functions"
* NAME                = var.NAME
* LOCATION            = var.LOCATION
* INSTANCE           = var.INSTANCE
* functions_RG_NAME   = azurerm_resource_group.kroger-functions.name
* FUNCTIONSAPP        = var.FUNCTIONSAPP
* }
* ```
*/

resource "azurerm_storage_account" "function-storage-account" {
  for_each                 = var.INSTANCE
  name                     = substr("${each.key}funcstorage", 0, 24)
  resource_group_name      = var.FUNCTION_RG
  location                 = var.LOCATION
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "function-deploy-container" {
    for_each                 = var.INSTANCE
    name                     = substr("${each.key}funccntr", 0, 24)
    storage_account_name     = azurerm_storage_account.function-storage-account[each.key].name
    container_access_type = "private"
}

resource "azurerm_storage_blob" "appcode" {
    for_each                  = var.INSTANCE
    name = "functionapp.zip"
    storage_account_name = azurerm_storage_account.function-storage-account[each.key].name
    storage_container_name = azurerm_storage_container.function-deploy-container[each.key].name
    type = "Block"
    source = var.FUNCTIONAPP
}

resource "azurerm_function_app" "function-app" {
  for_each                  = var.INSTANCE
  name                      = "${each.key}-function"
  location                  = var.LOCATION
  resource_group_name       = var.FUNCTION_RG
  app_service_plan_id       = "var.NAME-${each.key}"
  storage_connection_string = azurerm_storage_account.function-storage-account[each.key].primary_connection_string 
  version                   = "~2"
}
// data "azurerm_storage_account" "function-storage-account" {
//   for_each                 = var.INSTANCE
//   name                     = azurerm_storage_account.function-storage-account[each.key].name
//   resource_group_name      = var.FUNCTION_RG
// }
//resource "azurerm_app_service_plan" "function-service-plan" {
  //for_each                 = var.INSTANCE
//  name                     = "${each.key}-function-service-plan"
//  resource_group_name      = var.FUNCTION_RG
//  location                 = var.LOCATION
//  sku {
//    tier = "Standard"
//    size = "S1"
//  }
//}

resource "azurerm_kubernetes_cluster" "aks" {
  name                     = substr("${each.key}funcstorage", 0, 24)
  resource_group_name      = var.FUNCTION_RG
  location                 = var.LOCATION
  dns_prefix               = "var.DNS_PREFIX"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  agent_pool_profile {
    name = "default"
    count = 3
    vm_size = "Standard_DS1_v2"
    os_type = "Linux"
    os_disk_size_gb = "30"
  }

  service_principal {
    client_id = "00000000-0000-0000-0000-000000000000"
    client_secret = "000000000000000000000000000000000000"
  }

  tags {
    Environment = "Development"
  }
}

output "id" {
    value = "${azurerm_kubernetes_cluster.aks.id}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
}

output "client_key" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.host}"
}

