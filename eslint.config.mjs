import json from "eslint-plugin-json";
import globals from "globals";
import path from "node:path";
import {fileURLToPath} from "node:url";
import js from "@eslint/js";
import {FlatCompat} from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

export default [
  ...compat.extends(
    "eslint:recommended",
    "plugin:json/recommended-legacy",
    "eslint-config-prettier"
  ),
  {
    plugins: {
      json,
    },

    languageOptions: {
      globals: {
        ...globals.commonjs,
        ...globals.node,
      },

      ecmaVersion: 12,
      sourceType: "module",

      parserOptions: {
        parser: "babel-eslint",

        ecmaFeatures: {
          jsx: false,
          modules: true,
          arrowFunctions: true,
          classes: true,
          destructuring: true,
          forOf: true,
          impliedStrict: true,
          spread: true,
          templateStrings: true,
        },
      },
    },

    rules: {
      "json/*": [
        "error",
        {
          allowComments: false,
        },
      ],
    },
  },
  {
    files: [".vscode/*.json"],
    plugins: {json},
    processor: "json/json",
    rules: {
      "json/*": ["error", {allowComments: true}],
    },
  },
];
