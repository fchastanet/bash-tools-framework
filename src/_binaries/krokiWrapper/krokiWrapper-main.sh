#!/usr/bin/env bash
# @embed "${FRAMEWORK_ROOT_DIR}/src/_binaries/krokiWrapper/docker-compose.yml" AS krokiDockerCompose

# Server mode - manage Kroki Docker containers
# shellcheck disable=SC2154
if [[ -n "${optionServer}" ]]; then
  Docker::requireDockerCommand

  # Function to test API endpoint
  testApiEndpoint() {
    local apiName="$1"
    local serverStatus="$2"
    local serverUrl="$3"
    local diagramType="$4"
    local testDiagram="$5"
    local endpoint="${serverUrl}/${diagramType}/svg"

    printf "%*s ${apiName}:    " $((15 - ${#apiName}))
    if [[ "${serverStatus}" != "0" ]]; then
      echo -e "${__ERROR_COLOR}CONTAINER STOPPED${__RESET_COLOR}"
      return 1
    fi

    # Send test request with timeout
    local response
    response=$(curl -s -w "\n%{http_code}" --max-time 5 --data-raw "${testDiagram}" "${endpoint}" 2>/dev/null)
    local httpCode
    httpCode=$(echo "${response}" | tail -n1)

    # Accept both 200 (success) and 400 (bad request) as valid responses
    # 400 means the API is responding but our test diagram is invalid
    if [[ "${httpCode}" = "200" || "${httpCode}" = "400" ]]; then
      echo -e "${__SUCCESS_COLOR}RESPONDING${__RESET_COLOR} (${endpoint})"
    else
      echo -e "${__ERROR_COLOR}NOT RESPONDING${__RESET_COLOR} (${endpoint})"
      return 1
    fi
  }

  startServer() {
    Log::displayInfo "Starting Kroki server with Docker Compose..."

    # Set port via environment variable
    export KROKI_PORT="${optionServerPort:-8000}"

    # Pull images first
    Log::displayInfo "Pulling Docker images (this may take a while on first run)..."
    docker-compose -f "${embed_file_krokiDockerCompose}" pull

    # Start services in detached mode
    Log::displayInfo "Starting services..."

    if docker-compose -f "${embed_file_krokiDockerCompose}" up -d; then
      Log::displaySuccess "Kroki server started successfully"
      Log::displayInfo "Server URL: http://localhost:${KROKI_PORT}"
      Log::displayInfo "Services: Gateway, Mermaid, BPMN, Excalidraw"
      Log::displayInfo ""
      Log::displayInfo "To stop: ${SCRIPT_NAME} --server stop"
      Log::displayInfo "To check status: ${SCRIPT_NAME} --server status"
    else
      Log::displayError "Failed to start Kroki server"
      return 1
    fi
  }

  stopServer() {
    Log::displayInfo "Stopping Kroki server..."

    # Stop and remove containers using the embedded compose file
    if docker-compose -f "${embed_file_krokiDockerCompose}" down; then
      Log::displaySuccess "Kroki server stopped and containers removed"
    else
      Log::displayWarning "Some containers may still be running"
    fi
  }

  serviceStatus() {
    local serviceName="$1"
    local serviceLabel="$2"
    local status

    status=$(docker ps --filter "name=${serviceName}" --format 'table {{"{{"}}.Status{{"}}"}}' 2>/dev/null | tail -n +2)
    if [[ -n "${status}" ]]; then
      printf "%*s ${serviceLabel}:    ${__SUCCESS_COLOR}RUNNING${__RESET_COLOR} (${status})\n" $((15 - ${#serviceLabel}))
    else
      printf "%*s ${serviceLabel}:    ${__ERROR_COLOR}STOPPED${__RESET_COLOR}\n" $((15 - ${#serviceLabel}))
      return 1
    fi
  }

  serverStatus() {
    Log::displayInfo "Kroki server status:"
    echo ""

    # Display container status
    local gatewayStatus="0"
    local mermaidStatus="0"
    local bpmnStatus="0"
    local excalidrawStatus="0"

    serviceStatus "kroki-gateway" "Gateway" || gatewayStatus="$?"
    serviceStatus "kroki-mermaid" "Mermaid" || mermaidStatus="$?"
    serviceStatus "kroki-bpmn" "BPMN" || bpmnStatus="$?"
    serviceStatus "kroki-excalidraw" "Excalidraw" || excalidrawStatus="$?"

    echo ""

    # Test API endpoints if gateway is running
    if [[ "${gatewayStatus}" = "0" ]]; then
      Log::displayInfo "Testing API endpoints..."
      echo ""

      # Get port
      local port
      port=$(docker port kroki-gateway 8000 2>/dev/null | cut -d':' -f2 || true)
      if [[ -n "${port}" ]]; then
        echo -e "             API:    ${__SUCCESS_COLOR}RESPONDING${__RESET_COLOR} (http://localhost:${port})"
      else
        echo -e "             API:    ${__ERROR_COLOR}NOT RESPONDING${__RESET_COLOR}"
      fi
      local serverUrl="http://localhost:${port:-8000}"

      # Test main gateway with graphviz (simple and always available)
      testApiEndpoint "Gateway API" "${gatewayStatus}" "${serverUrl}" "graphviz" "digraph G {Test}" || true

      # Test mermaid endpoint
      testApiEndpoint "Mermaid API" "${mermaidStatus}" "${serverUrl}" "mermaid" "graph TD; A-->B" || true

      # Test BPMN endpoint
      testApiEndpoint "BPMN API" "${bpmnStatus}" "${serverUrl}" "bpmn" '<?xml version="1.0" encoding="UTF-8"?><definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"><process id="Process_1"/></definitions>' || true

      # Test Excalidraw endpoint
      testApiEndpoint "Excalidraw API" "${excalidrawStatus}" "${serverUrl}" "excalidraw" '{"type":"excalidraw","version":2,"elements":[]}' || true

      echo ""
      Log::displaySuccess "Server is ready at ${serverUrl}"
    else
      Log::displayWarning "Server is not running"
      Log::displayInfo "To start: ${SCRIPT_NAME} --server start"
    fi
  }

  case "${optionServer}" in
    start)
      startServer
      exit 0
      ;;

    stop)
      stopServer
      exit 0
      ;;

    status)
      serverStatus
      exit 0
      ;;

    *)
      Log::displayError "Invalid server option: ${optionServer}"
      Log::displayInfo "Valid options are: start, stop, status"
      exit 1
      ;;
  esac
fi

convert() {
  # Pass through convert command with all arguments
  # Don't use exec so we can show feedback after completion
  Log::displayInfo "Running kroki convert command"

  if "${KROKI_DIR:-${PERSISTENT_TMPDIR}/kroki}/kroki" "${krokiOptions[@]}" "${argKrokiWrapperFiles[@]}"; then
    Log::displaySuccess "kroki command completed successfully"
  else
    local exitCode=$?
    Log::displayError "kroki command failed with exit code ${exitCode}"
    return "${exitCode}"
  fi

  # Try to determine where the output file was created
  # Check for -o or --out-file in krokiOptions
  local outputFile=""
  local format="svg"
  local foundOutput=0
  local foundFormat=0

  for ((i = 1; i < ${#krokiOptions[@]}; i++)); do
    if [[ "${krokiOptions[i]}" =~ ^(-o|--out-file)$ ]] && ((i + 1 < ${#krokiOptions[@]})); then
      outputFile="${krokiOptions[i + 1]}"
      foundOutput=1
    elif [[ "${krokiOptions[i]}" =~ ^(-f|--format)$ ]] && ((i + 1 < ${#krokiOptions[@]})); then
      format="${krokiOptions[i + 1]}"
      foundFormat=1
    fi
  done

  # If no output file specified, kroki creates it based on input file
  if [[ "${foundOutput}" == "0" ]] && ((${#argKrokiWrapperFiles[@]} > 0)); then
    local inputFile="${argKrokiWrapperFiles[0]}"
    local baseName="${inputFile%.*}"
    outputFile="${baseName}.${format}"
  fi

  if ((foundFormat == 0)); then
    Log::displayWarning "Could not determine output format from options, defaulting to svg"
  fi

  if [[ -n "${outputFile}" && -f "${outputFile}" ]]; then
    Log::displaySuccess "Generated: ${outputFile}"
  else
    Log::displaySuccess "Conversion completed"
  fi
}

# Kroki subcommand passthrough - detect when user wants to run kroki subcommands directly
# shellcheck disable=SC2154
if ((${#krokiOptions[@]} > 0)); then
  case "${krokiOptions[0]}" in
    help | version | completion)
      # Pass through to kroki directly for these subcommands (no files needed)
      exec "${KROKI_DIR:-${PERSISTENT_TMPDIR}/kroki}/kroki" "${krokiOptions[@]}"
      ;;
    encode | decode)
      # Pass through encode/decode commands with file arguments
      exec "${KROKI_DIR:-${PERSISTENT_TMPDIR}/kroki}/kroki" "${krokiOptions[@]}" "${argKrokiWrapperFiles[@]}"
      ;;
    convert)
      convert || exit $?
      ;;
    *)
      Log::displayError "Unknown kroki subcommand: ${krokiOptions[0]}"
      Log::displayInfo "Supported subcommands are: help, version, completion, encode, decode, convert"
      exit 1
      ;;
  esac
fi

detectChangedAddedFiles() {
  git ls-files --exclude-standard --modified --others
}

declare -a files
# shellcheck disable=SC2154
if ((${#argKrokiWrapperFiles[@]} > 0)); then
  files=("${argKrokiWrapperFiles[@]}")
  if ((${#files[@]} == 0)); then
    Log::fatal "Command ${SCRIPT_NAME} - no file provided"
  fi
else
  changedFilesBefore=$(detectChangedAddedFiles)
  # Detect common diagram file extensions
  # Kroki supports: .plantuml, .puml, .iuml, .mmd, .dot, .gv, .ditaa, .erd, .nomnoml,
  # .pikchr, .svgbob, .umlet, .vega, .vegalite, .wavedrom, .excalidraw, .blockdiag,
  # .seqdiag, .actdiag, .nwdiag, .packetdiag, .rackdiag, .bpmn, .dmn, etc.
  readarray -t files < <(
    git ls-files --exclude-standard -c -o -m |
      grep -E -e '\.(plantuml|puml|iuml|mmd|dot|gv|ditaa|erd|nomnoml|pikchr|svgbob|bob|umlet|uxf|vega|vegalite|vl|wavedrom|excalidraw|blockdiag|seqdiag|actdiag|nwdiag|packetdiag|rackdiag|bpmn|dmn|d2)$' |
      sort | uniq
  )
  if ((${#files[@]} == 0)); then
    Log::displayInfo "Command ${SCRIPT_NAME} - no diagram file to process detected in git repository"
    exit 0
  fi
fi

Log::displayInfo "Will generate kroki output files for these files: ${files[*]}"
# shellcheck disable=SC2154
if [[ -z "${optionOutputFormat}" ]]; then
  optionOutputFormat="svg"
fi
Log::displayInfo "Output format: ${optionOutputFormat}"
if ((${#krokiOptions[@]} > 0)); then
  Log::displayInfo "with options: ${krokiOptions[*]}"
fi

# Process each file
for file in "${files[@]}"; do
  Log::displayInfo "Processing: ${file}"

  # Determine output file path
  declare outputFile
  declare baseFileName
  baseFileName="$(basename "${file}" | sed -E 's/\.[^.]+$//')"

  # shellcheck disable=SC2154
  if [[ "${sameDirectoryOption}" = "1" ]]; then
    declare fileDir
    fileDir="$(dirname "${file}")"
    outputFile="${fileDir}/${baseFileName}.${optionOutputFormat}"
  else
    outputFile="${optionOutputDir}/${baseFileName}.${optionOutputFormat}"
  fi

  # Convert using kroki-cli
  if "${KROKI_DIR:-${PERSISTENT_TMPDIR}/kroki}/kroki" convert \
    "${file}" \
    --format "${optionOutputFormat}" \
    --out-file "${outputFile}" \
    "${krokiOptions[@]}"; then
    Log::displaySuccess "Generated: ${outputFile}"
  else
    Log::displayError "Failed to convert: ${file}"
  fi
done

# shellcheck disable=SC2154
if [[ "${optionContinuousIntegrationMode}" = "1" ]] && ((${#argKrokiWrapperFiles[@]} == 0)); then
  changedFilesAfter=$(detectChangedAddedFiles)
  diff <(echo "${changedFilesBefore}") <(echo "${changedFilesAfter}") >&2 || {
    Log::fatal "CI mode - files have been added"
  }
fi
