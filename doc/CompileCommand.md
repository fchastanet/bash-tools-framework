# Compile Command

- [1. Why ?](#1-why-)
- [2. Compile tool](#2-compile-tool)
- [3. FrameworkLint](#3-frameworklint)
- [4. Best practices](#4-best-practices)
- [5. Acknowledgements](#5-acknowledgements)

## 1. Why ?

Scripts using multiple sourced files are not easy to distribute. We usually
distribute those as archives and rely on the end user to unpack and run them
from a predetermined location. To improve the experience we can instead prepare
a single script with other files embedded inside it.

Here are the goals:

- The script should consist of a single file, making it easy to distribute
- The script should be copy-paste-able between systems and different editors,
  even if multiple hops are required
- Files being embedded can be binary files i.e. can contain non-printable
  characters
- The script allow bash functions reusability

The first requirement implies that we should somehow store the contents of other
files in our main script. The second requires us to avoid non-printable
characters, as they tend to cause problems when performing a copy-paste
operation. Especially when we are talking about sending such characters over
messaging programs.

## 2. Compile tool

This tool allows to detect all the framework functions used inside a given sh
file. The framework functions matches the pattern `Namespace::functionName` (we
can have several namespaces separated by the characters `::`). These framework
functions will be injected inside a compiled file. The process is recursive so
that every framework functions used by imported framework functions will be
imported as well (of course only once).

You can see several examples of compiled files by checking
[src/\_binaries folder](../src/_binaries). For example:

- `src/_binaries/frameworkLint.sh` generates the file `bin/frameworkLint`

## 3. FrameworkLint

Lint files of the current repository

- check if all Namespace::functions are existing in the framework
- check that function defined in a .sh is correctly named
- check that each framework function has a bats file associated (warning if not)
- check that `REQUIRE` directive `AS` ids are not duplicated
- check for `# FUNCTIONS`, `# REQUIREMENTS` and `# ENTRYPOINT` presence
- check `# FUNCTIONS` placeholder is defined before `# REQUIREMENTS`
- check `# REQUIREMENTS` placeholder is defined before `# ENTRYPOINT`

This linter is used in precommit hooks, see
[.pre-commit-config.yaml](https://github.com/fchastanet/bash-tools-framework/blob/master/.pre-commit-config.yaml).

## 4. Best practices

**DISCLAIMER:** Some of the best practices mentioned in this document are not
applied in this project because I wrote some of them while writing this project.

[General Bash best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/00-Basic-BestPractices.md)
[Linux Best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/10-LinuxCommands-BestPractices.md)
[Bats Best practices](https://github.com/fchastanet/my-documents/blob/master/HowTo/HowTo-Write-Bash-Scripts/20-Bats-BestPractices.md)

`EMBED` keyword is really useful to inline configuration files. However to run
framework function using sudo, it is recommended to call the same binary but
passing options to change the behavior. This way the content of the script file
does not seem to be obfuscated.

## 5. Acknowledgements

I want to thank a lot Michał Zieliński(Tratif company) for this wonderful
article that helped me a lot in the conception of the file/dir/framework
function embedding feature.

for more information see
[Bash Tips #6 – Embedding Files In A Single Bash Script](https://blog.tratif.com/2023/02/17/bash-tips-6-embedding-files-in-a-single-bash-script/)
