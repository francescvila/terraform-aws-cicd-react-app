output "website_endpoint" {
  value = module.web_storage.website_endpoint
}

output "cdn_domain_name" {
  value = module.web_cdn.distribution_domain_name
}

output "repository_url_http" {
  value = module.web_repository.repository_url_http
}

output "repository_url_ssh" {
  value = module.web_repository.repository_url_ssh
}

output "codebuild_name" {
  value = module.web_pipeline.codebuild_name
}

output "codepipeline_name" {
  value = module.web_pipeline.codepipeline_name
}
