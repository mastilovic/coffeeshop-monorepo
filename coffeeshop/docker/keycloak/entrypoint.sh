#!/usr/bin/env bash
set -euo pipefail
# Import runs before the server starts so realm JSON updates apply even when the realm
# already exists (--import-realm on start skips existing realms).
/opt/keycloak/bin/kc.sh import --file /opt/keycloak/data/import/realm-coffeeshop.json
exec /opt/keycloak/bin/kc.sh start-dev
