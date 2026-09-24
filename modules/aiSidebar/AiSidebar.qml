import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: aiWindow

    property bool isOpen: false
    property list<var> chatMessages: [
        { sender: "assistant", text: "Hello! I am Linh-Long AI Copilot. How can I assist you with your desktop or code today?" }
    ]
    property bool isGenerating: false

    anchors {
        top: true
        bottom: true
        right: true
    }
    implicitWidth: 440
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-ai-sidebar"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        isOpen = !isOpen;
        if (isOpen) {
            promptInput.forceActiveFocus();
        }
    }

    GlassCard {
        anchors.fill: parent
        anchors.margins: 12
        radius: Theme.radiusLarge
        elevation: 3

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text { text: "󰚩"; font.family: Theme.fontFamily; font.pixelSize: 22; color: Theme.palette.primary }
                Text {
                    text: "AI Copilot"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle
                    font.weight: Font.Bold
                    color: Theme.palette.colOnSurface
                }
                Badge {
                    text: ConfigService.aiModel
                    badgeColor: Theme.palette.secondaryContainer
                    textColor: Theme.palette.colOnSecondaryContainer
                }
                Item { Layout.fillWidth: true }
                IconButton {
                    icon: "󰅖"
                    implicitWidth: 28
                    implicitHeight: 28
                    onClicked: aiWindow.isOpen = false
                }
            }

            // Chat Message List
            ListView {
                id: msgList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 10
                model: aiWindow.chatMessages

                delegate: ColumnLayout {
                    width: msgList.width
                    spacing: 4

                    Text {
                        text: modelData.sender === "user" ? "You" : "Linh-Long AI"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: modelData.sender === "user" ? Theme.palette.secondary : Theme.palette.primary
                        Layout.alignment: modelData.sender === "user" ? Qt.AlignRight : Qt.AlignLeft
                    }

                    Rectangle {
                        Layout.maximumWidth: parent.width * 0.88
                        Layout.alignment: modelData.sender === "user" ? Qt.AlignRight : Qt.AlignLeft
                        implicitWidth: msgText.implicitWidth + 24
                        implicitHeight: msgText.implicitHeight + 18
                        radius: Theme.radiusMedium
                        color: modelData.sender === "user" ? Theme.palette.primaryContainer : Theme.palette.layer2
                        border.width: 1
                        border.color: Theme.palette.glassBorder

                        Text {
                            id: msgText
                            anchors.fill: parent
                            anchors.margins: 9
                            text: modelData.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            color: modelData.sender === "user" ? Theme.palette.colOnPrimaryContainer : Theme.palette.colOnSurface
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            // Generating indicator
            Row {
                visible: aiWindow.isGenerating
                spacing: 8
                Text { text: "󰇘"; font.family: Theme.fontFamily; font.pixelSize: 18; color: Theme.palette.primary }
                Text { text: "Thinking..."; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.palette.colOnSurfaceVariant }
            }

            // Prompt Input Box
            GlassCard {
                Layout.fillWidth: true
                height: 48
                radius: Theme.radiusMedium
                elevation: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 8

                    TextInput {
                        id: promptInput
                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        color: Theme.palette.colOnSurface
                        selectByMouse: true

                        Text {
                            visible: !parent.text
                            text: "Ask anything (e.g. explain command, write code)..."
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            color: Theme.palette.outline
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onAccepted: aiWindow.sendPrompt()
                    }

                    IconButton {
                        icon: "󰒭"
                        checked: true
                        implicitWidth: 32
                        implicitHeight: 32
                        iconSize: 16
                        onClicked: aiWindow.sendPrompt()
                    }
                }
            }
        }
    }

    function sendPrompt() {
        let text = promptInput.text.trim();
        if (!text || isGenerating) return;

        // Add user message
        aiWindow.chatMessages = [...aiWindow.chatMessages, { sender: "user", text: text }];
        promptInput.text = "";
        aiWindow.isGenerating = true;

        // Send to local Ollama API
        let xhr = new XMLHttpRequest();
        xhr.open("POST", `${ConfigService.aiEndpoint}/api/generate`, true);
        xhr.setRequestHeader("Content-Type", "application/json");

        let body = JSON.stringify({
            model: ConfigService.aiModel,
            prompt: text,
            stream: false
        });

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                aiWindow.isGenerating = false;
                if (xhr.status === 200) {
                    try {
                        let res = JSON.parse(xhr.responseText);
                        aiWindow.chatMessages = [...aiWindow.chatMessages, { sender: "assistant", text: res.response }];
                    } catch(e) {
                        aiWindow.chatMessages = [...aiWindow.chatMessages, { sender: "assistant", text: "Error parsing LLM response." }];
                    }
                } else {
                    aiWindow.chatMessages = [...aiWindow.chatMessages, { sender: "assistant", text: "Could not connect to Ollama. Make sure 'ollama serve' is running at localhost:11434." }];
                }
            }
        };

        xhr.send(body);
    }
}
