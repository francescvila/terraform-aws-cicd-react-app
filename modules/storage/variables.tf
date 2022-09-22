variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "service_name" {
  description = "Service name (web, api, cms, ...)"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
