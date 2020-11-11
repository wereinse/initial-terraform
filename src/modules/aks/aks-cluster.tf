/**
* # Module Properties
*
* This module is used to create the Azure Kubernetes cluster to store private copies of the application containers to use in this test environment
* 
* For this to work you will need to assign `AcrPull` rights to the Application Insights service to the ACR post deployment. 
*
* Example usage
*
* ```hcl
* module "aks" {
*  source        = "../modules/aks"
*  NAME          = var.NAME
*  LOCATION      = var.LOCATION
*  REPO          = var.REPO
*  AKS_RG_NAME   = azurerm_resource_group.aks.name
* }
* ```
*/

resource "random_pet" "prefix" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${random_pet.prefix.id}-aks"
  location            = var.LOCATION
  resource_group_name = var.AKS_RG_NAME
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id       = var.TF_CLIENT_ID
    client_secret   = var.TF_CLIENT_SECRET
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

  tags = {
    environment = "Demo"
  }
}