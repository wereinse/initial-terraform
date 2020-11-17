variable "NAME" {
  type        = string
  description = "The prefix which should be used for all resources in this example"
}

variable "ACR_RG_NAME" {
  type        = string
  description = "The Azure Resource Group the resource should be added to"
}

// variable "ACR_SP_ID" {
//   type        = string
//   description = "The ACR Service Principal"
// }

// variable "ACR_SP_SECRET" {
//   type        = string
//   description = "The ACR Service Principal Secret"
// }

variable "LOCATION" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created."
}

variable "REPO" {
  type        = string
  description = "The repo from which to pull the image"
}

variable "TF_CLIENT_ID" {
  type        = string
  description = "The Client ID(AppID) of the Service Principal that TF will use to Authenticate and build resources as. This account should have at least Contributor Role on the subscription. This is only used by the parent main.tf"

}
variable "TF_CLIENT_SECRET" {
  type        = string
  description = "The Client Secret of the Service Principal that TF will use to Authenticate and build resources as. This account should have at least Contributor Role on the subscription. This is only used by the parent main.tf"
}