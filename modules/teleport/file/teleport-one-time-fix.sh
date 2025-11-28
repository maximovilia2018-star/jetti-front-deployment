#!/bin/bash
# /usr/local/bin/teleport-one-time-fix.sh

TELEPORT_SERVICE="teleport"
LOG_FILE="/var/log/teleport-one-time-fix.log"
MARKER_FILE="/root/.fix-applied"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
#    echo "$1"
}

# Проверяем маркер - если файл существует, выходим
check_marker() {
    if [ -f "$MARKER_FILE" ]; then
        log "Маркер $MARKER_FILE существует - пропускаем исправление"
        exit 0
    fi
}

# Проверяем, есть ли проблемы с Teleport
check_teleport_issues() {
    log "Проверка наличия проблем с Teleport..."
    # Проверяем, запущена ли служба
    if ! systemctl is-active "$TELEPORT_SERVICE" >/dev/null; then
        log "Обнаружена проблема: служба Teleport не запущена"
        return 0
    fi
    # Проверяем, есть ли процесс
    if ! pgrep -f "teleport start" >/dev/null; then
        log "Обнаружена проблема: процесс Teleport не найден"
        return 0
    fi
    log "Проблемы не обнаружены - Teleport работает нормально"
    return 1
}

reinstall_teleport() {
    log "Начинаем переустановку Teleport..."
    # Останавливаем службу
    systemctl stop "$TELEPORT_SERVICE" 2>/dev/null
    sleep 3
    # Сохраняем конфигурацию
    if [ -f "/etc/teleport.yaml" ]; then
        cp /etc/teleport.yaml /etc/teleport.yaml.backup.$(date +%Y%m%d_%H%M%S)
        log "Создана резервная копия конфигурации"
    fi
    # Удаляем старую версию
    log "Удаляем старый Teleport..."
    apt-get remove -y teleport 2>/dev/null
    rm -rf /opt/teleport
    rm -rf /var/lib/teleport
    rm -rf /etc/systemd/system/teleport.service.d
    rm -rf /etc/systemd/system/teleport.service.wants
    rm -f /etc/systemd/system/teleport*

    # Переустанавливаем
    log "Устанавливаем Teleport заново..."
    apt-get update
    apt-get install -y teleport

    # Восстанавливаем конфигурацию
    if [ -f "/etc/teleport.yaml.backup"* ]; then
        local backup_file=$(ls -t /etc/teleport.yaml.backup* | head -1)
        cp "$backup_file" /etc/teleport.yaml
        log "Восстановлена конфигурация из $backup_file"
    fi

    # Активируем автообновление
    if [ -f "/opt/teleport/system/bin/teleport-update" ]; then
        /opt/teleport/system/bin/teleport-update enable
    fi

    systemctl daemon-reload
    systemctl start "$TELEPORT_SERVICE"

    log "Переустановка Teleport завершена"
}
verify_fix() {
    log "Проверка результата исправления..."
    sleep 10
    # Проверяем, что служба запущена
    if systemctl is-active "$TELEPORT_SERVICE" >/dev/null; then
        log "✓ Служба Teleport запущена"
    else
        log "✗ Служба Teleport не запущена после переустановки"
        return 1
    fi
}

# Основная логика
log "=== Запуск однократного исправления Teleport ==="
# Проверяем маркер
check_marker
# Проверяем наличие проблем
if check_teleport_issues; then
    log "Обнаружены проблемы с Teleport - выполняем переустановку"
    reinstall_teleport
    if verify_fix; then
        log "✓ Исправление успешно завершено"
        # Создаем маркер только при успешном исправлении
        touch "$MARKER_FILE"
        log "Создан маркер $MARKER_FILE"
    else
        log "⚠ Исправление завершено с предупреждениями"
        # Маркер не создаем - возможно потребуется ручное вмешательство
    fi
else
    log "Проблемы не обнаружены - создаем маркер и завершаем работу"
    touch "$MARKER_FILE"
fi
log "=== Работа скрипта завершена ==="
