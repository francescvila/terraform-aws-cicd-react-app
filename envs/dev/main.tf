# Storage for static website serving

module "web_storage" {
  source       = "../../modules/storage"
  region       = var.region
  env          = var.env
  project_name = var.project_name
  service_name = "web"
  tags         = var.tags
}

# CDN: CloudFront distribution

module "web_cdn" {
  source             = "../../modules/cdn"
  region             = var.region
  env                = var.env
  project_name       = var.project_name
  service_name       = "web"
  target_domain_name = module.web_storage.bucket_domain_name
  tags               = var.tags
}

# Git repository for the web application

module "web_repository" {
  source       = "../../modules/repositories"
  env          = var.env
  project_name = var.project_name
  service_name = "web"
  tags         = var.tags
}
# CI/CD pipelines

module "web_pipeline" {
  source            = "../../modules/pipelines"
  env               = var.env
  project_name      = var.project_name
  service_name      = "web"
  bucket_name       = module.web_storage.bucket_name
  repository_name   = module.web_repository.repository_name
  repository_branch = module.web_repository.repository_branch
  tags              = var.tags
}
