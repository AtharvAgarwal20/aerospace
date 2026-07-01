# FIXES.md — regression guard

**Read this before changing `aerospace.toml`, any `*.sh`, or `README.md`.**

Each entry below is a behavior that was deliberately fixed and must keep working.
Every fix here was hard-won and at least one later change already broke another —
so before you edit, find the invariant(s) your change touches, and after you edit,
run that invariant's **Verify** step. Do not "clean up" code an invariant depends on
without re-reading why it exists.

## Preflight checklist (every change)

- [ ] Which invariant(s) below does this touch? (Grep the file you're editing here first.)
- [ ] Does the change alter a keybinding, workspace name, app assignment, or monitor pin?
      → mirror it in `README.md` (invariant **D**).
- [ ] Does it touch `focus-workspace.sh` or the `alt-<n>` bindings? → invariants **A** + **B**.
- [ ] Does it touch an `[[on-window-detected]]` rule? → invariant **C** (and re-sync graphify).
- [ ] Run the **Verify** step for each invariant you touched. Config changes to the TOML
      need `aerospace reload-config`; editing a `.sh` takes effect immediately (re-run per keypress).

---

## A. Workspace switch focuses the RIGHT window (two entangled fixes)

**These two conflict and must be reasoned about together.** Commit `fb34e10` +
this-session accordion fix. All in `focus-workspace.sh`, invoked by every `alt-<n>` binding.

**A1 — Cross-monitor same-app focus (bug #101).** Switching to a workspace whose app
has *another window of the same app on the other monitor* used to focus the wrong
(most-recently-used) twin, because macOS owns focus and picks by app-recency.
Guarantee: `alt-<n>` focuses a window that actually lives on the target workspace.
Mechanism: never issue a bare `aerospace workspace <n>` (that triggers the macOS grab);
instead `aerospace focus --window-id <exact-wid>`, retried until it sticks.

**A2 — Accordion top is preserved.** `alt-<n>` must restore the window you *last left
focused* on that workspace (so in accordion mode the one you left on top stays on top),
NOT a fixed "first" window. Mechanism: on switch-away the script records the focused
window to `/tmp/aerospace-last-focus-<ws>`; on return it focuses that (validated it's
still there), falling back to the first window only if unknown/gone.

**The trap (this literally happened):** A2 was originally implemented as `head -n1`
(always focus the first window). That accidentally satisfied A1 too — the first window
was often a *different* app, which has no same-app twin, so no macOS grab. When A2 was
fixed to restore the true last-focused window, that window can be the same app that has
a twin on the other monitor → A1's bug re-appears. The retry loop re-asserts focus to
beat the grab-back, but this is **best-effort** (the loop can still lose the race; more
retries only add switch latency — each is a slow AeroSpace CLI round-trip — without
winning reliably). The reliable fix is the macOS setting below, not the script.

**The only fully reliable fix for A1** is a macOS setting, not code: disable
"Displays have separate Spaces". If it's ever turned on again, A1 comes back.
```bash
defaults read  com.apple.spaces spans-displays          # 1 = OFF (good), 0/unset = ON (bug present)
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer   # then LOG OUT
```
Tradeoffs of disabling: menu bar only on main monitor; per-monitor fullscreen breaks
(the other monitor goes black while one is fullscreen). Windows can then span monitors.

**Do NOT** "simplify" `focus-workspace.sh` back to a bare `workspace` switch (breaks A1),
and do NOT drop the recording / go back to `head -n1` (breaks A2).

**Verify (both, without a second monitor):**
```bash
cd ~/.config/aerospace
# A2: seed "last left the 2nd window", confirm it (not the first) gets focused.
ws=2                                   # a workspace with >=2 windows
first=$( aerospace list-windows --workspace $ws --format '%{window-id}' | sed -n 1p)
second=$(aerospace list-windows --workspace $ws --format '%{window-id}' | sed -n 2p)
printf '%s' "$second" > /tmp/aerospace-last-focus-$ws
./focus-workspace.sh $ws
aerospace list-windows --focused --format '%{window-id} %{app-name}'   # expect $second, not $first
```
A1 needs a real dual-monitor same-app setup: open the same app on both monitors, focus
its twin on monitor B, `alt-<n>` to its workspace on monitor A, confirm the monitor-A
window (not the twin) ends up focused.

---

## B. `alt-<n>` routing integrity

Every `alt-<workspace>` binding must route through `focus-workspace.sh` (see A), for
BOTH numbered (`1`–`10`) and named (`S W D Z U N P`) workspaces. `alt-shift-<n>` is the
*move-node-to-workspace* path and is separate — don't collapse the two.
Named workspaces still obey the "three places must agree" rule (binding +
`[[on-window-detected]]` + optional `[workspace-to-monitor-force-assignment]`).

**Verify:** `grep -c 'focus-workspace.sh' aerospace.toml` — count must equal the number
of `alt-<workspace>` switch bindings (not the `alt-shift-` move bindings).

---

## C. App auto-routing rules (`[[on-window-detected]]`)

Apps are pinned to workspaces by **bundle id**, which is not always the obvious one —
Electron apps report an Electron id (commit `804ca13`: Docker is `com.electron.dockerdesktop`,
not a `docker`-ish id). Getting the id wrong silently sends the app to the wrong
workspace (or nowhere).

Also: the graphify knowledge graph (`graphify-out/`, commit `17fc6b6`) mirrors these
bundle ids. If you change an `[[on-window-detected]]` `app-id`, re-sync the graph map.

**Verify a rule:** launch the app, then
`aerospace list-windows --all --format '%{workspace} %{app-name} %{app-bundle-id}'` —
confirm it landed on the intended workspace and the bundle id matches the rule.
Find an id: `mdls -name kMDItemCFBundleIdentifier /Applications/YourApp.app`.

---

## D. Three-layer doc sync

`aerospace.toml` is the source of truth. Any change to a **keybinding, workspace name,
app assignment, or monitor pin** must be mirrored in `README.md` (it duplicates all of
them) — and any behavioral change to a script must be reflected in both `README.md`'s
script section and here in `FIXES.md`. TOML ↔ README ↔ FIXES drift is the #1 recurring
problem in this repo.

**Verify:** after a binding/workspace/app/monitor change, re-read the matching section
of `README.md` and confirm it says the same thing.

---

## E. Monitor pinning: static vs. imperative (known conflict)

Static `[workspace-to-monitor-force-assignment]` in the TOML (pins `S Z 8 9 10` →
`secondary`) and the imperative `monitor-setup.sh` ("1–5 → external, 6–10 + S → main")
disagree. Whichever runs last wins. `save-monitor-layout.sh` also iterates a stale
workspace list (`1..9 T S` — `T` doesn't exist; named workspaces omitted) and calls CLI
subcommands that may not match the installed AeroSpace. Treat these scripts as suspect;
don't wire them into `after-startup-command` without re-checking against the current CLI.
