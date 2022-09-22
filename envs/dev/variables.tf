# AWS

variable "region" {
  description = "AWS US Virginia Region"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS credentials profile"
  type        = string
  default     = "sandbox"
}

# Project

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Project name"
  default     = "reactapp"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
}
