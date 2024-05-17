FROM dunglas/frankenphp:1.1.5-php8 as base

ARG UPDATE_DATE
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN \
  set -exo pipefail ;\
  apt-get update ;\
  apt-get upgrade -y ;\
  apt-get install -y -q --no-install-recommends \
    git \
    unzip \
  ;\
  install-php-extensions \
    opcache \
  ;\
  curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin --filename=composer \
  ;\
  apt-get clean autoclean ;\
  apt-get autoremove -y --allow-remove-essential ;\
  apt-get autoremove apt --autoremove -y --allow-remove-essential ;\rm -rf \
    /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
    /var/cache/apt/archives /usr/share/{doc,man,locale}
RUN chown www-data:www-data /app
USER www-data

ONBUILD ARG USER=www-data
ONBUILD USER root
# hadolint ignore=SC3010
ONBUILD RUN \
  if [[ "${USER}" != "www-data" ]]; then \
    useradd -M "${USER}" ;\
    # Remove default capability
    setcap -r /usr/local/bin/frankenphp ;\
    # Give write access to /data/caddy and /config/caddy
    chown -R "${USER}:${USER}" /data/caddy ;\
    chown -R "${USER}:${USER}" /config/caddy ;\
  fi
ONBUILD USER ${USER}

###################################################################################
# STAGE prepare-binary-env
###################################################################################
FROM base as prepare-binary-env

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

COPY --chown=www-data:www-data composer.* /app
RUN composer install

COPY --chown=www-data:www-data . /app
RUN \
  # Set proper environment variables
  echo APP_ENV=prod > .env.local ;\
  echo APP_DEBUG=0 >> .env.local ;\
  \
  # Remove the tests and other unneeded files to save space
  # Alternatively, add these files with the export-ignore attribute
  # in your .gitattributes file
  rm -Rf tests/ config-generated/ ;\
  \
  # Install the dependencies
  composer install --ignore-platform-reqs --no-dev -a ;\
  \
  # Optimize .env
  composer config --no-plugins allow-plugins.symfony/flex true ;\
  composer require symfony/flex ;\
  composer require symfony/dotenv ;\
  composer dump-env prod

###################################################################################
# STAGE build-bin-file
###################################################################################
FROM dunglas/frankenphp:static-builder-1.1 as build-bin-file

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

WORKDIR /go/src/app/dist/app
COPY --from=prepare-binary-env /app .

# Build the static binary
WORKDIR /go/src/app/
RUN EMBED=dist/app/ ./build-static.sh
