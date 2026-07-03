#!/bin/bash
TELEPORT_SERVICE="teleport"
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "=== Запуск проверки Teleport ==="

# Проверяем версию запущенного/доступного бинарника
if command -v teleport >/dev/null 2>&1; then
    CURRENT_MAJOR=$(teleport version | awk '{print $2}' | sed 's/v//' | cut -d'.' -f1)
else
    CURRENT_MAJOR=""
fi

# Получаем мажорную версию от Puppet (например, "16")
TARGET_MAJOR=$(echo "$1" | sed 's/v//' | cut -d'.' -f1)

# Вычисляем разницу версий
if [ -n "$CURRENT_MAJOR" ]; then
    CRITICAL_VERSION_GAP=$((TARGET_MAJOR - CURRENT_MAJOR))
else
    CRITICAL_VERSION_GAP=99
fi

# Условие сбоя: не установлен ИЛИ служба лежит ИЛИ отставание >= 2 версий (ослепший агент)
if [ -z "$CURRENT_MAJOR" ] || ! systemctl is-active "$TELEPORT_SERVICE" >/dev/null || [ "$CRITICAL_VERSION_GAP" -ge 2 ]; then
    log "ОБНАРУЖЕН СБОЙ (Текущая версия: ${CURRENT_MAJOR:-нет}, Ожидаемая мажорная: ${TARGET_MAJOR}). Запуск очистки..."
    systemctl stop "$TELEPORT_SERVICE" 2>/dev/null || true
    sleep 2

    if [ -x "/opt/teleport/system/bin/teleport-update" ]; then
        /opt/teleport/system/bin/teleport-update unlink-package 2>/dev/null || true
    fi

    # Бэкапим конфиг во временную папку
    if [ -f "/etc/teleport.yaml" ]; then
        cp /etc/teleport.yaml /etc/teleport.yaml.backup
    fi

    # Бэкапим выданные кластером сертификаты/ключи ноды
    if [ -d "/var/lib/teleport" ]; then
        mv /var/lib/teleport /tmp/teleport_var_lib.backup
    fi

    # Сносим зависшие хвосты встроенного апгрейдера
    rm -rf /opt/teleport
    rm -rf /etc/systemd/system/teleport.service.d
    rm -rf /etc/systemd/system/teleport.service.wants
    rm -f /etc/systemd/system/teleport*
    rm -f /usr/local/bin/teleport

    systemctl daemon-reload

    # Полностью очищаем старый deb-пакет, чтобы Puppet поставил чистую базу
    dpkg --purge teleport 2>/dev/null || true

    # Возвращаем бэкапы на место ДО того, как Puppet начнет выполнять установку
    if [ -d "/tmp/teleport_var_lib.backup" ]; then
        mv /tmp/teleport_var_lib.backup /var/lib/teleport
    fi
    if [ -f "/tmp/teleport.yaml.backup" ]; then
        cp /etc/teleport.yaml.backup /etc/teleport.yaml
        rm -f /etc/teleport.yaml.backup
    fi

    log "Зачистка завершена. Передаем управление Puppet."
    exit 0 # Код 0 разрешает Puppet запустить exec и выполнить установку заново
else
    exit 1 # Код 1 сообщает Puppet пропустить шаг установки
fi
