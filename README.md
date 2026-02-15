# DevOps CI/CD Portfolio – Julio Reyes

Static, bilingual (EN/ES) portfolio deployed to production at **[julayo-dev.com](https://julayo-dev.com)**.

Built to showcase my experience as a **DevOps Engineer** (AWS · Terraform · CI/CD · Kubernetes) and to serve as a live example of a serverless static-site pipeline on AWS.

---

## 🌐 Live Site

**[https://julayo-dev.com](https://julayo-dev.com)**

---

## 🏗 Architecture

```
GitHub (main branch)
    │
    └─► AWS CodePipeline
            │
            └─► AWS CodeBuild  (buildspec.yml)
                    │
                    ├─► aws s3 sync → S3 (static hosting)
                    │
                    └─► aws cloudfront create-invalidation → CloudFront
                                                                  │
                                                                Route 53
                                                           julayo-dev.com
```

| Layer | Service |
|---|---|
| DNS | Route 53 |
| CDN / HTTPS | CloudFront |
| Storage | S3 (static website) |
| CI/CD orchestration | CodePipeline |
| Build & deploy | CodeBuild |
| IaC | Terraform (`infra/`) |

---

## ⚙️ CodeBuild Environment Variables

These must be configured in the CodeBuild project:

| Variable | Description |
|---|---|
| `TARGET_BUCKET` | S3 bucket name where the site is deployed |
| `CLOUDFRONT_DIST_ID` | CloudFront distribution ID (for cache invalidation) |

The `post_build` phase runs `aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DIST_ID} --paths "/*"` so changes are live immediately after every deploy.

---

## 📁 Project Structure

```
portfolio-devops/
├── index.html              # Main page (all sections, data-i18n attributes)
├── styles.css              # Terminal-theme styles + responsive breakpoints
├── buildspec.yml           # CodeBuild pipeline spec
├── resume.pdf              # Downloadable CV (served from S3)
│
├── js/
│   ├── lang.js             # Language switcher (loads JSON, sets innerHTML)
│   ├── main.js             # Section interactions
│   └── translation.js      # i18n init
│
├── translation/
│   ├── en.json             # English strings (supports inline HTML)
│   └── es.json             # Spanish strings (supports inline HTML)
│
└── infra/                  # Terraform — NOT deployed by buildspec
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── state-resources.tf
```

> `infra/` is excluded from `aws s3 sync`. It is applied manually via `terraform apply`.

---

## 🌍 Bilingual UX (EN / ES)

Language switcher in the header. Strings live in `translation/en.json` and `translation/es.json`.

Elements use `data-i18n` attributes:

```html
<h2 data-i18n="skills.title"></h2>
```

`js/lang.js` fetches the active JSON and applies `el.innerHTML = value` — which means translation values can contain HTML (links, `<strong>`, etc.).

---

## 🚀 Deploying

Every push to `main` triggers CodePipeline automatically.

The `buildspec.yml` sync excludes non-public files:

```yaml
aws s3 sync . s3://${TARGET_BUCKET} --delete
  --exclude '.git/*'
  --exclude '.gitignore'
  --exclude 'buildspec.yml'
  --exclude 'README.md'
  --exclude 'generate-og-image.html'
  --exclude 'resume.html'
  --exclude 'infra/*'
```

After sync, a CloudFront invalidation is created automatically.

---

## 🛠 Local Dev

No build step. Open `index.html` directly in a browser.

```bash
# Serve locally (optional)
npx serve .
```

---

## 📄 Resume

`resume.pdf` is served from S3 via the `> open resume.pdf` link in the hero section.

To regenerate an improved version, open `resume.html` (gitignored, local only) in Chrome → Print → Save as PDF → replace `resume.pdf`.

---

## ☁️ Infrastructure (Terraform)

Managed in `infra/`. Apply manually:

```bash
cd infra
terraform init
terraform apply -var-file="terraform.tfvars"
```

Required `.tfvars` (gitignored):

```hcl
site_bucket_name = "your-bucket-name"
```

---

*© 2025 Julio Reyes · Santiago, Chile 🇨🇱*
