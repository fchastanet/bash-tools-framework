<?php

return [
  'binFileConfig' => [
    'commandDefinitionFiles' => [
      '${FRAMEWORK_ROOT_DIR}/src/_binaries/commandDefinitions/defaultOptions.sh'
    ]
  ],
  'defaultCommandConfig' => [
    'author' => '[François Chastanet](https://github.com/fchastanet)',
    'sourceFile' => '${REPOSITORY_URL}/tree/master/${SRC_FILE_PATH}',
    'license' => 'MIT License',
    'copyright' => 'copyrightCallback',
    'optionGroups' => [
      'zzzGroupGlobalOptionsGroup' => [
        'title' => 'GLOBAL OPTIONS:',
      ],
    ],
    'callbacks' => [
      'commandOptionParseFinished'
    ]
  ],
  'vars' => [
    'MAIN_FUNCTION_NAME' => 'main',
  ],
  'defaultCommandOptions' => [
    [
      'variableName' => 'optionHelp',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'Boolean',
      'help' => 'Displays this command help',
      'alts' => ['--help','-h',],
      'callbacks' => [
        'optionHelpCallback',
      ],
    ],
    [
      'variableName' => 'optionConfig',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'Boolean',
      'help' => 'Displays configuration',
      'alts' => ['--config',],
    ],
    [
      'variableName' => 'optionBashFrameworkConfig',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'String',
      'help' => 'Use alternate bash framework configuration.',
      'alts' => ['--bash-framework-config',],
      'callbacks' => [
        'optionBashFrameworkConfigCallback',
      ]
    ],
    [
      'variableName' => 'optionInfoVerbose',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'Boolean',
      'help' => 'Info level verbose mode (alias of --display-level INFO)',
      'alts' => ['--verbose', '-v'],
      'callbacks' => [
        'optionInfoVerboseCallback',
        'updateArgListInfoVerboseCallback'
      ]
    ],
    [
      'variableName' => 'optionDebugVerbose',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'Boolean',
      'help' => 'Debug level verbose mode (alias of --display-level DEBUG)',
      'alts' => ['-vv'],
      'callbacks' => [
        'optionDebugVerboseCallback',
        'updateArgListDebugVerboseCallback'
      ]
    ],
    [
      'variableName' => 'optionTraceVerbose',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'Boolean',
      'help' => 'Trace level verbose mode (alias of --display-level TRACE)',
      'alts' => ['-vvv'],
      'callbacks' => [
        'optionTraceVerboseCallback',
        'updateArgListTraceVerboseCallback'
      ]
    ],
    [
      'variableName' => 'optionEnvFiles',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'StringArray',
      'help' => 'Load the specified env file (deprecated, please use --bash-framework-config option instead)',
      'alts' => ['--env-file'],
      "max" => -1,
      'callbacks' => [
        'optionEnvFileCallback',
        'updateArgListEnvFileCallback'
      ]
    ],
    [
      'variableName' => 'optionLogLevel',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'String',
      'help' => 'Set log level',
      'alts' => ['--log-level'],
      'authorizedValues' => ["OFF", "ERR", "ERROR", "WARN", "WARNING", "INFO", "DEBUG", "TRACE",],
      'callbacks' => [
        'optionLogLevelCallback',
        'updateArgListLogLevelCallback'
      ]
    ],
    [
      'variableName' => 'optionLogFile',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'String',
      'help' => 'Set log file',
      'alts' => ['--log-file'],
      'callbacks' => [
        'optionLogFileCallback',
        'updateArgListLogFileCallback'
      ]
    ],
    [
      'variableName' => 'optionDisplayLevel',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'String',
      'help' => 'Set display level',
      'alts' => ['--display-level'],
      'authorizedValues' => ["OFF", "ERR", "ERROR", "WARN", "WARNING", "INFO", "DEBUG", "TRACE"],
      'callbacks' => [
        'optionDisplayLevelCallback',
        'updateArgListDisplayLevelCallback'
      ]
    ],
    [
      'variableName' => 'optionNoColor',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'Boolean',
      'help' => 'Produce monochrome output. alias of --theme noColor.',
      'alts' => ['--no-color'],
      'callbacks' => [
        'optionNoColorCallback',
        'updateArgListNoColorCallback'
      ]
    ],
    [
      'variableName' => 'optionTheme',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'String',
      'help' => 'Choose color theme - default-force means colors will be produced even if command is piped.',
      'alts' => ['--theme'],
      'defaultValue' => "default",
      'authorizedValues' => ["default", "default-force", "noColor"],
      'callbacks' => [
        'optionThemeCallback',
        'updateArgListThemeCallback'
      ]
    ],
    [
      'variableName' => 'optionVersion',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'Boolean',
      'help' => 'Print version information and quit.',
      'alts' => ['--version'],
      'callbacks' => [
        'optionVersionCallback',
      ]
    ],
    [
      'variableName' => 'optionQuiet',
      'group' => 'zzzGroupGlobalOptionsGroup',
      'type' => 'Boolean',
      'help' => "Quiet mode, doesn't display any output.",
      'alts' => ['--quiet', '-q'],
      'callbacks' => [
        'optionQuietCallback',
        'updateArgListQuietCallback'
      ]
    ],
  ],
];
