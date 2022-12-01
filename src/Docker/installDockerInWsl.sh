#!/usr/bin/env bash

.INCLUDE lib/_header.tpl

# FUNCTIONS

.INCLUDE lib/_includes/executedAsRoot.sh

Log::displayInfo "install docker required packages"
Retry::default sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true
Retry::default sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2

Log::displayInfo "install docker apt source list"
source /etc/os-release

Retry::default curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | sudo apt-key add -

echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list

Retry::default sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true

Log::displayInfo "install docker"
Retry::default sudo apt-get install -y \
  containerd.io \
  docker-ce \
  docker-ce-cli

USERNAME="$(id -un)"
Log::displayInfo "allowing user '${USERNAME}' to use docker"
sudo getent group docker >/dev/null || sudo groupadd docker || true
sudo usermod -aG docker "${USERNAME}" || true

Log::displayInfo "Configure dockerd"
# see https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9
# see https://dev.solita.fi/2021/12/21/docker-on-wsl2-without-docker-desktop.html
DOCKER_DIR="/var/run/docker-data"
DOCKER_SOCK="${DOCKER_DIR}/docker.sock"
DOCKER_HOST="unix://${DOCKER_SOCK}"
export DOCKER_HOST
# shellcheck disable=SC2207
WSL_DISTRO_NAME="$(
  IFS='/'
  x=($(wslpath -m /))
  echo "${x[${#x[@]} - 1]}"
)"

if [[ -z "${WSL_DISTRO_NAME}" ]]; then
  Log::fatal "impossible to deduce distribution name"
fi

if [[ ! -d "${DOCKER_DIR}" ]]; then
  sudo mkdir -pm o=,ug=rwx "${DOCKER_DIR}" || exit 1
fi
sudo chgrp docker "${DOCKER_DIR}"
if [[ ! -d "/etc/docker" ]]; then
  sudo mkdir -p /etc/docker || exit 1
fi

# shellcheck disable=SC2174
if [[ ! -f "/etc/docker/daemon.json" ]]; then
  Log::displayInfo "Creating /etc/docker/daemon.json"
  LOCAL_DNS1="$(grep nameserver </etc/resolv.conf | cut -d ' ' -f 2)"
  LOCAL_DNS2="$(ip --json --family inet addr show eth0 | jq -re '.[].addr_info[].local')"
  (
    echo "{"
    echo "  \"hosts\": [\"${DOCKER_HOST}\"],"
    echo "  \"dns\": [\"${LOCAL_DNS1}\", \"${LOCAL_DNS2}\", \"8.8.8.8\", \"8.8.4.4\"]"
    echo "}"
  ) | sudo tee /etc/docker/daemon.json
fi

dockerIsStarted() {
  DOCKER_PS="$(docker ps 2>&1 || true)"
  [[ -S "${DOCKER_SOCK}" && ! "${DOCKER_PS}" =~ "Cannot connect to the Docker daemon" ]]
}
Log::displayInfo "Checking if docker is started ..."
if dockerIsStarted; then
  Log::displaySuccess "Docker connection success"
else
  Log::displayInfo "Starting docker ..."
  sudo rm -f "${DOCKER_SOCK}" || true
  wsl.exe -d "${WSL_DISTRO_NAME}" sh -c "nohup sudo -b dockerd < /dev/null > '${DOCKER_DIR}/dockerd.log' 2>&1"
  if ! dockerIsStarted; then
    Log::fatal "Unable to start docker"
  fi
fi

Log::displayInfo "Installing docker-compose v1"
[[ -f /usr/local/bin/docker-compose ]] && cp /usr/local/bin/docker-compose /tmp/docker-compose
upgradeGithubRelease \
  "docker/compose" \
  "/tmp/docker-compose" \
  "https://github.com/docker/compose/releases/download/v@latestVersion@/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" \
  defaultVersion

sudo mv /tmp/docker-compose /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

Log::displayInfo "Installing docker-compose v2"
# create the docker plugins directory if it doesn't exist yet
mkdir -p "${HOME}/.docker/cli-plugins"
sudo ln -sf /usr/local/bin/docker-compose "${HOME}/.docker/cli-plugins/docker-compose"

echo
UI::drawLine "-"
Log::displayInfo "docker executable path $(command -v docker)"
Log::displayInfo "docker version $(docker --version)"
Log::displayInfo "docker-compose version $(docker-compose --version)"

echo
if [[ "${SHELL}" = "/usr/bin/bash" ]]; then
  Log::displayInfo "Please add these lines at the end of your ~/.bashrc"
elif [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
  Log::displayInfo "Please add these lines at the end of your ~/.zshrc"
else
  Log::displayInfo "Please add these lines at the end of your shell entrypoint (${SHELL})"
fi
echo
echo "export DOCKER_HOST='${DOCKER_HOST}'"
echo "if [[ ! -S '${DOCKER_SOCK}' ]]; then"
echo "   sudo mkdir -pm o=,ug=rwx '${DOCKER_DIR}'"
echo "   sudo chgrp docker '${DOCKER_DIR}'"
echo "   /mnt/c/Windows/system32/wsl.exe -d '${WSL_DISTRO_NAME}' sh -c 'nohup sudo -b dockerd < /dev/null > \"${DOCKER_DIR}/dockerd.log\" 2>&1'"
echo "fi"
