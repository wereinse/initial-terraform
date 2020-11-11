/**
* # Module Properties
*
* This module is used to create the AppService, WebApp for Containers(linux), Azure Key Vault and the AppInsights used by the application.
*
* This module is broken into separate files for ease of organization but are treated as 1 single flat Terraform template when called by the module.
* This module also securely stores the tfstate files in an encrypted Azure blob
*
** Five alerts for  AppInsights are also provided as part of the service.  They are:
*  Web Test (WT) Availability (Service up / down)
*  Response Time (RT) (over 300 milliseconds)
*  Maximum requests (MR) (over 600)
*  Web requests below 1 (WV) (less than 1)
*
* Additional Parameters to Customize Alerts are available to you to add.
*
* (See complete list [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/app-insights-metrics))

* requests/count (Total Server Requests)
* requests/failed (Total Failed Server Requests)
* requests/duration (Server Response Time)
* performanceCounters/processCpuPercentage (% total CPU used by process)

* Window Sizes (aggregation granularities)

* 1m
* 5m
* 15m
* 30m
* 1h
* 6h
* 12h
* 24h

### Evaluation Frequencies

Note: The evaluation frequency must be less than or equal to the window size.

* 1m
* 5m
* 15m
* 30m
* 1h
*
* Example usage and testing
*
* ```hcl
* module "web" {
*  source = "../modules/webapp"
*  NAME              = var.NAME
*  LOCATION          = var.LOCATION
*  REPO              = var.REPO
*  ACR_SP_ID         = var.ACR_SP_ID
* ACR_SP_SECRET     = var.ACR_SP_SECRET
*  APP_RG_NAME       = azurerm_resource_group.init-app.name
*  TFSTATE_RG_NAME   = azurerm_resource_group.init-tfstate.name
*  TENANT_ID         = var.TF_TENANT_ID
*  COSMOS_RG_NAME    = azurerm_resource_group.cosmos.name
*  COSMOS_URL        = "https://${var.NAME}.documents.azure.com:443/"
*  COSMOS_KEY        = module.db.ro_key
*  COSMOS_DB         = var.COSMOS_DB
*  COSMOS_COL        = var.COSMOS_COL
*  DB_IMPORT_DONE    = "${module.db.DB_IMPORT_DONE}"
*  APP_SERVICE_DONE  = "${module.web.APP_SERVICE_DONE}"
*  ACI_DONE          = "${module.aci.ACI_DONE}"
*  TF_SUB_ID         = var.TF_SUB_ID
*  EMAIL_FOR_ALERTS  = var.EMAIL_FOR_ALERTS
*  RT_THRESHOLD      = var.RT_THRESHOLD
*  RT_OPERATOR       = var.RT_OPERATOR
*  RT_SEVERITY       = var.RT_SEVERITY
*  RT_FREQUENCY      = var.RT_FREQUENCY
*  RT_WINDOW_SIZE    = var.RT_WINDOW_SIZE
*  MR_THRESHOLD      = var.MR_THRESHOLD
*  MR_OPERATOR       = var.MR_OPERATOR
*  MR_SEVERITY       = var.MR_SEVERITY
*  MR_FREQUENCY      = var.MR_FREQUENCY
*  MR_WINDOW_SIZE    = var.MR_WINDOW_SIZE
*  WT_FREQUENCY      = var.WT_FREQUENCY
*  WT_WINDOW_SIZE    = var.WT_WINDOW_SIZE
*  WT_SEVERITY       = var.WT_SEVERITY
*  WT_THRESHOLD      = var.WT_THRESHOLD
*  WT_OPERATOR       = var.WT_OPERATOR
*  WV_FREQUENCY      = var.WV_FREQUENCY
*  WV_WINDOW_SIZE    = var.WV_WINDOW_SIZE
*  WV_SEVERITY       = var.WV_SEVERITY
*  WV_THRESHOLD      = var.WV_THRESHOLD
*  WV_OPERATOR       = var.WV_OPERATOR
*}
* ```
*/

resource azurerm_app_service_plan init-app-plan {
  name                = "${var.NAME}-plan"
  location            = var.LOCATION
  resource_group_name = var.APP_RG_NAME
  kind                = "linux"
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource azurerm_app_service init-webapp {
  depends_on = [
    var.DB_IMPORT_DONE
  ]
  name                = var.NAME
  location            = var.LOCATION
  resource_group_name = var.APP_RG_NAME
  https_only          = false
  app_service_plan_id = azurerm_app_service_plan.init-app-plan.id

  site_config {
    always_on                 = "true"
    app_command_line          = ""
    linux_fx_version          = "DOCKER|${var.NAME}.azurecr.io/${var.REPO}:latest"
    use_32_bit_worker_process = "true"
  }

  identity {
    type = "SystemAssigned"
    }

  logs {
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 100
      }
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.acr_sp_id.id})"
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.acr_sp_secret.id})"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${var.NAME}.azurecr.io"
    "DOCKER_ENABLE_CI"                    = "true"
    "KEYVAULT_NAME"                       = "${var.NAME}-kv"
  }
}
output "APP_SERVICE_DONE" {
  depends_on  = [azurerm_app_service.init-webapp]
  value       = true
  description = "App Service setup is complete"
}