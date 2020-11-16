
output "KEY_VAULT_ID" {
  value       =   azurerm_key_vault.kv.id
  description = "Key vault setup is complete"
}

output "APP_SERVICE_DONE" {
  depends_on  = [azurerm_app_service.init-webapp]
  value       = true
  description = "App Service setup is complete"
}

output "APP_INS_ID" {
  value = azurerm_application_insights.init-appIns.app_id
}

