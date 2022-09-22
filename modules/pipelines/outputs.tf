output "codebuild_name" {
  value = aws_codebuild_project.build_project.name
}

output "codepipeline_name" {
  value = aws_codepipeline.codepipeline.name
}
