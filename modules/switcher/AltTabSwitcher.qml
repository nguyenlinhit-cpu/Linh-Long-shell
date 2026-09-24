import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: switcherWindow

    property bool isOpen: ShellService.switcherOpen
    property int currentIndex: 0

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-switcher"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    readonly property var windowsList: CompositorService.openWindows

    onIsOpenChanged: {
        if (isOpen) {
            let len = switcherWindow.windowsList.length;
            if (len > 1) {
                switcherWindow.currentIndex = 1; // Highlight the next window
            } else {
                switcherWindow.currentIndex = 0;
            }
            containerItem.forceActiveFocus();
        }
    }

    function activateSelected() {
        if (windowsList.length > 0 && currentIndex < windowsList.length) {
            CompositorService.focusWindow(windowsList[currentIndex]);
        }
        ShellService.switcherOpen = false;
    }

    function cycleNext() {
        if (windowsList.length > 0) {
            currentIndex = (currentIndex + 1) % windowsList.length;
            windowList.positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    function cyclePrev() {
        if (windowsList.length > 0) {
            currentIndex = (currentIndex - 1 + windowsList.length) % windowsList.length;
            windowList.positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    // Dismiss backdrop
    MouseArea {
        anchors.fill: parent
        onClicked: ShellService.switcherOpen = false
    }

    Item {
        id: containerItem
        anchors.centerIn: parent
        width: Math.min(Math.max(windowsList.length * 160 + 40, 360), 960)
        height: 190
        focus: switcherWindow.isOpen

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellService.switcherOpen = false;
                event.accepted = true;
            } else if (event.key === Qt.Key_Tab) {
                if (event.modifiers & Qt.ShiftModifier) {
                    switcherWindow.cyclePrev();
                } else {
                    switcherWindow.cycleNext();
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                switcherWindow.cycleNext();
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                switcherWindow.cyclePrev();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                switcherWindow.activateSelected();
                event.accepted = true;
            }
        }

        GlassCard {
            anchors.fill: parent
            radius: Theme.radiusLarge
            elevation: 4

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "󰕰"
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        color: Theme.palette.primary
                    }
                    Text {
                        text: "Window Switcher"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        font.weight: Font.DemiBold
                        color: Theme.palette.colOnSurface
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Tab / Arrows to cycle • Enter to focus"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.palette.colOnSurfaceVariant
                    }
                }

                // Horizontal Window Cards Carousel
                ListView {
                    id: windowList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    orientation: ListView.Horizontal
                    spacing: 12
                    clip: true
                    model: switcherWindow.windowsList

                    delegate: GlassCard {
                        id: card
                        width: 140
                        height: 120
                        radius: Theme.radiusMedium
                        interactive: true
                        elevation: index === switcherWindow.currentIndex ? 3 : 1
                        color: index === switcherWindow.currentIndex ? Theme.palette.layer3 : Theme.palette.layer2
                        border.width: index === switcherWindow.currentIndex ? 2 : 1
                        border.color: index === switcherWindow.currentIndex ? Theme.palette.primary : Theme.palette.outlineVariant

                        onClicked: {
                            switcherWindow.currentIndex = index;
                            switcherWindow.activateSelected();
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            // App Icon
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 48
                                height: 48
                                radius: Theme.radiusSmall
                                color: Theme.palette.layer3

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        let app = (modelData.appId || "").toLowerCase();
                                        if (app.includes("term") || app.includes("kitty") || app.includes("foot") || app.includes("alacritty")) return "󰞷";
                                        if (app.includes("code") || app.includes("nvim")) return "󰨞";
                                        if (app.includes("firefox") || app.includes("chrome") || app.includes("browser")) return "󰈹";
                                        if (app.includes("music") || app.includes("spotify")) return "󰝚";
                                        if (app.includes("discord")) return "󰙯";
                                        if (app.includes("file") || app.includes("thunar") || app.includes("nautilus")) return "󰉋";
                                        return "󰣆";
                                    }
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 26
                                    color: index === switcherWindow.currentIndex ? Theme.palette.primary : Theme.palette.colOnSurface
                                }
                            }

                            // Window Title
                            Text {
                                Layout.fillWidth: true
                                text: modelData.title || modelData.appId || "Window"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: index === switcherWindow.currentIndex ? Font.Bold : Font.Normal
                                color: Theme.palette.colOnSurface
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                            }

                            // App ID badge
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.appId || ""
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.palette.colOnSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Empty State
                Text {
                    visible: switcherWindow.windowsList.length === 0
                    Layout.alignment: Qt.AlignHCenter
                    text: "No open windows"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBody
                    color: Theme.palette.colOnSurfaceVariant
                }
            }
        }
    }
}
