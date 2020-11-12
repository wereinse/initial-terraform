variable "NAME" {
  description = "The prefix which should be used for all resources in this example"
  type        = string
}

variable "LOCATION" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
}

variable "AML_RG_NAME" {
  description = "Resource group to put AKS cluster in"
  type        = string
}

// variable "KEY_VAULT_ID" {
//   description = "Key vault id to use to access Azure ML workspace"
//   type        = string
// }

// variable "APP_INS_ID" {
//   description = "Application Insights id to use to access Azure ML workspace"
//   type        = string
// }
