import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

WlSessionLock {
    id: rootLock
    locked: LockManager.isLocked

    surface: Component {
        WlSessionLockSurface {
            id: lockSurface

            color: Theme.palette.background

            // Desktop Blur Simulation / Dim Overlay
            Rectangle {
                anchors.fill: parent
                color: ColorResolver.transparentize(Theme.palette.background, 0.82)
            }

            // Centered Lock Box
            Item {
                anchors.centerIn: parent
                width: 360
                height: 480

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 24

                    // Large Lock Clock
                    Column {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDateTime(new Date(), "hh:mm")
                            font.family: Theme.fontFamily
                            font.pixelSize: 64
                            font.weight: Font.Bold
                            color: Theme.palette.colOnSurface

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm")
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTitle
                            color: Theme.palette.colOnSurfaceVariant
                        }
                    }

                    // User Avatar & Name
                    Column {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 76
                            height: 76
                            radius: 38
                            color: Theme.palette.primaryContainer
                            border.width: 2
                            border.color: Theme.palette.primary

                            Text {
                                anchors.centerIn: parent
                                text: "󰄛"
                                font.family: Theme.fontFamily
                                font.pixelSize: 38
                                color: Theme.palette.colOnPrimaryContainer
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Quickshell.env("USER") || "User"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTitle
                            font.weight: Font.DemiBold
                            color: Theme.palette.colOnSurface
                        }
                    }

                    // Password Input Box
                    GlassCard {
                        Layout.alignment: Qt.AlignHCenter
                        width: 320
                        height: 48
                        radius: Theme.radiusMedium
                        elevation: 3

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: "󰌾"
                                font.family: Theme.fontFamily
                                font.pixelSize: 18
                                color: LockManager.authFailed ? Theme.palette.colOnError : Theme.palette.primary
                            }

                            TextInput {
                                id: pwdInput
                                Layout.fillWidth: true
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                color: Theme.palette.colOnSurface
                                echoMode: TextInput.Password
                                focus: true

                                onAccepted: {
                                    if (text.length > 0) {
                                        LockManager.submitPassword(text);
                                        text = "";
                                    }
                                }

                                Text {
                                    visible: !parent.text
                                    text: LockManager.authenticating ? "Verifying..." : "Enter Password"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeBody
                                    color: LockManager.authFailed ? Theme.palette.colOnError : Theme.palette.outline
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            IconButton {
                                icon: "󰁔"
                                implicitWidth: 32
                                implicitHeight: 32
                                iconSize: 16
                                checked: true
                                onClicked: {
                                    if (pwdInput.text.length > 0) {
                                        LockManager.submitPassword(pwdInput.text);
                                        pwdInput.text = "";
                                    }
                                }
                            }
                        }
                    }

                    // Error feedback
                    Text {
                        visible: LockManager.authFailed
                        Layout.alignment: Qt.AlignHCenter
                        text: LockManager.authErrorMessage || "Incorrect password, try again"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption
                        color: Theme.palette.colOnError
                    }

                    // Media control pill on lock screen
                    GlassCard {
                        visible: MediaService.hasMedia
                        Layout.alignment: Qt.AlignHCenter
                        width: 320
                        height: 52
                        radius: Theme.radiusMedium
                        elevation: 2

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Text { text: "󰝚"; font.family: Theme.fontFamily; font.pixelSize: 18; color: Theme.palette.secondary }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: MediaService.title
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    color: Theme.palette.colOnSurface
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: MediaService.artist
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    color: Theme.palette.colOnSurfaceVariant
                                    elide: Text.ElideRight
                                }
                            }

                            IconButton {
                                icon: MediaService.isPlaying ? "󰏤" : "󰐊"
                                implicitWidth: 28
                                implicitHeight: 28
                                iconSize: 14
                                onClicked: MediaService.togglePlayPause()
                            }
                        }
                    }
                }
            }
        }
    }
}
