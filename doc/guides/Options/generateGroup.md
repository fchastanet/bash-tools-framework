# Option group generation

```bash
declare optionGroup=<% Options::generateGroup \
  --title "Command global options" \
  --help "The Console component adds some predefined options to all commands:"
%>
```

**Description**

Generates a function that allows to manipulate an option group.

**Syntax**

```text
Usage:  Options::generateGroup [OPTIONS]

Options::generateOption
  --help <String|Function>
  --title <String|Function>
```

**Mandatory Options:**

`--title <String|Function>`

> provides the variable name that will be used to store the parsed options.

**Options:**

`--help <String|Function>`

> provides option description help.

**Exit status:**

_Exit code 1_

> If function provided does not match any existing function in compiler srcDirs,
> the command fails with exit code 1. Bash framework Function naming convention
> are the only function supported in arguments.
