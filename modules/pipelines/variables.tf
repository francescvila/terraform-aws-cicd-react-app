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

variable "bucket_name" {
  description = "Bucket name"
  type        = string
}

variable "repository_name" {
  description = "Repository name"
  type        = string
}

variable "repository_branch" {
  description = "Repository branch"
  type        = string
}

variable "build_timeout" {
  description = "The time to wait for a CodeBuild to complete before timing out in minutes (default: 5)"
  type        = string
  default     = "5"
}

variable "queued_timeout" {
  description = "Number of minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out. The default is 8 hours."
  type        = string
  default     = "60"
}

variable "build_compute_type" {
  description = "The build instance type for CodeBuild (default: BUILD_GENERAL1_SMALL)"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "The build image for CodeBuild to use (default: aws/codebuild/nodejs:6.3.1)"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "package_buildspec" {
  description = "The buildspec to be used for the Package stage (default: buildspec.yml)"
  type        = string
  default     = "buildspec.yml"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
