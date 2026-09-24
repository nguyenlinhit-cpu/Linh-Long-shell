import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: overviewWindow

    property bool isOpen: ShellService.overviewOpen

    onIsOpenChanged: {
        if (isOpen) {
            overviewSearch.text = "";
            overviewSearch.forceActiveFocus();
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
    WlrLayershell.namespace: "linh-long-overview"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        ShellService.toggleOverview();
    }

    // Blurred Backdrop & Dismiss on click
    Rectangle {
        anchors.fill: parent
        color: ColorResolver.transparentize(Theme.palette.layer0, 0.4)

        MouseArea {
            anchors.fill: parent
            onClicked: ShellService.overviewOpen = false
        }
    }

    Item {
        anchors.centerIn: parent
        width: Math.min(1080, parent.width - 64)
        height: Math.min(680, parent.height - 64)

        focus: overviewWindow.isOpen
        Keys.onEscapePressed: ShellService.overviewOpen = false

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            // ══════════════════════════════════════════════════════════════
            // WORKSPACES STRIP
            // ══════════════════════════════════════════════════════════════
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Repeater {
                    model: CompositorService.workspaces
                    delegate: GlassCard {
                        implicitWidth: 80
                        implicitHeight: 44
                        radius: Theme.radiusMedium
                        elevation: modelData.active ? 3 : 1
                        interactive: true

                        color: modelData.active ? ColorResolver.transparentize(Theme.palette.primaryContainer, 0.5) : ColorResolver.transparentize(Theme.palette.layer2, 0.6)
                        border.color: modelData.active ? Theme.palette.primary : Theme.palette.glassBorder

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: `WS ${modelData.id}`
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                font.weight: modelData.active ? Font.Bold : Font.Normal
                                color: modelData.active ? Theme.palette.colOnPrimaryContainer : Theme.palette.colOnSurface
                            }

                            Rectangle {
                                visible: modelData.hasWindows
                                width: 6
                                height: 6
                                radius: 3
                                color: modelData.active ? Theme.palette.primary : Theme.palette.colOnSurfaceVariant
                            }
                        }

                        onClicked: {
                            CompositorService.switchToWorkspace(modelData.id);
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // SEARCH FILTER BAR
            // ══════════════════════════════════════════════════════════════
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Math.min(480, parent.width)
                implicitHeight: 44
                radius: Theme.radiusLarge
                color: Theme.palette.layer2
                border.width: 1
                border.color: overviewSearch.activeFocus ? Theme.palette.primary : Theme.palette.glassBorder

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
                        id: overviewSearch
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        color: Theme.palette.colOnSurface
                        selectByMouse: true

                        Text {
                            visible: !parent.text && !parent.inputMethodComposing
                            text: "Type to filter running windows..."
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            color: Theme.palette.outline
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // RUNNING WINDOWS GRID
            // ══════════════════════════════════════════════════════════════
            GridView {
                id: windowGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: width / 3
                cellHeight: 180
                clip: true

                model: {
                    let q = overviewSearch.text.trim().toLowerCase();
                    return CompositorService.openWindows.filter(w => {
                        if (!q) return true;
                        let title = (w.title || "").toLowerCase();
                        let app = (w.appId || "").toLowerCase();
                        return title.includes(q) || app.includes(q);
                    });
                }

                delegate: Item {
                    width: windowGrid.cellWidth
                    height: windowGrid.cellHeight

                    GlassCard {
                        anchors.fill: parent
                        anchors.margins: 8
                        radius: Theme.radiusMedium
                        elevation: hovered ? 3 : 1
                        interactive: true

                        color: hovered ? ColorResolver.transparentize(Theme.palette.layer3, 0.6) : ColorResolver.transparentize(Theme.palette.layer2, 0.4)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            // Header: App Icon & Close Button
                            RowLayout {
                                Layout.fillWidth: true

                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: Theme.radiusSmall
                                    color: Theme.palette.layer3

                                    Text {
                                        anchors.centerIn: parent
                                        text: overviewWindow.resolveAppIcon(modelData.appId)
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 18
                                        color: Theme.palette.primary
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.appId || "Window"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeCaption
                                    font.weight: Font.DemiBold
                                    color: Theme.palette.colOnSurfaceVariant
                                    elide: Text.ElideRight
                                }

                                IconButton {
                                    icon: "󰅖"
                                    implicitWidth: 26
                                    implicitHeight: 26
                                    iconSize: 12
                                    tooltip: "Close Window"
                                    onClicked: {
                                        CompositorService.closeWindow(modelData);
                                    }
                                }
                            }

                            // Body: Window Title
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: modelData.title || "Untitled"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                font.weight: Font.Medium
                                color: Theme.palette.colOnSurface
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 3
                            }

                            // Footer: Focus action badge
                            Badge {
                                text: "Click to Focus"
                                badgeColor: Theme.palette.primaryContainer
                                textColor: Theme.palette.colOnPrimaryContainer
                            }
                        }

                        onClicked: {
                            CompositorService.focusWindow(modelData);
                            ShellService.overviewOpen = false;
                        }
                    }
                }
            }
        }
    }

    function resolveAppIcon(appId) {
        let low = (appId || "").toLowerCase();
        if (low.includes("firefox")) return "󰈹";
        if (low.includes("ghostty") || low.includes("terminal") || low.includes("kitty")) return "󰄛";
        if (low.includes("nvim") || low.includes("vim")) return "󰕷";
        if (low.includes("yazi") || low.includes("file")) return "󰉋";
        if (low.includes("antigravity") || low.includes("code")) return "󰨞";
        if (low.includes("spotify") || low.includes("music")) return "󰓇";
        return "󱂬";
    }
}
