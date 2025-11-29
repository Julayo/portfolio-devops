output "site_bucket_name" {
  description = "Nombre del bucket S3 donde se aloja el sitio."
  value       = aws_s3_bucket.site.bucket
}

output "site_website_endpoint" {
  description = "Endpoint de website S3 (útil para pruebas sin CloudFront)."
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "codebuild_project_name" {
  description = "Nombre del proyecto de CodeBuild que construye/despliega el sitio."
  value       = aws_codebuild_project.portfolio.name
}
