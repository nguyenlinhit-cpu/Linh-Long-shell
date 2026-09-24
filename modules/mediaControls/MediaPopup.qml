import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: mediaWindow

    property bool isOpen: ShellService.mediaOpen

    anchors {
        top: true
        left: true
    }
    margins {
        top: 48
        left: 360
    }
    implicitWidth: 380
    implicitHeight: 220
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-media-popup"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    visible: isOpen

    GlassCard {
        anchors.fill: parent
        anchors.margins: 4
        radius: Theme.radiusLarge
        elevation: 3

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Header: Player identity + Close
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "󰝚"
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    color: Theme.palette.primary
                }

                Text {
                    text: MediaService.hasMedia ? (MediaService.activePlayer?.identity || "Now Playing") : "Now Playing"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBody
                    font.weight: Font.DemiBold
                    color: Theme.palette.colOnSurface
                }

                Item { Layout.fillWidth: true }

                IconButton {
                    icon: "󰅖"
                    implicitWidth: 26
                    implicitHeight: 26
                    iconSize: 14
                    onClicked: ShellService.mediaOpen = false
                }
            }

            // Track info with Album Art
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Album Art thumbnail
                Rectangle {
                    width: 64
                    height: 64
                    radius: Theme.radiusMedium
                    color: Theme.palette.layer3
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: MediaService.artUrl
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        visible: !MediaService.artUrl
                        anchors.centerIn: parent
                        text: "󰝚"
                        font.family: Theme.fontFamily
                        font.pixelSize: 28
                        color: Theme.palette.colOnSurfaceVariant
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: MediaService.title
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        font.weight: Font.Bold
                        color: Theme.palette.colOnSurface
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: MediaService.artist
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBodySmall
                        color: Theme.palette.colOnSurfaceVariant
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: !!MediaService.album
                        text: MediaService.album
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.palette.outline
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            // Scrubber Progress Bar
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Rectangle {
                    id: progressBar
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Theme.palette.layer3

                    Rectangle {
                        height: parent.height
                        width: parent.width * Math.min(1.0, Math.max(0.0, MediaService.progress))
                        radius: 3
                        color: Theme.palette.primary
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => {
                            let ratio = mouse.x / width;
                            MediaService.seekToProgress(ratio);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: MediaService.formatTime(MediaService.position)
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.palette.colOnSurfaceVariant
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: MediaService.formatTime(MediaService.length)
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.palette.colOnSurfaceVariant
                    }
                }
            }

            // Playback Controls Row
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                IconButton {
                    icon: "󰒮"
                    implicitWidth: 36
                    implicitHeight: 36
                    iconSize: 18
                    onClicked: MediaService.previous()
                }

                // Big Circular Play/Pause
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: Theme.palette.primary

                    Text {
                        anchors.centerIn: parent
                        text: MediaService.isPlaying ? "󰏤" : "󰐊"
                        font.family: Theme.fontFamily
                        font.pixelSize: 22
                        color: Theme.palette.colOnPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: MediaService.togglePlayPause()
                    }
                }

                IconButton {
                    icon: "󰒭"
                    implicitWidth: 36
                    implicitHeight: 36
                    iconSize: 18
                    onClicked: MediaService.next()
                }
            }
        }
    }
}
