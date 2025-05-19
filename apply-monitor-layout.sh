#!/bin/bash
# Apply saved monitor layout
# Place this in ~/.config/aerospace/apply-monitor-layout.sh and make it executable with:
# chmod +x ~/.config/aerospace/apply-monitor-layout.sh

CONFIG_FILE=~/.config/aerospace/monitor-layouts.conf

if [ -f "$CONFIG_FILE" ]; then
    echo "Applying saved monitor layout from $CONFIG_FILE"
    source $CONFIG_FILE
    echo "Monitor layout applied successfully"
else
    echo "No saved monitor layout found at $CONFIG_FILE"
fi
