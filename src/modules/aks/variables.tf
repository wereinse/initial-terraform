variable "NAME" {
  description = "The prefix which should be used for all resources in this example"
  type        = string
}

variable "LOCATION" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
}

variable "REPO" {
  description = "Docker image repo to use"
  type        = string
}

variable "AKS_RG_NAME" {
  description = "Resource group to put AKS cluster in"
  type        = string
}

variable "TF_CLIENT_ID" {
  description = "Azure AD client ID"
  type        = string
}

variable "TF_CLIENT_SECRET" {
  description = "Azure AD secret"
  type        = string
}