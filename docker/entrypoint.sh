#!/bin/sh
set -eu

CONFIG_PATH="${CONFIG_PATH:-/app/config/config.yaml}"

mkdir -p "$(dirname "${CONFIG_PATH}")" /app/data /app/logs

if [ ! -f "${CONFIG_PATH}" ]; then
  cat >"${CONFIG_PATH}" <<'CFG'
server:
  port: ":7575"

web:
  username: "admin"
  password: "admin"
CFG
fi

if [ "$#" -eq 0 ]; then
  exec /app/bin/vohive -c "${CONFIG_PATH}"
fi

if [ "$1" = "vohive" ]; then
  shift
  exec /app/bin/vohive "$@"
fi

exec "$@"

