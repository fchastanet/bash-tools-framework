# Command generation

```bash
declare commandForm=<% Options::generateCommand \
  --help "Command help" \
  --version "version 1.0" \
  --author "author is me" \
  --command-name "myCommand" \
  --License "MIT License" \
  --copyright "Copyright" \
  --help-template "path/to/template.tpl" \
  option1
  option2
%>
```

**Description**

Generates a function that allows to manipulate a command and its options.

**Syntax**

```text
Usage:  Options::generateCommand [OPTIONS] [optionsVariablesReferences]

Options::generateCommand
  --help <String|Function>
  [--command-name <String|Function>]
  [--version <String|Function>]
  [--author <String|Function>]
  [--License <String|Function>]
  [--copyright <String|Function>]
  [--help-template <String>]
```

**Mandatory Options:**

`--help <String|Function>`

> provides command description help

**Options:**

`--command-name <String|Function>` _(optional)_

> provides the command name. By default the name of current command file without
> path

`--version <String|Function>` _(optional)_

> provides version section help. Section not generated if not provided.

`--author <String|Function>` _(optional)_

> provides author section help. Section not generated if not provided.

`--License <String|Function>` _(optional)_

> provides License section help Section not generated if not provided.

`--copyright <String|Function>` _(optional)_

> provides copyright section help Section not generated if not provided.

`--help-template <String>` _(optional)_

> if you want to override the default template used to generate the help

**Exit status:**

_Exit code 1_

> If function provided does not match any existing function in compiler srcDirs,
> the command fails with exit code 1. Bash framework Function naming convention
> are the only function supported in arguments.
