#!/bin/bash

declare -r SERVICE_LIST_FILE="/var/run/carrier/conf.d/services.list"

if [ ! -f "$SERVICE_LIST_FILE" ] || [ -z "$(cat $SERVICE_LIST_FILE)" ]; then
  exit 0
fi

log () { echo "[carrier] $@"; }

while read -r line; do
  SERVICE_NAME="$(echo "$line" | cut -d ' ' -f 1 -)"
  SERVICE_HOST="$(echo "$line" | cut -d ' ' -f 2 -)"
  SERVICE_PORT="$(echo "$line" | cut -d ' ' -f 3 -)"

  if [ -z "$SERVICE_NAME" ] || [ -z "$SERVICE_HOST" ] || [ -z "$SERVICE_PORT" ]; then continue; fi

  TIMEOUT="$(echo "$line" | cut -d ' ' -f 4 -)"
  INTERVAL="$(echo "$line" | cut -d ' ' -f 5 -)"

  if [ -z "$TIMEOUT" ]; then
    TIMEOUT=60
  fi
  if [ -z "$INTERVAL" ]; then
    INTERVAL=3
  fi

  log "awaiting service '${SERVICE_NAME}' at '${SERVICE_HOST}:${SERVICE_PORT}'..."

  declare RETRIES=0
  until /usr/bin/nc -z -v -w30 "$SERVICE_HOST" "$SERVICE_PORT" &>/dev/null; do
    if [[ "$RETRIES" -gt "$TIMEOUT" ]]; then
      log "timeout exceeded, aborting!"
      exit 1
    fi

    log "service not ready yet, retrying in $INTERVAL seconds..."

    let 'RETRIES=RETRIES+1'
    sleep $INTERVAL
  done

  log "connection to service '${SERVICE_NAME}' at '${SERVICE_HOST}:${SERVICE_PORT}' succeeded."
done < "$SERVICE_LIST_FILE"

exit 0