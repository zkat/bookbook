const THEMES = ["light", "dark", "system"];

let themePickerLoaded = false;

function themePicker() {
  document.removeEventListener("DOMContentLoaded", themePicker);
  window.removeEventListener("load", themePicker);

  if (themePickerLoaded) return;
  themePickerLoaded = true;

  THEMES.forEach((theme) => {
    document
      .getElementById(`theme-picker-${theme}`)
      ?.addEventListener("click", (event) => {
        event.preventDefault();
        THEMES.forEach((t) =>
          document.body.classList.toggle(`theme-${t}`, t === theme),
        );
        document.cookie = `theme=${theme}; path=/`;
      });
  });
}

if (document.readyState !== "loading") {
  themePicker();
} else {
  document.addEventListener("DOMContentLoaded", themePicker);
  window.addEventListener("load", themePicker);
}
