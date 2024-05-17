<?php

$defaultCommandConfig = require(__DIR__."/default.php");

$shellcheckLintCommand = array_merge(
  $defaultCommandConfig,
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
    ],
    'options' => [
      [
        'variableName' => 'optionFormat',
        'type' => 'String',
        'help' => 'define output format of this command',
        'alts' => ['--format', '-f',],
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
    ],
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
    'commands' => [
      $shellcheckLintCommand,
    ],
  ],
];
