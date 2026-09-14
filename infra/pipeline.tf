# CI/CD pipeline for julayo-dev.com: GitHub -> CodePipeline -> CodeBuild -> S3.
# This is portfolio-specific. delete-from.com uses the GitHub Actions + OIDC
# alternative instead (see that repo's .github/workflows/deploy.yml). To reuse
# ONLY the hosting layer for another site, instantiate ./modules/static-site-aws
# without this file.

data "aws_caller_identity" "current" {}

# --- Artifacts bucket (CodePipeline source/build handoff) ---
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-artifacts-${data.aws_caller_identity.current.account_id}"
  tags   = merge({ "Project" = var.project_name, "Name" = "${var.project_name}-artifacts" }, var.tags)
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# --- CodeBuild role + policy ---
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  tags               = merge({ "Project" = var.project_name }, var.tags)
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid       = "AllowLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"]
    resources = ["*"]
  }
  statement {
    sid       = "AllowS3SiteBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:ListBucketVersions", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::${var.site_bucket_name}"]
  }
  statement {
    sid       = "AllowS3SiteObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.site_bucket_name}/*"]
  }
  statement {
    sid       = "AllowS3ArtifactsBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.artifacts.arn]
  }
  statement {
    sid       = "AllowS3ArtifactsObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }
}

resource "aws_iam_role_policy" "codebuild_inline" {
  name   = "${var.project_name}-codebuild-policy"
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

# --- CodeBuild project ---
resource "aws_codebuild_project" "site" {
  name          = "${var.project_name}-codebuild"
  description   = "Builds and deploys ${var.project_name} static site to S3"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 10

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "TARGET_BUCKET"
      value = var.site_bucket_name
      type  = "PLAINTEXT"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  source_version = "main"
  tags           = merge({ "Project" = var.project_name }, var.tags)
}

# --- CodeStar (GitHub) connection ---
resource "aws_codestarconnections_connection" "github" {
  name          = var.codestar_connection_name
  provider_type = "GitHub"
}

# --- CodePipeline role + policy ---
data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    sid       = "AllowS3Artifacts"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }
  statement {
    sid       = "AllowCodeBuild"
    effect    = "Allow"
    actions   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
    resources = [aws_codebuild_project.site.arn]
  }
  statement {
    sid       = "AllowUseConnection"
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github.arn]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  tags               = merge({ "Project" = var.project_name }, var.tags)
}

resource "aws_iam_role_policy" "codepipeline_inline" {
  name   = "${var.project_name}-codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.name
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

# --- CodePipeline (GitHub -> CodeBuild) ---
resource "aws_codepipeline" "site" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repo
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.site.name
      }
    }
  }

  tags = merge({ "Project" = var.project_name }, var.tags)
}
