# Compile Command

- [1. Why ?](#1-why-)
- [2. Compile tool](#2-compile-tool)
- [3.  compile command help](#3--compile-command-help)
  - [3.1. .framework-config environment variables](#31-framework-config-environment-variables)
  - [3.2. Template variables](#32-template-variables)
  - [3.3. Bash-tpl templating](#33-bash-tpl-templating)
  - [3.4. directives and template](#34-directives-and-template)
    - [3.4.1. `# FUNCTIONS` directive](#341--functions-directive)
    - [3.4.2. `META_*` directive (optional)](#342-meta_-directive-optional)
    - [3.4.3. `BIN_FILE` directive (optional)](#343-bin_file-directive-optional)
    - [3.4.4. Compiler - Embed::include](#344-compiler---embedinclude)
    - [3.4.5. `INCLUDE` directive (optional)](#345-include-directive-optional)
  - [3.5. `.framework-config` framework configuration file](#35-framework-config-framework-configuration-file)
- [4. FrameworkLint](#4-frameworklint)
- [5. Best practices](#5-best-practices)
- [6. Acknowledgements](#6-acknowledgements)

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
- bash functions reusability

The first requirement implies that we should somehow store the contents of other
files in our main script. The second requires us to avoid non-printable
characters, as they tend to cause problems when performing a copy-paste
operation. Especially when we are talking about sending such characters over
messaging programs.

## 2. Compile tool

This tool allows to detect all the framework functions used inside a given sh
file. The framework functions matches the pattern `namespace::functionName` (we
can have several namespaces separated by the characters `::`). These framework
functions will be injected inside a compiled file. The process is recursive so
that every framework functions used by imported framework functions will be
imported as well (of course only once).

You can see several examples of compiled files by checking
[src/\_binaries folder](src/_binaries). For example:

- `src/_binaries/frameworkLint.sh` generates the file `bin/frameworkLint`

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD033 -->

## 3. <a name="compileCommandHelp"></a> compile command help

<!-- markdownlint-restore -->

**Description:** inlines all the functions used in the script given in parameter

**Usage:**

```text
bin/compile` [-h|--help] prints this help and exits
```

**Usage:**

```text
bin/compile <fileToCompile>
            [--src-dir|-s <srcDir>]
            [--bin-dir|-b <binDir>] [--bin-file|-f <binFile>]
            [--root-dir|-r <rootDir>] [--src-path <srcPath>]
            [--template <templateName>] [--keep-temp-files|-k]
```

**Mandatory Arguments:**

- `<fileToCompile>` the relative or absolute path to compile into one file

**Options:**

- `--help,-h` prints this help and exits

- `--src-dir|-s <srcDir>` provide the directory where to find the functions
  source code. By default this project src directory is used.

  You can add as much --src-dir options as needed to define other source dirs.

  The functions will be searched in the order defined (it allows function
  redefinition)

  _Example:_ `--src-dir src --src-dir otherSrc`

  `Functions::myFunction` will be searched in

  - src/Functions/myFunction.sh
  - otherSrc/Functions/myFunction.sh

  **Important Note:** if you provide a `--src-dir` and you need also functions
  defined in this project, think about adding a `--src-dir` for this project
  too.

- `--bin-dir|-b <binDir>` allows to override the value of `BIN_DIR`. By default
  BIN_DIR is set to `bin` directory below the folder above `bin/compile`.

- `--bin-file|-f <binFile>` `BIN_FILE` directive will be overridden by `binFile`
  value

- `--template-dir|-t <templateDir>` the template directory used to override some
  template includes. Check environment variables below.

- `--root-dir|-r <rootDir>` if you whish to override `ROOT_DIR` variable
  (default value is the folder above `bin/compile`).

- `--src-path <path>` if you wish to override the filepath that will be
  displayed in the header to indicate the src filepath that has been compiled
  (`SRC_FILE_PATH`).

  By default, it is initialized with path relative to `ROOT_DIR`

- `--keep-temp-files|-k` keep temporary files for debug purpose

### 3.1. .framework-config environment variables

You can define global environment variables inside `.framework-config` file that
could be used in your templates.

_Example:_

- `REPOSITORY_URL`: used in template to indicate from which github repo the file
  has been generated

### 3.2. Template variables

Other variables are automatically generated to be used in your templates:

- `ORIGINAL_TEMPLATE_DIR` allowing you to include the template relative to the
  script being interpreted
- `TEMPLATE_DIR` the template directory in which you can override the templates
  defined in `ORIGINAL_TEMPLATE_DIR`
- `ROOT_DIR_RELATIVE_TO_BIN_DIR` is automatically computed from `BIN_FILE`
  directive. It allows to generate the framework root dir during runtime.

  `ROOT_DIR_RELATIVE_TO_BIN_DIR` has been kept for compatibility reason but
  prefer to use Embed feature instead.

The following variables depends upon parameters passed to this script:

- `SRC_FILE_PATH` the src file you want to show at the top of generated file to
  indicate from which source file the binary has been generated.
- `SRC_ABSOLUTE_PATH` is the path of the file being compiled, it can be useful
  if you need to access a path relative to this file during compilation.

### 3.3. Bash-tpl templating

Your compiled source file will be interpreted using bash-tpl
<https://github.com/TekWizely/bash-tpl>.

You can use this feature to inline external file, interpreting environment
variables during compilation, ...

_Example:_

inline a awk script inside the resulting binary:

```bash
awkScript="\$(
cat <<'AWK_EOF'
.INCLUDE "\$(cd "\$(dirname \${SRC_ABSOLUTE_PATH})" && pwd -P)/mysql2puml.awk"
AWK_EOF
)"
```

### 3.4. directives and template

You can use special optional directives in src file

- `BIN_FILE` directive
- `META_*` directive
- `INCLUDE` directive

One mandatory directive:

- `# FUNCTIONS` directive

Compile command allows to generate a binary file using some directives directly
inside the src file.

Eg:

```bash
#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/binaryExample
# META_SCRIPT=MinimumRequirements
# INCLUDE "Backup::file" as backupFile
# INCLUDE "${ROOT_DIR}/bin/otherNeededBinary" AS "otherNeededBinary"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

sudo "${embed_file_backupFile}" # ...
"${embed_file_otherNeededBinary}"
# ...
```

The above file header allows to generate the `bin/binaryExample` binary file. It
uses `INCLUDE` macro to allow the usage of `Backup::file` function as a binary
named backupFile that can even be called using `sudo`.

In previous example, the directive `# FUNCTIONS` is injected via the file
`_includes/_header.tpl`.

The srcFile should contains at least the directive `BIN_FILE` at top of the bash
script file (see example above).

#### 3.4.1. `# FUNCTIONS` directive

It is the most important directive as it will inform the compiler where
dependent framework functions will be injected in your resulting bash file.

#### 3.4.2. `META_*` directive (optional)

it is a directive variable used during compilation time (not during execution),
it can be used to generate binary files based generic template files.
[see specific usage in bash-dev-env project](https://github.com/fchastanet/bash-dev-env).

It's also possible to inject some variables specific to the binary file you are
generating and that will be used to interpret your templates.

_Example:_

Add this line to the beginning of the source file without breaking comment
section (no newlines between #)

```bash
#!/usr/bin/env bash
# META_SCRIPT=MinimumRequirements**
```

The variable SCRIPT can then be used in the template using

```bash
SCRIPT="<% ${SCRIPT} %>"
```

_Examples:_

Let's say you want to generate the binary file `bin/buildDoc` from the source
file `src/build/buildDoc.sh`

```bash
bin/compile "$(pwd)/src/_binaries/doc.sh" --src-dir "$(pwd)/src" \
  --bin-dir "$(pwd)/bin" --root-dir "$(pwd)"
```

Here you want to generate the binary but overriding some or all functions of
`vendor/bash-tools-framework/src` using `src` folder

```bash
bin/compile "$(pwd)/src/_binaries/doc.sh" --s "$(pwd)/src" \
  -s "$(pwd)/vendor/bash-tools-framework/src" --bin-dir "$(pwd)/bin" --root-dir "$(pwd)"
```

Here you want to override the default templates too

```bash
bin/compile "$(pwd)/src/_binaries/doc.sh" --s "$(pwd)/src" \
  -s "$(pwd)/vendor/bash-tools-framework/src" --bin-dir "$(pwd)/bin" \
  --root-dir "$(pwd)" --template-dir "$(pwd)/src/templates"
```

#### 3.4.3. `BIN_FILE` directive (optional)

allows to indicate where the resulting bin file will be generated if not
provided, the binary file will be copied to `binDir` without sh extension

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD033 -->

#### 3.4.4. <a name="embed_include" id="embed_include"></a>Compiler - Embed::include

<!-- markdownlint-restore -->

A new feature in the compiler is the ability to embed files, directories or a
framework function `Embed::include` allows to:

- include a file(binary or not) as md5 encoded, the file can then be extracted
  using the automatically generated method `Embed::extractFile_asName` where
  asName is the name chosen above the original file mode will be restored after
  extraction. The variable embed_file_asName contains the targeted filepath.
- include a directory, the directory will be tar gz and added to the compiled
  file as md5 encoded string. The directory can then be extracted using the
  automatically generated method `Embed::extractDir_asName` where asName is the
  name chosen above. The variable embed_dir_asName contains the targeted
  directory path.
- include a bash framework function, a special binary file that simply calls
  this function will be automatically generated. This binary file will be added
  to the compiled file as md5 encoded string and will be automatically extracted
  to temporary directory and is callable directly using `asName` chosen above
  because path of the temporary directory is in the PATH variable.

#### 3.4.5. `INCLUDE` directive (optional)

Allows to embed files, directories or a framework function. The following syntax
can be used:

_Syntax:_ `# INCLUDE "srcFile" AS "targetFile"`

_Syntax:_ `# INCLUDE "srcDir" AS "targetDir"`

_Syntax:_ `# INCLUDE namespace::functions AS "myFunction"`

if `INCLUDE` directive is provided, the file/dir provided will be added inside
the resulting bin file as a tar gz file(base64 encoded) and automatically
extracted when executed.

_`INCLUDE` directive usage example:_

```bash
#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/myBinary
# META_SCRIPT=MinimumRequirements
# INCLUDE "${ROOT_DIR}/bin/otherNeededBinary" AS "otherNeededBinary"
# INCLUDE Backup::file AS "backupFile"
sudo "${embed_file_backupFile}" ...
"${embed_file_otherNeededBinary}"
```

if `INCLUDE` directive is provided, the file/dir provided will be added inside
the resulting bin file as a tar gz file(base64 encoded) and automatically
extracted when executed.

See [compiler - Embed::include]#embed_include) above for more information.

### 3.5. `.framework-config` framework configuration file

The special file `.framework-config` allows to change some behaviors of the
compiler or the framework linter.

```bash
# describe the functions that will be skipped from being imported
FRAMEWORK_FUNCTIONS_IGNORE_REGEXP='^namespace::functions$|^Functions::myFunction$|^IMPORT::dir::file$|^Acquire::ForceIPv4$'
# describe the files that do not contain function to be imported
NON_FRAMEWORK_FILES_REGEXP="(.bats$|/testsData/|/_.sh$|/ZZZ.sh$|/__all.sh$|^src/_|^src/batsHeaders.sh$)"
# describe the files that are allowed to not have a function matching the filename
FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP="^bin/|^\.framework-config$|^build.sh$|^tests/|\.tpl$|testsData/binaryFile$"
# Source directories
FRAMEWORK_SRC_DIRS=()

# export here all the variables that will be used in your templates
# Use this when variables are common to most of your bin files
# You can alternatively use META directive to declare a constant
# specific to your bin file
export REPOSITORY_URL="https://github.com/fchastanet/bash-tools-framework"
```

## 4. FrameworkLint

Lint files of the current repository

- check if all namespace::functions are existing in the framework
- check that function defined in a .sh is correctly named
- check that each framework function has a bats file associated (warning if not)

This linter is used as one the precommit hooks, see
[.pre-commit-config.yaml](https://github.com/fchastanet/bash-tools-framework/blob/master/.pre-commit-config.yaml).

## 5. Best practices

`INCLUDE` keyword is really useful to inline configuration files. However to run
framework function using sudo, it is recommended to call the same binary but
passing options to change the behavior. This way the content of the script file
does not seem to be obfuscated.

## 6. Acknowledgements

I want to thank a lot Michał Zieliński(Tratif company) for this wonderful
article that helped me a lot in the conception of the file/dir/framework
function embedding feature.

for more information see
[Bash Tips #6 – Embedding Files In A Single Bash Script](https://blog.tratif.com/2023/02/17/bash-tips-6-embedding-files-in-a-single-bash-script/)
