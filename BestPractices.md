# Best practices and recipes

**DISCLAIMER:** Some of the best practices mentioned here are not applied in
this project because I wrote some of them while writing this project.

- [1. Bash Best practices](#1-bash-best-practices)
  - [1.1. Bash environment options](#11-bash-environment-options)
    - [1.1.1. errexit (set -e | set -o errexit)](#111-errexit-set--e--set--o-errexit)
    - [1.1.2. pipefail (set -o pipefail)](#112-pipefail-set--o-pipefail)
    - [1.1.3. errtrace (set -E | set -o errtrace)](#113-errtrace-set--e--set--o-errtrace)
    - [1.1.4. nounset (set -u | set -o nounset)](#114-nounset-set--u--set--o-nounset)
    - [shopt -s inherit\_errexit](#shopt--s-inherit_errexit)
    - [1.1.5. posix (set -o posix)](#115-posix-set--o-posix)
  - [1.2. Arguments](#12-arguments)
  - [1.3. some commands default options to use](#13-some-commands-default-options-to-use)
  - [1.4. Bash and grep regular expressions](#14-bash-and-grep-regular-expressions)
  - [1.5. General tips](#15-general-tips)
  - [1.6. Variables](#16-variables)
    - [1.6.1. Variable declaration](#161-variable-declaration)
    - [1.6.2. variable naming convention](#162-variable-naming-convention)
    - [1.6.3. Variable expansion](#163-variable-expansion)
    - [1.6.4. Check if a variable is defined](#164-check-if-a-variable-is-defined)
    - [1.6.5. Variable default value](#165-variable-default-value)
  - [1.7. Capture output](#17-capture-output)
    - [1.7.1. Capture output and test result](#171-capture-output-and-test-result)
    - [1.7.2. Capture output and retrieve status code](#172-capture-output-and-retrieve-status-code)
  - [1.8. Array](#18-array)
  - [1.9. Temporary directory](#19-temporary-directory)
- [2. Bin file best practices](#2-bin-file-best-practices)
  - [2.1. Bash-tpl best practice](#21-bash-tpl-best-practice)
- [3. Bats best practices](#3-bats-best-practices)
  - [3.1. use of default temp directory created by bats](#31-use-of-default-temp-directory-created-by-bats)
  - [3.2. avoid boilerplate code](#32-avoid-boilerplate-code)
  - [3.3. Override an environment variable when using bats run](#33-override-an-environment-variable-when-using-bats-run)
  - [3.4. Override a bash framework function](#34-override-a-bash-framework-function)

## 1. Bash Best practices

### 1.1. Bash environment options

See
[Set bash builtin documentation](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

This framework uses these mode by default:

- errexit
- pipefail
- errtrace

#### 1.1.1. errexit (set -e | set -o errexit)

Check official doc but it can be summarized like this:

> Exit immediately command returns a non-zero status.

This mode is a best practice because every non controlled command failure will
stop your program. But sometimes you need or expect a command to fail

**Eg1**: delete a folder that actually doesn't exists. Use `|| true` to ignore
the error.

```bash
rm -Rf folder || true
```

**Eg2**: a command that expects to fail if conditions are not met. Using `if`
will not stop the program on non-zero exit code.

```bash
if git diff-index --quiet HEAD --; then
  Log::displayInfo "Pull git repository '${dir}' as no changes detected"
  git pull --progress
  return 0
else
  Log::displayWarning "Pulling git repository '${dir}' avoided as changes detected"
fi
```

Caveats with command substitution:

```bash
#!/bin/bash
set -o errexit
echo `exit 1`
echo $?
```

Output:

```bash

0
```

it is because echo has succeeded. the same result occurs even with
`shopt -s inherit_errexit` (see below).

The **best practice** is to always assign command substitution to variable:

```bash
#!/bin/bash
set -o errexit
declare cmdOut
cmdOut=`exit 1`
echo "${cmdOut}"
echo $?
```

Outputs nothing because the script stopped before variable affectation, return
code is 1.

#### 1.1.2. pipefail (set -o pipefail)

> If set, the return value of a pipeline is the value of the last (rightmost)
> command to exit with a non-zero status, or zero if all commands in the
> pipeline exit successfully. This option is disabled by default.

It is complementary with errexit, as if it not activated, the failure of command
in pipe could hide the error.

**Eg**: without `pipefail` this command succeed

```bash
#!/bin/bash
set -o errexit
set +o pipefail # deactivate pipefail mode
foo | echo "a" # 'foo' is a non-existing command
# Output:
# a
# bash: foo: command not found
# echo $? # exit code is 0
# 0
```

#### 1.1.3. errtrace (set -E | set -o errtrace)

> If set, any trap on ERR is inherited by shell functions, command
> substitutions, and commands executed in a subShell environment. The ERR trap
> is normally not inherited in such cases.

#### 1.1.4. nounset (set -u | set -o nounset)

This is not implemented in current framework (TODO in future version).

> Treat unset variables and parameters other than the special parameters ‘@’ or
> ‘_’, or array variables subscripted with ‘@’ or ‘_’, as an error when
> performing parameter expansion. An error message will be written to the
> standard error, and a non-interactive shell will exit.

#### shopt -s inherit_errexit

set -e does not affect subShells created by Command Substitution. This rule is
stated in Command Execution Environment:

> subShells spawned to execute command substitutions inherit the value of the -e
> option from the parent shell. When not in POSIX mode, Bash clears the -e
> option in such subShells.

This rule means that the following script will run to completion, in spite of
INVALID_COMMAND.

```bash
#!/bin/bash
# command-substitution.sh
set -e
MY_VAR=$(echo -n Start; INVALID_COMMAND; echo -n End)
echo "MY_VAR is $MY_VAR"
```

Output:

```bash
./command-substitution.sh: line 4: INVALID_COMMAND: command not found
MY_VAR is StartEnd
```

shopt -s inherit_errexit, added in Bash 4.4 allows you to have command
substitution parameters inherit your set -e from the parent script.

From the Shopt Builtin documentation:

> If set, command substitution inherits the value of the errexit option, instead
> of unsetting it in the subShell environment. This option is enabled when POSIX
> mode is enabled.

So, modifying command-substitution.sh above, we get:

```bash
#!/bin/bash
# command-substitution-inherit_errexit.sh
set -e
shopt -s inherit_errexit
MY_VAR=$(echo -n Start; INVALID_COMMAND; echo -n End)
echo "MY_VAR is $MY_VAR"
```

Output:

```bash
./command-substitution-inherit_errexit.sh: line 5: INVALID_COMMAND: command not found
```

#### 1.1.5. posix (set -o posix)

This is not implemented in current framework (TODO in future version ? To check
if it is a good idea to implement it and what would be the impact).

> Change the behavior of Bash where the default operation differs from the POSIX
> standard to match the standard (see
> [Bash POSIX Mode](https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html)).
> This is intended to make Bash behave as a strict superset of that standard.

### 1.2. Arguments

- to construct complex command line, prefer to use an array
  - `declare -a cmd=(git push origin :${branch})`
  - then you can display the result using echo `"${cmd[*]}"`
  - you can execute the command using `"${cmd[@]}"`
- boolean arguments, to avoid seeing some calls like this `myFunction 0 1 0`
  with 3 boolean values. prefer to provide constants(using readonly) to make the
  call more clear like `myFunction arg1False arg2True arg3False` of course
  replacing argX with the real argument name. Eg:
  `Filters::directive "${FILTER_DIRECTIVE_REMOVE_HEADERS}"` You have to prefix
  all your constants to avoid conflicts.

### 1.3. some commands default options to use

- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html> but set -o
  nounset is not usable because empty array are considered unset
- always use `sed -E`
- avoid using grep -P as it is not supported on alpine, prefer using -E

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD033 -->

### 1.4. <a name="regularExpressions"></a>Bash and grep regular expressions

<!-- markdownlint-restore -->

- grep regular expression [A-Za-z] matches by default accentuated character, it
  you don't want to match them, use the environment variable `LC_ALL=POSIX`,
  - Eg: `LC_ALL=POSIX grep -E -q '^[A-Za-z_0-9:]+$'`
  - I added `export LC_ALL=POSIX` in all my headers, it can be overridden using
    a subShell

### 1.5. General tips

- `cat << 'EOF'` avoid to interpolate variables
- use `builtin cd` instead of `cd`, `builtin pwd` instead of `pwd`, ... to avoid
  using customized aliased commands by the user In this framework, I added the
  command `unalias -a || true` to remove all eventual aliases.
- use the right shebang, avoid `#!/bin/bash` as bash binary could be in another
  folder (especially on alpine), use this instead `#!/usr/bin/env bash`

### 1.6. Variables

#### 1.6.1. Variable declaration

- ensure we don't have any globals, all variables should be passed to the
  functions
- declare all variables as local in functions to avoid making them global
- local or declare multiple local a z
- `export readonly` does not work, first `readonly` then `export`

#### 1.6.2. variable naming convention

- env variable that aims to be exported should be capitalized with underscore
- local variables should conform to camelCase

#### 1.6.3. Variable expansion

`${PARAMETER:-WORD}` vs `${PARAMETER-WORD}`:

If the parameter PARAMETER is unset (was never defined) or null (empty),
`${PARAMETER:-WORD}` expands to WORD, otherwise it expands to the value of
PARAMETER, as if it just was ${PARAMETER}.

If you omit the `:`(colon) like in `${PARAMETER-WORD}`, the default value is
only used when the parameter is unset, not when it was empty.

#### 1.6.4. Check if a variable is defined

```bash
if [[ -z ${varName+xxx} ]]; then
  # varName is not set
fi
```

Alternatively you can use this framework function `Assert::varExistsAndNotEmpty`

#### 1.6.5. Variable default value

Always consider to set a default value to the variable that you are using.

**Eg.**: Let's see this dangerous example

```bash
# Don't Do that !!!!
rm -Rf "${TMPDIR}/etc" || true
```

This could end very badly if your script runs as root and if `${TMPDIR}` is not
set, this script will result to do a `rm -Rf /etc`

Instead you can do that

```bash
rm -Rf "${TMPDIR:-/tmp}/etc" || true
```

### 1.7. Capture output

You can use
[command substitution](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Command-Substitution).

Eg:

```bash
local output
output="$(functionThatOutputSomething "${arg1}")"
```

#### 1.7.1. Capture output and test result

```bash
local output
output="$(functionThatOutputSomething "${arg1}")" || {
  echo "error"
  exit 1
}
```

#### 1.7.2. Capture output and retrieve status code

It's advised to put it on the same line using `;`. If it was on 2 lines, other
commands could be put between the command and the status code retrieval, the
status would not be the same command status.

```bash
local output
output="$(functionThatOutputSomething "${arg1}")"; status=$?
```

### 1.8. Array

- read each line of a file to an array `readarray -t var < /path/to/filename`

### 1.9. Temporary directory

use `${TMPDIR:-/tmp}`, TMPDIR variable does not always exist. or when mktemp is
available, use `dirname $(mktemp -u --tmpdir)`

The variable TMPDIR is initialized in `src/_includes/_commonHeader.sh` used by
all the binaries used in this framework.

## 2. Bin file best practices

### 2.1. Bash-tpl best practice

To avoid shellcheck reporting errors about malformed script, try to always put
your variable replacements inside bash variable, so instead of doing:

```bash
<%% echo "${functionToCall}" %> "$@"
```

which results in shellcheck error, you can do this instead

```bash
# shellcheck disable=SC2016 # SC2016 needed because functionToCall inside quotes
#   is known when bash-tpl is interpreted but not inside the bash script being
# generated
functionToCall='<%% echo "${functionToCall}" %>'
"${functionToCall}" "$@"
```

## 3. Bats best practices

### 3.1. use of default temp directory created by bats

Instead of creating yourself your temp directory, you can use the special
variable `BATS_TEST_TMPDIR`, this directory is automatically destroyed at the
end of the test except if the option `--no-tempdir-cleanup` is provided to bats
command.

**Exception**: if you are testing bash traps, you would need to create your own
directories to avoid unexpected errors.

### 3.2. avoid boilerplate code

using this include, includes most of the features needed when using bats

```bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
```

It sets those bash features:

- set -o errexit
- set -o pipefail

It imports several common files like some additional bats features.

And makes several variables available:

- BASH_TOOLS_ROOT_DIR
- vendorDir
- srcDir
- FRAMEWORK_ROOT_DIR (same as BASH_TOOLS_ROOT_DIR but used by some bash
  framework functions)
- LC_ALL=POSIX see
  [Bash and grep regular expressions best practices](BestPractices.md#regularExpressions)

### 3.3. Override an environment variable when using bats run

```bash
SUDO="" run Apt::update
```

### 3.4. Override a bash framework function

using stub is not possible because it does not support executable with special
characters like `::`. So the solution is just to override the function inside
your test function without importing the original function of course. In
tearDown method do not forget to use `unset -f yourFunction`
