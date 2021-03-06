#!/bin/bash

s6-echo "[carrier-init] dumping container environment..."

declare -r CONTENV_DIR="/var/run/carrier/environment"
declare -ar _SYSTEM_ENV=(\
  "HOME" \
  "HOSTNAME" \
  "PATH" \
  "PWD" \
  "SHLVL" \
)

if [ ! -d "$CONTENV_DIR" ]; then
  s6-mkdir -p "$CONTENV_DIR"
fi

for ENV in "${_SYSTEM_ENV[@]}"; do
  if [ -n "$ENV" ]; then
    echo -nE "${!ENV}" > "${CONTENV_DIR}/${ENV}"
  fi
done

if [ -n "$KEEP_ENV" ]; then
  for ENV in $KEEP_ENV; do
    if [ -n "$ENV" ]; then
      echo -nE "${!ENV}" > "${CONTENV_DIR}/${ENV}"
    fi
  done
fi

exit 0
