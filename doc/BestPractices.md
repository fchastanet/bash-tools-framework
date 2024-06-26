# Best practices and recipes

- [1. Bash best practices](#1-bash-best-practices)
- [2. Best practices specific to this project](#2-best-practices-specific-to-this-project)
  - [2.1. Bash-tpl best practice](#21-bash-tpl-best-practice)
    - [2.1.1. Avoid shellcheck errors](#211-avoid-shellcheck-errors)
    - [2.1.2. Allow simple quotes to generated correctly](#212-allow-simple-quotes-to-generated-correctly)
  - [Embed](#embed)
    - [no need of `embed_function_InstallFile`](#no-need-of-embed_function_installfile)

## 1. Bash best practices

**DISCLAIMER:** Some of the best practices mentioned in this document are not
applied in this project because I wrote some of them while writing this project.

[General Bash best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/00-Basic-BestPractices.md)
[Linux Best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/10-LinuxCommands-BestPractices.md)
[Bats Best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/20-Bats-BestPractices.md)

## 2. Best practices specific to this project

### 2.1. Bash-tpl best practice

#### 2.1.1. Avoid shellcheck errors

To avoid shellcheck reporting errors about malformed script, try to always put
your variable replacements inside bash variable, so instead of doing:

`<%% echo "${functionToCall}" %> "$@"`

which results in shellcheck error, you can do this instead

```text
# shellcheck disable=SC2016 # SC2016 needed because functionToCall inside quotes
#   is known when bash-tpl is interpreted but not inside the bash script being
# generated
functionToCall='<%% echo "${functionToCall}" %>'
"${functionToCall}" "$@"
```

#### 2.1.2. Allow simple quotes to generated correctly

bash-tpl template:

```bash
echo "echo \"    <% ${help} %>\""
```

bash script:

```bash
help="quiet mode, doesn't display any output"
```

generated script:

```bash
echo "    quiet mode, doesn't display any output"
```

### Embed

#### no need of `embed_function_InstallFile`

use ${SUDO}
