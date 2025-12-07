#!/bin/sh

# Получаем SSID активной сети
ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes"{print $2; exit}')

if [ -n "$ssid" ]; then
    # Подключён — зелёный цвет
    echo "%{F#00ff00} %{F-}"
else
    # Не подключён — красный цвет
    echo "%{F#ff0000} %{F-}"
fi
