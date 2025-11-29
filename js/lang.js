// js/lang.js

const DEFAULT_LANG = "en";
const SUPPORTED_LANGS = ["en", "es"];

let currentLang = DEFAULT_LANG;
const translations = {};

/**
 * Carga el archivo JSON de traducción para el idioma dado
 * y aplica los textos al DOM.
 */
async function loadTranslations(lang) {
  if (!SUPPORTED_LANGS.includes(lang)) {
    lang = DEFAULT_LANG;
  }

  // Si ya está en caché, solo lo aplicamos
  if (translations[lang]) {
    applyTranslations(lang);
    return;
  }

  try {
    const response = await fetch(`translation/${lang}.json`);
    if (!response.ok) {
      throw new Error(`Error HTTP ${response.status}`);
    }
    const data = await response.json();
    translations[lang] = data;
    applyTranslations(lang);
  } catch (error) {
    console.error("Error loading translation file:", error);
  }
}

/**
 * Recorre todos los elementos con data-i18n y les asigna
 * el texto correspondiente usando el diccionario cargado.
 */
function applyTranslations(lang) {
  const dict = translations[lang];
  if (!dict) return;

  // Setear el atributo lang en <html>
  document.documentElement.setAttribute("lang", lang);

  const elements = document.querySelectorAll("[data-i18n]");
  elements.forEach((el) => {
    const key = el.getAttribute("data-i18n");
    if (Object.prototype.hasOwnProperty.call(dict, key)) {
      el.textContent = dict[key];
    }
  });

  currentLang = lang;
  highlightActiveLang(lang);
}

/**
 * Marca visualmente el idioma activo.
 */
function highlightActiveLang(lang) {
  const buttons = document.querySelectorAll("[data-lang]");
  buttons.forEach((btn) => {
    const btnLang = btn.getAttribute("data-lang");
    if (btnLang === lang) {
      btn.classList.add("lang-active");
    } else {
      btn.classList.remove("lang-active");
    }
  });
}

/**
 * Agrega listeners a los botones de idioma.
 */
function setupLanguageSwitcher() {
  const buttons = document.querySelectorAll("[data-lang]");
  buttons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const lang = btn.getAttribute("data-lang");
      loadTranslations(lang);
    });
  });
}

// Inicialización al cargar el DOM
document.addEventListener("DOMContentLoaded", () => {
  setupLanguageSwitcher();
  loadTranslations(currentLang);
});
