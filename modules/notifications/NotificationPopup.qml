import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: notifWindow

    anchors {
        top: true
        right: true
    }
    implicitWidth: 360
    implicitHeight: Math.min(600, toastsColumn.implicitHeight + 32)
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-notifications"

    visible: NotificationDaemon.activeToasts.length > 0

    ColumnLayout {
        id: toastsColumn
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        width: 340
        spacing: 10

        Repeater {
            model: NotificationDaemon.activeToasts
            delegate: GlassCard {
                id: toastCard
                Layout.fillWidth: true
                height: toastLayout.implicitHeight + 20
                radius: Theme.radiusMedium
                elevation: 3

                RowLayout {
                    id: toastLayout
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // App Icon
                    Rectangle {
                        width: 38
                        height: 38
                        radius: Theme.radiusSmall
                        color: Theme.palette.primaryContainer
                        Layout.alignment: Qt.AlignTop

                        Text {
                            anchors.centerIn: parent
                            text: "󰂚"
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                            color: Theme.palette.colOnPrimaryContainer
                        }
                    }

                    // Content
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: modelData.appName
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Theme.palette.primary
                                elide: Text.ElideRight
                            }
                            Item { Layout.fillWidth: true }
                            IconButton {
                                icon: "󰅖"
                                implicitWidth: 20
                                implicitHeight: 20
                                iconSize: 11
                                onClicked: NotificationDaemon.dismissToast(modelData.id)
                            }
                        }

                        Text {
                            text: modelData.summary
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: Theme.palette.colOnSurface
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: modelData.body.length > 0
                            text: modelData.body
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: Theme.palette.colOnSurfaceVariant
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
