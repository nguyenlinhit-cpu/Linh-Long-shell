# 🌌 Linh-Long Desktop Shell

> **The Ultimate Wayland Desktop Shell**: Built by combining the breathtaking Material 3 aesthetics of **`dots-hyprland`**, the unified zero-fork monolithic architecture of **`noctalia`**, and the hardware-accelerated fluid SceneGraph engine of **`quickshell`**.

> 📖 **Installation Guides**: [**Arch Linux (Hyprland & Niri)**](INSTALL_ARCH.md) | [**NixOS (Hyprland & Niri)**](INSTALL_NIXOS.md)

---

## 🌟 The 3-Way Synthesis: Best of All 3, None of the Weaknesses

| Architectural Layer | Origin Shell | What Was Inherited (Strengths) | What Was Eliminated (Weaknesses Removed) |
| :--- | :--- | :--- | :--- |
| **Aesthetics & UI System** | `dots-hyprland` (end-4 / ii) | **Material Design 3 (Material You)** dynamic tonal palette, 5-layer elevation system (`layer0`–`layer4`), adaptive glassmorphism transparency, expressive spring motion curves, squircle buttons. | **Eliminated 243+ bash subprocess forks** (`bash -c "pkill..."`, `cliphist decode \| wl-copy`, `lscpu \| awk`). Eliminated multi-daemon fragmentation (`swww`, `hyprlock`, `mako`, `wlogout`). |
| **Daemon & Core Architecture** | `noctalia` | **Unified Monolithic Shell**: Built-in Lock Screen (`ext-session-lock-v1` with PAM), built-in Notification Server, GPU wallpaper transitions, OSD, System Monitor, and single declarative `config.toml` with hot-reload. | **Eliminated rigid/plain OpenGL ES UI**: Upgraded to QtQuick 6 SceneGraph for fluid spring physics, glass blur, rich typography, and infinite visual expressiveness. Added AI Copilot and PipeWire stream mixer. |
| **Graphics & Protocol Engine** | `quickshell` | **QtQuick 6 SceneGraph**: Hardware-accelerated Vulkan/OpenGL rendering, 144Hz+ butter-smooth frame pacing, native C++ protocol bindings (`Pipewire`, `Mpris`, `Notifications`, `Pam`, `Upower`, `SessionLock`, `Layershell`, `Toplevel`). | **Eliminated raw engine barrier**: Built a complete, turnkey desktop shell that requires zero initial setup and provides clean declarative TOML configuration. |

---

## 🚀 Complete Feature Inventory (21 Integrated Modules)

1. **Dynamic Island Top Bar (`modules/bar`)**:
   - Workspaces pills with running application icons & active window title.
   - Interactive Clock that expands into a rich month-matrix Calendar popup.
   - Live media pill with track title and quick play/pause.
   - Zero-fork hardware micro-meters (CPU & RAM), PipeWire volume wheel, battery status.
   - One-click trigger buttons for Clipboard, Control Center, Settings, and Power.

2. **Smart Auto-Hiding Magnification Dock (`modules/dock`)**:
   - macOS-grade fluid magnification curve on mouse hover.
   - Running app indicator dots and live XDG desktop entry resolution.
   - NixOS Home button (`` / `󰣇`) for instant launcher access.
   - Quick buttons for Clipboard History (`󰅍`), Window Overview (`󰕰`), and Power Menu (`󰐥`).

3. **Multi-Provider Spotlight Launcher (`modules/launcher`)**:
   - Instant XDG application search with live icons and execution.
   - Math calculations (`/calc 42 * 1.5` or `42 * 1.5`).
   - Emoji search (`/emoji cat` or `:smile:`).
   - Web searches (`/g query`, `/ddg query`).
   - Quick power commands (`shutdown`, `reboot`, `lock`, `logout`).

4. **3-Tab Glassmorphic Control Center (`modules/controlCenter`)**:
   - **Tab 1: Controls & Audio Mixer**:
     - Quick Toggles: Wi-Fi, Bluetooth, Night Light, Do Not Disturb, Microphone Mute, Screen Snip.
     - Sliders: Master Volume, Display Backlight Brightness (`BrightnessService`), and Night Light warmth.
     - PipeWire Application Mixer: Independent volume sliders for each running audio app (Firefox, Spotify, Discord).
     - MPRIS media card with cover art, track info, and playback controls.
   - **Tab 2: Notification History**:
     - Full history of desktop notifications with timestamps, individual dismiss, and "Clear All".
   - **Tab 3: Widgets & Focus**:
     - Live Weather forecast (`wttr.in`) with condition, humidity, wind, and temperature.
     - Pomodoro Focus Timer with 25m work / 5m break interval notifications.
     - Interactive Tasks Checklist & Quick Scratchpad Notes.

5. **Clipboard History Manager (`modules/clipboard`)**:
   - Instant search across recent clipboard entries (`Super + V`).
   - Text previews, character counts, and timestamps.
   - Click to copy back to clipboard, pin favorite clips, or delete entries.

6. **Alt-Tab Window Switcher HUD (`modules/switcher`)**:
   - Centered frosted glass carousel (`Alt + Tab`).
   - Large app icons, window titles, and application classes.
   - Cycle with Tab/Arrows, focus with Enter, or cancel with Esc.

7. **Workspaces & Running Windows Overview (`modules/overview`)**:
   - Visual workspace bar (workspaces 1–10).
   - Live running window cards across all monitors.
   - Interactive window search and one-click close buttons (`󰅖`).

