# Staging config — pipeline vs local

## CI/CD (GitHub Actions)

Set **Variables** and **Secrets** only (see [deploy/GITHUB_SETUP.md](../../../GITHUB_SETUP.md)).

The deploy job generates:

- `config.env` ← `vars.STAGING_APP_HOST`, `vars.STAGING_AUTH_HOST`
- `secrets.env` ← `secrets.STAGING_*`
- `realm-coffeeshop.json` ← `realm-coffeeshop.json.template` + `envsubst`

## Local

1. `cp config.env.example config.env` and `cp secrets.env.example secrets.env`
2. `./render-local.sh`
3. `kubectl apply -k .`

Generated files are gitignored.
