#!/bin/bash
#
# Скрипт проверки состояния Teleport (read-only).
#
# Возвращает:
#   0 - требуется восстановление (Teleport сломан или сильно устарел)
#   1 - восстановление не требуется (Teleport работает корректно)

set -u

TELEPORT_SERVICE="teleport"

# Извлекаем мажорную версию из переданного аргумента
# Удаляем префикс 'v' и все после первой точки
TARGET_VERSION="${1:-}"
TARGET_MAJOR="${TARGET_VERSION#v}"
TARGET_MAJOR="${TARGET_MAJOR%%.*}"

# Проверяем, что целевая версия — число
if ! [[ "$TARGET_MAJOR" =~ ^[0-9]+$ ]]; then
    #echo "ERROR: Invalid target version: ${TARGET_VERSION}" >&2
    exit 0  # Выполняем восстановление
fi

# Проверяем версию установленного бинарника
if command -v teleport >/dev/null 2>&1; then
    CURRENT_VERSION=$(timeout 3 teleport version 2>/dev/null | awk '{print $2}')
    if [ -n "$CURRENT_VERSION" ]; then
        # Извлекаем мажорную версию
        CURRENT_MAJOR="${CURRENT_VERSION#v}"
        CURRENT_MAJOR="${CURRENT_MAJOR%%.*}"

        # Проверяем, что текущая версия — число
        if ! [[ "$CURRENT_MAJOR" =~ ^[0-9]+$ ]]; then
            #echo "WARNING: Unexpected teleport version format: ${CURRENT_VERSION}" >&2
            exit 0  # Выполняем восстановление при неожиданном формате
        fi
    else
        CURRENT_MAJOR=""
    fi
else
    CURRENT_MAJOR=""
fi

# Проверка: Teleport не установлен
if [ -z "${CURRENT_MAJOR:-}" ]; then
    exit 0  # требуется восстановление
fi

# Проверка: Сервис не запущен
if ! timeout 2 systemctl is-active --quiet "$TELEPORT_SERVICE" 2>/dev/null; then
    exit 0  # требуется восстановление
fi

# Проверка: Критический разрыв версий ("отставший" агент)
CRITICAL_VERSION_GAP=$((TARGET_MAJOR - CURRENT_MAJOR))
if [ "$CRITICAL_VERSION_GAP" -ge 2 ]; then
    exit 0  # требуется восстановление
fi

# Все проверки пройдены
exit 1  # восстановление не требуется
