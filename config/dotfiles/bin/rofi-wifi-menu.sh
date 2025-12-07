#!/bin/bash
set -euo pipefail

# Определение директории скрипта
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Значения по умолчанию
FIELDS="${FIELDS:-SSID,SECURITY}"
POSITION="${POSITION:-0}"
YOFF="${YOFF:-0}"
XOFF="${XOFF:-0}"
FONT="${FONT:-DejaVu Sans Mono 8}"

# Загрузка конфигурации
load_config() {
    local config_paths=(
        "$SCRIPT_DIR/config"
        "$HOME/.config/rofi/wifi"
    )
    
    for config in "${config_paths[@]}"; do
        if [[ -r "$config" ]]; then
            # shellcheck source=/dev/null
            source "$config"
            return 0
        fi
    done
    
    echo "WARNING: config file not found! Using default values." >&2
}

# Получение списка WiFi сетей
get_wifi_list() {
    # Если Wi-Fi выключен — не ломаем скрипт
    nmcli --fields "$FIELDS" device wifi list 2>/dev/null | sed '/^--/d' || true
}

# Получение текущего SSID
get_current_ssid() {
    LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}'
}

# Получение статуса WiFi
get_wifi_state() {
    nmcli -g WIFI general status
}

# Вычисление ширины меню rofi
calculate_width() {
    local list="$1"
    echo "$list" | awk '{ if (length($0) > max) max = length($0) } END { print max + 2 }'
}

# Определение номера строки для подсветки
get_highlight_line() {
    local list="$1"
    local current_ssid="$2"
    
    if [[ -n "$current_ssid" ]]; then
        local line_num=$(echo "$list" | awk -F "[[:space:]]{2,}" '{print $1}' | \
            grep -Fxn -m 1 "$current_ssid" | awk -F ":" '{print $1}')
        
        if [[ -n "$line_num" ]]; then
            echo $((line_num + 1))
        fi
    fi
}

# Подключение к WiFi
connect_wifi() {
    local ssid="$1"
    local password="${2:-}"
    
    if [[ -n "$password" ]]; then
        nmcli dev wifi connect "$ssid" password "$password"
    else
        nmcli dev wifi connect "$ssid"
    fi
}

# Ручной ввод SSID
manual_entry() {
    local input=$(echo "enter the SSID of the network (SSID,password)" | \
        rofi -dmenu -p "Manual Entry: " -font "$FONT" -lines 1)
    
    if [[ -z "$input" ]]; then
        return 1
    fi
    
    local ssid="${input%%,*}"
    local password="${input#*,}"
    
    # Если запятой не было, password будет равен ssid
    if [[ "$password" == "$ssid" ]]; then
        password=""
    fi
    
    connect_wifi "$ssid" "$password"
}

# Запрос пароля
prompt_password() {
    rofi -dmenu -p "password: " -lines 1 -font "$FONT" -password
}

# Основная функция
main() {
    load_config
    
    local wifi_state=$(get_wifi_state)

    # Если Wi-Fi выключен — не пытаемся сканировать
    if [[ "$wifi_state" =~ "disabled" ]]; then
        local wifi_list=""
        local current_ssid=""
    else
        local wifi_list=$(get_wifi_list)
        local current_ssid=$(get_current_ssid)
    fi
    local known_connections=$(nmcli connection show)
    
    # Определение количества строк
    local line_count=$(echo "$wifi_list" | wc -l)
    if [[ "$wifi_state" =~ "enabled" ]] && [[ $line_count -gt 8 ]]; then
        line_count=8
    elif [[ "$wifi_state" =~ "disabled" ]]; then
        line_count=1
    fi
    
    # Определение текста переключателя
    local toggle_text="toggle off"
    if [[ "$wifi_state" =~ "disabled" ]]; then
        toggle_text="toggle on"
    fi
    
    # Вычисление параметров меню
    local menu_width=$(calculate_width "$wifi_list")
    local highlight_line=$(get_highlight_line "$wifi_list" "$current_ssid")
    
    # Показ меню и получение выбора
    local choice=$(echo -e "$toggle_text\nmanual\n$wifi_list" | uniq -u | \
        rofi -dmenu \
        -p "Wi-Fi SSID: " \
        -lines "$line_count" \
        ${highlight_line:+-a "$highlight_line"} \
        -location "$POSITION" \
        -yoffset "$YOFF" \
        -xoffset "$XOFF" \
        -font "$FONT" \
        -width -"$menu_width")
    
    if [[ -z "$choice" ]]; then
        return 0
    fi
    
    # Обработка выбора
    case "$choice" in
        "toggle on")
            nmcli radio wifi on
            ;;
        "toggle off")
            nmcli radio wifi off
            ;;
        "manual")
            manual_entry
            ;;
        *)
            # Извлечение SSID из выбранной строки
            local ssid=$(echo "$choice" | sed 's/\s\{2,\}/|/g' | awk -F "|" '{print $1}')
            
            # Обработка активного соединения (помеченного *)
            if [[ "$ssid" == "*" ]]; then
                ssid=$(echo "$choice" | sed 's/\s\{2,\}/|/g' | awk -F "|" '{print $3}')
            fi
            
            # Проверка, известно ли соединение
            if echo "$known_connections" | grep -q "^$ssid"; then
                nmcli connection up "$ssid"
            else
                # Проверка, требуется ли пароль
                if [[ "$choice" =~ (WPA|WEP) ]]; then
                    local password=$(prompt_password)
                    if [[ -n "$password" ]]; then
                        connect_wifi "$ssid" "$password"
                    fi
                else
                    connect_wifi "$ssid"
                fi
            fi
            ;;
    esac
}

main "$@"
