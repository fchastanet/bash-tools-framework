# Best practices and recipes

## Arguments

- shift each arg to avoid not shifting at all
- to construct complex command line, prefer to use an array
  - `declare -a cmd=(git push origin :${branch})`
  - then you can display the result using echo `"${cmd[*]}"`
  - you can execute the command using `"${cmd[@]}"`

## some commands default options to use

- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html> but set -o
  nounset is not usable because empty array are considered unset
- always use `sed -E`
- avoid using grep -P as it is not supported on alpine, prefer using -E
- grep regular expression [A-Za-z] matches by default accentuated character, it
  you don't want to match them, use the environment variable `LC_ALL=POSIX`,
  - Eg: `LC_ALL=POSIX grep -E -q '^[A-Za-z_0-9:]+$'`
  - I added `export LC_ALL=POSIX` in all my headers, it can be overriden using a
    subshell

## General tips

- `cat << 'EOF'` avoid to interpolate variables
- use `builtin cd` instead of `cd`, `builtin pwd` instead of `pwd`, ... to avoid
  using customized aliased commands by the user
- use the right shebang, avoid `#!/bin/bash` as bash binary could be in another
  folder (expecially on alpine), use this instead `#!/usr/bin/env bash`

## Variables

### Variable declaration

- ensure we don't have any globals, all variables should be passed to the
  functions
- declare all variables as local in functions to avoid making them global
- local or declare multiple local a z
- `export readonly` does not work, first `readonly` then `export`

### Check if a variable is defined

```bash
if [[ -z ${varName+xxx} ]]; then
  # varName is not set
fi
```

alternatively you can use this framework function `Assert::validVariableName`

### variable naming convention

- env variable that aims to be exported should be capitalized with underscore
- local variables should conform to camelCase

### Variable expansion

- `${PARAMETER:-WORD}` `${PARAMETER-WORD}` If the parameter PARAMETER is unset
  (never was defined) or null (empty), this one expands to WORD, otherwise it
  expands to the value of PARAMETER, as if it just was ${PARAMETER}. If you omit
  the : (colon), like shown in the second form, the default value is only used
  when the parameter was unset, not when it was empty.

## Capture output

You can use
[command substitution](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Command-Substitution).

Eg:

```bash
local output
output="$(functionThatOutputSomething "${arg1}")"
```

### Capture output and test result

```bash
local output
output="$(functionThatOutputSomething "${arg1}")" || {
  echo "error"
  exit 1
}
```

### Capture output and retrieve status code

It's advised to put it on the same line using `;`. If it was on 2 lines, other
commands could be put between the command and the status code retrieval, the
status would not be the same command status.

```bash
local output
output="$(functionThatOutputSomething "${arg1}")"; status=$?
```

## Array

- read each line of a file to an array `readarray -t var < /path/to/filename`

## Temporary directory

use `${TMPDIR:-/tmp}`, TMDIR variable does not always exist.
or when mktemp is available, use `dirname $(mktemp -u --tmpdir)`
