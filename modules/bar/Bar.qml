import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: barWindow

    // Layer shell docking configuration
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: ConfigService.barHeight + ConfigService.barMarginY * 2
    color: "transparent"

    // Wayland layer shell properties
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "linh-long-bar"
    WlrLayershell.exclusiveZone: ConfigService.barHeight + ConfigService.barMarginY

    // Floating dynamic island container
    Item {
        anchors.fill: parent
        anchors.topMargin: ConfigService.barMarginY
        anchors.bottomMargin: ConfigService.barMarginY
        anchors.leftMargin: ConfigService.barMarginX
        anchors.rightMargin: ConfigService.barMarginX

        RowLayout {
            anchors.fill: parent
            spacing: 12

            // ══════════════════════════════════════════════════════════════
            // LEFT PILL: Launcher + Workspaces + Active Window
            // ══════════════════════════════════════════════════════════════
            GlassCard {
                Layout.fillHeight: true
                Layout.preferredWidth: leftLayout.implicitWidth + 20
                radius: Theme.radiusPill
                elevation: 2

                RowLayout {
                    id: leftLayout
                    anchors.centerIn: parent
                    spacing: 8

                    // App Launcher Trigger
                    IconButton {
                        icon: "" // NixOS / Wayland logo
                        tooltip: "Open Launcher (Super + Space)"
                        iconSize: 20
                        onClicked: ShellService.toggleLauncher()
                    }

                    // Workspace Indicators
                    Row {
                        spacing: 5
                        Repeater {
                            model: CompositorService.workspaces
                            delegate: Rectangle {
                                width: modelData.active ? 28 : 12
                                height: 12
                                radius: 6
                                color: modelData.active ? Theme.palette.primary : (modelData.hasWindows ? Theme.palette.layer3 : Theme.palette.layer2)

                                Behavior on width {
                                    NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutCubic }
                                }
                                Behavior on color {
                                    ColorAnimation { duration: Motion.durationShort3; easing.type: Easing.OutCubic }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: CompositorService.switchToWorkspace(modelData.id)
                                }
                            }
                        }
                    }

                    // Active Window Title Pill
                    Rectangle {
                        visible: CompositorService.activeWindowTitle.length > 0 && CompositorService.activeWindowTitle !== "Desktop"
                        width: 1
                        height: 16
                        color: Theme.palette.glassBorder
                    }

                    Row {
                        visible: CompositorService.activeWindowTitle.length > 0 && CompositorService.activeWindowTitle !== "Desktop"
                        spacing: 6

                        Text {
                            text: "󱂬"
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.palette.primary
                        }

                        Text {
                            text: CompositorService.activeWindowTitle.length > 28 ? CompositorService.activeWindowTitle.substring(0, 28) + "..." : CompositorService.activeWindowTitle
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeCaption
                            color: Theme.palette.colOnSurface
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // CENTER PILL: Clock (Interactive Calendar Trigger) + Media Scrobbler
            // ══════════════════════════════════════════════════════════════
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GlassCard {
                    anchors.centerIn: parent
                    height: parent.height
                    width: centerLayout.implicitWidth + 24
                    radius: Theme.radiusPill
                    elevation: 2

                    RowLayout {
                        id: centerLayout
                        anchors.centerIn: parent
                        spacing: 14

                        // Clock & Date (Click to open CalendarPopup)
                        Item {
                            implicitWidth: clockRow.implicitWidth
                            implicitHeight: clockRow.implicitHeight

                            Row {
                                id: clockRow
                                spacing: 6
                                Text {
                                    text: Qt.formatDateTime(new Date(), ConfigService.timeFormat)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeBody
                                    font.weight: Font.Bold
                                    color: Theme.palette.colOnSurface

                                    Timer {
                                        interval: 1000
                                        running: true
                                        repeat: true
                                        onTriggered: parent.text = Qt.formatDateTime(new Date(), ConfigService.timeFormat)
                                    }
                                }

                                Text {
                                    text: Qt.formatDateTime(new Date(), ConfigService.dateFormat)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeBodySmall
                                    color: Theme.palette.colOnSurfaceVariant
                                    anchors.baseline: parent.children[0].baseline
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: ShellService.toggleCalendar()
                            }
                        }

                        // Mini Media Pill (Visible when media is playing)
                        Rectangle {
                            visible: MediaService.hasMedia && ConfigService.barShowMediaPill
                            width: 1
                            height: 16
                            color: Theme.palette.glassBorder
                        }

                        RowLayout {
                            visible: MediaService.hasMedia && ConfigService.barShowMediaPill
                            spacing: 8

                            IconButton {
                                icon: MediaService.isPlaying ? "󰏤" : "󰐊"
                                iconSize: 14
                                implicitWidth: 26
                                implicitHeight: 26
                                onClicked: MediaService.togglePlayPause()
                            }

                            Text {
                                text: MediaService.title.length > 24 ? MediaService.title.substring(0, 24) + "..." : MediaService.title
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBodySmall
                                color: Theme.palette.colOnSurface
                                elide: Text.ElideRight
                                Layout.maximumWidth: 160

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: ShellService.toggleMedia()
                                }
                            }
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // RIGHT PILL: Hardware Gauges, Audio, Battery, Settings & Power
            // ══════════════════════════════════════════════════════════════
            GlassCard {
                Layout.fillHeight: true
                Layout.preferredWidth: rightLayout.implicitWidth + 20
                radius: Theme.radiusPill
                elevation: 2

                RowLayout {
                    id: rightLayout
                    anchors.centerIn: parent
                    spacing: 10

                    // Hardware Mini Gauges (CPU & RAM)
                    Row {
                        visible: ConfigService.barShowHardwareMini
                        spacing: 8

                        // CPU Pill
                        Row {
                            spacing: 4
                            Text { text: ""; font.family: Theme.fontFamily; font.pixelSize: 13; color: Theme.palette.primary }
                            Text {
                                text: Math.round(HardwareService.cpuUsage * 100) + "%"
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                color: Theme.palette.colOnSurfaceVariant
                            }
                        }

                        // RAM Pill
                        Row {
                            spacing: 4
                            Text { text: "󰘚"; font.family: Theme.fontFamily; font.pixelSize: 13; color: Theme.palette.secondary }
                            Text {
                                text: Math.round(HardwareService.ramUsage * 100) + "%"
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                color: Theme.palette.colOnSurfaceVariant
                            }
                        }
                    }

                    Rectangle {
                        width: 1
                        height: 16
                        color: Theme.palette.glassBorder
                    }

                    // Audio Volume Pill (Click = mute, Wheel = adjust)
                    Item {
                        implicitWidth: audioRow.implicitWidth
                        implicitHeight: audioRow.implicitHeight

                        Row {
                            id: audioRow
                            spacing: 4
                            Text {
                                text: AudioService.muted ? "󰝟" : (AudioService.volumePercent > 50 ? "󰕾" : "󰕿")
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                color: AudioService.muted ? Theme.palette.error : Theme.palette.colOnSurface
                            }
                            Text {
                                text: AudioService.volumePercent + "%"
                                font.family: Theme.fontMono
                                font.pixelSize: 11
                                color: Theme.palette.colOnSurfaceVariant
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: AudioService.toggleMute()
                            onWheel: wheel => {
                                if (wheel.angleDelta.y > 0) AudioService.incrementVolume();
                                else AudioService.decrementVolume();
                            }
                        }
                    }

                    // Battery Pill
                    Row {
                        visible: BatteryService.hasBattery && ConfigService.barShowBattery
                        spacing: 4
                        Text {
                            text: BatteryService.isCharging ? "󰂄" : "󰁹"
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            color: BatteryService.isCritical ? Theme.palette.error : Theme.palette.colOnSurface
                        }
                        Text {
                            text: BatteryService.percentageInt + "%"
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            color: Theme.palette.colOnSurfaceVariant
                        }
                    }

                    // Clipboard History Trigger Button
                    IconButton {
                        icon: "󰅍"
                        tooltip: "Clipboard History (Super + V)"
                        iconSize: 15
                        implicitWidth: 28
                        implicitHeight: 28
                        onClicked: ShellService.toggleClipboard()
                    }

                    // Control Center Trigger Button
                    IconButton {
                        icon: "󰍜"
                        tooltip: "Quick Settings & Mixer (Super + C)"
                        iconSize: 16
                        implicitWidth: 28
                        implicitHeight: 28
                        onClicked: ShellService.toggleControlCenter()
                    }

                    // Settings Button
                    IconButton {
                        icon: "󰒓"
                        tooltip: "Linh-Long Settings"
                        iconSize: 15
                        implicitWidth: 28
                        implicitHeight: 28
                        onClicked: ShellService.toggleSettings()
                    }

                    // Power / Session Button
                    IconButton {
                        icon: "󰐥"
                        tooltip: "Power & Session Menu (Super + Esc)"
                        iconSize: 15
                        implicitWidth: 28
                        implicitHeight: 28
                        onClicked: ShellService.toggleSession()
                    }
                }
            }
        }
    }
}
