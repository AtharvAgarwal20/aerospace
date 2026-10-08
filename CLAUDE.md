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

```

## Architecture

Three layers that must be kept consistent with each other:

1. **`aerospace.toml`** — the single source of truth AeroSpace actually loads. Contains binding modes, auto-assignment rules, and static monitor pinning. Editing this + `reload-config` is the normal change path.

2. **Scripts** — `focus-workspace.sh` (every `alt-<ws>` switch; see FIXES.md A) and `save-monitor-layout.sh` / `apply-monitor-layout.sh`, which snapshot and restore workspace→monitor assignments to `monitor-layouts.conf` (runtime-generated). Those two run **imperative** `aerospace` CLI commands and can override the static `[workspace-to-monitor-force-assignment]` at runtime.

3. **`README.md`** — extensive human-facing documentation (keybinding tables, cheat sheet, workflows). It duplicates the keybindings and rules from the TOML, so **any change to bindings, workspace names, app assignments, or monitor pinning in `aerospace.toml` must be mirrored in `README.md`** or the two drift.

### Binding modes

`main` (default) → `resize` (`alt+shift+r`) and `service` (`alt+shift+;`). Service mode's `esc` reloads the config. Note `alt+shift+{j,k,i,l}` is overloaded: it **moves** windows in main mode but **joins** containers in service mode. Focus/move use `j/k/i/l` = left/down/up/right (not standard vim `h/j/k/l`).

### Workspace model

Numbered workspaces `1`–`10` (`alt-0` = 10) plus named single-app workspaces (`S`, `W`, `D`, `Z`, `U`, `N`, `P`, `E`). Named workspaces are tied together by **three** places that must agree: the `alt-<key>` binding, the `[[on-window-detected]]` rule routing the app there, and (for some) `[workspace-to-monitor-force-assignment]`. Adding/renaming a workspace means updating all relevant ones plus the README.
