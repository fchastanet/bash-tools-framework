<?php
namespace CommandConfigurator\Transformers;

use CommandConfigurator\Exceptions\TransformException;
use Monolog\Logger;

class TransformConfigDefault {
  const PARAMETER_KIND_OPTION = "option";
  const PARAMETER_KIND_ARGUMENT = "argument";

  const PARAMETER_TYPE_BOOLEAN = "Boolean";
  const PARAMETER_TYPE_STRING = "String";
  const PARAMETER_TYPE_STRING_ARRAY = "StringArray";

  const CONTEXT_OPTION_GROUP_NAME = 'optionGroupName';
  const CONTEXT_COMMAND_INDEX = 'commandIndex';
  const CONTEXT_COMMAND_NAME = 'commandName';
  const CONTEXT_PARAMETER_KIND = 'parameterKind';
  const CONTEXT_PARAMETER_TYPE = 'parameterType';
  const CONTEXT_PARAMETER_INDEX = 'parameterIndex';
  const CONTEXT_PARAMETER_NAME = 'parameterName';

  private Logger $logger;

  private array $context;

  private array $optionGroups;
  private array $optionGroupFunctions;


  public function __construct(Logger $logger) {
    $this->logger = $logger;
    $this->context = [];
    $this->optionGroups = [];
    $this->optionGroupFunctions = [];
  }

  public function transformConfig(array &$config): void {
    $this->logger->info("Transform config");
    try {
      if (!is_array($config['binFile'])) {
        $this->transformError("binFile property is mandatory");
      }
      if (is_array($config['binData']['commands'])) {
        foreach($config['binData']['commands'] as $commandIndex => &$command) {
          $this->context[self::CONTEXT_COMMAND_INDEX] = $commandIndex;
          $this->transformCommand($command);
        }
        $this->context = [];
        unset($command);
      } else {
        $this->transformInfo("no command specified");
      }
    } catch(TransformException $ex) {
      $this->transformError($ex->getMessage());
      throw $ex;
    }
  }

  private function transformOptionGroup(array &$optionGroup, string $optionGroupName): void {
    // title
    if (empty($optionGroup['title'])) {
      $this->transformWarning("Option group set default empty title");
      $optionGroup['title'] = '';
    }
    $this->optionGroups[$optionGroupName] = $optionGroup;
  }

  private function transformCommand(array &$command): void {
    static $commandNames = [];
    static $functionNames = [];

    // command name
    if (empty($command['commandName'])) {
      throw new TransformException("command - property commandName is mandatory");
    }
    $commandName = $command['commandName'];
    if (isset($commandNames[$commandName])) {
      throw new TransformException("duplicated command commandName($commandName)");
    }
    $commandNames[$commandName] = true;
    $this->context[self::CONTEXT_COMMAND_NAME] = $commandName;

    if (is_array($command['optionGroups'])) {
      foreach($command['optionGroups'] as $optionGroupName => &$optionGroup) {
        $this->context[self::CONTEXT_OPTION_GROUP_NAME] = $optionGroupName;
        $this->transformOptionGroup($optionGroup, $optionGroupName);
      }
      $this->context = [];
      unset($optionGroup);
    } else {
      $command['optionGroups'] = [];
    }
    if (!isset($command['optionGroups']['__default'])) {
      $this->transformInfo('setting __default option group');
      $command['optionGroups']['__default'] = [
        'title' => 'DEFAULT OPTIONS:',
      ];
    }

    // function name
    $functionName = $command['functionName'];
    if (isset($functionNames[$functionName])) {
      throw new TransformException("duplicated command functionName($functionName)");
    }
    $functionNames[$functionName] = true;

    // version
    if (empty($command['version'])) {
      $defaultVersion = '1.0.0';
      $this->transformWarning("Command set default version $defaultVersion");
      $command['version'] = $defaultVersion;
    }

    // help
    if (empty($command['help'])) {
      $this->transformInfo("Command set default empty help");
      $command['help'] = '';
    }

    // longDescription
    if (empty($command['longDescription'])) {
      $this->transformInfo("Command set default empty longDescription");
      $command['longDescription'] = '';
    }

    // callbacks
    if (empty($command['callbacks'])) {
      $this->transformInfo("Command set default empty callbacks");
      $command['callbacks'] = [];
    }

    // unknownOptionCallbacks
    if (empty($command['unknownOptionCallbacks'])) {
      $this->transformInfo("Command set default empty unknownOptionCallbacks");
      $command['unknownOptionCallbacks'] = [];
    }

    // options
    if (is_array($command['options'])) {
      $this->transformOptions($command['options']);
      unset($this->context[self::CONTEXT_PARAMETER_TYPE]);
      unset($this->context[self::CONTEXT_PARAMETER_KIND]);
      unset($this->context[self::CONTEXT_PARAMETER_INDEX]);
      unset($this->context[self::CONTEXT_PARAMETER_NAME]);
    } else {
      $this->transformInfo("Command set default empty options");
      $command['options'] = [];
    }

    // arguments
    if (is_array($command['args'])) {
      $this->transformArgs($command['args']);
      unset($this->context[self::CONTEXT_PARAMETER_TYPE]);
      unset($this->context[self::CONTEXT_PARAMETER_KIND]);
      unset($this->context[self::CONTEXT_PARAMETER_INDEX]);
      unset($this->context[self::CONTEXT_PARAMETER_NAME]);
    } else {
      $this->transformInfo("Command set default empty args");
      $command['args'] = [];
    }
  }

