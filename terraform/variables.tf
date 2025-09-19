variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "clusterName" {
  description = "Name of the EKS cluster"
  type        =  string
  default     = "eks-cluster"
}
