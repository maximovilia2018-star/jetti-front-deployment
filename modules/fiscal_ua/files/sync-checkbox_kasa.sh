#!/bin/bash

readonly MAX_CASHBOXES=5
readonly C_PATH="/etc/checkbox_kasa"
CONF_FILE="/home/bit/.config/jetti-front/config.json"
LOG_FILE="/var/log/checkbox-sync.log"
DECRYPT_TOOL="/usr/local/bin/decrypt-pos"
API_URL="https://jetti-front-fn.azurewebsites.net/api/http-executor?code=MlpyWn8wsRS7tWqdhYq8S1aluLAm1xkUQY07ps6Buihpo2Dil0mXmA%3D%3D"

[ -f "$CONF_FILE" ] || exit 0                   # Касса ещё не настроена
POSID=$(jq -r '.posId // empty' "$CONF_FILE")   # Получение posId
[ -n "$POSID" ] || exit 0                       # Поврежденный конфигурационный файл

# -------------------------------------------------------------
# Функции
# -------------------------------------------------------------

# Функция логирования
log() {
    printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

# Преобразует имя папки в номер кассы
# Возвращает номер кассы через stdout.
# Код возврата: 0 - успех, 1 - неизвестное имя папки.
folder_to_num() {
    case "$1" in
        checkbox_kasa)
            printf '%s\n' 1
            ;;
        checkbox_kasa_[0-9]*)
            printf '%s\n' $(( ${1##*_} + 1 ))
            ;;
        *)
            return 1
            ;;
    esac
}

# Подготавливает директорию для кассы
# Параметры:
#   $1 - путь к директории
# Возвращает:
#   0 - успешно
#   1 - ошибка создания или установки прав
prepare_dir() {
    local dir="$1"
    log "Creating directory: $dir"
    mkdir -p "$dir" &&
    chown bit:bit "$dir" &&
    chmod 0755 "$dir"
}

# Создает конфигурационный файл для кассы
# Параметры:
#   $1 - путь к конфигурационному файлу
#   $2 - логин (license_key)
#   $3 - пароль (pin_code)
#   $4 - номер кассы (для вычисления tcp_port и log_file)
#   $5 - порт веб-сервера
# Возвращает:
#   0 - успешно
#   1 - ошибка создания или неверный JSON
create_config() {
    local config="$1"
    local login="$2"
    local password="$3"
    local num="$4"
    local port="$5"

    local tcp_port=$((13000 + num - 1))
    local log_file="/var/log/rro_agent_${num}.log"

    log "Creating config file: $config"

    cat >"$config" <<EOF || return 1
{
  "logging": {
    "file": "$log_file",
    "debug": false
  },
  "provider": {
    "url": "https://api.checkbox.in.ua",
    "license_key": "$login",
    "request_timeout": 60,
    "pin_code": "$password",
    "use_registry_backend": false
  },
  "transport": {
    "default": "TCP",
    "tcp": {
      "host": "127.0.0.1",
      "port": $tcp_port
    }
  },
  "web_server": {
    "host": "127.0.0.1",
    "port": $port,
    "docs": true
  },
  "printer": {
    "type": "generic",
    "custom_width": 27,
    "name": "Thermal"
  },
  "receipts_auto_clean": {
    "days_interval": 30,
    "max_duration": 120
  },
  "custom": {
    "online_receipt_mode": true,
    "online_receipt_timeout": 5,
    "online_timeout": 6,
    "create_receipts_in_shift_day": true,
    "run_from_any_user": true,
    "extended_nbu_rounding": true,
    "use_service_receipt_value_validation": true
  }
}
EOF

    # Проверяем, что конфиг создан и валидный JSON
    jq empty "$config" >/dev/null 2>&1 || {
        rm -f "$config"
        return 1
    }

    chown bit:bit "$config" || {
        rm -f "$config"
        return 1
    }

    chmod 0644 "$config" || {
        rm -f "$config"
        return 1
    }

    return 0
}

get_cashbox_info() {
    curl -fsS --max-time 15 --location --request POST "$API_URL" --header 'Content-Type: application/json' \
        --data "{\"args\":{\"posId\":\"${POSID}\"},\"method\":\"cashShift.getPosState\"}"
}

# -------------------------------------------------------------
# Основной код
# -------------------------------------------------------------
# --- Проверка количества и создание/удаление каталогов для касс ---
cashbox_response=$(get_cashbox_info) || exit 0          # Получаем информацию о кассах

# Быстрая проверка на валидность самого синтаксиса JSON
jq empty >/dev/null 2>&1 <<<"$cashbox_response" || exit 0

# Объединенная проверка структуры и получение длины массива за один вызов
count=$(
    jq -er '
        .result.fiscalSettings
        | select(type == "array")
        | length
    ' <<<"$cashbox_response"
) || exit 0

# Проверяем, что массив не пустой, чтобы случайно не удалить всё
(( count > 0 )) || exit 0

# Формирование списка активных касс для последующей сверки и архивации
cashbox_list=" $(jq -r '.result.fiscalSettings[].folderName // empty' <<<"$cashbox_response" | tr '\n' ' ') "

# -------------------------------------------------------------
# Создание новых касс
# -------------------------------------------------------------
while IFS= read -r cashbox
do
    # Получаем все поля одним вызовом jq
    readarray -t fields < <(
        jq -r '.folderName,.posId,.login,.password,.port' <<<"$cashbox"
    )

    folder="${fields[0]}"
    cashbox_posid="${fields[1]}"
    enc_login="${fields[2]}"
    enc_password="${fields[3]}"
    port="${fields[4]}"

    # Получаем номер каталога
    num=$(folder_to_num "$folder") || {
        log "Unknown folder name: $folder"
        continue
    }

    # Проверяем диапазон
    if (( num < 1 || num > MAX_CASHBOXES )); then
        log "Invalid cashbox number: $num (must be between 1 and $MAX_CASHBOXES)"
        continue
    fi

    confdir="$C_PATH/$num"
    config="$confdir/config.json"

    # Подготавливаем каталог
    if [ ! -d "$confdir" ]; then
        prepare_dir "$confdir" || {
            log "Failed to prepare directory: $confdir"
            continue
        }
    fi

    # Конфиг уже существует - больше ничего делать не нужно
    if [ -f "$config" ]; then
        continue
    fi

    # Проверяем, что утилита дешифрования доступна и может исполняться
    if [ ! -x "$DECRYPT_TOOL" ]; then
        log "ERROR: Decrypt tool not found or not executable at $DECRYPT_TOOL"
        continue
    fi

    # Расшифровка логина и пароля
    credentials=$(
        "$DECRYPT_TOOL" \
            "$cashbox_posid" \
            "$enc_login" \
            "$enc_password"
    ) || {
        log "Decrypt failed for $folder"
        continue
    }

    IFS=$'\t' read -r login password <<<"$credentials"

    # Проверяем, что оба значения получены
    if [ -z "$login" ] || [ -z "$password" ]; then
        log "Invalid decrypted credentials for $folder"
        continue
    fi

    # Создаем конфиг
    create_config \
        "$config" \
        "$login" \
        "$password" \
        "$num" \
        "$port" || {
            log "Failed to create config: $config"
            continue
        }

    log "Enable and Start service checkbox-kasa@$num"
#    systemctl enable "checkbox-kasa@$num"
#    systemctl start "checkbox-kasa@$num"

done < <(jq -c '.result.fiscalSettings[]' <<<"$cashbox_response")

# -------------------------------------------------------------
# Архивация отсутствующих касс
# -------------------------------------------------------------

archdir="$C_PATH/arch"

# Получаем время запуска один раз для всех касс
timestamp=$(date +%Y%m%d_%H%M)

if mkdir -p "$archdir"; then
    for ((num=1; num<=MAX_CASHBOXES; num++))
    do
        name="checkbox_kasa"
        (( num > 1 )) && name+="_$((num-1))"

        confdir="$C_PATH/$num"

        [[ "$cashbox_list" == *" $name "* ]] && continue
        [ -d "$confdir" ] || continue

        # Формируем базовое имя архива
        target_arch="$archdir/${num}_${timestamp}"

        # Защита от коллизий при совпадении времени (добавляем PID процесса)
        if [ -e "$target_arch" ]; then
            target_arch="${target_arch}_$$"
        fi

        log "Stop and Disable service checkbox-kasa@$num"
#         systemctl stop "checkbox-kasa@$num"
#         systemctl disable "checkbox-kasa@$num"

        # Перемещение и логирование
        if mv "$confdir" "$target_arch"; then
            log "Archived $confdir to $target_arch"
        else
            log "Failed to archive $confdir" >&2
        fi
    done
else
    log "Failed to create archive directory: $archdir"
fi

exit 0
