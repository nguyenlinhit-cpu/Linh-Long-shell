import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: launcherWindow

    property bool isOpen: ShellService.launcherOpen
    property var allApps: (typeof DesktopEntries !== "undefined" && DesktopEntries.applications) ? DesktopEntries.applications.values : []

    onIsOpenChanged: {
        if (isOpen) {
            searchInput.text = "";
            resultsList.currentIndex = 0;
            searchInput.forceActiveFocus();
        }
    }

    // Ensure apps update when scanner finishes or files change
    Connections {
        target: (typeof DesktopEntries !== "undefined") ? DesktopEntries : null
        function onApplicationsChanged() {
            launcherWindow.allApps = DesktopEntries.applications.values;
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-launcher"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        ShellService.toggleLauncher();
    }

    // Dismiss on background click
    MouseArea {
        anchors.fill: parent
        onClicked: ShellService.launcherOpen = false
    }

    // Center Modal Box
    GlassCard {
        anchors.centerIn: parent
        width: ConfigService.launcherWidth
        height: Math.min(560, contentCol.implicitHeight + 36)
        radius: Theme.radiusLarge
        elevation: 4

        // Prevent click propagation to background
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // ══════════════════════════════════════════════════════════════
            // SEARCH INPUT BOX
            // ══════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: Theme.radiusMedium
                color: Theme.palette.layer2
                border.width: 1
                border.color: searchInput.activeFocus ? Theme.palette.primary : Theme.palette.glassBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        text: "󰍉"
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        color: Theme.palette.primary
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        color: Theme.palette.colOnSurface
                        selectByMouse: true

                        Keys.onEscapePressed: launcherWindow.isOpen = false

                        Keys.onDownPressed: {
                            if (resultsList.currentIndex < resultsList.count - 1) {
                                resultsList.currentIndex++;
                                resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain);
                            }
                        }

                        Keys.onUpPressed: {
                            if (resultsList.currentIndex > 0) {
                                resultsList.currentIndex--;
                                resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain);
                            }
                        }

                        Keys.onReturnPressed: {
                            let results = launcherWindow.computeResults(searchInput.text, launcherWindow.allApps);
                            if (results && results.length > 0) {
                                let idx = Math.max(0, Math.min(resultsList.currentIndex, results.length - 1));
                                launcherWindow.executeResult(results[idx]);
                            }
                        }

                        Text {
                            visible: !parent.text && !parent.inputMethodComposing
                            text: "Type to search installed apps, /calc, /win, /clip..."
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            color: Theme.palette.outline
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    IconButton {
                        visible: searchInput.text.length > 0
                        icon: "󰅖"
                        implicitWidth: 24
                        implicitHeight: 24
                        iconSize: 12
                        onClicked: {
                            searchInput.text = "";
                            resultsList.currentIndex = 0;
                            searchInput.forceActiveFocus();
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // DYNAMIC SEARCH RESULTS LIST (ACTUAL SYSTEM APPS)
            // ══════════════════════════════════════════════════════════════
            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: Math.min(420, count * 58)
                clip: true
                spacing: 6

                model: launcherWindow.computeResults(searchInput.text, launcherWindow.allApps)

                delegate: GlassCard {
                    id: delegateCard
                    width: resultsList.width
                    height: 52
                    radius: Theme.radiusMedium
                    elevation: index === resultsList.currentIndex ? 2 : 1
                    interactive: true

                    color: {
                        if (index === resultsList.currentIndex) return ColorResolver.transparentize(Theme.palette.primaryContainer, 0.4);
                        if (hovered) return ColorResolver.transparentize(Theme.palette.layer2, 0.7);
                        return ColorResolver.transparentize(Theme.palette.layer1, 0.4);
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        // Leading App Icon
                        Rectangle {
                            width: 32
                            height: 32
                            radius: Theme.radiusSmall
                            color: Theme.palette.layer3
                            clip: true

                            Image {
                                id: appImg
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: (modelData.entry && modelData.entry.icon) ? ("image://icon/" + modelData.entry.icon) : ""
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                visible: appImg.status !== Image.Ready
                                anchors.centerIn: parent
                                text: modelData.icon || "󰀻"
                                font.family: Theme.fontFamily
                                font.pixelSize: 18
                                color: Theme.palette.primary
                            }
                        }

                        // Title & Subtitle
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.title
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                font.weight: Font.DemiBold
                                color: Theme.palette.colOnSurface
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.subtitle
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeCaption
                                color: Theme.palette.colOnSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }

                        // Category / Type Badge
                        Badge {
                            text: modelData.badge || "App"
                            badgeColor: {
                                if (modelData.badge === "Window") return Theme.palette.secondaryContainer;
                                if (modelData.badge === "CLI") return Theme.palette.tertiaryContainer;
                                return Theme.palette.primaryContainer;
                            }
                            textColor: {
                                if (modelData.badge === "Window") return Theme.palette.colOnSecondaryContainer;
                                if (modelData.badge === "CLI") return Theme.palette.colOnTertiaryContainer;
                                return Theme.palette.colOnPrimaryContainer;
                            }
                        }
                    }

                    onClicked: {
                        resultsList.currentIndex = index;
                        launcherWindow.executeResult(modelData);
                    }
                }
            }
        }
    }

    // Dynamic Result Engine: Discovers Real Installed Desktop Apps
    function computeResults(query, appsList) {
        let q = query ? query.trim() : "";

        // 1. Math Calculator Provider (/calc ...)
        if (q.startsWith("/calc ") || (!isNaN(q[0]) && (q.includes("+") || q.includes("-") || q.includes("*") || q.includes("/")))) {
            let expr = q.startsWith("/calc ") ? q.substring(6).trim() : q;
            try {
                let sanitized = expr.replace(/[^0-9\+\-\*\/\(\)\.\s]/g, "");
                let ans = Function(`'use strict'; return (${sanitized})`)();
                return [{
                    title: `${expr} = ${ans}`,
                    subtitle: "Press Enter to copy result to clipboard",
                    icon: "󰪚",
                    badge: "Calc",
                    action: "copy",
                    payload: `${ans}`
                }];
            } catch(e) {
                return [{
                    title: "Evaluating expression...",
                    subtitle: "Invalid or incomplete math syntax",
                    icon: "󰪚",
                    badge: "Calc",
                    action: "none"
                }];
            }
        }

        // 2. Window Switcher Provider (/win ...)
        if (q.startsWith("/win")) {
            let winQuery = q.substring(4).trim().toLowerCase();
            return CompositorService.openWindows
                .filter(w => !winQuery || (w.title?.toLowerCase().includes(winQuery) || w.appId?.toLowerCase().includes(winQuery)))
                .map(w => ({
                    title: w.title || "Window",
                    subtitle: w.appId || "Application",
                    icon: "󱂬",
                    badge: "Window",
                    action: "focus_window",
                    payload: w
                }));
        }

        // 3. Clipboard History Provider (/clip ...)
        if (q.startsWith("/clip")) {
            let clipQuery = q.substring(5).trim().toLowerCase();
            return ClipboardService.history
                .filter(c => !clipQuery || c.text.toLowerCase().includes(clipQuery))
                .slice(0, 8)
                .map(c => ({
                    title: c.preview,
                    subtitle: Qt.formatDateTime(c.timestamp, "hh:mm:ss"),
                    icon: "󰅌",
                    badge: "Clip",
                    action: "copy",
                    payload: c.text
                }));
        }

        // 4. Emoji Picker Provider (/emoji ... or :emoji)
        if (q.startsWith("/emoji ") || q.startsWith(":") || (q.length >= 3 && ["fire", "rocket", "smile", "heart", "sparkles", "cat", "dog", "coffee", "check", "star"].some(e => e.includes(q.toLowerCase())))) {
            let eq = q.startsWith("/emoji ") ? q.substring(7).trim() : (q.startsWith(":") ? q.substring(1).trim() : q);
            let emojis = [
                { name: "fire", char: "🔥", desc: "Flame / Fire" },
                { name: "rocket", char: "🚀", desc: "Rocket / Launch" },
                { name: "smile", char: "😄", desc: "Smiling Face" },
                { name: "heart", char: "❤️", desc: "Red Heart" },
                { name: "sparkles", char: "✨", desc: "Sparkles / Magic" },
                { name: "zap lightning", char: "⚡", desc: "High Voltage" },
                { name: "check ok", char: "✅", desc: "Check Mark" },
                { name: "cross x", char: "❌", desc: "Cross Mark" },
                { name: "party celebration", char: "🎉", desc: "Party Popper" },
                { name: "cool sunglasses", char: "😎", desc: "Cool Sunglasses" },
                { name: "coffee", char: "☕", desc: "Hot Beverage" },
                { name: "laptop computer", char: "💻", desc: "Laptop Computer" },
                { name: "bulb idea", char: "💡", desc: "Light Bulb / Idea" },
                { name: "cat", char: "🐱", desc: "Cat Face" },
                { name: "thumbsup like", char: "👍", desc: "Thumbs Up" },
                { name: "thinking ponder", char: "🤔", desc: "Thinking Face" }
            ];

            let matched = emojis.filter(e => !eq || e.name.includes(eq.toLowerCase()));
            if (matched.length > 0) {
                return matched.map(e => ({
                    title: `${e.char}  :${e.name.split(" ")[0]}:`,
                    subtitle: `${e.desc} • Press Enter to copy`,
                    icon: "󰞅",
                    badge: "Emoji",
                    action: "copy",
                    payload: e.char
                }));
            }
        }

        // 5. Web Search Provider (/g ... or /ddg ...)
        if (q.startsWith("/g ") || q.startsWith("/ddg ")) {
            let isGoogle = q.startsWith("/g ");
            let sq = isGoogle ? q.substring(3).trim() : q.substring(5).trim();
            let url = isGoogle ? `https://www.google.com/search?q=${encodeURIComponent(sq)}` : `https://duckduckgo.com/?q=${encodeURIComponent(sq)}`;
            return [{
                title: `Search web for "${sq}"`,
                subtitle: `Open in default web browser (${isGoogle ? "Google" : "DuckDuckGo"})`,
                icon: "󰖟",
                badge: "Web",
                action: "open_url",
                payload: url
            }];
        }

        // 6. Direct System Power Actions (shutdown, reboot, lock, logout, sleep)
        let lowQ = q.toLowerCase();
        if (lowQ === "shutdown" || lowQ === "poweroff") {
            return [{ title: "Shutdown System", subtitle: "Turn off computer immediately", icon: "󰐥", badge: "Power", action: "exec_cmd", cmd: ["systemctl", "poweroff"] }];
        } else if (lowQ === "reboot" || lowQ === "restart") {
            return [{ title: "Restart System", subtitle: "Reboot computer now", icon: "󰜉", badge: "Power", action: "exec_cmd", cmd: ["systemctl", "reboot"] }];
        } else if (lowQ === "lock") {
            return [{ title: "Lock Screen", subtitle: "Lock current Wayland session", icon: "󰌾", badge: "Security", action: "lock" }];
        } else if (lowQ === "logout" || lowQ === "exit") {
            return [{ title: "Log Out", subtitle: "Exit current desktop session", icon: "󰍃", badge: "Session", action: "logout" }];
        } else if (lowQ === "sleep" || lowQ === "suspend") {
            return [{ title: "Suspend System", subtitle: "Put computer to sleep", icon: "󰤄", badge: "Power", action: "exec_cmd", cmd: ["systemctl", "suspend"] }];
        } else if (lowQ === "wallpaper" || lowQ === "wall" || lowQ === "/wall") {
            return [{ title: "Open Wallpaper & Theme Studio", subtitle: "Browse wallpapers and dynamic M3 palette", icon: "󰸉", badge: "Theme", action: "toggle_wallpaper" }];
        } else if (lowQ === "settings" || lowQ === "/settings") {
            return [{ title: "Open Linh-Long Settings", subtitle: "Configure appearance, blur, bar & dock", icon: "󰒓", badge: "Settings", action: "toggle_settings" }];
        }

        // 7. Real Installed System Applications (via Quickshell DesktopEntries)
        let entries = [];
        if (appsList && appsList.length > 0) {
            entries = appsList;
        } else if (typeof DesktopEntries !== "undefined" && DesktopEntries.applications && DesktopEntries.applications.values) {
            entries = DesktopEntries.applications.values;
        }

        let appResults = entries.filter(app => !app.noDisplay).map(app => {
            let cat = (app.categories && app.categories.length > 0) ? app.categories[0] : (app.runInTerminal ? "CLI" : "App");
            let appIcon = launcherWindow.resolveNerdIcon(app);

            return {
                title: app.name || app.id,
                subtitle: app.genericName || app.comment || app.id,
                icon: appIcon,
                badge: app.runInTerminal ? "Terminal" : cat,
                action: "launch_entry",
                entry: app
            };
        });

        // Sort alphabetically
        appResults.sort((a, b) => a.title.localeCompare(b.title));

        if (!q) {
            return appResults;
        }

        let filtered = appResults.filter(app => {
            let lowTitle = app.title.toLowerCase();
            let lowSub = app.subtitle.toLowerCase();
            let lowId = (app.entry && app.entry.id) ? app.entry.id.toLowerCase() : "";
            return lowTitle.includes(lowQ) || lowSub.includes(lowQ) || lowId.includes(lowQ);
        });

        // 8. If user typed an arbitrary command, offer to run it in terminal or directly
        if (filtered.length === 0 || !filtered.some(a => a.title.toLowerCase() === lowQ)) {
            filtered.push({
                title: `Run "${q}" in Terminal`,
                subtitle: `Execute using Ghostty terminal emulator`,
                icon: "󰆍",
                badge: "Terminal",
                action: "exec_terminal",
                cmd: q
            });
        }

        return filtered;
    }

    function resolveNerdIcon(app) {
        let low = ((app.name || "") + " " + (app.id || "")).toLowerCase();
        if (low.includes("firefox") || low.includes("browser") || low.includes("chrome") || low.includes("web")) return "󰈹";
        if (low.includes("ghostty") || low.includes("terminal") || low.includes("kitty") || low.includes("alacritty") || low.includes("foot")) return "󰄛";
        if (low.includes("nvim") || low.includes("neovim") || low.includes("vim")) return "󰕷";
        if (low.includes("yazi") || low.includes("file") || low.includes("thunar") || low.includes("dolphin")) return "󰉋";
        if (low.includes("antigravity") || low.includes("code") || low.includes("ide") || low.includes("vscodium")) return "󰨞";
        if (low.includes("fcitx") || low.includes("keyboard") || low.includes("layout")) return "󰌌";
        if (low.includes("nvidia") || low.includes("settings") || low.includes("config") || low.includes("control") || low.includes("uuctl")) return "󰒓";
        if (low.includes("nixos") || low.includes("manual") || low.includes("help")) return "";
        if (low.includes("music") || low.includes("spotify") || low.includes("sound")) return "󰓇";
        if (low.includes("video") || low.includes("mpv") || low.includes("vlc")) return "󰕼";
        return "󰀻";
    }

    function executeResult(item) {
        if (!item) return;

        if (item.action === "copy") {
            ClipboardService.copyToClipboard(item.payload);
        } else if (item.action === "focus_window") {
            CompositorService.focusWindow(item.payload);
        } else if (item.action === "open_url") {
            Quickshell.execDetached(["xdg-open", item.payload]);
        } else if (item.action === "lock") {
            LockManager.lock();
        } else if (item.action === "toggle_wallpaper") {
            wallpaperSelector.toggle();
        } else if (item.action === "toggle_settings") {
            settingsDialog.toggle();
        } else if (item.action === "logout") {
            sessionWindow.executeAction("logout");
        } else if (item.action === "exec_cmd" && item.cmd) {
            Quickshell.execDetached(item.cmd);
        } else if (item.action === "launch_entry" && item.entry) {
            if (item.entry.runInTerminal) {
                let cmd = item.entry.command && item.entry.command.length > 0 ? item.entry.command : [item.entry.id];
                Quickshell.execDetached(["ghostty", "-e", ...cmd]);
            } else {
                item.entry.execute();
            }
        } else if (item.action === "exec_terminal") {
            Quickshell.execDetached(["ghostty", "-e", item.cmd]);
        } else if (item.cmd) {
            Quickshell.execDetached([item.cmd]);
        }

        ShellService.launcherOpen = false;
    }
}
