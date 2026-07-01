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

# Windows that actually live on the target workspace (queried without switching).
target_wids="$(aerospace list-windows --workspace "$target" --format '%{window-id}' 2>/dev/null || true)"

# Which one to focus: prefer the window we last left focused on this workspace
# (so the accordion top you left stays on top), falling back to the first window
# if that record is missing or the window is gone. See the record step below.
target_wid="$(cat "/tmp/aerospace-last-focus-$target" 2>/dev/null || true)"
if [ -z "$target_wid" ] || ! grep -qxF "$target_wid" <<<"$target_wids"; then
  target_wid="$(head -n1 <<<"$target_wids")"
fi

# Empty target workspace: nothing to mis-focus — plain switch and exit.
if [ -z "$target_wid" ]; then exec aerospace workspace "$target"; fi

# Snapshot the window / workspace / monitor we're leaving, in one call.
from_wid=''; from_ws=''; from_mon=''
IFS='|' read -r from_wid from_ws from_mon \
  < <(aerospace list-windows --focused --format '%{window-id}|%{workspace}|%{monitor-id}' 2>/dev/null || true)

# Remember the window we're leaving on its workspace, so next time we return here
# we restore it instead of always snapping to the first window. Read above.
[ -n "$from_ws" ] && [ -n "$from_wid" ] && \
  printf '%s' "$from_wid" > "/tmp/aerospace-last-focus-$from_ws" 2>/dev/null || true

# Already on the target window? nothing to do.
[ "$from_wid" = "$target_wid" ] && exit 0

# Focus the exact target window, retrying until it sticks (beats the MRU race).
# ponytail: best-effort — restoring the last-focused window (above) can re-expose the
# #101 same-app grab; more retries here just add latency without winning. The reliable
# fix is disabling macOS "Displays have separate Spaces" (README / FIXES.md invariant A).
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
