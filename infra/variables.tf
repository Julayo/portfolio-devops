variable "aws_region" {
  description = "Main AWS region for the infrastructure."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Logical project name; used to name and tag resources."
  type        = string
  default     = "portfolio-devops"
}

variable "domain_name" {
  description = "Public custom domain for the site."
  type        = string
  default     = "julayo-dev.com"
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID that owns domain_name."
  type        = string
  default     = "Z0305295VR3EQCJOGGXX"
}

variable "site_bucket_name" {
  description = "Globally-unique S3 bucket name for the site files. No default on purpose — set it in terraform.tfvars."
  type        = string
}

variable "github_repo" {
  description = "GitHub repo (owner/name) that CodePipeline deploys from."
  type        = string
  default     = "Julayo/portfolio-devops"
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    Environment = "dev"
  }
}
