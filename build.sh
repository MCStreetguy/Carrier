#!/bin/bash

set -e

declare -r TAG_NAME="mcstreetguy/carrier"

if [ "$#" -eq 1 ]; then
  declare -r ALPINE_VERSION="$1"

  if [ "$ALPINE_VERSION" == "latest" ]; then
    declare -r TAG_VERSION="latest"
  else
    declare -r TAG_VERSION="alpine-${ALPINE_VERSION}"
  fi

  echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..."

  docker build --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" .

  echo "Done."
  exit 0
elif [ "$#" -ne 0 ]; then
  echo "ERROR! Wrong argument count!"
  exit 1
fi

declare -ar ALPINE_VERSION_TARGETS=( "3.8" "3.9" "3.10" "3.11" "latest" )

for ALPINE_VERSION in "${ALPINE_VERSION_TARGETS[@]}"; do
  if [ "$ALPINE_VERSION" == "latest" ]; then
    declare TAG_VERSION="latest"
  else
    declare TAG_VERSION="alpine-${ALPINE_VERSION}"
  fi

  echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..."

  docker build --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" .
  docker push "${TAG_NAME}:${TAG_VERSION}"

  unset TAG_VERSION
done

echo "Done."
exit 0