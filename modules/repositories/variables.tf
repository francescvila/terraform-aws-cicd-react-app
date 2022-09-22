variable "env" {
  description = "Environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "service_name" {
  description = "Service name"
  type        = string
}

variable "repository_branch" {
  description = "Repository default branch"
  type        = string
  default     = "main"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
