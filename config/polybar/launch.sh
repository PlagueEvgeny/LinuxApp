#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log

# Run on the desired monitor
if [[ $(xrandr -q | grep 'HDMI-1 connected' ) ]]; then
	polybar bspwm-hdmi -r >>/tmp/polybar1.log 2>&1 & disown
	polybar bspwm -r >>/tmp/polybar1.log 2>&1 & disown
	echo "Polybar launched for two monitors"
else
	polybar bspwm -r >>/tmp/polybar1.log 2>&1 & disown
	echo "Polybar launched for one monitor..."
fi
