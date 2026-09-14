# Root config for julayo-dev.com.
# All the reusable hosting infrastructure lives in ./modules/static-site-aws.
# The CI/CD pipeline (portfolio-specific) lives in ./pipeline.tf.

module "site" {
  source = "./modules/static-site-aws"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  project_name     = var.project_name
  domain_name      = var.domain_name
  hosted_zone_id   = var.hosted_zone_id
  site_bucket_name = var.site_bucket_name
  tags             = var.tags
}
