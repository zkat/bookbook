import { typecheckPlugin } from "@jgoz/esbuild-plugin-typecheck";
import esbuild from "esbuild";
import AnalyzerPlugin from "esbuild-analyzer";
import eslint from "esbuild-plugin-eslint";
import process from "process";

import { mkdirSync } from "node:fs";
import { join } from "node:path";

const analysisDir = join(import.meta.dirname, "bundle-analysis");
mkdirSync(analysisDir, { recursive: true });

const prod = process.argv[2] === "production";
const watch = !prod && process.argv[2] !== "nowatch";

function plugins(name) {
  return [
    typecheckPlugin({ build: true, watch }),
    eslint({
      warnIgnored: false,
    }),
    AnalyzerPlugin({ outfile: join(analysisDir, `${name}.html`) }),
  ]
}

const contextBase = {
  bundle: true,
  external: [
    "/fonts/*",
    "/images/*",
  ],
  target: "es2022",
  logLevel: "info",
  treeShaking: prod,
  minify: prod,
  format: "esm",
  nodePaths: [
    "../deps",
  ],
  legalComments: "linked",
  metafile: true,
};

const mainContext = await esbuild.context({
  ...contextBase,
  entryPoints: [
    "js/site.ts",
    "js/app.ts",
    "css/app.css",
    "css/theme-dark.css",
    "css/theme-light.css",
  ],
  outdir: "../priv/static/assets",
  loader: {
    ".svg": "dataurl",
  },
  plugins: plugins("main"),
});

const litSSRContext = await esbuild.context({
  ...contextBase,
  external: [
    "node:process",
    "node:readline",
  ],
  entryPoints: [
    "js/lit-ssr.ts",
  ],
  outfile: "../priv/ssr/lit-ssr.js",
  platform: "node",
  format: "cjs",
  plugins: plugins("ssr"),
});

if (!watch) {
  await Promise.all([mainContext.rebuild(), litSSRContext.rebuild()]);
  process.exit(0);
} else {
  // https://github.com/vitejs/vite/issues/5743
  process.stdin.on("close", () => {
    process.exit(0);
  });
  process.stdin.resume();

  await Promise.all([mainContext.watch(), litSSRContext.watch()]);
}
