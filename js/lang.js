const DEFAULT_LANG = 'en';
const STORAGE_KEY = 'portfolio_lang';

function getNested(obj, key) {
    return key.split('.').reduce((acc, part) => acc && acc[part], obj);
}

function applyTranslations(lang, translations) {
    const elements = document.querySelectorAll('[data-i18n]');
    elements.forEach(el => {
        const key = el.getAttribute('data-i18n');
        const value = getNested(translations, key);
        if (value) {
            el.innerHTML = value;
        } else {
            console.warn(`Missing translation for key "${key}" in lang "${lang}"`);
        }
    });
}

async function loadLanguage(lang) {
    try {
        const res = await fetch(`translation/${lang}.json`);
        if (!res.ok) {
            throw new Error(`HTTP ${res.status}`);
        }
        const translations = await res.json();
        applyTranslations(lang, translations);
        localStorage.setItem(STORAGE_KEY, lang);
        document.documentElement.lang = lang;
        // marcar botón activo
        document.querySelectorAll('.lang-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.lang === lang);
        });
    } catch (err) {
        console.error(`Error loading translations for "${lang}":`, err);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const saved = localStorage.getItem(STORAGE_KEY);
    const initialLang = saved || DEFAULT_LANG;

    document.querySelectorAll('.lang-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const lang = btn.dataset.lang;
            loadLanguage(lang);
        });
    });

    loadLanguage(initialLang);
});
