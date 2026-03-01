---
title: Best Practices
description: Bash development best practices and recipes
weight: 30
categories: [documentation, guides]
tags: [best-practices, bash, testing, development]
creationDate: 2026-03-01
lastUpdated: 2026-03-01
version: "1.0"
---

# Bash Best Practices & Recipes

**DISCLAIMER:** Some of the best practices mentioned are not fully applied in this project as they were written during development.

## External Resources

For comprehensive guides on Bash best practices, please refer to these documents:

- [General Bash Best Practices](https://fchastanet.github.io/my-documents/docs/bash-scripts/basic-best-practices/) - Core Bash scripting practices
- [Linux Commands Best Practices](https://fchastanet.github.io/my-documents/docs/bash-scripts/linux-commands-best-practices/) - Effective Linux command usage
- [Bats Best Practices](https://fchastanet.github.io/my-documents/docs/bash-scripts/bats-best-practices/) - Testing best practices with Bats

## Framework-Specific Recommendations

### Using @embed Keyword

The `@embed` keyword is really useful to inline configuration files. However, to run framework functions using sudo, it is recommended to call the same binary but passing options to change the behavior. This way the content of the script file does not seem to be obfuscated.

### Function Organization

Follow the framework's naming conventions:
- Use `Namespace::functionName` pattern
- Place functions in appropriate namespace directories
- Include comprehensive documentation using shdoc annotations
- Write unit tests for every function

### Testing Strategy

- Run tests on multiple Bash versions (4.4, 5.0, 5.3)
- Test on both Ubuntu and Alpine environments
- Use `# bats test_tags=ubuntu_only` for Ubuntu-specific tests
- Leverage stub/mock capabilities for external dependencies
