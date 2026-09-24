import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: osdWindow

    property bool showOsd: false
    property string osdIcon: "󰕾"
    property real osdValue: 0.5
    property string osdTitle: "Volume"

    anchors {
        bottom: true
    }
    implicitWidth: 280
    implicitHeight: 80
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-osd"

    visible: showOsd

    Timer {
        id: hideTimer
        interval: 1800
        repeat: false
        onTriggered: osdWindow.showOsd = false
    }

    // Connect to volume changes
    Connections {
        target: AudioService
        function onVolumeChanged() {
            osdWindow.osdIcon = AudioService.muted ? "󰝟" : "󰕾";
            osdWindow.osdValue = AudioService.volume;
            osdWindow.osdTitle = "Volume";
            osdWindow.trigger();
        }
    }

    function trigger() {
        showOsd = true;
        hideTimer.restart();
    }

    GlassCard {
        anchors.centerIn: parent
        width: 260
        height: 64
        radius: Theme.radiusLarge
        elevation: 3

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Text {
                text: osdWindow.osdIcon
                font.family: Theme.fontFamily
                font.pixelSize: 24
                color: Theme.palette.primary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: osdWindow.osdTitle
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Theme.palette.colOnSurface
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Math.round(osdWindow.osdValue * 100) + "%"
                        font.family: Theme.fontMono
                        font.pixelSize: 12
                        color: Theme.palette.colOnSurfaceVariant
                    }
                }

                // Smooth Progress Bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Theme.palette.layer3

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: Math.min(parent.width, parent.width * Math.max(0, Math.min(1, osdWindow.osdValue)))
                        radius: 4
                        color: Theme.palette.primary

                        Behavior on width {
                            NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
}
