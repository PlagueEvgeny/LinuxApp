#!/bin/bash

# Получаем текущие переменные окружения
export DISPLAY=${DISPLAY:-":0"}
export XAUTHORITY=${XAUTHORITY:-"$HOME/.Xauthority"}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-"wayland-0"}

# Запускаем через pkexec с окружением
pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" /opt/hiddify/squashfs-root/hiddify
