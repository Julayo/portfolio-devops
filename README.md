# DevOps CI/CD Portfolio – Julio Reyes

Static, bilingual (EN/ES) portfolio site built to showcase my experience as a **DevOps Engineer** focused on **CI/CD, AWS and automation**.

The goal of this repo is twofold:

1. Present my profile, skills and projects in a clear, recruiter-friendly way.  
2. Serve as a living example of how I structure and automate a simple front-end deployment pipeline in the cloud.

---

## 🔍 Tech Overview

- **Frontend**:  
  - Pure HTML, CSS and vanilla JavaScript  
  - Bilingual content (English / Spanish) via JSON translation files  
- **CI/CD Target** (design goal):  
  - Source: GitHub  
  - Build & Deploy: AWS CodeBuild  
  - Hosting: S3 static website (optionally fronted by CloudFront)  
- **Cloud & DevOps Skills Demonstrated**:
  - S3 static hosting
  - AWS CodeBuild buildspec
  - Ready to plug into CodePipeline for full CI/CD

---

## 🌐 Bilingual UX (EN / ES)

The site supports **two languages**: English and Spanish.

### How it works

- Language switcher in the header with flag emojis:
  - 🇺🇸 EN
  - 🇨🇱 ES
- Text content is not hard-coded: instead, it uses **translation keys** via `data-i18n` attributes in the HTML, for example:

  ```html
  <h1 data-i18n="home.title">Hola, soy Julio Reyes</h1>

- Actual strings live in JSON files:
    translation/
    ├── en.json
    └── es.json

-A small JavaScript controller js/lang.js:
    - Loads en.json or es.json on demand.
    - Replaces the textContent of all elements that have data-i18n="some.key".
    - Marks the active language button with a CSS class (.lang-active).

This pattern keeps the HTML clean and makes it easy to add more languages or update text without touching the structure.