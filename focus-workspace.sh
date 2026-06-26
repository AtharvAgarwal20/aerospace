#!/usr/bin/env bash
# Best-effort fix for the macOS "wrong same-app window gets focused" bug when
# switching to a workspace whose app has another window on a different monitor.
# macOS focuses the most-recently-used instance and AeroSpace "is not the focus
# owner" (issues #101 / #571 / #1097 / #2130).
#
# Strategy: focus the exact window that lives on the target workspace DIRECTLY.
# Focusing a window also makes its workspace visible on its monitor, but — unlike
# a bare `workspace` switch — it never asks macOS to pick a same-app window by
# recency, which is what grabs the wrong window. We retry briefly to beat the
# focus race, and repair the monitor we left if it still got flipped.
# Best-effort: the macOS race can occasionally still win.
set -uo pipefail

target="${1:?usage: focus-workspace.sh <workspace>}"

# A window that actually lives on the target workspace (queried without switching).
target_wid="$(aerospace list-windows --workspace "$target" --format '%{window-id}' 2>/dev/null | head -n1 || true)"

# Empty target workspace: nothing to mis-focus — plain switch and exit.
if [ -z "$target_wid" ]; then exec aerospace workspace "$target"; fi

# Snapshot the window / workspace / monitor we're leaving, in one call.
from_wid=''; from_ws=''; from_mon=''
IFS='|' read -r from_wid from_ws from_mon \
  < <(aerospace list-windows --focused --format '%{window-id}|%{workspace}|%{monitor-id}' 2>/dev/null || true)

# Already on the target window? nothing to do.
[ "$from_wid" = "$target_wid" ] && exit 0

# Focus the exact target window, retrying until it sticks (beats the MRU race).
cur=''; to_mon=''
for _ in 1 2 3 4 5 6; do
  aerospace focus --window-id "$target_wid" 2>/dev/null || true
  IFS='|' read -r cur to_mon \
    < <(aerospace list-windows --focused --format '%{window-id}|%{monitor-id}' 2>/dev/null || true)
  [ "$cur" = "$target_wid" ] && break
  sleep 0.04
done

# Safety net: if the focus crossed monitors and the monitor we left got flipped to
# a different workspace, restore it via the window we were on, then refocus target.
if [ -n "$from_mon" ] && [ -n "$from_wid" ] && [ "$to_mon" != "$from_mon" ] && \
   [ "$(aerospace list-workspaces --monitor "$from_mon" --visible 2>/dev/null || true)" != "$from_ws" ]; then
  aerospace focus --window-id "$from_wid" 2>/dev/null || true
  aerospace focus --window-id "$target_wid" 2>/dev/null || true
fi
