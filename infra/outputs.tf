output "site_bucket_name" {
  value       = aws_s3_bucket.site.id
  description = "Nombre del bucket S3 del sitio estático."
}

output "site_website_endpoint" {
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
  description = "Endpoint de website S3 (solo interno, el público será CloudFront)."
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.portfolio.domain_name
  description = "Dominio de CloudFront para el portfolio."
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.portfolio.id
  description = "ID de la distribución CloudFront."
}

output "custom_domain_url" {
  value       = "https://${var.domain_name}"
  description = "URL pública del portfolio."
}