  private function transformParameter(array &$parameter): void {
    if (empty($parameter['variableName'])) {
      throw new TransformException("Parameter - variableName property is mandatory");
    }
    $variableName = $parameter['variableName'];
    $this->context[self::CONTEXT_PARAMETER_NAME] = $parameter['variableName'];
    if (empty($parameter['functionName'])) {
      $defaultFunctionName = "{$variableName}Function";
      $this->transformInfo("Parameter - set default functionName $defaultFunctionName");
      $parameter['functionName'] = $defaultFunctionName;
    }
    if (
      isset($parameter['min'])
      && (
        !is_int($parameter['min']) ||
        $parameter['min'] < 0
      )
    ) {
      throw new TransformException("Parameter - min property should be an int >= 0");
    }
    if (
      isset($parameter['max'])
      && (
        !is_int($parameter['max']) ||
        $parameter['max'] === 0 ||
        $parameter['max'] < -1
      )
    ) {
      throw new TransformException("Parameter - max property should be an int > 0 or -1");
    }
    if (isset($parameter['type'])) {
      if (!in_array($parameter['type'], [
        self::PARAMETER_TYPE_BOOLEAN,
        self::PARAMETER_TYPE_STRING,
        self::PARAMETER_TYPE_STRING_ARRAY,
      ])) {
        $invalidType = $parameter['type'];
        throw new TransformException("Parameter - invalid type property provided($invalidType)");
      }
    } else {
      if (isset($parameter['max']) && ($parameter['max'] > 1 || $parameter['max'] === -1)) {
        $defaultType = self::PARAMETER_TYPE_STRING_ARRAY;
        $max = $parameter['max'];
        $this->transformWarning("Parameter - due to max property with value {$max}, type {$defaultType} is implied");
      } else if (
        isset($parameter['max']) && isset($parameter['min']) &&
        $parameter['max'] === 1 && $parameter['min'] === 1
      ) {
        $defaultType = self::PARAMETER_TYPE_STRING;
        $this->transformWarning("Parameter - as min and max equals one, property type {$defaultType} implied");
      } else if ($this->context[self::CONTEXT_PARAMETER_KIND] === self::PARAMETER_KIND_ARGUMENT) {
        $defaultType = self::PARAMETER_TYPE_STRING;
        $this->transformWarning("Parameter - as argument, property type {$defaultType} implied");
      } else {
        $defaultType = self::PARAMETER_TYPE_BOOLEAN;
        $this->transformWarning("Parameter - property type use default {$defaultType}");
      }
      $parameter['type'] = $defaultType;
    }
    $this->context[self::CONTEXT_PARAMETER_TYPE] = $parameter['type'];

    if (!isset($parameter['min'])) {
      $defaultMin = 0;
      if (isset($parameter['mandatory']) && $parameter['mandatory']) {
        $defaultMin = 1;
        $this->transformWarning("Parameter - property min not provided, use default $defaultMin as mandatory parameter");
      } else {
        if ($this->context[self::CONTEXT_PARAMETER_KIND] === self::PARAMETER_KIND_ARGUMENT) {
          $defaultMin = 1;
          $this->transformWarning("Argument - property min not provided, use default $defaultMin");
        } else {
          $this->transformWarning("Option - property min not provided, use default $defaultMin as optional");
        }
      }
      $parameter['min'] = $defaultMin;
    }
    if (!isset($parameter['max'])) {
      $defaultMax = ($parameter['type'] === self::PARAMETER_TYPE_STRING_ARRAY) ? -1 : 1;
      $parameter['max'] = $defaultMax;
      $this->transformWarning("Parameter - property max not provided, use default $defaultMax");
    }
    // callbacks
    if (empty($parameter['callbacks'])) {
      $this->transformInfo("parameter set default empty callbacks");
      $parameter['callbacks'] = [];
    }
    // help
    if (empty($parameter['help'])) {
      $this->transformInfo("Parameter set default empty help");
      $parameter['help'] = '';
    }
    if ($parameter['type'] === self::PARAMETER_TYPE_BOOLEAN) {
      $parameter['regexp'] = null;
      $parameter['authorizedValues'] = null;
      $parameter['authorizedValuesList'] = null;
      if (empty($parameter['onValue'])) {
        $this->transformInfo("parameter set default onValue property to 1");
        $parameter['onValue'] = 1;
      }
      if (empty($parameter['offValue'])) {
        $this->transformInfo("parameter set default offValue property to 0");
        $parameter['offValue'] = 0;
      }
      if ($parameter['offValue'] === $parameter['onValue']) {
        throw new TransformException("Parameter type boolean, offValue should be different than onValue");
      }
      $parameter['defaultValue'] = $parameter['offValue'];
    } else if ($parameter['type'] === self::PARAMETER_TYPE_STRING) {
      if ($parameter['min'] > 1) {
        throw new TransformException("Parameter type string, min property cannot be greater than 1");
      }
      if (!isset($parameter['defaultValue'])) {
        $parameter['defaultValue'] = '';
        $this->transformWarning("Parameter - property defaultValue set to empty string");
      }
    } else if ($parameter['type'] === self::PARAMETER_TYPE_STRING_ARRAY) {
      if (!isset($parameter['defaultValue'])) {
        $parameter['defaultValue'] = null;
      }
    }
    if (
      $parameter['type'] === self::PARAMETER_TYPE_STRING ||
      $parameter['type'] === self::PARAMETER_TYPE_STRING_ARRAY
    ) {
      if ($this->context[self::CONTEXT_PARAMETER_KIND] === self::PARAMETER_KIND_OPTION) {
        $parameter['onValue'] = null;
        $parameter['offValue'] = null;
      }
      // regexp
      if (empty($parameter['regexp'])) {
        $parameter['regexp'] = null;
      } else {
        $regexp = $parameter['regexp'];
        if (preg_match("/{$regexp}/", '', $matches) === false) {
          throw new TransformException("Parameter - property regexp($regexp) is not a valid regular expression");
        }
      }
      // authorizedValues
      if (isset($parameter['authorizedValues'])) {
        if (!is_array($parameter['authorizedValues'])) {
          throw new TransformException("Parameter - property authorizedValues should be an array");
        }
        $parameter['authorizedValuesList'] = [];
        foreach($parameter['authorizedValues'] as &$authorizedValue) {
          if (empty($authorizedValue)) {
            throw new TransformException("Parameter - property authorizedValues - empty value is not valid");
          }
          if (is_string($authorizedValue)) {
            $authorizedValue = [
              "value" => $authorizedValue,
              "help" => $authorizedValue,
            ];
          }
          $parameter['authorizedValuesList'][] = $authorizedValue['value'];
        }
        unset($authorizedValue);
      } else {
        $parameter['authorizedValues'] = null;
        $parameter['authorizedValuesList'] = null;
      }
    }
    if ($parameter['max'] !== -1 && $parameter['min'] > $parameter['max']) {
      throw new TransformException("Parameter min property cannot be greater than max property");
    }
  }

