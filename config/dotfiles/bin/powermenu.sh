#!/bin/env bash

choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | rofi -m -1 -dmenu)
case "$choice" in
  Lock) sh ~/.config/dotfiles/bin/screen-lock.sh ;;
  Logout) pkill -KILL -u "$USER" ;;
  Suspend) systemctl suspend && sh ~/.config/dotfiles/bin/screen-lock.sh ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
