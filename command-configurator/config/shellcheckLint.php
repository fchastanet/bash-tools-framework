<?php

$defaultConfig = require(__DIR__."/default.php");

$options = array_merge(
  $defaultConfig['defaultCommandOptions'],
  [
    [
      'variableName' => 'optionFormat',
      'type' => 'String',
      'help' => 'define output format of this command',
      'alts' => ['--format', '-f',],
      "group" => "shellcheckLintOptionsFunction",
      'defaultValue' => 'tty',
      'authorizedValues' => ['checkstyle', 'diff', 'gcc', 'json', 'json1', 'quiet', 'tty',],
    ],
    [
      'variableName' => 'optionStaged',
      'functionName' => 'optionStagedFunction',
      'help' => 'lint only staged git files(files added to file list to be committed) and which are beginning with a bash shebang.',
      'alts' => ['--staged',],
    ],
    [
      'variableName' => 'optionXargs',
      'functionName' => 'optionXargsFunction',
      'type' => 'Boolean',
      'help' => 'uses parallelization(using xargs command) only if tty format',
      'alts' => ['--xargs',],
    ],
  ]
);

$shellcheckLintCommand = array_merge(
  $defaultConfig['defaultCommandConfig'],
  [
    'functionName' => 'shellcheckLintCommand',
    'commandName' => 'shellcheckLint',
    'version' => '1.0',
    'help' => 'Lint bash files using shellcheck.',
    'longDescription' => file_get_contents(__DIR__."/shellcheckLint.help"),
    'callbacks' => [
      'shellcheckLintParseCallback',
    ],
    'unknownOptionCallbacks' => [
      'unknownOption',
    ],
    'optionGroups' => [
      [
        'title' => 'GLOBAL OPTIONS:',
        'functionName' => 'zzzGroupGlobalOptionsFunction',
      ],
      [
        'title' => 'OPTIONS:',
        'functionName' => 'shellcheckLintOptionsFunction',
      ],
    ],
    'options' => $options,
    'args' => [
      [
        'variableName' => 'argShellcheckFiles',
        'functionName' => 'argShellcheckFilesFunction',
        'min' => 0,
        'max' => -1,
        'name' => 'shellcheckFiles',
        'callbacks' => ['argShellcheckFilesCallback',],
        'help' => file_get_contents(__DIR__."/shellcheckLint-argShellcheckFiles.help"),
      ],
    ],
  ]
);

return [
  'binFile' => [
    'targetFile' => '${FRAMEWORK_ROOT_DIR}/bin/shellcheckLint',
    'relativeRootDirBasedOnTargetDir' => '..',
    'templateFile' => 'binFile.gtpl',
    'templateName' => 'binFile',
    'srcDirs' => [
      '/home/wsl/fchastanet/bash-dev-env/vendor/bash-tools-framework/src',
    ],
    'templateDirs' => [
      "templates-examples",
    ],
  ],
  'binData' => [
    'commands' => [
      $shellcheckLintCommand,
    ],
  ],
];
