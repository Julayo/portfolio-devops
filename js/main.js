// Diccionario de traducciones
const translations = {
  es: {
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
    "about.text":
      "Soy ingeniero DevOps en Chile, con experiencia trabajando para clientes en Estados Unidos. Me especializo en CI/CD, automatización con Python y entornos en la nube (principalmente AWS).",

    "skills.title": "Skills principales",
    "skills.item1": "CI/CD con Jenkins, Tekton, GitHub Actions y AWS CodePipeline.",
    "skills.item2": "Infraestructura en AWS (Lambda, S3, ECS/EKS, CloudFront, etc.).",
    "skills.item3": "Scripting con Python y Bash para automatizar tareas.",
    "skills.item4": "Contenedores (Docker) y despliegues en Kubernetes/OpenShift.",

    "projects.title": "Proyectos",
    "projects.p1.title": "Plataforma CI/CD multi-entorno",
    "projects.p1.text":
      "Diseño y automatización de pipelines desde desarrollo hasta producción, incorporando análisis estático de código, creación de imágenes Docker y despliegues automatizados en Kubernetes.",
    "projects.p2.title": "Automatización de despliegues serverless",
    "projects.p2.text":
      "Implementación de pipelines para funciones Lambda con pruebas automatizadas y despliegues controlados por rama, reduciendo el tiempo de entrega y errores manuales.",

    "cicd.title": "CI/CD Demo",
    "cicd.text1":
      "Esta sección está pensada para conectarse a un pipeline que cambie el tema o colores del sitio con cada despliegue.",
    "cicd.text2": "Entorno actual: Demo local (placeholder).",

    "contact.title": "Contacto",
    "contact.email": "📧 Email: tu-correo-profesional@ejemplo.com",
    "contact.linkedin": "🔗 LinkedIn: linkedin.com/in/tu-perfil",
    "contact.location":
      "📍 Ubicación: Santiago, Chile (disponible remoto para USA / Latam)",
    "contact.footer":
      "Portafolio construido como sitio estático para demostración de DevOps/CI-CD.",

    "footer.text": "© 2025 Julio Reyes - Portafolio DevOps CI/CD",
  },

  en: {
    "nav.home": "Home",
    "nav.about": "About",
    "nav.skills": "Skills",
    "nav.projects": "Projects",
    "nav.cicd": "CI/CD Demo",
    "nav.contact": "Contact",

    "home.title": "Hi, I'm Julio Reyes",
    "home.subtitle":
      "DevOps Engineer based in Chile, helping U.S. teams automate their cloud deployments.",

    "about.title": "About me",
    "about.text":
      "I am a DevOps engineer in Chile with experience working for U.S. clients. I specialize in CI/CD, automation with Python, and cloud environments (mainly AWS).",

    "skills.title": "Main skills",
    "skills.item1": "CI/CD with Jenkins, Tekton, GitHub Actions, and AWS CodePipeline.",
    "skills.item2": "AWS infrastructure (Lambda, S3, ECS/EKS, CloudFront, etc.).",
    "skills.item3": "Scripting in Python and Bash to automate tasks.",
    "skills.item4": "Containers (Docker) and deployments on Kubernetes/OpenShift.",

    "projects.title": "Projects",
    "projects.p1.title": "Multi-environment CI/CD platform",
    "projects.p1.text":
      "Design and automation of pipelines from development to production, including static code analysis, Docker image creation, and automated deployments to Kubernetes.",
    "projects.p2.title": "Serverless deployment automation",
    "projects.p2.text":
      "Implementation of pipelines for Lambda functions with automated tests and branch-based deployments, reducing delivery time and manual errors.",

    "cicd.title": "CI/CD Demo",
    "cicd.text1":
      "This section is intended to connect to a pipeline that changes the theme or colors of the site on each deployment.",
    "cicd.text2": "Current environment: Local demo (placeholder).",

    "contact.title": "Contact",
    "contact.email": "📧 Email: your-professional-email@example.com",
    "contact.linkedin": "🔗 LinkedIn: linkedin.com/in/your-profile",
    "contact.location":
      "📍 Location: Santiago, Chile (available for remote work for USA / Latam)",
    "contact.footer":
      "Portfolio built as a static site to showcase DevOps/CI-CD skills.",

    "footer.text": "© 2025 Julio Reyes - DevOps CI/CD Portfolio",
  },
};

function setLanguage(lang) {
  const dict = translations[lang];
  if (!dict) return;

  // Cambia textos
  document.querySelectorAll("[data-i18n-key]").forEach((el) => {
    const key = el.getAttribute("data-i18n-key");
    if (dict[key]) {
      el.textContent = dict[key];
    }
  });

  // Cambia atributo lang del html
  document.documentElement.setAttribute("lang", lang);

  // Marca botón activo
  document.querySelectorAll(".lang-btn").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.lang === lang);
  });

  // Guarda preferencia
  localStorage.setItem("portfolio-lang", lang);
}

document.addEventListener("DOMContentLoaded", () => {
  const savedLang = localStorage.getItem("portfolio-lang") || "es";
  setLanguage(savedLang);

  // Listener de banderitas
  document.querySelectorAll(".lang-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      const lang = btn.dataset.lang;
      setLanguage(lang);
    });
  });
});
