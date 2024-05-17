FROM dunglas/frankenphp

ARG UPDATE_DATE
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]
RUN \
  set -exo pipefail ;\
  apt-get update ;\
  apt-get upgrade -y ;\
  apt-get install -y -q --no-install-recommends \
    git \
  ;\
  install-php-extensions \
    zip \
    opcache \
  ;\
  curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin --filename=composer \
  ;\
  apt-get clean autoclean ;\
  apt-get autoremove -y --allow-remove-essential ;\
  apt-get autoremove apt --autoremove -y --allow-remove-essential ;\
  rm -rf \
    /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
    /var/cache/apt/archives /usr/share/{doc,man,locale}/

RUN chown www-data:www-data /app
USER www-data

COPY --chown=www-data:www-data composer.* /app
RUN composer install

COPY --chown=www-data:www-data . /app

ONBUILD ARG USER=www-data
ONBUILD USER root
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
