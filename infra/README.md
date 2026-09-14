# infra/ — Static site on AWS (Terraform)

Reusable Terraform to stand up a **static website on AWS**: private S3 + CloudFront
(OAC) + ACM (DNS-validated TLS) + Route53, plus an optional GitHub → CodePipeline →
CodeBuild deploy pipeline.

The hosting layer is a **reusable module** (`modules/static-site-aws`) — point it at any
domain to bring up a new site. This same module can host `delete-from.com` or any future
project; `julayo-dev.com` is just the first caller.

## Layout

```
infra/
├── versions.tf              # Terraform + AWS provider constraints
├── providers.tf             # aws (main region) + aws.us_east_1 (for ACM)
├── backend.tf               # remote state in S3 + DynamoDB lock
├── main.tf                  # calls module "site"
├── pipeline.tf              # CodePipeline/CodeBuild (portfolio-specific, optional)
├── variables.tf             # inputs (see table below)
├── outputs.tf
├── terraform.tfvars.example # copy → terraform.tfvars, fill in
├── modules/
│   └── static-site-aws/     # ← the reusable hosting module
└── bootstrap/               # one-time state bucket + lock table (own local state)
```

## What data to enter to bring it up

Copy `terraform.tfvars.example` → `terraform.tfvars` and set:

| Variable | Required? | What it is | How to get it |
|---|---|---|---|
| `project_name` | yes | Logical name; prefixes/tags all resources | You choose (lowercase, no spaces) |
| `domain_name` | yes | Public domain to serve | A domain you own |
| `hosted_zone_id` | yes | Route53 zone that owns the domain | `aws route53 list-hosted-zones --query "HostedZones[].[Name,Id]" --output text` |
| `site_bucket_name` | yes | Globally-unique S3 bucket for the files | You choose; must be unique across all AWS |
| `aws_region` | no (def `us-west-2`) | Main region | — |
| `github_repo` | no (def `Julayo/portfolio-devops`) | Repo CodePipeline builds from | `owner/name` |
| `tags` | no | Extra tags | — |

## Prerequisites

1. **AWS credentials** with enough permissions (see *Permissions* below). Log in:
   `aws sso login --profile julayo` (see the AWS SSO memory).
2. **A registered domain + Route53 hosted zone** for it.
3. **Terraform ≥ 1.0** (`terraform version`).

## Usage

```sh
cd infra
cp terraform.tfvars.example terraform.tfvars    # then edit it
terraform init          # downloads providers + connects to remote state
terraform fmt -check     # style
terraform validate       # structural check (no creds needed with -backend=false)
terraform plan           # preview — READ THIS before applying
terraform apply          # create/update (asks for confirmation)
```

After the first apply, **authorize the CodeStar (GitHub) connection once** in the AWS
console: CodePipeline → Settings → Connections → the `github-<project>` connection is
`PENDING` until you click *Update pending connection* and approve the GitHub app.

Tear down: `terraform destroy` (careful — removes the live site).

## Remote state

State lives in `s3://julayo-terraform-state/portfolio-devops/terraform.tfstate` with a
DynamoDB lock (`terraform-locks`). Those two resources are created **once** by
`bootstrap/` (which keeps its own local state) — never by this config. See
`bootstrap/state-backend.tf`.

## Permissions

`terraform plan`/`apply` here needs broad access: S3 (incl. the state bucket:
`s3:ListBucket`/`GetObject`/`PutObject`), CloudFront, ACM, Route53, IAM, CodePipeline,
CodeBuild, CodeStar/CodeConnections, DynamoDB.

> ⚠️ The current SSO role **`DeleteFromDeploy` is NOT enough** — it lacks S3 bucket
> listing, CodePipeline, CodeBuild and CodeStar permissions. Use a broader role (or an
> admin/PowerUser permission set in IAM Identity Center) to operate this stack.

## Adopting the EXISTING live infrastructure (important)

`julayo-dev.com` is **already deployed** (CloudFront `E1HPFRXWL7VWVQ`), but the original
Terraform state was not found locally. So before the first `apply`, the existing
resources must be **imported** into the new remote state — otherwise Terraform will try to
recreate resources that already exist and fail.

Plan:
1. Get a role with the permissions above; `terraform init` (connects remote state).
2. `terraform import` each live resource, e.g.:
   ```sh
   terraform import 'module.site.aws_cloudfront_distribution.cdn' E1HPFRXWL7VWVQ
   terraform import 'module.site.aws_s3_bucket.site' <site-bucket-name>
   terraform import 'module.site.aws_route53_record.alias' <zoneid>_<domain>_A
   # ...ACM, bucket policy, OAC, pipeline resources
   ```
3. `terraform plan` until it shows **no changes** (state now matches reality).
4. Only then is `apply` safe.

See `../../../docker/homelab/silverbullet/space/Carrera/Sitios plan refactor.md` for the
overall plan.
