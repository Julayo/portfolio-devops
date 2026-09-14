# Remote state in S3 with DynamoDB locking.
#
# The bucket (julayo-terraform-state) and lock table (terraform-locks) are
# bootstrapped ONCE by ./bootstrap (separate root, local state) — never by this
# config, or you get a chicken-and-egg loop. See bootstrap/README.md.
#
# Requires the caller's role to allow, on the state bucket:
#   s3:ListBucket, s3:GetObject, s3:PutObject   (bucket + bucket/*)
# and on the lock table: dynamodb:GetItem/PutItem/DeleteItem.
# NOTE: the SSO role "DeleteFromDeploy" currently lacks these — use a broader
# role (or admin) for `terraform init`/`plan`/`apply` here.
terraform {
  backend "s3" {
    bucket         = "julayo-terraform-state"
    key            = "portfolio-devops/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
