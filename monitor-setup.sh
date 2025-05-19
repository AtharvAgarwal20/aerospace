#!/bin/bash
# Monitor setup script for AeroSpace
# Place this in ~/.config/aerospace/monitor-setup.sh and make it executable with:
# chmod +x ~/.config/aerospace/monitor-setup.sh

# Get list of connected monitors
connected_monitors=$(system_profiler SPDisplaysDataType | grep -E "^ {8}[^ ]+" | sed 's/ //g')

# Count monitors
monitor_count=$(echo "$connected_monitors" | wc -l | xargs)

echo "Found $monitor_count connected monitors: $connected_monitors" > /tmp/aerospace-monitor-setup.log

# Check monitor configuration
if [ "$monitor_count" -eq 1 ]; then
    # Single monitor setup - just the built-in display
    echo "Single monitor setup detected" >> /tmp/aerospace-monitor-setup.log
    
    # Set the only monitor to main
    aerospace set-monitor-label main main
    
    # Move all workspaces to main display since that's all we have
    for workspace in 1 2 3 4 5 6 7 8 9 10 S; do
        aerospace move-workspace-to-monitor $workspace main
    done
    
elif [ "$monitor_count" -eq 2 ]; then
    # Dual monitor setup
    echo "Dual monitor setup detected" >> /tmp/aerospace-monitor-setup.log
    
    # Set appropriate monitor labels
    aerospace set-monitor-label main main
    
    # Detect the external monitor (this is simplified - might need adjustment for your setup)
    # Assuming external monitor is to the right of main
    aerospace set-monitor-label right external
    
    # Per your request:
    # Workspaces 1-6 go to external monitor
    for i in {1..6}; do
        aerospace move-workspace-to-monitor $i external
    done
    
    # Workspaces 7-10 and S go to main monitor
    for i in {7..10}; do
        aerospace move-workspace-to-monitor $i main
    done
    aerospace move-workspace-to-monitor S main
    
    # Switch to workspace 1 on external monitor
    aerospace focus-monitor right --wrap-around
    aerospace workspace 1
    
    # Then focus back to workspace 7 on main monitor
    aerospace focus-monitor left --wrap-around
    aerospace workspace 7
    
elif [ "$monitor_count" -ge 3 ]; then
    # Triple monitor setup or more - for simplicity, we'll use only two monitors
    # and follow the same pattern as dual monitor setup
    echo "Multi-monitor setup detected (using main + one external)" >> /tmp/aerospace-monitor-setup.log
    
    # Set monitor labels
    aerospace set-monitor-label main main
    
    # Choose one of the external monitors (right one in this case)
    # You may need to adjust this based on your physical setup
    aerospace set-monitor-label right external
    
    # Per your request:
    # Workspaces 1-6 go to external monitor
    for i in {1..6}; do
        aerospace move-workspace-to-monitor $i external
    done
    
    # Workspaces 7-10 and S go to main monitor
    for i in {7..10}; do
        aerospace move-workspace-to-monitor $i main
    done
    aerospace move-workspace-to-monitor S main
    
    # Switch to workspace 1 on external monitor
    aerospace focus-monitor right --wrap-around
    aerospace workspace 1
    
    # Then focus back to workspace 7 on main monitor
    aerospace focus-monitor left --wrap-around
    aerospace workspace 7
fi

# IMPORTANT: Commenting out the re-applying of saved layouts
# This was likely causing your configuration issues
# If you want to use saved layouts, you can uncomment this later
#if [ -f ~/.config/aerospace/monitor-layouts.conf ]; then
#    echo "Applying saved monitor layouts" >> /tmp/aerospace-monitor-setup.log
#    source ~/.config/aerospace/monitor-layouts.conf
#fi

echo "Monitor setup completed" >> /tmp/aerospace-monitor-setup.log