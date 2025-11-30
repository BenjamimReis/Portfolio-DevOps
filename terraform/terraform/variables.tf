variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "portfolio-devops"
}
