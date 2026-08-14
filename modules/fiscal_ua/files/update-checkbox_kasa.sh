#!/bin/bash

CONF_FILE="/home/bit/.config/jetti-front/config.json"
LOG_FILE="/var/log/checkbox-update.log"

readonly VERSION="${1:-}"               # Получаем номер версии для проверки/установки '1.7.5'
if [ -r /etc/environment ]; then
    . /etc/environment
fi
readonly ENVIRONMENT="${ENV:-staging}"  # Окружение (production|staging)

# Функция логирования
log() {
    printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

[ -n "$VERSION" ] || exit 0
log "----------------------------------------------"
log "* Started update Checkbox-kasa (version:$VERSION)"

INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' checkbox-kasa 2>/dev/null || true)
if [ -z "$INSTALLED_VERSION" ]; then
    log "Initial installation of checkbox-kasa $VERSION"
    /usr/bin/apt-get update -qq || exit 0
    DEBIAN_FRONTEND=noninteractive \
        /usr/bin/apt-get -q -y install checkbox-kasa="$VERSION" || exit 0
    log "Successfully installed checkbox-kasa $VERSION"
    exit 0
fi

[ -f "$CONF_FILE" ] || exit 0                           # Касса ещё не настроена
POSID=$(jq -r '.posId // empty' "$CONF_FILE")           # Получение posId
[ -n "$POSID" ] || exit 0                               # Поврежденный конфигурационный файл

[ "$INSTALLED_VERSION" = "$VERSION" ] && exit 0         # Уже установлена нужная версия

/usr/bin/apt-get update -qq || exit 0                   # Обновляем индекс APT и заранее скачиваем пакет в кэш APT
if ! DEBIAN_FRONTEND=noninteractive \
    /usr/bin/apt-get -q -y --download-only install "checkbox-kasa=$VERSION" >/dev/null 2>&1
then
    log "Failed to pre-download checkbox-kasa $VERSION"
fi

PSNAME=$(hostname)

URL="https://version-provider.x100-apps.com/api/getversion?environment=${ENVIRONMENT}&posid=${POSID}&psname=${PSNAME}"
version_response=$(curl -sSL --max-time 15 "$URL") || exit 0    # Получение разрешения на обновление
jq empty >/dev/null 2>&1 <<<"$version_response" || exit 0       # Если сервер ответил не JSON — ничего не делаем

status=$(jq -r '.readytoupdate // "false"' <<<"$version_response")

# --- Установка новой версии ---
if [ "$status" = "true" ]; then
    log "Upgrade checkbox-kasa $INSTALLED_VERSION -> $VERSION"
    /usr/bin/dpkg --configure -a || {
        log "dpkg --configure -a failed"
        exit 0
    }
    if DEBIAN_FRONTEND=noninteractive \
        /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold \
            --allow-downgrades install checkbox-kasa="$VERSION"
    then
        log "Successfully installed checkbox-kasa $VERSION"
        # Перезапускаем все включенные сервисы checkbox-kasa
        while read -r unit _
        do
            log "Restart service $unit"
            systemctl restart "$unit"
        done < <(systemctl list-unit-files --state=enabled --no-legend 'checkbox-kasa*')
    fi
    exit 0
fi

exit 0
