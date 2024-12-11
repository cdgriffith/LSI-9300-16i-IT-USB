#!/bin/sh

set -e

TAG="flasher_no_bios"
IMG="$TAG.img"


read -r -p "Do you agree to broadcom's personal use download agreement found at https://docs.broadcom.com/eula? [y/N] " response

case "$response" in [yY][eE][sS]|[yY])
      docker build --build-arg IMG="$IMG" --build-arg DISABLE_BIOS="1"  -t "$TAG" .
      container="$(docker create "$TAG" true)"
      docker cp "$container:/$IMG" .
      docker rm "$container"

      TAG="flasher_bios"
      IMG="$TAG.img"

      docker build --build-arg IMG="$IMG" -t "$TAG" .
      container="$(docker create "$TAG" true)"
      docker cp "$container:/$IMG" .
      docker rm "$container"

      TAG="list_only"
      IMG="$TAG.img"

      docker build --build-arg IMG="$IMG" --build-arg LIST_ONLY="1" -t "$TAG" .
      container="$(docker create "$TAG" true)"
      docker cp "$container:/$IMG" .
      docker rm "$container"
        ;;
    *)
        echo "Cannot run script without agreeing to personal use download agreement";
        ;;
esac

