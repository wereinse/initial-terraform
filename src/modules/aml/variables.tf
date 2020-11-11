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
