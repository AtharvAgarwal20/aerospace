# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ Read `FIXES.md` FIRST — every session, before any edit

[`FIXES.md`](./FIXES.md) is the regression guard: a registry of behaviors that were
deliberately fixed and keep getting broken by later changes. **Open it and run its
preflight checklist before editing `aerospace.toml`, any `*.sh`, or `README.md`.** In
this repo, fixes step on each other (e.g. the workspace-focus fix vs. the accordion-top
fix — see invariant A); do not "simplify" or refactor code without checking which
invariant it protects. After a change, run the affected invariant's **Verify** step.

## What this is

A personal [AeroSpace](https://nikitabobko.github.io/AeroSpace/) (i3-inspired tiling WM for macOS) configuration. There is no build/test/lint step — `aerospace.toml` is declarative TOML and the `.sh` files are plain bash. "Running" means reloading the config or invoking the `aerospace` CLI.

## Commands

```bash
# Reload config after editing aerospace.toml (also done via Service mode: alt+shift+; then esc)
aerospace reload-config

# Validate config without applying
aerospace config --get <key>          # read effective value
aerospace list-windows --all          # inspect window/app-ids for on-window-detected rules

# Find an app's bundle id for a new [[on-window-detected]] rule
mdls -name kMDItemCFBundleIdentifier /Applications/YourApp.app

# Monitor scripts (must be chmod +x)
~/.config/aerospace/monitor-setup.sh          # auto-distribute workspaces by monitor count
cat /tmp/aerospace-monitor-setup.log          # its log output
```

## Architecture

Three layers that must be kept consistent with each other:

1. **`aerospace.toml`** — the single source of truth AeroSpace actually loads. Contains binding modes, auto-assignment rules, and static monitor pinning. Editing this + `reload-config` is the normal change path.

2. **Monitor scripts** — `monitor-setup.sh` (called manually or from `after-startup-command`, currently empty) detects monitor count via `system_profiler` and distributes workspaces with `move-workspace-to-monitor`. `save-monitor-layout.sh` / `apply-monitor-layout.sh` snapshot and restore layouts to `monitor-layouts.conf` (gitignored / runtime-generated). These scripts run **imperative** `aerospace` CLI commands and can override the static assignments in step 3 at runtime.

3. **`README.md`** — extensive human-facing documentation (keybinding tables, cheat sheet, workflows). It duplicates the keybindings and rules from the TOML, so **any change to bindings, workspace names, app assignments, or monitor pinning in `aerospace.toml` must be mirrored in `README.md`** or the two drift.

### Binding modes

`main` (default) → `resize` (`alt+shift+r`) and `service` (`alt+shift+;`). Service mode's `esc` reloads the config. Note `alt+shift+{j,k,i,l}` is overloaded: it **moves** windows in main mode but **joins** containers in service mode. Focus/move use `j/k/i/l` = left/down/up/right (not standard vim `h/j/k/l`).

### Workspace model

Numbered workspaces `1`–`10` (`alt-0` = 10) plus named single-app workspaces (`S`, `W`, `B`, `D`, `Z`, `U`, `N`, `P`, `X`). Named workspaces are tied together by **three** places that must agree: the `alt-<key>` binding, the `[[on-window-detected]]` rule routing the app there, and (for some) `[workspace-to-monitor-force-assignment]`. Adding/renaming a workspace means updating all relevant ones plus the README.

## Known inconsistencies (verify before relying on these)

- `save-monitor-layout.sh` iterates workspaces `1..9 T S` — `T` is not a workspace that exists in the config, and named workspaces (W, B, D, Z, U, N, P, X) are omitted. It also calls `get-workspace-monitor` / `get-workspace-layout` / `set-workspace-layout`, which may not match the installed AeroSpace CLI's command names.
- `monitor-setup.sh` hard-codes "workspaces 1–5 → external, 6–10 + S → main" and assumes the external monitor is the **right** one. This conflicts with the static `[workspace-to-monitor-force-assignment]` in `aerospace.toml` (which pins S, Z, 8, 9, 10 to `secondary`). Whichever runs last wins; the script does not touch the named workspaces beyond S.
