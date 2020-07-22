resource azurerm_application_insights init-appIns {
  name                = var.NAME
  location            = var.LOCATION
  resource_group_name = var.APP_RG_NAME
  application_type    = "web"
}
