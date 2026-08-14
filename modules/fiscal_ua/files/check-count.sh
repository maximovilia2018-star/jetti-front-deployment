#!/bin/bash

CONF_FILE="/home/bit/.config/jetti-front/config.json"
API_URL="https://jetti-front-fn.azurewebsites.net/api/http-executor?code=MlpyWn8wsRS7tWqdhYq8S1aluLAm1xkUQY07ps6Buihpo2Dil0mXmA%3D%3D"

[ -f "$CONF_FILE" ] || exit 0                           # Терминал ещё не настроен
POSID=$(jq -r '.posId // empty' "$CONF_FILE")
[ -n "$POSID" ] || exit 0

get_cashbox_info() {
    curl -fsS --max-time 15 --location --request POST "$API_URL" --header 'Content-Type: application/json' \
        --data "{\"args\":{\"posId\":\"${POSID}\"},\"method\":\"cashShift.getPosState\"}"
}

cashbox_response=$(get_cashbox_info) || exit 1          # Получаем информацию о кассах

# Проверяем, что сервер вернул корректный JSON
jq empty >/dev/null 2>&1 <<<"$cashbox_response" || exit 1

# Получаем количество касс
api_count=$(
    jq -er '
        .result.fiscalSettings
        | select(type == "array")
        | length
    ' <<<"$cashbox_response"
) || exit 1

# Считаем локальные каталоги касс
local_count=$(
    find /etc/checkbox_kasa \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -name '[1-5]' \
    | wc -l
)

[ "$api_count" -eq "$local_count" ] && exit 0           # Количество совпадает — синхронизация не требуется
# Требуется синхронизация
exit 1
