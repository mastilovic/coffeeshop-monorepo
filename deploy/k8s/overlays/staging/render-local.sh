#!/usr/bin/env bash
# Generate config.env, secrets.env (from examples), and realm-coffeeshop.json for local kubectl apply.
set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f config.env ]]; then
  echo "Copy config.env.example to config.env and set APP_HOST / AUTH_HOST." >&2
  exit 1
fi
if [[ ! -f secrets.env ]]; then
  echo "Copy secrets.env.example to secrets.env and set passwords." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source ./config.env
# shellcheck disable=SC1091
source ./secrets.env
set +a

export STAGING_APP_HOST="${APP_HOST}"
export STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET="${KEYCLOAK_BACKEND_CLIENT_SECRET}"

envsubst '${STAGING_APP_HOST} ${STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET}' \
  < realm-coffeeshop.json.template > realm-coffeeshop.json

echo "Wrote realm-coffeeshop.json (APP_HOST=${STAGING_APP_HOST})"
