---
title: Pre-commit Hooks
linkTitle: Pre-commit Hooks
description: Overview of the Bash Tools Framework pre-commit hooks
type: docs
weight: 11
date: '2026-03-15T08:00:00+01:00'
lastmod: '2026-04-26T23:17:38+02:00'
version: '1.4'
---

The Bash Tools Framework provides pre-commit hooks to ensure code quality and consistency before changes are committed
to your repository. These hooks are defined in the `.pre-commit-hooks.yaml` file and can be easily integrated into your
development workflow using the [pre-commit](https://pre-commit.com/) tool.

<!--TOC-->

- [1. Available Hooks](#1-available-hooks)
  - [1.1. fixShebangExecutionBit](#11-fixshebangexecutionbit)
  - [1.2. frameworkLint](#12-frameworklint)
  - [1.3. awkLint](#13-awklint)
  - [1.4. shellcheckLint](#14-shellchecklint)
  - [1.5. runUnitTests](#15-rununittests)
  - [1.6. plantuml](#16-plantuml)
  - [1.7. mermaid](#17-mermaid)
  - [1.8. rimage](#18-rimage)
  - [1.9. html2image](#19-html2image)
  - [1.10. html2imageMarkwhen](#110-html2imagemarkwhen)
  - [1.11. megalinterCheckVersion](#111-megalintercheckversion)
  - [1.12. megalinter](#112-megalinter)
  - [1.13. hugoUpdateLastmod](#113-hugoupdatelastmod)
- [2. Usage](#2-usage)

<!--TOC-->

## 1. Available Hooks

### 1.1. fixShebangExecutionBit

This hook finds all files containing a shebang and marks them as executable if they are not already.

### 1.2. frameworkLint

This hook checks if your files use the correct syntax for using the bash-tools-framework.

### 1.3. awkLint

This hook lints awk files using awk.

### 1.4. shellcheckLint

This hook lints bash files using shellcheck. It automatically installs the latest version of shellcheck if it's not
already available.

### 1.5. runUnitTests

Internal hook used in the framework to run unit tests using bats in a Docker isolated environment. It ensures that your
code is tested in a consistent environment before being committed.

### 1.6. plantuml

This hook generates Plantuml diagrams from `.puml` files. It uses the `bin/plantuml` script, which can be configured to
run in CI mode, generate images in the same directory as the source files, and specify output formats. It uses the
latest plantuml docker image and uses it to generate diagrams. It also detects added files in CI mode to only generate
diagrams for new files.

### 1.7. mermaid

This hook generates Mermaid diagrams from `.mmd` files. It uses the `bin/mermaid` script, which can be configured to run
in CI mode, generate images in the same directory as the source files, and specify output formats. It uses the latest
mermaid binary using npx and uses it to generate diagrams. It also detects added files in CI mode to only generate
diagrams for new files.

### 1.8. rimage

This hook generates images from source image files using the [rimage tool](https://github.com/vlad-salone/rimage). It
uses the `bin/rimageWrapper` script, which can be configured to run in CI mode, generate images in the same directory as
the source files, and specify output formats. It uses the latest rimage binary and uses it to generate images. It also
detects added files in CI mode to only generate images for new files.

### 1.9. html2image

This hook generates images from HTML files using the `bin/html2image` script, which can be configured to run in CI mode,
generate images in the same directory as the source files, and specify output formats. It also detects added files in CI
mode to only generate images for new files.

### 1.10. html2imageMarkwhen

This hook generates images from Markwhen files using the `bin/html2image` script, which can be configured to run in CI
mode, generate images in the same directory as the source files, and specify output formats. It is a special
configuration of the html2image hook that uses the `--transform-cmd` option to transform Markwhen files into HTML using
the `npx markwhen` command before generating images.

### 1.11. megalinterCheckVersion

This hook checks if a new version of megalinter is available. It uses the `bin/megalinter` script with the
`--check-megalinter-version` option to check for updates.

### 1.12. megalinter

This hook runs megalinter for comprehensive code quality checks. It uses the `bin/megalinter` script, which can be
configured to specify the megalinter image, configuration file, and whether to automatically fix issues.

### 1.13. hugoUpdateLastmod

This hook updates the `lastmod` and `version` fields in Hugo frontmatter based on git modification dates or the current
date.

## 2. Usage

To use these hooks, simply add the desired hooks to your `.pre-commit-config.yaml` file. For example:

```yaml
default_install_hook_types: [pre-commit, pre-push]
default_stages: [pre-commit, manual]
minimum_pre_commit_version: 3.5.0
repos:
  - repo: https://github.com/fchastanet/bash-tools-framework
    rev: 6.2.6
    hooks:
      - id: fixShebangExecutionBit
      - id: awkLint
      - id: shellcheckLint
      - id: plantuml
        args: [--same-dir, -f, svg, --limit-size, '1200']
      - id: hugoUpdateLastmod

```
