variable "location" {
  default     = "westus2"
  description = "The Azure Region to create all resources in."
}

variable "cluster_count" {
  default     = 1
  description = "The number of OpenShift clusters to create."
}

variable "client_id" {
  default     = ""
  description = "The client ID of the service principal to be used by Kubernetes when creating Azure resources like load balancers."
}

variable "client_secret" {
  default     = ""
  description = "The client secret of the service principal to be used by Kubernetes when creating Azure resources like load balancers."
}

variable "tags" {
  type        = map
  default     = {}
  description = "tags to attach to the created resources."
}
