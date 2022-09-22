output "repository_name" {
  value = aws_codecommit_repository.repository.repository_name
}

output "repository_branch" {
  value = aws_codecommit_repository.repository.default_branch
}

output "repository_url_http" {
  value = aws_codecommit_repository.repository.clone_url_http
}

output "repository_url_ssh" {
  value = aws_codecommit_repository.repository.clone_url_ssh
}
