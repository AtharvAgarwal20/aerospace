# AeroSpace — Tiling Window Manager Config

> An [i3](https://i3wm.org/)-inspired tiling window manager for macOS.  
> This repo contains my personal AeroSpace configuration with keybindings, auto-assignment rules, monitor management scripts, and multi-monitor workspace routing.

---

## Table of Contents

- [Installation \& Setup](#installation--setup)
  - [Install AeroSpace](#1-install-aerospace)
  - [Clone This Config](#2-clone-this-config)
  - [Make Scripts Executable](#3-make-scripts-executable)
  - [Start AeroSpace](#4-start-aerospace)
- [Repository Structure](#repository-structure)
- [Configuration Overview](#configuration-overview)
  - [Core Settings](#core-settings)
  - [Normalizations](#normalizations)
  - [Gaps](#gaps)
  - [Mouse Behaviour](#mouse-behaviour)
- [Binding Modes](#binding-modes)
- [Main Mode](#main-mode)
  - [Layout](#layout)
  - [Focus (Navigate Windows)](#focus-navigate-windows)
  - [Move Windows](#move-windows)
  - [Close Window](#close-window)
  - [Workspace Navigation](#workspace-navigation)
  - [Move Window to Workspace](#move-window-to-workspace)
  - [Monitor Management](#monitor-management)
  - [Enter Other Modes](#enter-other-modes)
- [Resize Mode](#resize-mode)
- [Service Mode](#service-mode)
- [Auto-Assignment Rules](#auto-assignment-rules)
- [Monitor Assignments](#monitor-assignments)
- [Helper Scripts](#helper-scripts)
  - [focus-workspace.sh](#focus-workspacesh)
  - [monitor-setup.sh](#monitor-setupsh)
  - [save-monitor-layout.sh](#save-monitor-layoutsh)
  - [apply-monitor-layout.sh](#apply-monitor-layoutsh)
- [Common Workflows](#common-workflows)
- [Quick Reference Card](#quick-reference-card)
- [Customization Tips](#customization-tips)

---

## Installation & Setup

### 1. Install AeroSpace

Install via [Homebrew](https://brew.sh/):

```bash
brew install --cask nikitabobko/tap/aerospace
```

Alternatively, download the latest release from the [AeroSpace GitHub releases page](https://github.com/nikitabobko/AeroSpace/releases).

### 2. Clone This Config

AeroSpace looks for its config at `~/.config/aerospace/aerospace.toml` (or `~/.aerospace.toml`). Clone this repo directly into your config directory:

```bash
# Back up any existing config
mv ~/.config/aerospace ~/.config/aerospace.bak 2>/dev/null

# Clone
git clone <your-repo-url> ~/.config/aerospace
```

Or, if you manage dotfiles with a symlink approach:

```bash
git clone <your-repo-url> ~/dotfiles/aerospace
ln -s ~/dotfiles/aerospace ~/.config/aerospace
```

### 3. Make Scripts Executable

The helper scripts need execute permissions:

```bash
chmod +x ~/.config/aerospace/focus-workspace.sh
chmod +x ~/.config/aerospace/monitor-setup.sh
chmod +x ~/.config/aerospace/save-monitor-layout.sh
chmod +x ~/.config/aerospace/apply-monitor-layout.sh
```

### 4. Start AeroSpace

Launch AeroSpace from your Applications folder, or run:

```bash
open -a AeroSpace
```

The config has `start-at-login = true`, so after the first launch AeroSpace will start automatically on every login. To reload the config without restarting, enter **Service mode** (`alt + shift + ;`) and press `Esc`.

> [!NOTE]
> You'll need to grant AeroSpace **Accessibility permissions** in  
> **System Settings → Privacy & Security → Accessibility**  
> for it to manage your windows.

> [!NOTE]
> **Multi-monitor focus quirk.** Switching to a workspace whose app has another window of the
> *same app* on another monitor can focus the wrong window — a macOS Accessibility limitation
> (AeroSpace "is not the focus owner"). The `alt + <workspace>` keys are routed through
> [`focus-workspace.sh`](#focus-workspacesh) as a best-effort workaround. The only fully reliable
> fix is disabling macOS "Displays have separate Spaces" (`defaults write com.apple.spaces
> spans-displays -bool true`, then log out), but that makes macOS **native** fullscreen blank the
> other monitor — so it's left as an opt-in choice, not the default.

---

## Repository Structure

```
~/.config/aerospace/
├── aerospace.toml              # Main AeroSpace configuration
├── focus-workspace.sh          # Best-effort fix for cross-monitor same-app focus
├── monitor-setup.sh            # Auto-detects monitor count and distributes workspaces
├── save-monitor-layout.sh      # Saves current workspace-to-monitor assignments
├── apply-monitor-layout.sh     # Restores a previously saved monitor layout
└── README.md                   # This guide
```

---

## Configuration Overview

### Core Settings

| Setting | Value | Description |
|---|---|---|
| `start-at-login` | `true` | AeroSpace launches automatically on login |
| `key-mapping.preset` | `qwerty` | Keybinds mapped for standard QWERTY layout |
| `default-root-container-layout` | `tiles` | New workspaces default to tiled (side-by-side) |
| `default-root-container-orientation` | `auto` | Wide monitors → horizontal; tall monitors → vertical |
| `accordion-padding` | `30` | 30px padding around accordion-stacked windows |

### Normalizations

Both are **enabled**:

- **Flatten containers** — prevents unnecessarily deep nesting in the window tree
- **Opposite orientation for nested containers** — nested containers automatically get the perpendicular orientation (e.g., horizontal inside vertical), mimicking i3's default behaviour

### Gaps

All gaps are set to a uniform **10px**:

```
┌──────────────────────────────────────────┐
│ 10px outer top                           │
│  ┌────────────┐ 10px  ┌────────────┐    │
│  │            │ inner  │            │    │
│  │  Window A  │◄─────►│  Window B  │    │
│  │            │  gap   │            │    │
│  └────────────┘        └────────────┘    │
│ 10px outer bottom                        │
└──────────────────────────────────────────┘
  10px                              10px
  outer                             outer
  left                              right
```

### Mouse Behaviour

| Event | Action |
|---|---|
| Focused **monitor** changes | Mouse warps to center of monitor (lazy) |
| Focused **window** changes | Mouse warps to center of window (lazy) |

> **"Lazy"** means the mouse only moves if it isn't already inside the target area — no jarring teleports when you're already on the correct screen/window.

---

## Binding Modes

The config defines **three modes**. You always start in `main`.

```
                  alt+shift+r            alt+shift+;
    ┌──────────┐ ────────────► ┌────────┐          ┌─────────┐
    │   MAIN   │               │ RESIZE │          │ SERVICE │
    │  (default)│ ◄──────────── │        │          │         │
    └──────────┘  enter / esc  └────────┘          └─────────┘
         ▲                                              │
         └──────────────── esc (+ reload config) ───────┘
```

---

## Main Mode

### Layout

| Keybind | Command | Description |
|---|---|---|
| `alt + /` | `layout tiles horizontal vertical` | Cycle through tiling orientations |
| `alt + ,` | `layout accordion horizontal vertical` | Cycle through accordion orientations |
| `alt + shift + F` | `fullscreen` | Toggle fullscreen for focused window |

### Focus (Navigate Windows)

| Keybind | Direction |
|---|---|
| `alt + J` | Focus **left** |
| `alt + K` | Focus **down** |
| `alt + I` | Focus **up** |
| `alt + L` | Focus **right** |

> **Mnemonic:** `J-K-I-L` works like an arrow cluster — **J** (←), **K** (↓), **I** (↑), **L** (→).

### Move Windows

| Keybind | Direction |
|---|---|
| `alt + shift + J` | Move window **left** |
| `alt + shift + K` | Move window **down** |
| `alt + shift + I` | Move window **up** |
| `alt + shift + L` | Move window **right** |

### Close Window

| Keybind | Command |
|---|---|
| `alt + shift + Q` | Close the focused window/tile |

### Workspace Navigation

#### Numbered Workspaces

| Keybind | Workspace |
|---|---|
| `alt + 1` … `alt + 9` | Workspace **1** – **9** |
| `alt + 0` | Workspace **10** |

#### Named Workspaces

| Keybind | Workspace | Intended Use |
|---|---|---|
| `alt + S` | **S** | Spotify |
| `alt + W` | **W** | WhatsApp |
| `alt + D` | **D** | Discord |
| `alt + Z` | **Z** | Zoom |
| `alt + U` | **U** | Figma |
| `alt + N` | **N** | Neat Download Manager / Docker / Wispr Flow |
| `alt + P` | **P** | Brave Browser |

#### Quick Switching

| Keybind | Command | Description |
|---|---|---|
| `alt + Tab` | `workspace-back-and-forth` | Toggle between current and previous workspace |
| `alt + shift + →` | `workspace --wrap-around next` | Next workspace (wraps) |
| `alt + shift + ←` | `workspace --wrap-around prev` | Previous workspace (wraps) |

### Move Window to Workspace

Add **shift** to the workspace keybind — the window moves and you follow it:

| Keybind | Action |
|---|---|
| `alt + shift + 1` … `alt + shift + 9` | Move window to workspace **1–9** and switch |
| `alt + shift + 0` | Move window to workspace **10** and switch |
| `alt + shift + S/W/D/Z/U/N/P` | Move window to named workspace and switch |

### Monitor Management

| Keybind | Command | Description |
|---|---|---|
| `alt + shift + Tab` | `move-workspace-to-monitor --wrap-around next` | Move the **entire workspace** to the next monitor |

### Enter Other Modes

| Keybind | Target Mode |
|---|---|
| `alt + shift + ;` | Enter **Service** mode |
| `alt + shift + R` | Enter **Resize** mode |

---

## Resize Mode

> **Enter:** `alt + shift + R` · **Exit:** `Enter` or `Esc`

Once in resize mode, adjust window sizes **without holding modifiers**:

| Key | Action |
|---|---|
| `H` | Shrink width by 50px |
| `L` | Grow width by 50px |
| `K` | Shrink height by 50px |
| `J` | Grow height by 50px |
| `B` | **Balance** all window sizes equally |
| `-` | Smart shrink (−50px, auto-detected axis) |
| `=` | Smart grow (+50px, auto-detected axis) |
| `Enter` / `Esc` | Return to **main** mode |

> `resize smart` automatically picks the axis (width or height) based on the tiling direction of the current container.

---

## Service Mode

> **Enter:** `alt + shift + ;` · **Exit:** `Esc` (also **reloads config**)

Service mode provides maintenance and layout-manipulation commands:

| Key | Action |
|---|---|
| `Esc` | **Reload config** and return to main mode |
| `R` | **Flatten workspace tree** — reset layout nesting |
| `F` | Toggle between **floating** and **tiling** for focused window |
| `Backspace` | **Close all windows** except the focused one |

### Join Operations (Service Mode)

Merge the focused window into an adjacent container:

| Keybind | Direction |
|---|---|
| `alt + shift + J` | Join with **left** neighbour |
| `alt + shift + K` | Join with **down** neighbour |
| `alt + shift + I` | Join with **up** neighbour |
| `alt + shift + L` | Join with **right** neighbour |

> These use the same keys as main-mode move bindings but behave differently in service mode. After each join, you're automatically returned to main mode.

---

## Auto-Assignment Rules

These apps are automatically routed to dedicated workspaces when they open:

| App | Bundle ID | → Workspace |
|---|---|---|
| Spotify | `com.spotify.client` | **S** |
| WhatsApp | `net.whatsapp.WhatsApp` | **W** |
| Zoom | `us.zoom.xos` | **Z** |
| Discord | `com.hnc.Discord` | **D** |
| Figma | `com.figma.Desktop` | **U** |
| Neat Download Manager | `com.NeatDownloadManager` | **N** |
| Brave Browser | `com.brave.Browser` | **P** |
| Docker | `com.electron.dockerdesktop` | **N** |
| Wispr Flow | `com.electron.wispr-flow` | **N** |

To find the bundle ID of any app:

```bash
mdls -name kMDItemCFBundleIdentifier /Applications/YourApp.app
```

---

## Monitor Assignments

Certain workspaces are permanently pinned to the **secondary monitor**:

| Workspace | Monitor |
|---|---|
| **S** (Spotify) | Secondary |
| **Z** (Zoom) | Secondary |
| **8** | Secondary |
| **9** | Secondary |
| **10** | Secondary |

All other workspaces default to the primary monitor. Use `alt + shift + Tab` to manually move a workspace between monitors.

---

## Helper Scripts

### `focus-workspace.sh`

Best-effort workaround for the macOS bug where switching to a workspace focuses the *wrong* window
of the same app on another monitor (macOS focuses the most-recently-used instance; AeroSpace isn't
the focus owner). Every `alt + <workspace>` key routes through it. Instead of a bare workspace
switch — the command that makes macOS grab the wrong window — it focuses an *exact* window that
lives on the target workspace (which also switches to it), retrying briefly to beat the race, then
repairs the monitor you left if it still got flipped. Empty workspaces fall back to a plain switch.

It restores the window you *last left focused* on that workspace (recorded to `/tmp/aerospace-last-focus-<ws>`
each time you switch away), so in accordion mode the window you left on top stays on top instead of
always snapping to the first window. Leaving via mouse click / `alt+tab` / `alt+shift+←→` isn't
recorded, so those fall back to the last `alt+<ws>` value or the first window.

> [!NOTE]
> **Best-effort** — the macOS focus race can still occasionally win, and the retries add slight
> latency on cross-monitor switches. The only fully reliable fix is disabling "Displays have
> separate Spaces" (see the macOS note under [Start AeroSpace](#4-start-aerospace)).

### `monitor-setup.sh`

Automatically detects how many monitors are connected and distributes workspaces accordingly.

| Monitors Detected | Behaviour |
|---|---|
| **1** (laptop only) | All workspaces assigned to the single display |
| **2** (dual setup) | Workspaces 1–5 → external monitor; 6–10 + S → main; focuses WS 6 on main |
| **3+** (multi) | Same as dual — uses main + one external |

**Run manually:**

```bash
~/.config/aerospace/monitor-setup.sh
```

**Check logs:**

```bash
cat /tmp/aerospace-monitor-setup.log
```

### `save-monitor-layout.sh`

Snapshots the current workspace-to-monitor mapping and per-workspace layouts to `~/.config/aerospace/monitor-layouts.conf`.

```bash
~/.config/aerospace/save-monitor-layout.sh
```

### `apply-monitor-layout.sh`

Restores a previously saved layout from `monitor-layouts.conf`.

```bash
~/.config/aerospace/apply-monitor-layout.sh
```

---

## Common Workflows

### Coding Session

1. Open your editor — it lands on your current workspace (e.g., **1**)
2. Open Brave — auto-assigned to workspace **P**
3. Open a terminal alongside your editor in workspace **1**
4. Use `alt + /` to toggle horizontal/vertical splits
5. Bounce between code and browser with `alt + 1` / `alt + P`, or `alt + Tab`

### Resizing a Split

1. Focus the window you want to resize
2. `alt + shift + R` → enter resize mode
3. `H` / `L` for width, `J` / `K` for height
4. `B` to equalize all windows
5. `Enter` or `Esc` to exit

### Cleaning Up a Messy Layout

1. `alt + shift + ;` → enter service mode
2. `R` → flatten the workspace tree
3. You're back in main mode — rearrange as needed

### Toggling a Window to Float

1. `alt + shift + ;` → enter service mode
2. `F` → window becomes floating (or tiling if already floating)
3. Automatically returned to main mode

### Moving a Workspace to Another Monitor

1. Focus the workspace you want to move
2. `alt + shift + Tab` → workspace hops to the next monitor

---

## Quick Reference Card

```
╔══════════════════════════════════════════════════════════════╗
║                    AEROSPACE CHEAT SHEET                     ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  NAVIGATE          MOVE WINDOW        WORKSPACES             ║
║  alt+j  ← left     alt+shift+j ←     alt+1..9,0  #1-10     ║
║  alt+k  ↓ down     alt+shift+k ↓     alt+s/w/d/  named     ║
║  alt+i  ↑ up       alt+shift+i ↑      z/u/n/p               ║
║  alt+l  → right    alt+shift+l →     alt+tab     toggle     ║
║                                                              ║
║  LAYOUT            WINDOW             MONITORS               ║
║  alt+/  tile mode  alt+shift+q close  alt+shift+tab move ws  ║
║  alt+,  accordion  alt+shift+f full   alt+shift+→  next ws   ║
║                                       alt+shift+←  prev ws   ║
║                                                              ║
║  MODES                                                       ║
║  alt+shift+r  → resize mode    alt+shift+;  → service mode  ║
║                                                              ║
║  RESIZE MODE         SERVICE MODE                            ║
║  h/l  width ±50      esc    reload config                    ║
║  j/k  height ±50     r      flatten layout                   ║
║  b    balance         f      toggle float                    ║
║  -/=  smart ±50      bksp   close other windows             ║
║  enter/esc → main    alt+shift+jkil  join windows            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## Customization Tips

- **Add a new app auto-assignment** — append an `[[on-window-detected]]` block to `aerospace.toml`:
  ```toml
  [[on-window-detected]]
  if.app-id = 'com.example.MyApp'
  run = "move-node-to-workspace X"
  ```

- **Change gap sizes** — edit the `[gaps]` section. You can also use per-monitor values:
  ```toml
  [gaps]
  outer.top = [{ monitor.main = 10 }, { monitor."external" = 20 }, 8]
  ```

- **Add startup commands** — populate `after-startup-command` to run commands on launch:
  ```toml
  after-startup-command = [
      'exec-and-forget ~/.config/aerospace/monitor-setup.sh'
  ]
  ```

- **Pin workspaces to monitors** — use `[workspace-to-monitor-force-assignment]`:
  ```toml
  [workspace-to-monitor-force-assignment]
  S = "secondary"
  1 = "main"
  ```

---

## Resources

- [AeroSpace Documentation](https://nikitabobko.github.io/AeroSpace/)
- [AeroSpace Commands Reference](https://nikitabobko.github.io/AeroSpace/commands)
- [AeroSpace GitHub](https://github.com/nikitabobko/AeroSpace)
- [Default Config Reference](https://nikitabobko.github.io/AeroSpace/guide#default-config)
