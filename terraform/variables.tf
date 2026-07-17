variable "project_name" {
  description = "Name prefix applied to all resources and tags"
  type        = string
  default     = "aws-ha-webapp"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment tag applied to every resource (e.g. lab, staging, prod)"
  type        = string
  default     = "lab"
}

variable "alert_email" {
  description = "Email that receives AWS Budget alerts. No default on purpose: set it in terraform.tfvars (gitignored) so personal data stays out of the repository."
  type        = string
}

variable "monthly_budget_limit" {
  description = "Monthly cost ceiling in USD for the budget alert"
  type        = string
  default     = "10"
}
