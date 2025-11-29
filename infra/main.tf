terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Región principal (Oregón)
provider "aws" {
  region = var.aws_region
}

# Para ACM de CloudFront (siempre us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# ---------------------------
# S3 Static Website Bucket
# ---------------------------

resource "aws_s3_bucket" "site" {
  bucket = var.site_bucket_name

  tags = merge(
    {
      "Name"        = "${var.project_name}-site"
      "Environment" = "dev"
    },
    var.tags
  )
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# ---------------------------
# IAM Role for CodeBuild
# ---------------------------

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = merge(
    {
      "Name"        = "${var.project_name}-codebuild-role"
      "Environment" = "dev"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "codebuild_policy" {
  # Logs
  statement {
    sid    = "AllowLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }

  # Nivel bucket
  statement {
    sid    = "AllowS3PortfolioBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.site_bucket_name}"
    ]
  }

  # Objetos
  statement {
    sid    = "AllowS3PortfolioObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.site_bucket_name}/*"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_inline" {
  name   = "${var.project_name}-codebuild-policy"
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

# ---------------------------
# CodeBuild Project
# ---------------------------

resource "aws_codebuild_project" "portfolio" {
  name          = "portfolio-devops-codebuild"
  description   = "Builds and deploys the DevOps portfolio static site to S3"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 10

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    # Variable usada en buildspec.yml
    environment_variable {
      name  = "TARGET_BUCKET"
      value = var.site_bucket_name
      type  = "PLAINTEXT"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/Julayo/portfolio-devops.git"
    git_clone_depth = 1
  }

  source_version = "main"
}

# ---------------------------
# ACM Certificate (us-east-1)
# ---------------------------

resource "aws_acm_certificate" "portfolio" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-cert"
  }
}

# Registro DNS para validar el certificado
resource "aws_route53_record" "portfolio_cert_validation" {
  zone_id = var.hosted_zone_id
  name    = tolist(aws_acm_certificate.portfolio.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.portfolio.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.portfolio.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "portfolio" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.portfolio.arn

  validation_record_fqdns = [
    aws_route53_record.portfolio_cert_validation.fqdn
  ]
}

# ---------------------------
# CloudFront + OAC
# ---------------------------

resource "aws_cloudfront_origin_access_control" "portfolio_oac" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "portfolio" {
  enabled             = true
  comment             = "CloudFront distribution for ${var.project_name}"
  default_root_object = "index.html"

  aliases = [var.domain_name]

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-portfolio-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-portfolio-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.portfolio.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(
    {
      "Name"        = "${var.project_name}-cloudfront"
      "Environment" = "dev"
    },
    var.tags
  )

  depends_on = [aws_acm_certificate_validation.portfolio]
}

# Bucket policy para permitir solo a CloudFront leer objetos
data "aws_iam_policy_document" "site_cloudfront" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.site.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.portfolio.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site_cloudfront" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_cloudfront.json
}

# ---------------------------
# Route 53 - A Alias → CloudFront
# ---------------------------

resource "aws_route53_record" "portfolio_alias" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio.hosted_zone_id
    evaluate_target_health = false
  }
}
