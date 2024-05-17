<?php
require(__DIR__."/vendor/autoload.php");

use Monolog\Formatter\LineFormatter;
use Monolog\Handler\StreamHandler;
use Monolog\Logger;
use Symfony\Component\Yaml\Yaml;
use Opis\JsonSchema\{
  Validator,
  ValidationResult,
  Errors\ErrorFormatter,
};
use Opis\JsonSchema\Errors\ValidationError;
use Opis\JsonSchema\Exceptions\InvalidKeywordException;
use Opis\JsonSchema\Exceptions\ParseException;

const YAML_INDENTATION = 2;
const YAML_DUMP_LEVEL = PHP_INT_MAX;
const JSON_SCHEMA_ID = 'https://raw.githubusercontent.com/fchastanet/bash-tools-framework/master/command-configurator/schema/commands.schema.json';

function initLogger(): Logger {
  $logger = new Logger('app');
  $formatter = new LineFormatter("%level_name%: %message%\n");
  $streamHandler = new StreamHandler('php://output', Logger::DEBUG);
  $streamHandler->setFormatter($formatter);
  $logger->pushHandler($streamHandler);
  return $logger;
}

function initJsonSchemaValidator() {
  // Create a new validator
  $validator = new Validator();
  $validator->setMaxErrors(10);
  $validator->parser()
    //->setOption('defaultDraft', true)
    ->setOption('decodeContent', true)
    ->setOption('allowDefaults', true)
    ->setOption('allowKeywordsAlongsideRef', true)
    ->setOption('allowRelativeJsonPointerInRef', true)
  ;
  return $validator;
}

function getConfig(Logger $logger, string $configFile): array {
  $logger->info("Load config $configFile");
  return require($configFile);
}

function transformConfig(Logger $logger, array &$config): void {
  $logger->info("Transform config");
  // check if each option has type set
  if (is_array($config['binFile']['commands'])) {
    foreach($config['binFile']['commands'] as &$command) {
      if (is_array($command['options'])) {
        foreach($command['options'] as &$option) {
          if (!isset($option['type'])) {
            $option['type'] = 'Boolean';
          }
          if (!isset($option['callbacks'])) {
            $option['callbacks'] = [];
          }
        }
        unset($option);
      }
      if (is_array($command['args'])) {
        foreach($command['args'] as &$option) {
          if (!isset($option['callbacks'])) {
            $option['callbacks'] = [];
          }
        }
        unset($option);
      }
    }
    unset($command);
  }
}

function generateConfig(Logger $logger, string $configFile, array $config, string $targetConfigFile) {
  $value = Yaml::dump(
    $config,
    YAML_DUMP_LEVEL,
    YAML_INDENTATION,
    Yaml::DUMP_EMPTY_ARRAY_AS_SEQUENCE|Yaml::DUMP_MULTI_LINE_LITERAL_BLOCK
  );
  $logger->info("Generating $targetConfigFile from $configFile");
  file_put_contents($targetConfigFile, $value);
}

function formatJsonSchemaParseError(Logger $logger, ValidationError $validationError): void {
  $errorFormatter = new ErrorFormatter();

  $errors = $errorFormatter->format($validationError, 'verbose');
  foreach($errors as $path => $error) {
    $logger->error("Validation error at path '$path' : " . $error[0]);
  }
}

function validateJson($jsonValidator, array $config, object $jsonSchema): bool {
  $config = json_decode(json_encode($config));
  $result = $jsonValidator->validate($config, $jsonSchema);
  if (!$result->isValid()) {
    // Print errors
    formatJsonSchemaParseError($logger, $result->error());
    return false;
  }
  return true;
}

$logger = initLogger();
$configFile = __DIR__ . "/config/shellcheckLint.php";
$config = getConfig($logger, $configFile);
$intermediateConfigFile = __DIR__ . "/config-generated/shellcheckLint.beforeTransform.json";
file_put_contents(
  $intermediateConfigFile,
  json_encode($config, JSON_PRETTY_PRINT)
);
$logger->info("Written intermediate json file before transform $intermediateConfigFile");
transformConfig($logger, $config);

$jsonValidator = initJsonSchemaValidator();
$jsonSchema = json_decode(
  file_get_contents(__DIR__.'/schema/commands.schema.json')
);
if (!validateJson($jsonValidator, $config, $jsonSchema)) {
  exit(1);
}
try {
  generateConfig(
    $logger,
    $configFile,
    $config,
    __DIR__."/config-generated/shellcheckLint.yaml"
  );
} catch(ParseException $ex) {
  $schemaInfo = $ex->schemaInfo();

  $logger->error("Parse error in json schema" . $ex->getMessage() . " : ". json_encode($ex->schemaInfo()->data()));
}
