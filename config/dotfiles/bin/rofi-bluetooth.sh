#!/usr/bin/env bash
#             __ _       _     _            _              _   _
#  _ __ ___  / _(_)     | |__ | |_   _  ___| |_ ___   ___ | |_| |__
# | '__/ _ \| |_| |_____| '_ \| | | | |/ _ \ __/ _ \ / _ \| __| '_ \
# | | | (_) |  _| |_____| |_) | | |_| |  __/ || (_) | (_) | |_| | | |
# |_|  \___/|_| |_|     |_.__/|_|\__,_|\___|\__\___/ \___/ \__|_| |_|
#
# Author: Nick Clyde (clydedroid)
# Modified: Enhanced version with connection indicators
#
# A script that generates a rofi menu that uses bluetoothctl to
# connect to bluetooth devices and display status info.
#
# Depends on:
#   rofi, bluez-utils (bluetoothctl), bc

# Constants
divider="─────────────────────────"
goback="⬅ Назад"

# Icons for connection status
icon_connected="✓"
icon_paired="◆"
icon_disconnected="○"

# Checks if bluetooth controller is powered on
power_on() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

# Toggles power state
toggle_power() {
    if power_on; then
        bluetoothctl power off
        show_menu
    else
        if rfkill list bluetooth | grep -q 'blocked: yes'; then
            rfkill unblock bluetooth && sleep 3
        fi
        bluetoothctl power on
        show_menu
    fi
}

# Checks if controller is scanning for new devices
scan_on() {
    if bluetoothctl show | grep -q "Discovering: yes"; then
        echo "🔍 Сканирование: вкл"
        return 0
    else
        echo "🔍 Сканирование: выкл"
        return 1
    fi
}

# Toggles scanning state
toggle_scan() {
    if scan_on; then
        kill $(pgrep -f "bluetoothctl --timeout 5 scan on") 2>/dev/null
        bluetoothctl scan off
        show_menu
    else
        bluetoothctl --timeout 5 scan on &
        sleep 1
        show_menu
    fi
}

# Checks if controller is able to pair to devices
pairable_on() {
    if bluetoothctl show | grep -q "Pairable: yes"; then
        echo "🔗 Сопряжение: вкл"
        return 0
    else
        echo "🔗 Сопряжение: выкл"
        return 1
    fi
}

# Toggles pairable state
toggle_pairable() {
    if pairable_on; then
        bluetoothctl pairable off
        show_menu
    else
        bluetoothctl pairable on
        show_menu
    fi
}

# Checks if controller is discoverable by other devices
discoverable_on() {
    if bluetoothctl show | grep -q "Discoverable: yes"; then
        echo "📡 Видимость: вкл"
        return 0
    else
        echo "📡 Видимость: выкл"
        return 1
    fi
}

# Toggles discoverable state
toggle_discoverable() {
    if discoverable_on; then
        bluetoothctl discoverable off
        show_menu
    else
        bluetoothctl discoverable on
        show_menu
    fi
}

# Checks if a device is connected
device_connected() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

# Toggles device connection
toggle_connection() {
    if device_connected "$1"; then
        bluetoothctl disconnect "$1"
        device_menu "$device"
    else
        bluetoothctl connect "$1"
        device_menu "$device"
    fi
}

# Checks if a device is paired
device_paired() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Paired: yes"; then
        echo "🔗 Сопряжено: да"
        return 0
    else
        echo "🔗 Сопряжено: нет"
        return 1
    fi
}

# Toggles device paired state
toggle_paired() {
    if device_paired "$1"; then
        bluetoothctl remove "$1"
        device_menu "$device"
    else
        bluetoothctl pair "$1"
        device_menu "$device"
    fi
}

# Checks if a device is trusted
device_trusted() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Trusted: yes"; then
        echo "⭐ Доверенное: да"
        return 0
    else
        echo "⭐ Доверенное: нет"
        return 1
    fi
}

# Toggles device trust
toggle_trust() {
    if device_trusted "$1"; then
        bluetoothctl untrust "$1"
        device_menu "$device"
    else
        bluetoothctl trust "$1"
        device_menu "$device"
    fi
}

