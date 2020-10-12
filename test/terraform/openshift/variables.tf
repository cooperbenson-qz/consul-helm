variable "region" {
  default     = "West US 2"
  description = "The Azure Region to create all resources in."
}

variable "cluster_count" {
  default     = 1
  description = "The number of OpenShift clusters to create."
}