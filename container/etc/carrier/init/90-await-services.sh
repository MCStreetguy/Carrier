#!/bin/bash

declare -r SERVICE_LIST_FILE="/var/run/carrier/conf.d/services.list"

if [ ! -f "$SERVICE_LIST_FILE" ] || [ -z "$(cat $SERVICE_LIST_FILE)" ]; then
  exit 0
fi

log () { s6-echo "[await-services] $@"; }

while IFS= read -r line || [ -n "$LINE" ]; do
  if [ -z "$line" ]; then continue; fi

  SERVICE_NAME="$(echo "$line" | cut -d ' ' -f 1 -)"
  SERVICE_HOST="$(echo "$line" | cut -d ' ' -f 2 -)"
  SERVICE_PORT="$(echo "$line" | cut -d ' ' -f 3 -)"

  if [ -z "$SERVICE_NAME" ] || [ -z "$SERVICE_HOST" ] || [ -z "$SERVICE_PORT" ]; then continue; fi

  if [[ "$SERVICE_NAME" =~ ^\$ ]]; then
    SERVICE_NAME="${SERVICE_NAME:1}"

    if [ ! -v "${SERVICE_NAME}" ] || [ -z "${!SERVICE_NAME}" ]; then
      log "WARN: invalid variable encountered: ${SERVICE_NAME}! Skipping..."
      continue
    fi

    eval SERVICE_NAME=${!SERVICE_NAME}
  fi

  if [[ "$SERVICE_HOST" =~ ^\$ ]]; then
    SERVICE_HOST="${SERVICE_HOST:1}"

    if [ ! -v "${SERVICE_HOST}" ] || [ -z "${!SERVICE_HOST}" ]; then
      log "WARN: invalid variable encountered: ${SERVICE_HOST}! Skipping service ${SERVICE_NAME}..."
      continue
    fi

    eval SERVICE_HOST=${!SERVICE_HOST}
  fi

  if [[ "$SERVICE_PORT" =~ ^\$ ]]; then
    SERVICE_PORT="${SERVICE_PORT:1}"
    
    if [ ! -v "${SERVICE_PORT}" ] || [ -z "${!SERVICE_PORT}" ]; then
      log "WARN: invalid variable encountered: ${SERVICE_PORT}! Skipping service ${SERVICE_NAME}..."
      continue
    fi

    eval SERVICE_PORT=${!SERVICE_PORT}
  fi

  TIMEOUT="$(echo "$line" | cut -d ' ' -f 4 -)"
  INTERVAL="$(echo "$line" | cut -d ' ' -f 5 -)"

  if [ -z "$TIMEOUT" ]; then
    TIMEOUT=60
  elif [ "$TIMEOUT" == 0 ]; then
    TIMEOUT=99999
  fi

  if [ -z "$INTERVAL" ] || [ "$INTERVAL" -eq 0 ]; then
    INTERVAL=3
  fi

  log "awaiting service '${SERVICE_NAME}' at '${SERVICE_HOST}:${SERVICE_PORT}'..."

  declare RETRIES=0
  until /usr/bin/nc -z -v -w30 "$SERVICE_HOST" "$SERVICE_PORT" &>/dev/null; do
    if [[ "$RETRIES" -gt "$TIMEOUT" ]]; then
      log "timeout exceeded, aborting!"
      exit 1
    fi

    log "'${SERVICE_NAME}' not ready yet, retrying in $INTERVAL seconds..."

    let 'RETRIES=RETRIES+1'
    sleep $INTERVAL
  done

  log "connection to service '${SERVICE_NAME}' at '${SERVICE_HOST}:${SERVICE_PORT}' succeeded."
done < "$SERVICE_LIST_FILE"

exit 0