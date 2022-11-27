/* eslint-disable no-magic-numbers */
// https://eslint.org/docs/user-guide/configuring
// File taken from https://github.com/vuejs-templates/webpack/blob/1.3.1/template/.eslintrc.js, thanks.
module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module',
    parser: 'babel-eslint',
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
  env: {
    es2021: true,
    commonjs: true,
    node: true,
  },
  extends: ['eslint:recommended', 'plugin:prettier/recommended'],
};
