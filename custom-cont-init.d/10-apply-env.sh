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

# LDAP / Active Directory
set_env AUTH_METHOD                 "${AUTH_METHOD}"
set_env LDAP_SERVER                 "${LDAP_SERVER}"
set_env LDAP_BASE_DN                "${LDAP_BASE_DN}"
set_env LDAP_DN                     "${LDAP_DN}"
set_env LDAP_PASS                   "${LDAP_PASS}"
set_env LDAP_USER_FILTER            "${LDAP_USER_FILTER}"
set_env LDAP_VERSION                "${LDAP_VERSION}"
set_env LDAP_ID_ATTRIBUTE           "${LDAP_ID_ATTRIBUTE}"
set_env LDAP_EMAIL_ATTRIBUTE        "${LDAP_EMAIL_ATTRIBUTE}"
set_env LDAP_DISPLAY_NAME_ATTRIBUTE "${LDAP_DISPLAY_NAME_ATTRIBUTE}"
set_env LDAP_THUMBNAIL_ATTRIBUTE    "${LDAP_THUMBNAIL_ATTRIBUTE}"
set_env LDAP_START_TLS              "${LDAP_START_TLS}"
set_env LDAP_TLS_INSECURE           "${LDAP_TLS_INSECURE}"
set_env LDAP_FOLLOW_REFERRALS       "${LDAP_FOLLOW_REFERRALS}"

# SMTP / e-mail
set_env MAIL_DRIVER       "${MAIL_DRIVER}"
set_env MAIL_HOST         "${MAIL_HOST}"
set_env MAIL_PORT         "${MAIL_PORT}"
set_env MAIL_USERNAME     "${MAIL_USERNAME}"
set_env MAIL_PASSWORD     "${MAIL_PASSWORD}"
set_env MAIL_ENCRYPTION   "${MAIL_ENCRYPTION}"
set_env MAIL_FROM         "${MAIL_FROM}"
set_env MAIL_FROM_NAME    "${MAIL_FROM_NAME}"
set_env MAIL_VERIFY_SSL   "${MAIL_VERIFY_SSL}"

chown abc:abc "$ENV_FILE" 2>/dev/null || true
