variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets for EKS worker nodes"
  type        = list(string)
}