// js/translations.js

const TRANSLATIONS = {
  es: {
    site_title: "Portafolio DevOps CI/CD",

    nav_home: "Inicio",
    nav_about: "Sobre mí",
    nav_skills: "Skills",
    nav_projects: "Proyectos",
    nav_cicd: "CI/CD Demo",
    nav_contact: "Contacto",

    hero_title: "Hola, soy Julio — DevOps & CI/CD Engineer",
    hero_subtitle:
      "Automatizo despliegues, pipelines y nubes para que el código llegue a producción de forma rápida y segura.",
    hero_cta: "Ver proyectos",

    about_title: "Sobre mí",
    about_body:
      "Soy ingeniero DevOps en Chile, con experiencia trabajando para clientes en Estados Unidos. Me especializo en CI/CD, automatización con Python y entornos en la nube (principalmente AWS).",

    skills_title: "Skills principales",
    skills_item_1:
      "CI/CD con Jenkins, Tekton, GitHub Actions y AWS CodePipeline.",
    skills_item_2:
      "Infraestructura en AWS (Lambda, S3, ECS/EKS, CloudFront, etc.).",
    skills_item_3:
      "Scripting con Python y Bash para automatizar tareas.",
    skills_item_4:
      "Contenedores y orquestación (Docker, Kubernetes/OpenShift).",

    projects_title: "Proyectos destacados",
    project1_title: "Portafolio auto-deploy con AWS Lambda",
    project1_body:
      "Sitio estático desplegado desde un repositorio Git. Un pipeline de CI/CD actualiza automáticamente el sitio cuando se hace push a la rama principal, incluyendo cambios visuales como color de fondo o estructura.",
    project1_meta: "Stack: S3, CloudFront, Lambda, CodePipeline, CodeBuild, Git.",

    project2_title: "Automatización de despliegues en banca",
    project2_body:
      "Implementación de pipelines de despliegue para aplicaciones de banca en entornos controlados, integrando control de calidad, validaciones y aprobaciones antes de llegar a producción.",
    project2_meta:
      "Stack: Jenkins, UrbanCode / Tekton, SonarQube, OpenShift, Git.",

    cicd_title: "Demo de CI/CD",
    cicd_body:
      "La idea de esta sección es mostrar visualmente el resultado de un pipeline. Por ahora es un ejemplo estático, pero se puede conectar a un backend (por ejemplo, una Lambda) para cambiar el color del sitio o el texto cuando se complete un despliegue.",
    cicd_status_label: "Estado del último despliegue:",
    cicd_status_value: "Éxito (ejemplo)",
    cicd_button_fake: "Simular nuevo despliegue (demo)",

    contact_title: "Contacto",
    contact_body:
      "Si te interesa trabajar conmigo o conversar sobre proyectos DevOps desde Latam hacia Estados Unidos, puedes escribirme:",

    footer_text:
      "Hecho con ❤️ desde Chile — Portafolio DevOps CI/CD."
  },

  en: {
    site_title: "DevOps CI/CD Portfolio",

    nav_home: "Home",
    nav_about: "About",
    nav_skills: "Skills",
    nav_projects: "Projects",
    nav_cicd: "CI/CD Demo",
    nav_contact: "Contact",

    hero_title: "Hi, I'm Julio — DevOps & CI/CD Engineer",
    hero_subtitle:
      "I automate deployments, pipelines and cloud environments so code can reach production quickly and safely.",
    hero_cta: "View projects",

    about_title: "About me",
    about_body:
      "I am a DevOps engineer based in Chile, with experience working for U.S. clients. I specialize in CI/CD, Python automation and cloud environments (mainly AWS).",

    skills_title: "Main skills",
    skills_item_1:
      "CI/CD with Jenkins, Tekton, GitHub Actions and AWS CodePipeline.",
    skills_item_2:
      "Infrastructure on AWS (Lambda, S3, ECS/EKS, CloudFront, etc.).",
    skills_item_3:
      "Scripting with Python and Bash to automate tasks.",
    skills_item_4:
      "Containers and orchestration (Docker, Kubernetes/OpenShift).",

    projects_title: "Highlighted projects",
    project1_title: "Auto-deploy portfolio with AWS Lambda",
    project1_body:
      "Static site deployed from a Git repository. A CI/CD pipeline automatically updates the site when pushing to the main branch, including visual changes such as background color or layout.",
    project1_meta: "Stack: S3, CloudFront, Lambda, CodePipeline, CodeBuild, Git.",

    project2_title: "Deployment automation in banking",
    project2_body:
      "Implementation of deployment pipelines for banking applications in controlled environments, integrating quality checks, validations and approvals before reaching production.",
    project2_meta:
      "Stack: Jenkins, UrbanCode / Tekton, SonarQube, OpenShift, Git.",

    cicd_title: "CI/CD Demo",
    cicd_body:
      "The idea of this section is to visually show a pipeline result. For now it's a static example, but it can be connected to a backend (for example, a Lambda) to change the site's color or text when a deployment completes.",
    cicd_status_label: "Last deployment status:",
    cicd_status_value: "Success (demo)",
    cicd_button_fake: "Simulate new deployment (demo)",

    contact_title: "Contact",
    contact_body:
      "If you're interested in working with me or discussing DevOps projects from Latam to the U.S., feel free to reach out:",

    footer_text:
      "Made with ❤️ from Chile — DevOps CI/CD Portfolio."
  }
};
