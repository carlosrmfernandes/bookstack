#!/usr/bin/with-contenv bash
# Patches /config/www/.env with values from container env vars on every start.
# Required because lscr.io/linuxserver/bookstack does not substitute env vars
# into the BookStack .env (it only copies .env.example once).

ENV_FILE=/config/www/.env

mkdir -p /config/www

if [[ ! -s "$ENV_FILE" ]]; then
    if [[ -f /app/www/.env.example ]]; then
        cp /app/www/.env.example "$ENV_FILE"
    else
        : > "$ENV_FILE"
    fi
fi

set_env() {
    local key="$1"
    local value="$2"
    [[ -z "$value" ]] && return 0
    local escaped
    escaped=$(printf '%s\n' "$value" | sed -e 's/[\/&|]/\\&/g')
    if grep -qE "^${key}=" "$ENV_FILE"; then
        sed -i "s|^${key}=.*|${key}=${escaped}|" "$ENV_FILE"
    else
        echo "${key}=${value}" >> "$ENV_FILE"
    fi
}

set_env APP_URL      "${APP_URL}"
set_env APP_KEY      "${APP_KEY}"
set_env DB_HOST      "${DB_HOST}"
set_env DB_PORT      "${DB_PORT}"
set_env DB_DATABASE  "${DB_DATABASE}"
set_env DB_USERNAME  "${DB_USERNAME}"
set_env DB_PASSWORD  "${DB_PASSWORD}"

chown abc:abc "$ENV_FILE" 2>/dev/null || true
