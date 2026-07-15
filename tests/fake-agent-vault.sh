#!/bin/sh
set -eu

if [ "$1" != "--root" ]; then
  echo "expected --root" >&2
  exit 2
fi
root=$2
command=$3
path=${4:-}
target=$root/$path

case "$command" in
  read)
    test -f "$target"
    cat "$target"
    ;;
  write)
    if [ -e "$target" ]; then
      echo "already exists: $path" >&2
      exit 1
    fi
    mkdir -p "$(dirname "$target")"
    cat >"$target"
    ;;
  *)
    echo "unsupported fake command: $command" >&2
    exit 2
    ;;
esac
