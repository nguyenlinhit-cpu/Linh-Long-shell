import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: sessionWindow

    property bool isOpen: ShellService.sessionOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-session"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        ShellService.toggleSession();
    }

    // Blurred Backdrop & Dismiss on click
    Rectangle {
        anchors.fill: parent
        color: ColorResolver.transparentize(Theme.palette.layer0, 0.35)

        MouseArea {
            anchors.fill: parent
            onClicked: ShellService.sessionOpen = false
        }
    }

    // Modal Content
    Item {
        anchors.centerIn: parent
        width: Math.min(840, parent.width - 48)
        height: contentCol.implicitHeight

        // Focus scope for keyboard shortcuts
        focus: sessionWindow.isOpen
        Keys.onEscapePressed: ShellService.sessionOpen = false
        Keys.onPressed: event => {
            if (event.key === Qt.Key_S) sessionWindow.executeAction("poweroff");
            else if (event.key === Qt.Key_R) sessionWindow.executeAction("reboot");
            else if (event.key === Qt.Key_U) sessionWindow.executeAction("suspend");
            else if (event.key === Qt.Key_L) sessionWindow.executeAction("lock");
            else if (event.key === Qt.Key_O) sessionWindow.executeAction("logout");
            else if (event.key === Qt.Key_H) sessionWindow.executeAction("hibernate");
        }

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            spacing: 28

            // ══════════════════════════════════════════════════════════════
            // USER INFO & SYSTEM UPTIME HEADER
            // ══════════════════════════════════════════════════════════════
            GlassCard {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: headerRow.implicitWidth + 36
                implicitHeight: 64
                radius: Theme.radiusLarge
                elevation: 3

                RowLayout {
                    id: headerRow
                    anchors.centerIn: parent
                    spacing: 16

                    // User Avatar Icon
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: Theme.palette.primaryContainer

                        Text {
                            anchors.centerIn: parent
                            text: "󰄛"
                            font.family: Theme.fontFamily
                            font.pixelSize: 22
                            color: Theme.palette.colOnPrimaryContainer
                        }
                    }

                    // Username & Hostname
                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: `${HardwareService.username}@${HardwareService.hostname}`
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTitle
                            font.weight: Font.Bold
                            color: Theme.palette.colOnSurface
                        }
                        Text {
                            text: `Uptime: ${HardwareService.uptimeFormatted} • Battery: ${Math.round(BatteryService.percentage * 100)}%`
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeCaption
                            color: Theme.palette.colOnSurfaceVariant
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // 6 POWER ACTION TILES
            // ══════════════════════════════════════════════════════════════
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Repeater {
                    model: [
                        { label: "Shutdown", key: "S", icon: "󰐥", cmd: "poweroff", accent: Theme.palette.error, bg: Theme.palette.errorContainer, fg: Theme.palette.colOnErrorContainer },
                        { label: "Restart", key: "R", icon: "󰜉", cmd: "reboot", accent: Theme.palette.colWarning, bg: Theme.palette.layer2, fg: Theme.palette.colOnSurface },
                        { label: "Suspend", key: "U", icon: "󰤄", cmd: "suspend", accent: Theme.palette.primary, bg: Theme.palette.layer2, fg: Theme.palette.colOnSurface },
                        { label: "Lock", key: "L", icon: "󰌾", cmd: "lock", accent: Theme.palette.secondary, bg: Theme.palette.layer2, fg: Theme.palette.colOnSurface },
                        { label: "Logout", key: "O", icon: "󰍃", cmd: "logout", accent: Theme.palette.tertiary, bg: Theme.palette.layer2, fg: Theme.palette.colOnSurface },
                        { label: "Hibernate", key: "H", icon: "󰒲", cmd: "hibernate", accent: Theme.palette.outline, bg: Theme.palette.layer2, fg: Theme.palette.colOnSurface }
                    ]

                    delegate: GlassCard {
                        id: actionCard
                        implicitWidth: 110
                        implicitHeight: 120
                        radius: Theme.radiusLarge
                        elevation: hovered ? 4 : 2
                        interactive: true

                        color: hovered ? ColorResolver.transparentize(modelData.bg, 0.6) : ColorResolver.transparentize(Theme.palette.layer2, 0.4)
                        border.color: hovered ? modelData.accent : Theme.palette.glassBorder
                        border.width: hovered ? 2 : 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            // Big Icon
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                font.family: Theme.fontFamily
                                font.pixelSize: 36
                                color: hovered ? modelData.accent : modelData.fg
                            }

                            // Label
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                font.weight: Font.DemiBold
                                color: Theme.palette.colOnSurface
                            }

                            // Key Shortcut Hint
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 22
                                height: 18
                                radius: 4
                                color: Theme.palette.layer3

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.key
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: Theme.palette.colOnSurfaceVariant
                                }
                            }
                        }

                        onClicked: {
                            sessionWindow.executeAction(modelData.cmd);
                        }
                    }
                }
            }

            // Keyboard navigation hint footer
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Press [S]hutdown, [R]estart, s[U]spend, [L]ock, l[O]gout, [H]ibernate, or [Esc] to cancel"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeCaption
                color: Theme.palette.outline
            }
        }
    }

    function executeAction(cmd) {
        ShellService.sessionOpen = false;
        if (cmd === "poweroff") {
            Quickshell.execDetached(["systemctl", "poweroff"]);
        } else if (cmd === "reboot") {
            Quickshell.execDetached(["systemctl", "reboot"]);
        } else if (cmd === "suspend") {
            Quickshell.execDetached(["systemctl", "suspend"]);
        } else if (cmd === "hibernate") {
            Quickshell.execDetached(["systemctl", "hibernate"]);
        } else if (cmd === "lock") {
            LockManager.lock();
        } else if (cmd === "logout") {
            if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")) {
                Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
            } else {
                Quickshell.execDetached(["pkill", "-u", HardwareService.username]);
            }
        }
    }
}
