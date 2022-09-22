resource "aws_codecommit_repository" "repository" {
  repository_name = "${var.project_name}-${var.service_name}-repo-${var.env}"
  description     = "Git repository for project ${var.project_name}"
  default_branch  = var.repository_branch
  tags            = var.tags
}
