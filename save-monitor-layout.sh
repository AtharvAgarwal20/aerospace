#!/bin/bash
# Save current monitor layout
# Place this in ~/.config/aerospace/save-monitor-layout.sh and make it executable with:
# chmod +x ~/.config/aerospace/save-monitor-layout.sh

CONFIG_FILE=~/.config/aerospace/monitor-layouts.conf

echo "# Monitor layouts saved on $(date)" > "$CONFIG_FILE"

# Record each workspace's current monitor as a restore command.
# Workspaces are enumerated dynamically from AeroSpace rather than hard-coded.
# Note: AeroSpace exposes no command to query/set a workspace's *layout*
# (tiles/accordion), so only workspace-to-monitor assignments are saved.
aerospace list-workspaces --all --format '%{workspace}|%{monitor-name}' \
    | while IFS='|' read -r workspace monitor; do
        [ -z "$workspace" ] && continue
        echo "aerospace move-workspace-to-monitor --workspace \"$workspace\" \"$monitor\"" >> "$CONFIG_FILE"
    done

echo "Monitor layout saved to $CONFIG_FILE"
