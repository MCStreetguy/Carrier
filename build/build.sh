#!/bin/bash

set -e

if [ "$1" == "--no-publish" ]; then
  declare -r NOPUBLISH=true
  shift 1
elif [ "$1" == "--push-only" ]; then
  declare -r PUSHONLY=true
  shift 1
fi

declare -r TAG_NAME="mcstreetguy/carrier"

if [ "$#" -eq 1 ]; then
  declare -r ALPINE_VERSION="$1"

  if [ "$ALPINE_VERSION" == "latest" ]; then
    declare -r TAG_VERSION="latest"
  else
    declare -r TAG_VERSION="alpine-${ALPINE_VERSION}"
  fi

  if [ "$NOPUBLISH" ]; then
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" .
  elif [ "$PUSHONLY" ]; then
    docker push "${TAG_NAME}:${TAG_VERSION}"
  else
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" .
    docker push "${TAG_NAME}:${TAG_VERSION}"
  fi

  echo "Done." >&2
  exit 0
elif [ "$#" -ne 0 ]; then
  echo "ERROR! Wrong argument count!" >&2
  exit 1
fi

declare -ar ALPINE_VERSION_TARGETS=( "3.2" "3.3" "3.4" "3.5" "3.6" "3.7" "3.8" "3.9" "3.10" "3.11" "latest" )

for ALPINE_VERSION in "${ALPINE_VERSION_TARGETS[@]}"; do
  if [ "$ALPINE_VERSION" == "latest" ]; then
    declare TAG_VERSION="latest"
  else
    declare TAG_VERSION="alpine-${ALPINE_VERSION}"
  fi

  if [ "$NOPUBLISH" ]; then
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" .
  elif [ "$PUSHONLY" ]; then
    docker push "${TAG_NAME}:${TAG_VERSION}"
  else
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" .
    docker push "${TAG_NAME}:${TAG_VERSION}"
  fi

  unset TAG_VERSION
done

echo "Done." >&2
exit 0