  private function transformOptions(array &$options): void {
    foreach($options as $optionIndex => &$option) {
      $this->context[self::CONTEXT_PARAMETER_KIND] = self::PARAMETER_KIND_OPTION;
      $this->context[self::CONTEXT_PARAMETER_INDEX] = $optionIndex;
      $this->transformParameter($option);
      if (!isset($option['alts'])) {
        throw new TransformException("Option - you must provide alts property");
      }

      if (!isset($option['group'])) {
        $defaultGroupFunctionName = $this->optionGroups[0]['functionName'];
        if (isset($this->optionGroups[1]['functionName'])) {
          $defaultGroupFunctionName = $this->optionGroups[1]['functionName'];
        }
        $option['group'] = $defaultGroupFunctionName;
        $this->transformInfo("Option - property group set to first group available $defaultGroupFunctionName");
      } else {
        $groupFunction = $option['group'];
        if (!isset($this->optionGroups[$groupFunction])) {
          throw new TransformException("Option - group function $groupFunction does not exist");
        }
      }
      if (
        $option['type'] === self::PARAMETER_TYPE_STRING ||
        $option['type'] === self::PARAMETER_TYPE_STRING_ARRAY
      ) {
        if (!isset($option['helpValueName'])) {
          $option['helpValueName'] = isset($option['alts'][0]) ? ltrim($option['alts'][0], '-') : '';
          $this->transformWarning("Option - property helpValueName set to empty string");
        }
      }
    }
    unset($option);
  }

  private function transformArgs(array &$args): void {
    foreach($args as $argIndex => &$arg) {
      $this->context[self::CONTEXT_PARAMETER_KIND] = self::PARAMETER_KIND_ARGUMENT;
      $this->context[self::CONTEXT_PARAMETER_INDEX] = $argIndex;
      $this->transformParameter($arg);
      if (!isset($arg['name'])) {
        $defaultName = $arg['variableName'];
        $arg['name'] = $defaultName;
        $this->transformWarning("Argument - property name set to default value $defaultName");
      }
    }
    unset($arg);
  }

  private function transformWarning(string $message): void {
    $this->logger->warning("$message, context ".json_encode($this->context));
  }

  private function transformInfo(string $message): void {
    $this->logger->info("$message, context ".json_encode($this->context));
  }

  private function transformError(string $message): void {
    $this->logger->error("$message, context ".json_encode($this->context));
  }
}