8. **Floating Media Player Controller (`modules/mediaControls`)**:
   - Floating popover card (`Super + M` or clicking bar media pill).
   - Album art, track title, artist, album name.
   - Interactive seeking scrubber progress bar.
   - Shuffle, previous, play/pause, next, loop, and volume slider.

9. **Polkit GUI Authentication Agent (`modules/polkit`)**:
   - Native Wayland Polkit agent dialog for privilege escalation (`sudo`, `pkexec`).
   - Password prompt with security icon and failure retry feedback.

10. **Desktop Backdrop Layer & Desktop Widgets (`modules/desktop`)**:
    - Wallpaper backdrop layer (`WlrLayer.Background`) behind all windows.
    - Large aesthetic desktop digital clock & full date.
    - Desktop hardware monitor (CPU, RAM, Weather pills).
    - Right-click desktop context menu (Change Wallpaper, Terminal, Launcher, Overview, Settings, Lock, Power).

11. **Hot Corners Gestures (`modules/hotCorners`)**:
    - Top-Left: Trigger Workspaces & Window Overview.
    - Top-Right: Trigger Quick Settings Control Center.
    - Bottom-Left: Trigger App Launcher.

12. **Curved Screen Hardware Bezels (`modules/screenCorners`)**:
    - 4 aesthetic rounded monitor corners overlay giving modern hardware curvature.

13. **Region Snip Screenshot Tool (`modules/regionSelector`)**:
    - Interactive crosshair drag-to-snip overlay (`Print` / `Super + Shift + S`).
    - Live dimension badge and auto-copy to clipboard via `grim` + `wl-copy`.

14. **Wallpaper & Material You Theme Studio (`modules/wallpaperSelector`)**:
    - Visual wallpaper gallery grid with thumbnails.
    - Random wallpaper button.
    - Real-time Material 3 tonal palette generation from wallpaper colors.

15. **Graphical Settings Dialog (`modules/settings`)**:
    - Theme presets: Dynamic M3, Catppuccin, Tokyo Night, Dracula, Nord, Pure OLED.
    - Dark / Light mode toggle.
    - Dock autohide and corner curvature sliders.

16. **Fullscreen Session & Power Menu (`modules/sessionScreen`)**:
    - 6 power actions: Shutdown, Restart, Suspend, Lock, Logout, Hibernate.
    - User avatar, uptime, and battery stats.
    - Hotkeys: `S`, `R`, `U`, `L`, `O`, `H`, `Esc`.

17. **Native Secure Lock Screen (`modules/lockscreen`)**:
    - Official Wayland `ext-session-lock-v1` protocol: Cannot be bypassed.
    - Linux PAM authentication with unlock animation.

18. **Keybindings Cheatsheet Modal (`modules/cheatsheet`)**:
    - Categorized Hyprland/Linh-Long shortcuts with live filter search (`Super + /`).

19. **AI Copilot Sidebar (`modules/aiSidebar`)**:
    - Local LLM via Ollama (`http://localhost:11434`) or cloud API.

20. **On-Screen Display HUD (`modules/osd`)**:
    - Sleek pill HUD feedback for volume and brightness adjustments.

21. **Notification Toast Daemon (`modules/notifications`)**:
    - Rich desktop notifications with action buttons and dismiss animations.

---

## ⌨️ Global Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Super + Space` | Toggle Spotlight App Launcher |
| `Super + C` | Toggle Quick Settings & Audio Mixer |
| `Super + V` | Toggle Clipboard History Manager |
| `Alt + Tab` | Toggle Window Switcher Carousel |
| `Super + Tab` | Toggle Workspaces & Window Overview |
| `Super + M` | Toggle Floating Music Controller |
| `Super + W` | Toggle Wallpaper & Theme Studio |
| `Super + Comma` | Toggle Graphical Settings Dialog |
| `Super + Slash` | Toggle Keyboard Cheatsheet |
| `Super + A` | Toggle AI Copilot Sidebar |
| `Super + L` | Lock Screen |
| `Super + Escape` | Toggle Fullscreen Power & Session Menu |
| `Print` / `Super+Shift+S` | Capture Screen Snip to Clipboard |

---

## 🛠️ CLI & IPC Commands (`linh-long-shell`)

```bash
# Shell Lifecycle
linh-long-shell start         # Start Linh-Long Desktop Shell
linh-long-shell stop          # Stop running shell
linh-long-shell restart       # Restart shell
linh-long-shell status        # Check status

# Direct IPC Action Toggles
linh-long-shell launcher      # Toggle App Launcher
linh-long-shell control-center# Toggle Control Center
linh-long-shell clipboard     # Toggle Clipboard Manager
linh-long-shell switcher      # Toggle Window Switcher
linh-long-shell overview      # Toggle Workspaces Overview
linh-long-shell media         # Toggle Floating Media Player
linh-long-shell wallpaper     # Toggle Wallpaper Studio
linh-long-shell calendar      # Toggle Calendar Popup
linh-long-shell settings      # Toggle Settings Studio
linh-long-shell session       # Toggle Power & Session Menu
linh-long-shell cheatsheet    # Toggle Keybindings Cheatsheet
linh-long-shell ai            # Toggle AI Copilot
linh-long-shell screenshot    # Snip region to clipboard
linh-long-shell lock          # Lock screen

# Volume & Playback
linh-long-shell vol-up        # Volume up
linh-long-shell vol-down      # Volume down
linh-long-shell vol-mute      # Mute toggle
linh-long-shell media-play    # Media play/pause
linh-long-shell media-next    # Media next
linh-long-shell media-prev    # Media prev

# Script Integration
linh-long-shell dmenu         # Drop-in dmenu / rofi replacement
```
