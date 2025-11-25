// lang.js

const translations = {
  es: {
    siteTitle: "Portafolio DevOps CI/CD",

    "nav.home": "Inicio",
    "nav.about": "Sobre mí",
    "nav.skills": "Skills",
    "nav.projects": "Proyectos",
    "nav.cicd": "CI/CD Demo",
    "nav.contact": "Contacto",

    "home.title": "Hola, soy Julio Reyes",
    "home.subtitle":
      "Ingeniero DevOps en Chile, ayudando a equipos de Estados Unidos a automatizar sus despliegues en la nube.",

    "about.title": "Sobre mí",
    "about.body":
      "Soy ingeniero DevOps en Chile, con experiencia trabajando para clientes en Estados Unidos. Me especializo en CI/CD, automatización con Python y entornos en la nube (principalmente AWS).",

    "skills.title": "Skills principales",
    "skills.item1": "CI/CD con Jenkins, Tekton, GitHub Actions y AWS CodePipeline.",
    "skills.item2": "Infraestructura en AWS (Lambda, S3, ECS/EKS, CloudFront, etc.).",
    "skills.item3": "Scripting con Python y Bash para automatizar tareas.",
    "skills.item4": "Contenedores (Docker) y despliegues en Kubernetes/OpenShift.",

    "projects.title": "Proyectos",
    "projects.platformTitle": "Plataforma CI/CD multi-entorno",
    "projects.platformBody":
      "Diseño y automatización de pipelines desde desarrollo hasta producción, incorporando análisis estático de código, creación de imágenes Docker y despliegues automatizados en Kubernetes.",
    "projects.serverlessTitle": "Automatización de despliegues serverless",
    "projects.serverlessBody":
      "Implementación de pipelines para funciones Lambda con pruebas automatizadas y despliegues controlados por rama, reduciendo el tiempo de entrega y errores manuales.",

    "cicd.title": "CI/CD Demo",
    "cicd.body1":
      "Esta sección está pensada para conectarse a un pipeline que cambie el tema o colores del sitio con cada despliegue.",
    "cicd.body2":
      "Pipeline conectado (placeholder). Entorno actual: Demo local.",
    "cicd.body3":
      "La idea es que, en producción, un pipeline en AWS (por ejemplo con CodePipeline + CodeBuild + Lambda) pueda actualizar este sitio y reflejar cambios visuales simples (como el color del tema) para demostrar el flujo de CI/CD.",

    "contact.title": "Contacto",
    "contact.email": "📧 Email: tu-correo-profesional@ejemplo.com",
    "contact.linkedin": "🔗 LinkedIn: linkedin.com/in/tu-perfil",
    "contact.location":
      "📍 Ubicación: Santiago, Chile (disponible remoto para USA / Latam)",
    "contact.footer":
      "Portafolio construido como sitio estático para demostración de DevOps/CI-CD.",

    "footer.text": "© 2025 Julio Reyes - Portafolio DevOps CI/CD"
  },

  en: {
    siteTitle: "DevOps CI/CD Portfolio",

    "nav.home": "Home",
    "nav.about": "About",
    "nav.skills": "Skills",
    "nav.projects": "Projects",
    "nav.cicd": "CI/CD Demo",
    "nav.contact": "Contact",

    "home.title": "Hi, I'm Julio Reyes",
    "home.subtitle":
      "DevOps engineer based in Chile, helping U.S. teams automate their cloud deployments.",

    "about.title": "About me",
    "about.body":
      "I'm a DevOps engineer in Chile with experience working for U.S. clients. I specialize in CI/CD, Python automation, and cloud environments (mainly AWS).",

    "skills.title": "Key skills",
    "skills.item1": "CI/CD with Jenkins, Tekton, GitHub Actions and AWS CodePipeline.",
    "skills.item2": "AWS infrastructure (Lambda, S3, ECS/EKS, CloudFront, etc.).",
    "skills.item3": "Python and Bash scripting to automate tasks.",
    "skills.item4": "Containers (Docker) and deployments on Kubernetes/OpenShift.",

    "projects.title": "Projects",
    "projects.platformTitle": "Multi-environment CI/CD platform",
    "projects.platformBody":
      "Design and automation of pipelines from development to production, including static code analysis, Docker image builds, and automated deployments to Kubernetes.",
    "projects.serverlessTitle": "Serverless deployment automation",
    "projects.serverlessBody":
      "Implementation of pipelines for AWS Lambda functions with automated tests and branch-based deployments, reducing delivery time and manual errors.",

    "cicd.title": "CI/CD Demo",
    "cicd.body1":
      "This section is meant to connect to a pipeline that changes the theme or colors of the site on each deployment.",
    "cicd.body2":
      "Pipeline connected (placeholder). Current environment: Local demo.",
    "cicd.body3":
      "The idea is that, in production, a pipeline in AWS (for example with CodePipeline + CodeBuild + Lambda) can update this site and reflect simple visual changes (like theme color) to demonstrate the CI/CD flow.",

    "contact.title": "Contact",
    "contact.email": "📧 Email: julioreyesrepiso@gmail.com",
    "contact.linkedin": "🔗 LinkedIn: https://www.linkedin.com/in/julio-reyes-repiso-78a87454/",
    "contact.location":
      "📍 Location: Santiago, Chile (available for remote work for USA / Latam)",
    "contact.footer":
      "Portfolio built as a static site to showcase DevOps/CI-CD skills.",

    "footer.text": "© 2025 Julio Reyes - DevOps CI/CD Portfolio"
  }
};

function setLanguage(lang) {
  const dict = translations[lang];
  if (!dict) return;

  // Para accesibilidad
  document.documentElement.setAttribute("lang", lang);

  // Textos
  document.querySelectorAll("[data-i18n]").forEach((el) => {
    const key = el.getAttribute("data-i18n");
    const text = dict[key];
    if (!text) return;

    const tag = el.tagName.toLowerCase();
    if (tag === "input" || tag === "textarea") {
      el.placeholder = text;
    } else {
      el.innerHTML = text;
    }
  });

  // Estado visual de los botones
  document.querySelectorAll(".lang-btn").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.lang === lang);
  });

  // Persistir preferencia
  localStorage.setItem("portfolio-lang", lang);
}

document.addEventListener("DOMContentLoaded", () => {
  // Idioma guardado o español por defecto
  const saved = localStorage.getItem("portfolio-lang") || "es";
  setLanguage(saved);

  // Listeners de los botones
  document.querySelectorAll(".lang-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      const lang = btn.dataset.lang;
      setLanguage(lang);
    });
  });
});
