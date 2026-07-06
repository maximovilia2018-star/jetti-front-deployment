#!/bin/bash
#
# Скрипт восстановления Teleport для POS-терминалов.
# Выполняет полную очистку системы перед переустановкой.
#
# Внимание: этот скрипт DESTRUCTIVE!
# Выполняется только при необходимости восстановления.

set -euo pipefail
cd /tmp

TELEPORT_SERVICE="teleport"
TARGET_MAJOR=$(echo "$1" | sed 's/v//' | cut -d'.' -f1)
LOG_FILE="/var/log/teleport-recovery.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "=== НАЧАЛО ВОССТАНОВЛЕНИЯ TARGET=${TARGET_MAJOR} ==="

# Останавливаем сервис
log "Остановка сервиса ${TELEPORT_SERVICE}..."
systemctl stop "$TELEPORT_SERVICE" 2>/dev/null || true
sleep 2

# Удаляем старый пакет через teleport-update (если есть)
if [ -x "/opt/teleport/system/bin/teleport-update" ]; then
    log "Удаление старого пакета через teleport-update..."
    /opt/teleport/system/bin/teleport-update unlink-package 2>/dev/null || true
fi

# Бэкапим конфигурацию (используем mv для атомарности)
if [ -f "/etc/teleport.yaml" ]; then
    log "Бэкап /etc/teleport.yaml -> /etc/teleport.yaml.backup"
    mv -f /etc/teleport.yaml /etc/teleport.yaml.backup
fi

# Бэкапим данные
if [ -d "/var/lib/teleport" ]; then
    log "Бэкап /var/lib/teleport -> /tmp/teleport_var_lib.backup"
    rm -rf /tmp/teleport_var_lib.backup 2>/dev/null || true
    mv -f /var/lib/teleport /tmp/teleport_var_lib.backup
fi

# Полная очистка
log "Полная очистка файлов Teleport..."
rm -rf /opt/teleport
rm -f /etc/systemd/system/teleport.service
rm -f /etc/systemd/system/teleport-upgrade.service
rm -rf /etc/systemd/system/teleport.service.d
rm -rf /etc/systemd/system/teleport-upgrade.service.d
rm -rf /etc/systemd/system/teleport.service.wants
rm -f /usr/local/bin/teleport
rm -f /usr/local/bin/teleport-update
rm -f /usr/local/bin/tctl
rm -f /usr/local/bin/tsh
rm -f /usr/local/bin/tbot
rm -f /usr/local/bin/fdpass-teleport

# Перезагружаем systemd
log "Перезагрузка systemd..."
systemctl daemon-reload

# Полностью удаляем deb-пакет
log "Удаление deb-пакета teleport..."
dpkg --purge teleport 2>/dev/null || true

# Восстанавливаем бэкапы (если есть)
if [ -d "/tmp/teleport_var_lib.backup" ]; then
    log "Восстановление /var/lib/teleport из бэкапа"
    mv -f /tmp/teleport_var_lib.backup /var/lib/teleport
fi

if [ -f "/etc/teleport.yaml.backup" ]; then
    log "Восстановление /etc/teleport.yaml из бэкапа"
    mv -f /etc/teleport.yaml.backup /etc/teleport.yaml
fi

log "=== ВОССТАНОВЛЕНИЕ ЗАВЕРШЕНО ==="
log "Передача управления Puppet для установки Teleport ${TARGET_MAJOR}"

exit 0
