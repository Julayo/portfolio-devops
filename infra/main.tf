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

# Desbloquear public ACLs para static website (solo para este bucket)
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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

# Política para permitir lectura pública de objetos
data "aws_iam_policy_document" "site_public_read" {
  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.site.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "site_public_read" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_public_read.json
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

# Permisos para CodeBuild (logs + S3 + básico)
data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  # Permisos sobre el bucket del sitio
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.site.arn,
      "${aws_s3_bucket.site.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_inline" {
  name   = "${var.project_name}-codebuild-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

# ---------------------------
# CodeBuild Project
# ---------------------------

resource "aws_codebuild_project" "portfolio" {
  name         = "${var.project_name}-codebuild"
  description  = "Build & deploy static DevOps portfolio site to S3"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TARGET_BUCKET"
      value = aws_s3_bucket.site.bucket
    }

    environment_variable {
      name  = "SITE_SOURCE_DIR"
      value = "."
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repository_url
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project_name}"
      stream_name = "build-log"
      status      = "ENABLED"
    }
  }

  tags = merge(
    {
      "Name"        = "${var.project_name}-codebuild"
      "Environment" = "dev"
    },
    var.tags
  )
}
