import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: dockWindow

    anchors {
        bottom: true
    }
    implicitWidth: dockCard.width + 32
    implicitHeight: ConfigService.dockHeight + 24
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "linh-long-dock"

    // Listen for desktop entries scan completion
    property int refreshCounter: 0
    Connections {
        target: (typeof DesktopEntries !== "undefined") ? DesktopEntries : null
        function onApplicationsChanged() {
            dockWindow.refreshCounter++;
        }
    }

    function findDesktopEntry(id) {
        let dummy = dockWindow.refreshCounter;
        if (typeof DesktopEntries !== "undefined") {
            return DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(id);
        }
        return null;
    }

    // Dock Card Container
    GlassCard {
        id: dockCard
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        height: ConfigService.dockHeight
        width: dockRow.implicitWidth + 24
        radius: Theme.radiusLarge
        elevation: 3

        RowLayout {
            id: dockRow
            anchors.centerIn: parent
            spacing: 8

            // ══════════════════════════════════════════════════════════════
            // 1. HOME / APP LAUNCHER BUTTON
            // ══════════════════════════════════════════════════════════════
            Item {
                id: homeBtn
                implicitWidth: 46
                implicitHeight: 46

                property bool isHovered: homeMouse.containsMouse

                // Tooltip
                Rectangle {
                    visible: homeBtn.isHovered
                    anchors.bottom: homeIconBox.top
                    anchors.bottomMargin: 8
                    anchors.horizontalCenter: homeIconBox.horizontalCenter
                    width: homeTooltip.implicitWidth + 16
                    height: 24
                    radius: Theme.radiusSmall
                    color: Theme.palette.inverseSurface
                    z: 100

                    Text {
                        id: homeTooltip
                        anchors.centerIn: parent
                        text: "Home / Applications (Super + Space)"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption
                        color: Theme.palette.colOnInverseSurface
                    }
                }

                Rectangle {
                    id: homeIconBox
                    anchors.centerIn: parent
                    width: 40
                    height: 40
                    radius: Theme.radiusMedium
                    color: homeBtn.isHovered ? Theme.palette.primaryContainer : Theme.palette.layer2
                    clip: true

                    scale: homeBtn.isHovered ? 1.25 : 1.0
                    y: homeBtn.isHovered ? -8 : 0

                    Behavior on scale { NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack } }
                    Behavior on y { NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "" // Home / NixOS icon
                        font.family: Theme.fontFamily
                        font.pixelSize: 22
                        color: homeBtn.isHovered ? Theme.palette.colOnPrimaryContainer : Theme.palette.primary
                    }
                }

                MouseArea {
                    id: homeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            Quickshell.execDetached(["ghostty", "-e", "yazi"]);
                        } else {
                            ShellService.toggleLauncher();
                        }
                    }
                }
            }

            // Separator Line
            Rectangle {
                width: 1
                height: 26
                color: Theme.palette.glassBorder
            }

            // ══════════════════════════════════════════════════════════════
            // 2. PINNED APPLICATIONS
            // ══════════════════════════════════════════════════════════════
            Repeater {
                model: ConfigService.dockPinnedApps
                delegate: Item {
                    id: dockItem
                    implicitWidth: 46
                    implicitHeight: 46

                    property var desktopEntry: dockWindow.findDesktopEntry(modelData)

                    property bool isHovered: itemMouse.containsMouse
                    property bool isRunning: {
                        let target = modelData.toLowerCase();
                        let entryId = dockItem.desktopEntry ? (dockItem.desktopEntry.id || "").toLowerCase() : "";
                        let startupClass = dockItem.desktopEntry ? (dockItem.desktopEntry.startupClass || "").toLowerCase() : "";
                        return CompositorService.openWindows.some(w => {
                            let id = (w.appId || "").toLowerCase();
                            let title = (w.title || "").toLowerCase();
                            return id.includes(target) || (entryId && id.includes(entryId)) || (startupClass && id.includes(startupClass));
                        });
                    }

                    // Hover Tooltip
                    Rectangle {
                        visible: dockItem.isHovered
                        anchors.bottom: iconBox.top
                        anchors.bottomMargin: 8
                        anchors.horizontalCenter: iconBox.horizontalCenter
                        width: tooltipText.implicitWidth + 16
                        height: 24
                        radius: Theme.radiusSmall
                        color: Theme.palette.inverseSurface
                        z: 100

                        Text {
                            id: tooltipText
                            anchors.centerIn: parent
                            text: dockItem.desktopEntry ? dockItem.desktopEntry.name : modelData
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeCaption
                            color: Theme.palette.colOnInverseSurface
                        }
                    }

                    // Icon container with spring magnification zoom
                    Rectangle {
                        id: iconBox
                        anchors.centerIn: parent
                        width: 40
                        height: 40
                        radius: Theme.radiusMedium
                        color: dockItem.isHovered ? Theme.palette.layer3 : Theme.palette.layer2
                        clip: true

                        scale: dockItem.isHovered ? 1.25 : 1.0
                        y: dockItem.isHovered ? -8 : 0

                        Behavior on scale {
                            NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack }
                        }
                        Behavior on y {
                            NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack }
                        }

                        Image {
                            id: dockAppImg
                            anchors.centerIn: parent
                            width: 26
                            height: 26
                            source: (dockItem.desktopEntry && dockItem.desktopEntry.icon) ? ("image://icon/" + dockItem.desktopEntry.icon) : ""
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            visible: dockAppImg.status !== Image.Ready
                            anchors.centerIn: parent
                            text: {
                                let m = (modelData + " " + (dockItem.desktopEntry?.id || "")).toLowerCase();
                                if (m.includes("firefox") || m.includes("browser")) return "󰈹";
                                if (m.includes("ghostty") || m.includes("terminal") || m.includes("kitty")) return "󰄛";
                                if (m.includes("antigravity") || m.includes("code") || m.includes("ide")) return "󰨞";
                                if (m.includes("nvim") || m.includes("vim")) return "󰕷";
                                if (m.includes("yazi") || m.includes("file")) return "󰉋";
                                if (m.includes("fcitx")) return "󰌌";
                                if (m.includes("nvidia")) return "󰒓";
                                if (m.includes("nixos")) return "";
                                return "󰀻";
                            }
                            font.family: Theme.fontFamily
                            font.pixelSize: 22
                            color: Theme.palette.primary
                        }
                    }

                    // Stable Hit-Target MouseArea (NOT inside moving iconBox!)
                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // 1. Focus running window if any
                            let target = modelData.toLowerCase();
                            let entryId = dockItem.desktopEntry ? (dockItem.desktopEntry.id || "").toLowerCase() : "";
                            let startupClass = dockItem.desktopEntry ? (dockItem.desktopEntry.startupClass || "").toLowerCase() : "";
                            let match = CompositorService.openWindows.find(w => {
                                let id = (w.appId || "").toLowerCase();
                                return id.includes(target) || (entryId && id.includes(entryId)) || (startupClass && id.includes(startupClass));
                            });
                            if (match) {
                                CompositorService.focusWindow(match);
                                return;
                            }

                            // 2. Launch desktop app or terminal app with robust fallbacks
                            if (dockItem.desktopEntry) {
                                if (dockItem.desktopEntry.runInTerminal) {
                                    let cmd = dockItem.desktopEntry.command && dockItem.desktopEntry.command.length > 0 ? dockItem.desktopEntry.command : [dockItem.desktopEntry.id];
                                    Quickshell.execDetached(["ghostty", "-e", ...cmd]);
                                } else {
                                    dockItem.desktopEntry.execute();
                                }
                            } else {
                                if (modelData === "com.mitchellh.ghostty") Quickshell.execDetached(["ghostty"]);
                                else if (modelData === "nvim") Quickshell.execDetached(["ghostty", "-e", "nvim"]);
                                else if (modelData === "yazi") Quickshell.execDetached(["ghostty", "-e", "yazi"]);
                                else Quickshell.execDetached([modelData]);
                            }
                        }
                    }

                    // Running dot indicator
                    Rectangle {
                        visible: dockItem.isRunning
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 4
                        height: 4
                        radius: 2
                        color: Theme.palette.primary
                    }
                }
            }

            // Separator Line
            Rectangle {
                width: 1
                height: 26
                color: Theme.palette.glassBorder
            }

            // 3. CLIPBOARD BUTTON
            Item {
                id: clipBtn
                implicitWidth: 46
                implicitHeight: 46

                property bool isHovered: clipMouse.containsMouse

                Rectangle {
                    anchors.centerIn: parent
                    width: 40
                    height: 40
                    radius: Theme.radiusMedium
                    color: clipBtn.isHovered ? Theme.palette.layer3 : Theme.palette.layer2
                    clip: true

                    scale: clipBtn.isHovered ? 1.25 : 1.0
                    y: clipBtn.isHovered ? -8 : 0

                    Behavior on scale { NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack } }
                    Behavior on y { NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰅍"
                        font.family: Theme.fontFamily
                        font.pixelSize: 20
                        color: Theme.palette.tertiary
                    }
                }

                MouseArea {
                    id: clipMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ShellService.toggleClipboard()
                }
            }

            // ══════════════════════════════════════════════════════════════
            // 4. OVERVIEW BUTTON
            // ══════════════════════════════════════════════════════════════
            Item {
                id: overviewBtn
                implicitWidth: 46
                implicitHeight: 46

                property bool isHovered: overviewMouse.containsMouse

                Rectangle {
                    id: overviewIconBox
                    anchors.centerIn: parent
                    width: 40
                    height: 40
                    radius: Theme.radiusMedium
                    color: overviewBtn.isHovered ? Theme.palette.layer3 : Theme.palette.layer2
                    clip: true

                    scale: overviewBtn.isHovered ? 1.25 : 1.0
                    y: overviewBtn.isHovered ? -8 : 0

                    Behavior on scale { NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack } }
                    Behavior on y { NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "󱂬" // Overview / Windows icon
                        font.family: Theme.fontFamily
                        font.pixelSize: 20
                        color: Theme.palette.primary
                    }
                }

                MouseArea {
                    id: overviewMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ShellService.toggleOverview()
                }
            }

            // ══════════════════════════════════════════════════════════════
            // 4. POWER / SESSION BUTTON
            // ══════════════════════════════════════════════════════════════
            Item {
                id: powerBtn
                implicitWidth: 46
                implicitHeight: 46

                property bool isHovered: powerMouse.containsMouse

                Rectangle {
                    id: powerIconBox
                    anchors.centerIn: parent
                    width: 40
                    height: 40
                    radius: Theme.radiusMedium
                    color: powerBtn.isHovered ? Theme.palette.layer3 : Theme.palette.layer2
                    clip: true

                    scale: powerBtn.isHovered ? 1.25 : 1.0
                    y: powerBtn.isHovered ? -8 : 0

                    Behavior on scale { NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack } }
                    Behavior on y { NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰐥" // Power icon
                        font.family: Theme.fontFamily
                        font.pixelSize: 20
                        color: Theme.palette.error
                    }
                }

                MouseArea {
                    id: powerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ShellService.toggleSession()
                }
            }
        }
    }
}
