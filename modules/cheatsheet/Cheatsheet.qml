import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: cheatsheetWindow

    property bool isOpen: false

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-cheatsheet"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        isOpen = !isOpen;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: cheatsheetWindow.isOpen = false
    }

    GlassCard {
        anchors.centerIn: parent
        width: 780
        height: 520
        radius: Theme.radiusLarge
        elevation: 4

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text { text: "󰌌"; font.family: Theme.fontFamily; font.pixelSize: 24; color: Theme.palette.primary }
                Text {
                    text: "Keyboard Shortcuts Cheatsheet"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeHeadline
                    font.weight: Font.Bold
                    color: Theme.palette.colOnSurface
                }
                Item { Layout.fillWidth: true }
                IconButton {
                    icon: "󰅖"
                    onClicked: cheatsheetWindow.isOpen = false
                }
            }

            // Shortcuts Grid
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                rowSpacing: 14
                columnSpacing: 24

                // Section 1: Shell Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { text: "Desktop Shell"; font.family: Theme.fontFamily; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.palette.primary }
                    
                    Repeater {
                        model: [
                            { keys: ["Super", "Space"], desc: "Open App Launcher" },
                            { keys: ["Super", "C"], desc: "Toggle Control Center" },
                            { keys: ["Super", "A"], desc: "Toggle AI Copilot Sidebar" },
                            { keys: ["Super", "L"], desc: "Lock Screen" },
                            { keys: ["Super", "/"], desc: "Toggle This Cheatsheet" }
                        ]
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            Text { text: modelData.desc; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.palette.colOnSurface; Layout.fillWidth: true }
                            Row {
                                spacing: 4
                                Repeater {
                                    model: modelData.keys
                                    delegate: Rectangle {
                                        width: keyText.implicitWidth + 12
                                        height: 22
                                        radius: 4
                                        color: Theme.palette.layer2
                                        border.width: 1
                                        border.color: Theme.palette.outline
                                        Text { id: keyText; anchors.centerIn: parent; text: modelData; font.family: Theme.fontMono; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.palette.colOnSurface }
                                    }
                                }
                            }
                        }
                    }
                }

                // Section 2: Window Management
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { text: "Window Management"; font.family: Theme.fontFamily; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.palette.secondary }

                    Repeater {
                        model: [
                            { keys: ["Super", "Q"], desc: "Close Active Window" },
                            { keys: ["Super", "F"], desc: "Toggle Fullscreen" },
                            { keys: ["Super", "V"], desc: "Toggle Floating" },
                            { keys: ["Super", "1-9"], desc: "Switch Workspace" },
                            { keys: ["Super", "Shift", "1-9"], desc: "Move Window to Workspace" }
                        ]
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            Text { text: modelData.desc; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.palette.colOnSurface; Layout.fillWidth: true }
                            Row {
                                spacing: 4
                                Repeater {
                                    model: modelData.keys
                                    delegate: Rectangle {
                                        width: keyText2.implicitWidth + 12
                                        height: 22
                                        radius: 4
                                        color: Theme.palette.layer2
                                        border.width: 1
                                        border.color: Theme.palette.outline
                                        Text { id: keyText2; anchors.centerIn: parent; text: modelData; font.family: Theme.fontMono; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.palette.colOnSurface }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
