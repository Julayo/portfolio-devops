# Bootstrap for the Terraform remote-state backend.
#
# This is a SEPARATE root module with its own LOCAL state. It creates the S3
# bucket and DynamoDB lock table that the main config (../backend.tf) then uses
# for remote state. You cannot store this config's state in a bucket it is
# itself creating — hence the split.
#
# STATUS: already applied once. The bucket "julayo-terraform-state" and table
# "terraform-locks" exist in account 567626725406 (us-west-2). Do NOT re-apply
# blindly; if you ever recreate the account, run `terraform init && apply` here
# FIRST, then init the main config.

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
  region = "us-west-2"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "julayo-terraform-state"
  tags   = { Name = "Terraform State Bucket" }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access to the state bucket (state can contain secrets).
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = { Name = "Terraform Locks Table" }
}
