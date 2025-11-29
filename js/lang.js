// js/lang.js

const SUPPORTED_LANGS = ["en", "es"];
const DEFAULT_LANG = "en";

function resolveKey(obj, key) {
  return key.split(".").reduce((acc, part) => (acc ? acc[part] : undefined), obj);
}

async function loadLanguage(lang) {
  if (!SUPPORTED_LANGS.includes(lang)) {
    lang = DEFAULT_LANG;
  }

  try {
    const res = await fetch(`translation/${lang}.json?_=${Date.now()}`);
    const translations = await res.json();

    // Aplica traducciones a todos los elementos con data-i18n
    document.querySelectorAll("[data-i18n]").forEach((el) => {
      const key = el.getAttribute("data-i18n");
      const value = resolveKey(translations, key);

      if (typeof value === "string") {
        el.innerHTML = value;
      }
    });

    // Marca botón activo
    document.querySelectorAll(".lang-btn").forEach((btn) => {
      if (btn.dataset.lang === lang) {
        btn.classList.add("active");
      } else {
        btn.classList.remove("active");
      }
    });

    document.documentElement.lang = lang;
    localStorage.setItem("portfolioLang", lang);
  } catch (err) {
    console.error("Error loading language", lang, err);
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const saved = localStorage.getItem("portfolioLang");
  const initialLang = SUPPORTED_LANGS.includes(saved) ? saved : DEFAULT_LANG;

  // Listeners de los botones
  document.querySelectorAll(".lang-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      const lang = btn.dataset.lang || DEFAULT_LANG;
      loadLanguage(lang);
    });
  });

  // Carga inicial
  loadLanguage(initialLang);
});
