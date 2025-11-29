terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
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

# Ownership controls (requerido por S3 moderno)
resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Public access block: dejamos el bucket privado por ahora
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Habilitar website hosting (index.html + error.html)
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

# Permisos para CodeBuild (logs + S3)
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

  # Permisos sobre el bucket del sitio (nivel bucket)
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

  # Permisos sobre objetos dentro del bucket
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

    environment_variable {
      name  = "SITE_BUCKET_NAME"
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
