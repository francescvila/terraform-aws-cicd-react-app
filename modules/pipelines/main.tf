# CodePipeline resources
resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket        = "${var.project_name}-${var.service_name}-build-artifact-bucket-${var.env}"
  force_destroy = "false"
}

resource "aws_s3_bucket_acl" "build_artifact_bucket_acl" {
  bucket = aws_s3_bucket.build_artifact_bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project_name}-${var.service_name}-codepipeline-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_policy.json
}

# CodePipeline policy needed to use CodeCommit and CodeBuild
data "template_file" "codepipeline_policy_template" {
  template = file("${path.module}/iam-policies/codepipeline.tpl")
  vars = {
    aws_kms_key     = aws_kms_key.artifact_encryption_key.arn
    artifact_bucket = aws_s3_bucket.build_artifact_bucket.arn
  }
}

resource "aws_iam_role_policy" "attach_codepipeline_policy" {
  name   = "${var.project_name}-${var.service_name}-codepipeline-policy-${var.env}"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.template_file.codepipeline_policy_template.rendered
}

# Encryption key for build artifacts
resource "aws_kms_key" "artifact_encryption_key" {
  description             = "artifact-encryption-key"
  deletion_window_in_days = 10
}

# CodeBuild IAM Permissions
data "template_file" "codepipeline_assume_role_policy_template" {
  template = file("${path.module}/iam-policies/codebuild_assume_role.tpl")
}

resource "aws_iam_role" "codebuild_assume_role" {
  name               = "${var.project_name}-${var.service_name}-codebuild-role-${var.env}"
  assume_role_policy = data.template_file.codepipeline_assume_role_policy_template.rendered
}

data "template_file" "codebuild_policy_template" {
  template = file("${path.module}/iam-policies/codebuild.tpl")
  vars = {
    artifact_bucket         = aws_s3_bucket.build_artifact_bucket.arn
    aws_kms_key             = aws_kms_key.artifact_encryption_key.arn
    codebuild_project_build = aws_codebuild_project.build_project.id
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.project_name}-${var.service_name}-codebuild-policy-${var.env}"
  role   = aws_iam_role.codebuild_assume_role.id
  policy = data.template_file.codebuild_policy_template.rendered
}

data "template_file" "buildspec" {
  template = file("${path.module}/templates/${var.package_buildspec}")
  vars = {
    env = var.env
  }
}

resource "aws_codebuild_project" "build_project" {
  badge_enabled  = false
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout
  name           = "${var.project_name}-${var.service_name}-build-project-${var.env}"
  description    = "Build CodeBuild project for ${var.repository_name}"
  service_role   = aws_iam_role.codebuild_assume_role.arn

  tags = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = data.template_file.buildspec.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}

# Full CodePipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_name}-${var.service_name}-pipeline-${var.env}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.build_artifact_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact_encryption_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = var.repository_name
        BranchName     = var.repository_branch
        # PollForSourceChanges = "false"
      }

      run_order = 1
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.build_project.name
      }
      input_artifacts  = ["source"]
      name             = "Build"
      output_artifacts = ["build"]
      owner            = "AWS"
      provider         = "CodeBuild"
      run_order        = 1
      version          = "1"
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "BucketName" = var.bucket_name
        "Extract"    = "true"
      }
      input_artifacts  = ["build"]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "S3"
      run_order        = 1
      version          = "1"
    }
  }
}
