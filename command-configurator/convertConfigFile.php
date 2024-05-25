<?php
require(__DIR__."/vendor/autoload.php");

use Monolog\Formatter\LineFormatter;
use Monolog\Handler\StreamHandler;
use Monolog\Logger;
use Symfony\Component\Yaml\Yaml;
use Opis\JsonSchema\{
  Validator,
  Errors\ErrorFormatter,
};
use Opis\JsonSchema\Errors\ValidationError;
use Opis\JsonSchema\Exceptions\ParseException;
use CommandConfigurator\Transformers\TransformConfigDefault;

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

function validateJson(Logger $logger, $jsonValidator, array $config, object $jsonSchema): bool {
  $config = json_decode(json_encode($config));
  $result = $jsonValidator->validate($config, $jsonSchema);
  if (!$result->isValid()) {
    // Print errors
    formatJsonSchemaParseError($logger, $result->error());
    return false;
  }
  return true;
}

function generateJsonSchema(Logger $logger) {
  $base = loadJsonFile($logger, __DIR__ . "/src/jsonSchema/commands.schema.template.json");
  $args = loadJsonFile($logger, __DIR__ . "/src/jsonSchema/args.json");
  $binFile = loadJsonFile($logger, __DIR__ . "/src/jsonSchema/binFile.json");
  $commands = loadJsonFile($logger, __DIR__ . "/src/jsonSchema/commands.json");
  $options = loadJsonFile($logger, __DIR__ . "/src/jsonSchema/options.json");
  $parameter = loadJsonFile($logger, __DIR__ . "/src/jsonSchema/parameter.json");
  $base['properties']['binFile'] = $binFile;
  $base['properties']['binData']['properties']['commands'] = $commands;
  $base['properties']['binData']['properties']['commands']['items']['properties']['options']['items'] = array_merge_recursive(
    $parameter, $options
  );
  $base['properties']['binData']['properties']['commands']['items']['properties']['args']['items'] = array_merge_recursive(
    $parameter, $args
  );
  file_put_contents(
    __DIR__ . '/src/commands.schema.json',
    json_encode($base, JSON_PRETTY_PRINT)
  );
}

function loadJsonFile(Logger $logger, string $file) {
  $logger->debug("Loading $file");
  return json_decode(file_get_contents($file), true);
}

$logger = initLogger();
$configFile = __DIR__ . "/config/shellcheckLint.php";
$config = getConfig($logger, $configFile);
print_r(
  $config);
$intermediateConfigFile = __DIR__ . "/config-generated/shellcheckLint.beforeTransform.json";
file_put_contents(
  $intermediateConfigFile,
  json_encode($config, JSON_PRETTY_PRINT)
);
$logger->info("Written intermediate json file before transform $intermediateConfigFile");

$intermediateConfigFile = __DIR__ . "/config-generated/shellcheckLint.afterTransform.json";
$transformConfig = new TransformConfigDefault($logger);
$transformConfig->transformConfig($config);
file_put_contents(
  $intermediateConfigFile,
  json_encode($config, JSON_PRETTY_PRINT)
);
$logger->info("Written intermediate json file after transform $intermediateConfigFile");

generateJsonSchema($logger);
$jsonValidator = initJsonSchemaValidator();
$jsonSchema = json_decode(
  file_get_contents(__DIR__.'/src/commands.schema.json')
);
if (!validateJson($logger, $jsonValidator, $config, $jsonSchema)) {
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
