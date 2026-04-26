---
title: Best Practices
description: Bash development best practices and recipes
weight: 30
type: docs
categories: [documentation, guides]
tags: [best-practices, bash, testing, development]
version: '1.0'
date: '2026-03-01T08:00:00+01:00'
lastmod: '2026-03-01T08:00:00+01:00'
---

**DISCLAIMER:** Some of the best practices mentioned are not fully applied in this project as they were written during
development.

## 1. Framework-Specific Recommendations

### 1.1. Using @embed Keyword

The `@embed` keyword is really useful to inline configuration files. However, to run framework functions using sudo, it
is recommended to call the same binary but passing options to change the behavior. This way the content of the script
file does not seem to be obfuscated.

### 1.2. Function Organization

Follow the framework's naming conventions:

- Use `Namespace::functionName` pattern
- Place functions in appropriate namespace directories
- Include comprehensive documentation using shdoc annotations
- Write unit tests for every function

### 1.3. Testing Strategy

- Run tests on multiple Bash versions (4.4, 5.0, 5.3)
- Test on both Ubuntu and Alpine environments
- Use `# bats test_tags=ubuntu_only` for Ubuntu-specific tests
- Leverage stub/mock capabilities for external dependencies
