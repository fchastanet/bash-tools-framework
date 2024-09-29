# Compile Command

- [3. FrameworkLint](#3-frameworklint)
- [4. Best practices](#4-best-practices)

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

`@embed` keyword is really useful to inline configuration files. However to run
framework function using sudo, it is recommended to call the same binary but
passing options to change the behavior. This way the content of the script file
does not seem to be obfuscated.
