# Hosting outputs come from the reusable module.
output "site_bucket_name" {
  description = "S3 bucket holding the site."
  value       = module.site.site_bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (use for cache invalidations)."
  value       = module.site.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name."
  value       = module.site.cloudfront_domain_name
}

output "custom_domain_url" {
  description = "Public URL."
  value       = module.site.custom_domain_url
}

# Pipeline outputs.
output "codestar_connection_arn" {
  description = "CodeStar connection ARN — must be authorized once in the AWS console (status PENDING -> AVAILABLE)."
  value       = aws_codestarconnections_connection.github.arn
}

output "artifacts_bucket" {
  description = "CodePipeline artifacts bucket."
  value       = aws_s3_bucket.artifacts.bucket
}
