#!/bin/bash
# Save current monitor layout
# Place this in ~/.config/aerospace/save-monitor-layout.sh and make it executable with:
# chmod +x ~/.config/aerospace/save-monitor-layout.sh

CONFIG_FILE=~/.config/aerospace/monitor-layouts.conf

echo "# Monitor layouts saved on $(date)" > $CONFIG_FILE

# Get all workspace-to-monitor assignments
for workspace in 1 2 3 4 5 6 7 8 9 T S; do
    monitor=$(aerospace get-workspace-monitor $workspace 2>/dev/null)
    if [ ! -z "$monitor" ]; then
        echo "aerospace move-workspace-to-monitor $workspace $monitor" >> $CONFIG_FILE
    fi
done

# Save current layout for each workspace
for workspace in 1 2 3 4 5 6 7 8 9 T S; do
    layout=$(aerospace get-workspace-layout $workspace 2>/dev/null)
    if [ ! -z "$layout" ]; then
        echo "aerospace set-workspace-layout $workspace $layout" >> $CONFIG_FILE
    fi
done

echo "Monitor layout saved to $CONFIG_FILE"
