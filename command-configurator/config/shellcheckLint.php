<?php

$defaultConfig = require(__DIR__."/default.php");

$options = array_merge(
  [
    [
      'variableName' => 'optionFormat',
      'type' => 'String',
      'help' => 'define output format of this command',
      'alts' => ['--format', '-f',],
      "group" => "shellcheckLintOptionGroup",
      'defaultValue' => 'tty',
      'authorizedValues' => ['checkstyle', 'diff', 'gcc', 'json', 'json1', 'quiet', 'tty',],
    ],
    [
      'variableName' => 'optionStaged',
      'functionName' => 'optionStagedFunction',
      "group" => "shellcheckLintOptionGroup",
      'help' => 'lint only staged git files(files added to file list to be committed) and which are beginning with a bash shebang.',
      'alts' => ['--staged',],
    ],
    [
      'variableName' => 'optionXargs',
      'functionName' => 'optionXargsFunction',
      'type' => 'Boolean',
      "group" => "shellcheckLintOptionGroup",
      'help' => 'uses parallelization(using xargs command) only if tty format',
      'alts' => ['--xargs',],
    ],
  ],
  $defaultConfig['defaultCommandOptions'],
);

$shellcheckLintCommand = array_merge_recursive(
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
      'shellcheckLintOptionGroup' => [
        'title' => 'OPTIONS:',
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
        'help' => file_get_contents(__DIR__.'/shellcheckLint-argShellcheckFiles.help'),
      ],
    ],
  ]
);

return [
  'binFile' => array_merge_recursive(
    $defaultConfig['binFileConfig'],
    [
      'targetFile' => '${FRAMEWORK_ROOT_DIR}/bin/shellcheckLint',
      'relativeRootDirBasedOnTargetDir' => '..',
      'templateFile' => 'binFile.gtpl',
      'templateName' => 'binFile',
      'srcDirs' => [
        '${FRAMEWORK_ROOT_DIR}/src',
      ],
      'commandDefinitionFiles' => [
        '${FRAMEWORK_ROOT_DIR}/src/_binaries/commandDefinitions/shellcheckLint.sh'
      ],
      'templateDirs' => [
        "templates-examples",
      ],
    ],
  ),
  'vars' => array_merge_recursive(
    $defaultConfig['vars'],
    []
  ),
  'binData' => [
    'commands' => [
      $shellcheckLintCommand,
    ],
  ],
];
