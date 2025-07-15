import pluginJs from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";

export default tseslint.config(
  { files: ["./**/*.{js,mjs,cjs,ts}", "!deps/**/*"] },
  { languageOptions: { globals: globals.browser } },
  pluginJs.configs.recommended,
  tseslint.configs.recommended,
);
