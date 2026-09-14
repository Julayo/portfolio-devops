output "site_bucket_name" {
  description = "Name of the S3 bucket holding the site."
  value       = aws_s3_bucket.site.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (use it for cache invalidations in CI/CD)."
  value       = aws_cloudfront_distribution.cdn.id
}

output "cloudfront_domain_name" {
  description = "CloudFront-generated domain name."
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "custom_domain_url" {
  description = "Public URL of the site."
  value       = "https://${var.domain_name}"
}

output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate."
  value       = aws_acm_certificate_validation.cert.certificate_arn
}
