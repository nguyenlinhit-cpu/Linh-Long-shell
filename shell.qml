//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "theme"
import "services"
import "modules/bar"
import "modules/dock"
import "modules/controlCenter"
import "modules/launcher"
import "modules/notifications"
import "modules/osd"
import "modules/lockscreen"
import "modules/aiSidebar"
import "modules/cheatsheet"
import "modules/sessionScreen"
import "modules/wallpaperSelector"
import "modules/overview"
import "modules/regionSelector"
import "modules/settings"
import "modules/screenCorners"
import "modules/clipboard"
import "modules/switcher"
import "modules/mediaControls"
import "modules/polkit"
import "modules/desktop"
import "modules/hotCorners"

ShellRoot {
    id: root

    // ══════════════════════════════════════════════════════════════
    // INITIALIZATION & THEME COORDINATION
    // ══════════════════════════════════════════════════════════════
    Component.onCompleted: {
        // Apply theme source settings from config
        if (ConfigService.themeSource !== "wallpaper") {
            Theme.palette.applyPreset(ConfigService.themeSource, ConfigService.themeMode === "dark");
        }
        Theme.palette.oledMode = ConfigService.pureBlackOled;
        Theme.radiusScale = ConfigService.cornerRadius;

        // Set default initial wallpaper if none active
        if (!WallpaperService.activeWallpaper) {
            WallpaperService.setWallpaper(Qt.resolvedUrl("assets/wallpapers/cyberpunk_neon_city.jpg").toString().replace("file://", ""));
        }
    }

    // ══════════════════════════════════════════════════════════════
    // PRIMARY SHELL SURFACES
    // ══════════════════════════════════════════════════════════════

    // 0. Desktop Wallpaper Backdrop & Desktop Widgets (Layer: Background)
    DesktopBackdrop {
        id: desktopBackdrop
    }

    // 1. Dynamic Island Top Bar
    Bar {
        id: mainBar
    }

    // 2. Interactive Calendar Popup (attached under Clock)
    CalendarPopup {
        id: calendarPopup
    }

    // 3. Smart Auto-Hiding Magnification Dock
    Dock {
        id: mainDock
        visible: ConfigService.dockEnabled
    }

    // 4. Glassmorphic Control Center & Granular Audio Mixer
    ControlCenter {
        id: controlCenterPopup
    }

    // 5. Raycast-grade Multi-Provider Spotlight Launcher
    Launcher {
        id: launcherPopup
    }

    // 6. On-Screen Display (Volume & Brightness feedback)
    OSD {
        id: osdOverlay
    }

    // 7. Notification Toast Stack
    NotificationPopup {
        id: notificationToasts
    }

    // 8. AI Copilot Sidebar (Ollama LLM integration)
    AiSidebar {
        id: aiSidebarPanel
    }

    // 9. Keybindings Cheatsheet Modal
    Cheatsheet {
        id: cheatsheetModal
    }

    // 10. Native Secure Lock Screen Surface
    LockScreen {
        id: sessionLockScreen
    }

    // 11. Fullscreen Session & Power Menu
    SessionScreen {
        id: sessionWindow
    }

    // 12. Wallpaper & Theme Studio Selector
    WallpaperSelector {
        id: wallpaperSelector
    }

    // 13. Workspaces & Running Windows Overview Switcher
    Overview {
        id: overviewWindow
    }

    // 14. Screen Snip & Capture Region Selector
    RegionSelector {
        id: regionSelector
    }

    // 15. Graphical Settings Studio Dialog
    SettingsDialog {
        id: settingsDialog
    }

    // 16. Curved Hardware Monitor Bezels Overlay
    ScreenCorners {
        id: screenCorners
    }

    // 17. Clipboard History Manager
    ClipboardPopup {
        id: clipboardPopup
    }

    // 18. Window Switcher Carousel (Alt + Tab HUD)
    AltTabSwitcher {
        id: altTabSwitcher
    }

    // 19. Floating Media Player Popup
    MediaPopup {
        id: mediaPopup
    }

    // 20. Wayland Native Polkit Authentication Agent Dialog
    PolkitDialog {
        id: polkitDialog
    }

    // 21. Hot Corners Trigger Zones
    HotCorners {
        id: hotCorners
    }

    // ══════════════════════════════════════════════════════════════
    // GLOBAL SHORTCUTS (WAYLAND COMPOSITOR KEYBINDS)
    // ══════════════════════════════════════════════════════════════

    // Toggle Launcher (Super + Space)
    GlobalShortcut {
        name: "launcher"
        description: "Toggle Linh-Long App Launcher"
        onPressed: ShellService.toggleLauncher()
    }

    // Toggle Control Center (Super + C)
    GlobalShortcut {
        name: "controlCenter"
        description: "Toggle Linh-Long Control Center"
        onPressed: ShellService.toggleControlCenter()
    }

    // Toggle AI Copilot (Super + A)
    GlobalShortcut {
        name: "aiCopilot"
        description: "Toggle Linh-Long AI Copilot Sidebar"
        onPressed: ShellService.toggleAi()
    }

    // Toggle Cheatsheet (Super + Slash)
    GlobalShortcut {
        name: "cheatsheet"
        description: "Toggle Linh-Long Keyboard Cheatsheet"
        onPressed: ShellService.toggleCheatsheet()
    }

    // Lock Screen (Super + L)
    GlobalShortcut {
        name: "lock"
        description: "Lock Screen using Native Session Lock"
        onPressed: LockManager.lock()
    }

    // Toggle Session & Power Menu (Super + Escape)
    GlobalShortcut {
        name: "session"
        description: "Toggle Power & Session Menu"
        onPressed: ShellService.toggleSession()
    }

    // Toggle Wallpaper Studio (Super + W)
    GlobalShortcut {
        name: "wallpaper"
        description: "Toggle Wallpaper & Theme Studio"
        onPressed: ShellService.toggleWallpaper()
    }

    // Toggle Workspace & Window Overview (Super + Tab)
    GlobalShortcut {
        name: "overview"
        description: "Toggle Workspaces & Windows Overview"
        onPressed: ShellService.toggleOverview()
    }

    // Toggle Settings Studio (Super + Comma)
    GlobalShortcut {
        name: "settings"
        description: "Toggle Linh-Long Settings Dialog"
        onPressed: ShellService.toggleSettings()
    }

    // Capture Screen Snip (Print / Super + Shift + S)
    GlobalShortcut {
        name: "screenshot"
        description: "Snip Screenshot to Clipboard"
        onPressed: ShellService.toggleRegionSnip()
    }

    // Toggle Clipboard History (Super + V)
    GlobalShortcut {
        name: "clipboard"
        description: "Toggle Clipboard History Manager"
        onPressed: ShellService.toggleClipboard()
    }

    // Toggle Alt-Tab Window Switcher (Alt + Tab)
    GlobalShortcut {
        name: "switcher"
        description: "Cycle Running Windows"
        onPressed: ShellService.toggleSwitcher()
    }

    // Toggle Media Player (Super + M)
    GlobalShortcut {
        name: "media"
        description: "Toggle Floating Music Controller"
        onPressed: ShellService.toggleMedia()
    }

    // ══════════════════════════════════════════════════════════════
    // IPC HANDLER (FOR SCRIPT & CLI INTEGRATION)
    // ══════════════════════════════════════════════════════════════
    IpcHandler {
        target: "linh-long"

        function toggleLauncher(): void { ShellService.toggleLauncher(); }
        function toggleControlCenter(): void { ShellService.toggleControlCenter(); }
        function toggleAi(): void { ShellService.toggleAi(); }
        function toggleCheatsheet(): void { ShellService.toggleCheatsheet(); }
        function toggleCalendar(): void { ShellService.toggleCalendar(); }
        function toggleSession(): void { ShellService.toggleSession(); }
        function toggleWallpaper(): void { ShellService.toggleWallpaper(); }
        function toggleOverview(): void { ShellService.toggleOverview(); }
        function toggleSettings(): void { ShellService.toggleSettings(); }
        function toggleClipboard(): void { ShellService.toggleClipboard(); }
        function toggleSwitcher(): void { ShellService.toggleSwitcher(); }
        function toggleMedia(): void { ShellService.toggleMedia(); }
        function toggleDesktopWidgets(): void { ShellService.toggleDesktopWidgets(); }
        function captureRegion(): void { ShellService.toggleRegionSnip(); }
        function lockScreen(): void { LockManager.lock(); }
        function volumeUp(): void { AudioService.incrementVolume(); }
        function volumeDown(): void { AudioService.decrementVolume(); }
        function volumeMute(): void { AudioService.toggleMute(); }
        function mediaToggle(): void { MediaService.togglePlayPause(); }
        function mediaNext(): void { MediaService.next(); }
        function mediaPrev(): void { MediaService.previous(); }
    }
}
