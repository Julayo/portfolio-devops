# DevOps CI/CD Portfolio – Julio Reyes

Static, bilingual (EN/ES) portfolio deployed to **[julayo-dev.com](https://julayo-dev.com)**.

Serves two purposes: showcase my experience as a **DevOps / Platform Engineer** (AWS · Terraform · CI/CD · Kubernetes), and demonstrate a live serverless static-site pipeline on AWS.

---

## Live Site

**[https://julayo-dev.com](https://julayo-dev.com)**

---

## Architecture

```
GitHub (main branch)
    │
    └─► AWS CodePipeline
            │
            └─► AWS CodeBuild  (buildspec.yml)
                    │
                    ├─► aws s3 cp index.html      (Cache-Control: no-cache)
                    ├─► aws s3 sync translation/  (Cache-Control: no-cache)
                    ├─► aws s3 sync . --delete    (Cache-Control: max-age=86400)
                    │
                    └─► CloudFront invalidation → /index.html /styles.css /js/* /translation/*
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

## CodeBuild Environment Variables

| Variable | Description |
|---|---|
| `TARGET_BUCKET` | S3 bucket name where the site is deployed |
| `CLOUDFRONT_DIST_ID` | CloudFront distribution ID (for cache invalidation) |

---

## Project Structure

```
portfolio-devops/
├── index.html              # Main page (all sections, data-i18n attributes)
├── styles.css              # Terminal-theme styles + responsive breakpoints
├── buildspec.yml           # CodeBuild pipeline spec
├── resume.pdf              # Downloadable CV (served from S3)
│
├── js/
│   └── lang.js             # Language switcher — fetches JSON, sets innerHTML
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

> `infra/` is excluded from `aws s3 sync`. Applied manually via `terraform apply`.

---

## Bilingual UX (EN / ES)

Language switcher in the header. Strings live in `translation/en.json` and `translation/es.json`.

Elements use `data-i18n` attributes:

```html
<h2 data-i18n="skills.title"></h2>
```

`js/lang.js` fetches the active JSON on load and applies `el.innerHTML = value` — so translation values can contain HTML (links, `<strong>`, etc.). The HTML also carries fallback text in English for the rare case where the fetch fails.

---

## Architecture Diagrams

The Architecture section uses [Mermaid](https://mermaid.js.org/) v11 loaded via ESM from jsDelivr. Diagrams are inside `<details>` elements and render lazily on first open — this avoids the known issue where Mermaid calculates SVG dimensions as 0×0 inside a hidden container.

```js
mermaid.initialize({ startOnLoad: false, ... });
details.addEventListener("toggle", async () => {
  if (details.open && !rendered) await mermaid.run({ nodes: ... });
});
```

---

## Deploying

Every push to `main` triggers CodePipeline automatically.

`buildspec.yml` runs a three-step sync to set correct Cache-Control headers:

1. `index.html` → `no-cache, must-revalidate` (users always get the latest version)
2. `translation/*.json` → `no-cache, must-revalidate` (content changes with each deploy)
3. Everything else → `max-age=86400` (CSS, JS, images — 1-day browser cache)

CloudFront invalidation targets specific paths (`/index.html /styles.css /js/* /translation/* /favicon.svg`) rather than `/*` to stay within the free tier (1000 paths/month) and complete faster.

---

## Local Dev

No build step. Open `index.html` directly in a browser, or serve locally:

```bash
npx serve .
# or
python3 -m http.server 8080
```

> Translations are loaded via `fetch()`, so you need a local server — opening the file directly with `file://` will cause a CORS error on the JSON fetch.

---

## Resume

`resume.pdf` is served from S3 via the `> open resume.pdf` link in the hero section.

To regenerate: open `resume.html` (gitignored, local only) in Chrome → Print → Save as PDF → replace `resume.pdf`.

---

## Infrastructure (Terraform)

Managed in `infra/`. Apply manually:

```bash
cd infra
terraform init
terraform apply -var-file="terraform.tfvars"
```

Required `terraform.tfvars` (gitignored):

```hcl
site_bucket_name = "your-bucket-name"
```

---

*© 2026 Julio Reyes · Santiago, Chile 🇨🇱*
