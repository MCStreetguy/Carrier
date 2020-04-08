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
  declare -r UBUNTU_VERSION="$1"

  if [ "$UBUNTU_VERSION" == "latest" ]; then
    declare -r TAG_VERSION="latest"
  else
    declare -r TAG_VERSION="ubuntu-${UBUNTU_VERSION}"
  fi

  if [ "$NOPUBLISH" ]; then
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --file build/ubuntu/Dockerfile --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "UBUNTU_VERSION=${UBUNTU_VERSION}" .
  elif [ "$PUSHONLY" ]; then
    docker push "${TAG_NAME}:${TAG_VERSION}"
  else
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --file build/ubuntu/Dockerfile --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "UBUNTU_VERSION=${UBUNTU_VERSION}" .
    docker push "${TAG_NAME}:${TAG_VERSION}"
  fi

  echo "Done." >&2
  exit 0
elif [ "$#" -ne 0 ]; then
  echo "ERROR! Wrong argument count!" >&2
  exit 1
fi

declare -ar UBUNTU_VERSION_TARGETS=( "14.04" "16.04" "18.04" "latest" )

for UBUNTU_VERSION in "${UBUNTU_VERSION_TARGETS[@]}"; do
  if [ "$UBUNTU_VERSION" == "latest" ]; then
    declare TAG_VERSION="latest"
  else
    declare TAG_VERSION="ubuntu-${UBUNTU_VERSION}"
  fi

  if [ "$NOPUBLISH" ]; then
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --file build/ubuntu/Dockerfile --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "UBUNTU_VERSION=${UBUNTU_VERSION}" .
  elif [ "$PUSHONLY" ]; then
    docker push "${TAG_NAME}:${TAG_VERSION}"
  else
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --file build/ubuntu/Dockerfile --compress --force-rm --pull --tag "${TAG_NAME}:${TAG_VERSION}" --build-arg "UBUNTU_VERSION=${UBUNTU_VERSION}" .
    docker push "${TAG_NAME}:${TAG_VERSION}"
  fi

  unset TAG_VERSION
done

echo "Done." >&2
exit 0