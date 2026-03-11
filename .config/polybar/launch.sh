#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

DPI=$(xrdb -query | grep dpi | awk '{print $2}')

# for multimonitor
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m POLYBAR_DPI=$DPI polybar --reload example & disown
  done
else
  polybar --reload example & disown
fi
