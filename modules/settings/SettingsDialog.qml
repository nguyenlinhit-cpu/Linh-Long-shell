import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: settingsWindow

    property bool isOpen: ShellService.settingsOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-settings"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        ShellService.toggleSettings();
    }

    // Dismiss on backdrop click
    Rectangle {
        anchors.fill: parent
        color: ColorResolver.transparentize(Theme.palette.layer0, 0.4)

        MouseArea {
            anchors.fill: parent
            onClicked: ShellService.settingsOpen = false
        }
    }

    GlassCard {
        anchors.centerIn: parent
        width: Math.min(680, parent.width - 48)
        height: Math.min(640, parent.height - 48)
        radius: Theme.radiusLarge
        elevation: 4

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // ══════════════════════════════════════════════════════════════
            // HEADER
            // ══════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "󰒓"
                    font.family: Theme.fontFamily
                    font.pixelSize: 26
                    color: Theme.palette.primary
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Linh-Long Shell Settings"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTitle
                        font.weight: Font.Bold
                        color: Theme.palette.colOnSurface
                    }
                    Text {
                        text: "Customize aesthetics, themes, hardware services & layout"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption
                        color: Theme.palette.colOnSurfaceVariant
                    }
                }

                IconButton {
                    icon: "󰅖"
                    tooltip: "Close"
                    onClicked: ShellService.settingsOpen = false
                }
            }

            // ══════════════════════════════════════════════════════════════
            // SETTINGS SECTIONS (SCROLLABLE)
            // ══════════════════════════════════════════════════════════════
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: settingsCol.implicitHeight
                clip: true

                ColumnLayout {
                    id: settingsCol
                    width: parent.width
                    spacing: 20

                    // SECTION 1: THEME & COLOR PRESETS
                    Text {
                        text: "THEME PRESETS"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption
                        font.weight: Font.Bold
                        color: Theme.palette.primary
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 10

                        Repeater {
                            model: [
                                { id: "wallpaper", label: "Dynamic M3", icon: "󰸉" },
                                { id: "catppuccin", label: "Catppuccin", icon: "󰄛" },
                                { id: "tokyo-night", label: "Tokyo Night", icon: "󰌌" },
                                { id: "dracula", label: "Dracula", icon: "󰞆" },
                                { id: "nord", label: "Nord Frost", icon: "󰋊" },
                                { id: "oled", label: "Pure OLED", icon: "󰌶" }
                            ]

                            delegate: GlassCard {
                                Layout.fillWidth: true
                                height: 50
                                radius: Theme.radiusMedium
                                elevation: Theme.palette.activePreset === modelData.id ? 2 : 1
                                interactive: true

                                color: Theme.palette.activePreset === modelData.id ? ColorResolver.transparentize(Theme.palette.primaryContainer, 0.4) : ColorResolver.transparentize(Theme.palette.layer2, 0.5)
                                border.color: Theme.palette.activePreset === modelData.id ? Theme.palette.primary : Theme.palette.glassBorder

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Text {
                                        text: modelData.icon
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 18
                                        color: Theme.palette.primary
                                    }

                                    Text {
                                        text: modelData.label
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeBody
                                        font.weight: Font.DemiBold
                                        color: Theme.palette.colOnSurface
                                    }
                                }

                                onClicked: {
                                    if (modelData.id === "oled") {
                                        Theme.palette.oledMode = true;
                                        Theme.palette.applyPreset("wallpaper", true);
                                    } else {
                                        Theme.palette.oledMode = false;
                                        Theme.palette.applyPreset(modelData.id, true);
                                    }
                                }
                            }
                        }
                    }

                    // SECTION 2: VISUAL TOGGLES
                    Text {
                        text: "SHELL AESTHETICS"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption
                        font.weight: Font.Bold
                        color: Theme.palette.primary
                    }

                    GlassCard {
                        Layout.fillWidth: true
                        radius: Theme.radiusMedium
                        elevation: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 14

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "Glassmorphism Blur Effect"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeBody
                                    color: Theme.palette.colOnSurface
                                }
                                Switch {
                                    checked: ConfigService.blurEnabled
                                    onToggled: ConfigService.blurEnabled = checked
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "Dock Auto-Hide on Maximize"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeBody
                                    color: Theme.palette.colOnSurface
                                }
                                Switch {
                                    checked: ConfigService.dockAutohide
                                    onToggled: ConfigService.dockAutohide = checked
                                }
                            }
                        }
                    }

                    // SECTION 3: SYSTEM ACTIONS
                    Text {
                        text: "QUICK LAUNCHERS"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption
                        font.weight: Font.Bold
                        color: Theme.palette.primary
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        GlassCard {
                            Layout.fillWidth: true
                            height: 48
                            radius: Theme.radiusMedium
                            interactive: true
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "󰸉"; font.family: Theme.fontFamily; font.pixelSize: 18; color: Theme.palette.primary }
                                Text { text: "Open Wallpapers"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeBody; color: Theme.palette.colOnSurface }
                            }
                            onClicked: {
                                settingsWindow.isOpen = false;
                                ShellService.toggleWallpaper();
                            }
                        }

                        GlassCard {
                            Layout.fillWidth: true
                            height: 48
                            radius: Theme.radiusMedium
                            interactive: true
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "󰐥"; font.family: Theme.fontFamily; font.pixelSize: 18; color: Theme.palette.error }
                                Text { text: "Power Menu"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeBody; color: Theme.palette.colOnSurface }
                            }
                            onClicked: {
                                settingsWindow.isOpen = false;
                                ShellService.toggleSession();
                            }
                        }
                    }
                }
            }
        }
    }
}
