variable "aws_region" {
  type        = string
  description = "The AWS Region you are using"
  default     = "us-west-2"
}

variable "eks_backend_allowed_arns" {
  type        = list(string)
  description = "List of EKS ARNs backend developers are allowed access to"
}
