/**
* # Module Properties
*
* This module is used to create the  instances needed for End to End testing of the terraform functionality
*
* Visit the PUT PROJECT HERE project for more information on how it works
*
* Example usage and testing
*
* ```hcl
* module "aci" {
* source              = "../modules/aci"
* NAME                = var.NAME
* LOCATION            = var.LOCATION
* CONTAINER_FILE_NAME = var.CONTAINER_FILE_NAME
* ACI_RG_NAME         = azurerm_resource_group.aci.name
* }
* ```
*/

resource azurerm_log_analytics_workspace logs {
  name                = "${var.NAME}-logs"
  location            = var.LOCATION
  resource_group_name = var.ACI_RG_NAME
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_container_group" aci {
  depends_on = [
    var.APP_SERVICE_DONE,
    azurerm_log_analytics_workspace.logs
  ]
  for_each            = var.INSTANCE
  name                = var.NAME
  location            = each.key
  resource_group_name = var.ACI_RG_NAME
  os_type             = "Linux"

  container {
    name  = var.NAME
    image = var.IMAGE_NAME
    commands = ["docker",  "run",  "hello-world:latest", "--server", var.NAME, "--files", var.REPO, "--json-log", "--tag", var.REPO]
    cpu      = "0.5"
    memory   = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.logs.workspace_id
      workspace_key = azurerm_log_analytics_workspace.logs.primary_shared_key
    }
  }

  tags = {
    environment = var.NAME,
    repo        = var.REPO
  }
}

output "ACI_DONE" {
  depends_on  = [azurerm_container_group.aci]
  value       = true
  description = "ACI setup is complete"
}