# Get device icon based on connection and pairing status
get_device_icon() {
    local mac=$1
    if device_connected "$mac"; then
        echo "$icon_connected"
    elif device_paired "$mac" &>/dev/null; then
        echo "$icon_paired"
    else
        echo "$icon_disconnected"
    fi
}

# Prints a short string with the current bluetooth status
# Useful for status bars like polybar, etc.
print_status() {
    if power_on; then
        printf ''

        paired_devices_cmd="devices Paired"
        # Check if an outdated version of bluetoothctl is used to preserve backwards compatibility
        if (( $(echo "$(bluetoothctl version | cut -d ' ' -f 2) < 5.65" | bc -l) )); then
            paired_devices_cmd="paired-devices"
        fi

        mapfile -t paired_devices < <(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
        counter=0

        for device in "${paired_devices[@]}"; do
            if device_connected "$device"; then
                device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)

                if [ $counter -gt 0 ]; then
                    printf ", %s" "$device_alias"
                else
                    printf " %s" "$device_alias"
                fi

                ((counter++))
            fi
        done
        printf "\n"
    else
        echo ""
    fi
}

# A submenu for a specific device that allows connecting, pairing, and trusting
device_menu() {
    device=$1

    # Get device name and mac address
    device_name=$(echo "$device" | cut -d ' ' -f 3-)
    mac=$(echo "$device" | cut -d ' ' -f 2)

    # Build options
    if device_connected "$mac"; then
        connected="🔌 Подключено: да"
    else
        connected="🔌 Подключено: нет"
    fi
    paired=$(device_paired "$mac")
    trusted=$(device_trusted "$mac")
    options="$connected\n$paired\n$trusted\n$divider\n$goback\n❌ Выход"

    # Open rofi menu, read chosen option
    chosen="$(echo -e "$options" | $rofi_command "$device_name")"

    # Match chosen option to command
    case "$chosen" in
        "" | "$divider")
            echo "No option chosen."
            ;;
        "$connected")
            toggle_connection "$mac"
            ;;
        "$paired")
            toggle_paired "$mac"
            ;;
        "$trusted")
            toggle_trust "$mac"
            ;;
        "$goback")
            show_menu
            ;;
    esac
}

# Opens a rofi menu with current bluetooth status and options to connect
show_menu() {
    # Get menu options
    if power_on; then
        power="⚡ Питание: вкл"

        # Get all devices with connection indicators
        devices=""
        while IFS= read -r line; do
            mac=$(echo "$line" | cut -d ' ' -f 2)
            name=$(echo "$line" | cut -d ' ' -f 3-)
            icon=$(get_device_icon "$mac")
            
            if [ -z "$devices" ]; then
                devices="$icon $name"
            else
                devices="$devices\n$icon $name"
            fi
        done < <(bluetoothctl devices | grep Device)

        # Get controller flags
        scan=$(scan_on)
        pairable=$(pairable_on)
        discoverable=$(discoverable_on)

        # Options passed to rofi
        options="$devices\n$divider\n$power\n$scan\n$pairable\n$discoverable\n❌ Выход"
    else
        power="⚡ Питание: выкл"
        options="$power\n❌ Выход"
    fi

    # Open rofi menu, read chosen option
    chosen="$(echo -e "$options" | $rofi_command "Bluetooth")"

    # Match chosen option to command
    case "$chosen" in
        "" | "$divider")
            echo "No option chosen."
            ;;
        "$power")
            toggle_power
            ;;
        "$scan")
            toggle_scan
            ;;
        "$discoverable")
            toggle_discoverable
            ;;
        "$pairable")
            toggle_pairable
            ;;
        *)
            # Remove icon from chosen device name
            device_name=$(echo "$chosen" | sed 's/^[✓◆○] //')
            device=$(bluetoothctl devices | grep "$device_name")
            # Open a submenu if a device is selected
            if [[ $device ]]; then device_menu "$device"; fi
            ;;
    esac
}

# Rofi command to pipe into, can add any options here
rofi_command="rofi -dmenu $* -p"

case "$1" in
    --status)
        print_status
        ;;
    *)
        show_menu
        ;;
esac
