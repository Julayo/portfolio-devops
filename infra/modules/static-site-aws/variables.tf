variable "project_name" {
  description = "Logical name of the project; used to name/tag resources."
  type        = string
}

variable "domain_name" {
  description = "Public custom domain served by CloudFront (e.g. example.com)."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID that owns domain_name."
  type        = string
}

variable "site_bucket_name" {
  description = "Globally-unique S3 bucket name that stores the site files."
  type        = string
}

variable "tags" {
  description = "Extra tags merged onto every resource."
  type        = map(string)
  default     = {}
}

variable "spa_fallback" {
  description = "true = serve index.html on 404 (single-page-app routing). false = serve /404.html (multi-page static site)."
  type        = bool
  default     = false
}
