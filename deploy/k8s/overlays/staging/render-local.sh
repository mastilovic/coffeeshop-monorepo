#!/usr/bin/env bash
# Generate realm-coffeeshop.json for local kubectl apply (config.env / secrets.env must exist).
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

PUBLIC_SCHEME="${PUBLIC_SCHEME:-http}"
if [[ "$PUBLIC_SCHEME" != "http" && "$PUBLIC_SCHEME" != "https" ]]; then
  echo "PUBLIC_SCHEME must be http or https (got: ${PUBLIC_SCHEME})" >&2
  exit 1
fi
if [[ -z "${APP_HOST:-}" || -z "${AUTH_HOST:-}" ]]; then
  echo "Set APP_HOST and AUTH_HOST in config.env" >&2
  exit 1
fi

export STAGING_APP_HOST="${APP_HOST}"
export STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET="${KEYCLOAK_BACKEND_CLIENT_SECRET}"

envsubst '${STAGING_APP_HOST} ${STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET}' \
  < realm-coffeeshop.json.template > realm-coffeeshop.json

echo "Wrote realm-coffeeshop.json (APP_HOST=${STAGING_APP_HOST}, AUTH_HOST=${AUTH_HOST}, scheme=${PUBLIC_SCHEME})"
echo "Ensure config.env has KEYCLOAK_PUBLIC_URL=${PUBLIC_SCHEME}://${AUTH_HOST}"
echo "Ensure config.env has KEYCLOAK_JWT_ISSUER_URI=${PUBLIC_SCHEME}://${AUTH_HOST}/realms/coffeeshop"
