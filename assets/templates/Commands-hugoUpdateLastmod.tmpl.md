---
title: hugoUpdateLastmod command
linkTitle: Build - hugoUpdateLastmod
description: Overview of the hugoUpdateLastmod command for updating Hugo frontmatter lastmod fields
tags: [commands, build]
type: docs
weight: 10
date: 2026-03-01
lastmod: 2026-03-02
version: 1.0
---

## 1. Help

**Command:** `bin/hugoUpdateLastmod --help`

```text
@@@hugoUpdateLastmod_help@@@
```

## 2. Usage

Update `lastmod` field in Hugo frontmatter based on git modification dates or the current date. It can be run in two
modes: migration mode (using `--init`) to update all git-tracked markdown files in the `content/` directory, and commit
mode (using `--commit`) to update only staged files. The hook includes smart update detection to prevent unnecessary
changes, making it ideal for use in pre-commit hooks to ensure that your Hugo content is always up-to-date with the
latest modification dates.
