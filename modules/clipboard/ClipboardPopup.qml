import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: clipWindow

    property bool isOpen: ShellService.clipboardOpen
    property string searchQuery: ""
    property int selectedIndex: 0

    readonly property var filteredList: {
        let query = clipWindow.searchQuery.toLowerCase().trim();
        let list = ClipboardService.history;
        if (!query) return list;
        return list.filter(item => (item.text || "").toLowerCase().includes(query));
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-clipboard"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    onIsOpenChanged: {
        if (isOpen) {
            searchQuery = "";
            selectedIndex = 0;
            ClipboardService.refresh();
            searchInput.forceActiveFocus();
        }
    }

    // Dismiss when clicking outside modal card
    MouseArea {
        anchors.fill: parent
        onClicked: ShellService.toggleClipboard()
    }

    // Center Dialog
    GlassCard {
        id: mainCard
        width: 580
        height: 520
        anchors.centerIn: parent
        radius: Theme.radiusLarge
        elevation: 4

        // Prevent click propagation
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "󰅍"
                    font.family: Theme.fontFamily
                    font.pixelSize: 22
                    color: Theme.palette.primary
                }

                Text {
                    text: "Clipboard History"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle
                    font.weight: Font.Bold
                    color: Theme.palette.colOnSurface
                }

                Badge {
                    text: `${clipWindow.filteredList.length} items`
                    variant: "primary"
                }

                Item { Layout.fillWidth: true }

                IconButton {
                    icon: "󰃢"
                    implicitWidth: 32
                    implicitHeight: 32
                    iconSize: 16
                    onClicked: ClipboardService.clearAll()
                }

                IconButton {
                    icon: "󰅖"
                    implicitWidth: 32
                    implicitHeight: 32
                    iconSize: 16
                    onClicked: ShellService.toggleClipboard()
                }
            }

            // Search Bar
            GlassCard {
                Layout.fillWidth: true
                height: 44
                radius: Theme.radiusMedium
                elevation: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "󰍉"
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                        color: Theme.palette.colOnSurfaceVariant
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        color: Theme.palette.colOnSurface
                        clip: true
                        text: clipWindow.searchQuery
                        onTextChanged: {
                            clipWindow.searchQuery = text;
                            clipWindow.selectedIndex = 0;
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                ShellService.toggleClipboard();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                if (clipWindow.selectedIndex < clipWindow.filteredList.length - 1) {
                                    clipWindow.selectedIndex++;
                                    clipList.positionViewAtIndex(clipWindow.selectedIndex, ListView.Contain);
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                if (clipWindow.selectedIndex > 0) {
                                    clipWindow.selectedIndex--;
                                    clipList.positionViewAtIndex(clipWindow.selectedIndex, ListView.Contain);
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (clipWindow.filteredList.length > 0 && clipWindow.selectedIndex < clipWindow.filteredList.length) {
                                    let item = clipWindow.filteredList[clipWindow.selectedIndex];
                                    ClipboardService.copyToClipboard(item.text);
                                    NotificationDaemon.sendNotification("Clipboard", "Copied to clipboard", "󰅍");
                                    ShellService.toggleClipboard();
                                }
                                event.accepted = true;
                            }
                        }

                        Text {
                            visible: !searchInput.text
                            text: "Type to search clips... (Enter to copy, Esc to exit)"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            color: Theme.palette.colOnSurfaceVariant
                            opacity: 0.6
                        }
                    }
                }
            }

            // Clipboard Items List
            ListView {
                id: clipList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: clipWindow.filteredList

                delegate: GlassCard {
                    id: itemCard
                    width: clipList.width
                    height: 56
                    radius: Theme.radiusSmall
                    interactive: true
                    elevation: index === clipWindow.selectedIndex ? 3 : 1
                    color: index === clipWindow.selectedIndex ? Theme.palette.layer3 : Theme.palette.layer2

                    onClicked: {
                        ClipboardService.copyToClipboard(modelData.text);
                        NotificationDaemon.sendNotification("Clipboard", "Copied to clipboard", "󰅍");
                        ShellService.toggleClipboard();
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        // Icon
                        Text {
                            text: modelData.pinned ? "󰐃" : "󰆏"
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            color: modelData.pinned ? Theme.palette.primary : Theme.palette.colOnSurfaceVariant
                        }

                        // Preview content
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.preview.replace(/[\r\n]+/g, " ")
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                color: Theme.palette.colOnSurface
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            RowLayout {
                                spacing: 8
                                Text {
                                    text: `${modelData.chars || modelData.text.length} chars`
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: Theme.palette.colOnSurfaceVariant
                                }
                                Text {
                                    text: "•"
                                    font.pixelSize: 9
                                    color: Theme.palette.colOnSurfaceVariant
                                }
                                Text {
                                    text: modelData.timestamp || ""
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: Theme.palette.colOnSurfaceVariant
                                }
                            }
                        }

                        // Pin button
                        IconButton {
                            icon: modelData.pinned ? "󰐃" : "󰤱"
                            implicitWidth: 28
                            implicitHeight: 28
                            iconSize: 14
                            color: modelData.pinned ? Theme.palette.primary : Theme.palette.colOnSurfaceVariant
                            onClicked: ClipboardService.togglePin(modelData.id)
                        }

                        // Delete button
                        IconButton {
                            icon: "󰅖"
                            implicitWidth: 28
                            implicitHeight: 28
                            iconSize: 14
                            onClicked: ClipboardService.deleteEntry(modelData.id)
                        }
                    }
                }

                // Empty Placeholder
                Item {
                    anchors.centerIn: parent
                    visible: clipList.count === 0
                    width: 200
                    height: 100

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰅍"
                            font.family: Theme.fontFamily
                            font.pixelSize: 36
                            color: Theme.palette.colOnSurfaceVariant
                            opacity: 0.4
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No clipboard entries found"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            color: Theme.palette.colOnSurfaceVariant
                        }
                    }
                }
            }
        }
    }
}
