pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Reactive Config Options State
    property var rawConfig: ({})
    property bool loaded: false

    // Shell configuration values
    property string compositor: "auto"
    property real uiScale: 1.0
    property real cornerRadius: 1.0
    property string fontFamily: "Inter, Roboto, sans-serif"
    property string fontMono: "JetBrainsMono Nerd Font, monospace"
    property string timeFormat: "hh:mm"
    property string dateFormat: "ddd, MMM d"

    // Theme configuration
    property string themeMode: "dark"
    property string themeSource: "wallpaper"
    property bool pureBlackOled: false
    property bool blurEnabled: true
    property real blurStrength: 24.0
    property real backgroundOpacity: 0.78
    property real surfaceOpacity: 0.88
    property real cardOpacity: 0.94

    // Bar configuration
    property bool barEnabled: true
    property string barStyle: "floating"
    property string barEdge: "top"
    property int barHeight: 44
    property int barMarginY: 8
    property int barMarginX: 16
    property bool barShowWorkspaces: true
    property bool barShowMediaPill: true
    property bool barShowClock: true
    property bool barShowHardwareMini: true
    property bool barShowNetwork: true
    property bool barShowBattery: true
    property bool barShowTray: true

    // Dock configuration
    property bool dockEnabled: true
    property bool dockAutohide: true
    property string dockEdge: "bottom"
    property int dockHeight: 56
    property var dockPinnedApps: ["org.mozilla.firefox", "kitty", "codium", "org.kde.dolphin", "spotify"]

    // Launcher configuration
    property int launcherWidth: 620
    property string prefixCalc: "/calc"
    property string prefixWin: "/win"
    property string prefixClip: "/clip"
    property string prefixAi: "/ai"

    // Notifications configuration
    property bool notifEnabled: true
    property int notifTimeoutMs: 5000
    property bool notifDnd: false

    // AI configuration
    property bool aiEnabled: true
    property string aiProvider: "ollama"
    property string aiEndpoint: "http://localhost:11434"
    property string aiModel: "llama3"

    // FileView for live watching config.toml
    FileView {
        id: configFile
        path: Quickshell.env("XDG_CONFIG_HOME") ? `${Quickshell.env("XDG_CONFIG_HOME")}/linh-long-shell/config.toml` : `${Quickshell.env("HOME")}/.config/linh-long-shell/config.toml`
        
        onLoadedChanged: {
            if (configFile.loaded) {
                root.parseToml(configFile.text());
            }
        }
    }

    // Fallback: Check local workspace config.toml if user hasn't copied to ~/.config/linh-long-shell/
    FileView {
        id: localConfigFile
        path: Qt.resolvedUrl("../config.toml").toString().replace("file://", "")
        
        onLoadedChanged: {
            if (!configFile.loaded && localConfigFile.loaded) {
                root.parseToml(localConfigFile.text());
            }
        }
    }

    // Lightweight robust TOML key-value & section parser
    function parseToml(content) {
        if (!content || content.trim().length === 0) return;

        let lines = content.split("\n");
        let currentSection = "";
        let result = {};

        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].trim();
            if (line.length === 0 || line.startsWith("#")) continue;

            // Section match: [section.subsection]
            let sectionMatch = line.match(/^\[([a-zA-Z0-9_\.]+)\]$/);
            if (sectionMatch) {
                currentSection = sectionMatch[1];
                if (!result[currentSection]) result[currentSection] = {};
                continue;
            }

            // Key-value match: key = value
            let kvMatch = line.match(/^([a-zA-Z0-9_]+)\s*=\s*(.+)$/);
            if (kvMatch) {
                let key = kvMatch[1].trim();
                let valStr = kvMatch[2].trim();

                // Strip inline comment if any
                let commentIdx = valStr.indexOf("#");
                if (commentIdx !== -1 && !valStr.startsWith("\"")) {
                    valStr = valStr.substring(0, commentIdx).trim();
                }

                // Parse primitive values
                let val = valStr;
                if (valStr === "true") val = true;
                else if (valStr === "false") val = false;
                else if (!isNaN(Number(valStr)) && !valStr.startsWith("\"")) val = Number(valStr);
                else if (valStr.startsWith("\"") && valStr.endsWith("\"")) val = valStr.slice(1, -1);
                else if (valStr.startsWith("[") && valStr.endsWith("]")) {
                    try {
                        val = JSON.parse(valStr.replace(/'/g, '"'));
                    } catch(e) {
                        val = [];
                    }
                }

                if (currentSection) {
                    if (!result[currentSection]) result[currentSection] = {};
                    result[currentSection][key] = val;
                } else {
                    result[key] = val;
                }
            }
        }

        root.rawConfig = result;
        root.applyConfig(result);
        root.loaded = true;
    }

    function applyConfig(cfg) {
        if (!cfg) return;

        if (cfg.shell) {
            if (cfg.shell.compositor !== undefined) root.compositor = cfg.shell.compositor;
            if (cfg.shell.ui_scale !== undefined) root.uiScale = cfg.shell.ui_scale;
            if (cfg.shell.corner_radius !== undefined) root.cornerRadius = cfg.shell.corner_radius;
            if (cfg.shell.font_family !== undefined) root.fontFamily = cfg.shell.font_family;
            if (cfg.shell.font_mono !== undefined) root.fontMono = cfg.shell.font_mono;
            if (cfg.shell.time_format !== undefined) root.timeFormat = cfg.shell.time_format;
            if (cfg.shell.date_format !== undefined) root.dateFormat = cfg.shell.date_format;
        }

        if (cfg.theme) {
            if (cfg.theme.mode !== undefined) root.themeMode = cfg.theme.mode;
            if (cfg.theme.source !== undefined) root.themeSource = cfg.theme.source;
            if (cfg.theme.pure_black_oled !== undefined) root.pureBlackOled = cfg.theme.pure_black_oled;
            if (cfg.theme.blur_enabled !== undefined) root.blurEnabled = cfg.theme.blur_enabled;
            if (cfg.theme.blur_strength !== undefined) root.blurStrength = cfg.theme.blur_strength;
            if (cfg.theme.background_opacity !== undefined) root.backgroundOpacity = cfg.theme.background_opacity;
            if (cfg.theme.surface_opacity !== undefined) root.surfaceOpacity = cfg.theme.surface_opacity;
            if (cfg.theme.card_opacity !== undefined) root.cardOpacity = cfg.theme.card_opacity;
        }

        if (cfg.bar) {
            if (cfg.bar.enabled !== undefined) root.barEnabled = cfg.bar.enabled;
            if (cfg.bar.style !== undefined) root.barStyle = cfg.bar.style;
            if (cfg.bar.edge !== undefined) root.barEdge = cfg.bar.edge;
            if (cfg.bar.height !== undefined) root.barHeight = cfg.bar.height;
            if (cfg.bar.show_workspaces !== undefined) root.barShowWorkspaces = cfg.bar.show_workspaces;
            if (cfg.bar.show_media_pill !== undefined) root.barShowMediaPill = cfg.bar.show_media_pill;
            if (cfg.bar.show_clock !== undefined) root.barShowClock = cfg.bar.show_clock;
            if (cfg.bar.show_hardware_mini !== undefined) root.barShowHardwareMini = cfg.bar.show_hardware_mini;
            if (cfg.bar.show_network !== undefined) root.barShowNetwork = cfg.bar.show_network;
            if (cfg.bar.show_battery !== undefined) root.barShowBattery = cfg.bar.show_battery;
            if (cfg.bar.show_tray !== undefined) root.barShowTray = cfg.bar.show_tray;
        }

        if (cfg.dock) {
            if (cfg.dock.enabled !== undefined) root.dockEnabled = cfg.dock.enabled;
            if (cfg.dock.autohide !== undefined) root.dockAutohide = cfg.dock.autohide;
            if (cfg.dock.edge !== undefined) root.dockEdge = cfg.dock.edge;
            if (cfg.dock.height !== undefined) root.dockHeight = cfg.dock.height;
            if (cfg.dock.pinned_apps !== undefined) root.dockPinnedApps = cfg.dock.pinned_apps;
        }

        if (cfg.launcher) {
            if (cfg.launcher.width !== undefined) root.launcherWidth = cfg.launcher.width;
            if (cfg.launcher.prefix_calc !== undefined) root.prefixCalc = cfg.launcher.prefix_calc;
            if (cfg.launcher.prefix_win !== undefined) root.prefixWin = cfg.launcher.prefix_win;
            if (cfg.launcher.prefix_clip !== undefined) root.prefixClip = cfg.launcher.prefix_clip;
            if (cfg.launcher.prefix_ai !== undefined) root.prefixAi = cfg.launcher.prefix_ai;
        }

        if (cfg.notifications) {
            if (cfg.notifications.enabled !== undefined) root.notifEnabled = cfg.notifications.enabled;
            if (cfg.notifications.timeout_ms !== undefined) root.notifTimeoutMs = cfg.notifications.timeout_ms;
            if (cfg.notifications.dnd_enabled !== undefined) root.notifDnd = cfg.notifications.dnd_enabled;
        }

        if (cfg.ai) {
            if (cfg.ai.enabled !== undefined) root.aiEnabled = cfg.ai.enabled;
            if (cfg.ai.provider !== undefined) root.aiProvider = cfg.ai.provider;
            if (cfg.ai.endpoint !== undefined) root.aiEndpoint = cfg.ai.endpoint;
            if (cfg.ai.model !== undefined) root.aiModel = cfg.ai.model;
        }
    }
}
