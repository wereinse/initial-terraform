resource azurerm_application_insights init-appIns {
  name                = var.NAME
  location            = var.LOCATION
  resource_group_name = var.APP_RG_NAME
  application_type    = "web"
}

output "APP_INS_ID" {
  value = azurerm_application_insights.init-appIns.app_id
}
