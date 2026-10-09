#!/bin/bash

CONF_FILE="/home/bit/.config/jetti-front/config.json"
LOG_FILE="/var/log/update-jetti-front.log"

readonly VERSION="${1:-}"               # Получаем номер версии для проверки/установки '2.0.0-hotfix.271'
if [ -r /etc/environment ]; then
    . /etc/environment
fi
readonly ENVIRONMENT="${ENV:-staging}"  # Окружение (production|staging)

# Функция логирования
log() {
    printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}
[ -n "$VERSION" ] || exit 0
log "-------------------------------------------------------"
log "* Started update Jetti-front (version:$VERSION)"
INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' jetti-front 2>/dev/null || true)
# Установленных версий нет - ставим новую и запускаем
if [ -z "$INSTALLED_VERSION" ]; then
    log "Installing jetti-front $VERSION (first install)"
    /usr/bin/apt-get update -qq || exit 0
    DEBIAN_FRONTEND=noninteractive \
        /usr/bin/apt-get -q -y install "jetti-front=$VERSION" || exit 0
    log "Successfully installed jetti-front $VERSION"
    sudo -u bit bash -c '
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

exec setsid jetti-front >/dev/null 2>&1 < /dev/null
' &
    log "Start Jetti Front"
    exit 0
fi

[ -f "$CONF_FILE" ] || exit 0
POSID=$(jq -r '.posId // empty' "$CONF_FILE")
[ -n "$POSID" ] || exit 0                               # Нет posId — касса ещё не настроена
[ "$INSTALLED_VERSION" = "$VERSION" ] && exit 0         # Уже установлена нужная версия

# Обновляем индекс APT и заранее скачиваем пакет в кэш APT
/usr/bin/apt-get update -qq || exit 0
if ! DEBIAN_FRONTEND=noninteractive \
    /usr/bin/apt-get -q -y --download-only install "jetti-front=$VERSION" >/dev/null 2>&1
then
    log "Failed to pre-download jetti-front $VERSION"
fi

PSNAME=$(hostname)
URL="https://version-provider.x100-apps.com/api/getversion?environment=${ENVIRONMENT}&posid=${POSID}&psname=${PSNAME}"
response=$(curl -sSL --max-time 15 "$URL") || exit 0

jq empty >/dev/null 2>&1 <<<"$response" || exit 0       # Сервер вернул мусор
status=$(jq -r '.readytoupdate // "false"' <<<"$response")

#[ "$status" = "true" ] || exit 0                       # Рабочий день открыт — обновляться нельзя
if [ "$status" = "true" ]; then
    log "Upgrade jetti-front $INSTALLED_VERSION -> $VERSION"
    # Обновление разрешено (исправляем зависимости)
    /usr/bin/dpkg --configure -a || {
        log "dpkg --configure -a failed"
        exit 0
    }
    # Устанавливаем новую версию
    DEBIAN_FRONTEND=noninteractive \
    /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --allow-downgrades install jetti-front="$VERSION" || exit 0
    log "Successfully installed jetti-front $VERSION"
    sleep 1
    # Перезапуск приложения
    pkill -f jetti-front-electron >/dev/null 2>&1 || true
    log "Restarting Jetti Front"
    timeout=50
    while pgrep -f jetti-front-electron >/dev/null && [ "$timeout" -gt 0 ]; do
        sleep 0.2
        timeout=$((timeout - 1))
    done
    # Перезапуск спулера (если он активен)
    if systemctl -q is-active jetti-front-fiscal-spooler.service 2>/dev/null; then
        log "Restarting Fiscal Spooler"
        if systemctl restart jetti-front-fiscal-spooler.service; then
            log "Fiscal Spooler restarted"
        else
            log "Failed to restart Fiscal Spooler"
        fi
    else
        log "Fiscal Spooler is not running - restart skipped"
    fi
    log "Starting Jetti Front"
    sudo -u bit bash -c '
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

exec setsid jetti-front >/dev/null 2>&1 < /dev/null
' &
fi

log "- Finished update Jetti-front -"

exit 0
