import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: polkitWindow

    property bool isPrompting: PolkitService.interactionAvailable

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-polkit"
    WlrLayershell.keyboardFocus: isPrompting ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isPrompting

    onIsPromptingChanged: {
        if (isPrompting) {
            passwordInput.text = "";
            passwordInput.forceActiveFocus();
        }
    }

    // Scrim / dark backdrop
    Rectangle {
        anchors.fill: parent
        color: ColorResolver.transparentize(Theme.palette.layer0, 0.45)
    }

    // Center Dialog Card
    GlassCard {
        width: 440
        anchors.centerIn: parent
        radius: Theme.radiusLarge
        elevation: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 16

            // Top Shield Icon & Title
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: Theme.palette.secondaryContainer

                    Text {
                        anchors.centerIn: parent
                        text: "󰌾"
                        font.family: Theme.fontFamily
                        font.pixelSize: 22
                        color: Theme.palette.primary
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Authentication Required"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTitle
                        font.weight: Font.Bold
                        color: Theme.palette.colOnSurface
                    }
                    Text {
                        text: "Privileged System Action"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBodySmall
                        color: Theme.palette.colOnSurfaceVariant
                    }
                }
            }

            // Polkit action message
            Text {
                Layout.fillWidth: true
                text: PolkitService.messageText || "An application is requesting administrative rights."
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBody
                color: Theme.palette.colOnSurfaceVariant
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            // Error notice
            Text {
                visible: !!PolkitService.errorMessage
                Layout.fillWidth: true
                text: PolkitService.errorMessage
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Theme.palette.error
                horizontalAlignment: Text.AlignHCenter
            }

            // Password Field
            GlassCard {
                Layout.fillWidth: true
                height: 46
                radius: Theme.radiusMedium
                elevation: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "󰌆"
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                        color: Theme.palette.colOnSurfaceVariant
                    }

                    TextInput {
                        id: passwordInput
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        color: Theme.palette.colOnSurface
                        echoMode: TextInput.Password
                        clip: true

                        onAccepted: {
                            if (text.length > 0) {
                                PolkitService.submit(text);
                            }
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                PolkitService.cancel();
                                event.accepted = true;
                            }
                        }

                        Text {
                            visible: !passwordInput.text
                            text: PolkitService.promptText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            color: Theme.palette.colOnSurfaceVariant
                            opacity: 0.6
                        }
                    }
                }
            }

            // Buttons: Cancel & Authenticate
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item { Layout.fillWidth: true }

                GlassCard {
                    width: 100
                    height: 38
                    radius: Theme.radiusMedium
                    interactive: true
                    elevation: 1
                    onClicked: PolkitService.cancel()

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        color: Theme.palette.colOnSurface
                    }
                }

                Rectangle {
                    width: 120
                    height: 38
                    radius: Theme.radiusMedium
                    color: Theme.palette.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Authenticate"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        font.weight: Font.DemiBold
                        color: Theme.palette.colOnPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (passwordInput.text.length > 0) {
                                PolkitService.submit(passwordInput.text);
                            }
                        }
                    }
                }
            }
        }
    }
}
