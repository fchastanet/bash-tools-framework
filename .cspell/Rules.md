# Spelling Rules

## 1. CSpell Dictionaries

- `bash.txt` - contains words related to bash scripting and command line usage.
- `readme.txt` - contains words commonly used in documentation writing, such as "markdown", and files in `content/`
  directory.
- `software.txt` - contains words related to software development, such as "docker", "kubernetes", "aws", "jenkins",
  command names, etc.
- `lintersConfig.txt` - contains mostly words that are used in all the other kind of files. Shell script and
  documentation files don't use this dictionary.

## 2. Codespell Dictionaries

- `codespellrc-dic.txt` is a dictionary used by codespell to detect typos in the codebase. It contains common
  misspellings and their corrections. This file is not used by cspell, but it is important for maintaining code quality.
- `.cspell/codespellrc-ignore.txt` is a list of words that codespell should ignore when checking for typos. This file is
  used to prevent false positives in the codebase, such as technical terms or acronyms that may be flagged as
  misspellings by codespell.
