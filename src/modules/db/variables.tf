variable "NAME" {
  type        = string
  description = "The prefix which should be used for all resources in this example"
}

variable "COSMOS_RG_NAME" {
  type        = string
  description = "The Azure Resource Group the resource should be added to"
}

variable "LOCATION" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created."
}

variable "COSMOS_RU" {
  type    = number
  default = 400
}

variable "COSMOS_DB" {
  type        = string
  description = "The Cosmos DB database name"
  default     = "initdb"
}

variable "COSMOS_COL" {
  type        = string
  description = "The Cosmos DB collection name"
  default     = "init-col-name"
}
variable "REPO" {
  type        = string
  description = "The repo from which to pull an image"
  default     = "docker-library/hello-world"
}
variable "ACR_SP_ID" {
  type        = string
  description = "The ACR Service Principal ID"
}

variable "ACR_SP_SECRET" {
  type        = string
  description = "The ACR Service Principal secret"
}
