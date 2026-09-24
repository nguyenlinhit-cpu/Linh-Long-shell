import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: ccWindow

    property bool isOpen: ShellService.controlCenterOpen
    property int currentTab: 0 // 0: Controls, 1: Notifications, 2: Widgets & Focus

    anchors {
        top: true
        right: true
    }
    margins {
        top: 48
        right: 16
    }
    implicitWidth: 440
    implicitHeight: 700
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-control-center"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        ShellService.toggleControlCenter();
    }

    GlassCard {
        anchors.fill: parent
        radius: Theme.radiusLarge
        elevation: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // ══════════════════════════════════════════════════════════════
            // HEADER & TABS NAVIGATION
            // ══════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Tab 0: Controls
                GlassCard {
                    Layout.fillWidth: true
                    height: 36
                    radius: Theme.radiusMedium
                    interactive: true
                    elevation: ccWindow.currentTab === 0 ? 2 : 0
                    color: ccWindow.currentTab === 0 ? Theme.palette.layer2 : "transparent"
                    onClicked: ccWindow.currentTab = 0

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰕾"
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            color: ccWindow.currentTab === 0 ? Theme.palette.primary : Theme.palette.colOnSurfaceVariant
                        }
                        Text {
                            text: "Controls"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: ccWindow.currentTab === 0 ? Font.Bold : Font.Normal
                            color: ccWindow.currentTab === 0 ? Theme.palette.colOnSurface : Theme.palette.colOnSurfaceVariant
                        }
                    }
                }

                // Tab 1: Notifications
                GlassCard {
                    Layout.fillWidth: true
                    height: 36
                    radius: Theme.radiusMedium
                    interactive: true
                    elevation: ccWindow.currentTab === 1 ? 2 : 0
                    color: ccWindow.currentTab === 1 ? Theme.palette.layer2 : "transparent"
                    onClicked: ccWindow.currentTab = 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰂚"
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            color: ccWindow.currentTab === 1 ? Theme.palette.primary : Theme.palette.colOnSurfaceVariant
                        }
                        Text {
                            text: "Alerts"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: ccWindow.currentTab === 1 ? Font.Bold : Font.Normal
                            color: ccWindow.currentTab === 1 ? Theme.palette.colOnSurface : Theme.palette.colOnSurfaceVariant
                        }
                        Badge {
                            visible: NotificationDaemon.history.length > 0
                            text: `${NotificationDaemon.history.length}`
                            variant: "primary"
                        }
                    }
                }

                // Tab 2: Widgets & Focus
                GlassCard {
                    Layout.fillWidth: true
                    height: 36
                    radius: Theme.radiusMedium
                    interactive: true
                    elevation: ccWindow.currentTab === 2 ? 2 : 0
                    color: ccWindow.currentTab === 2 ? Theme.palette.layer2 : "transparent"
                    onClicked: ccWindow.currentTab = 2

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰔄"
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            color: ccWindow.currentTab === 2 ? Theme.palette.primary : Theme.palette.colOnSurfaceVariant
                        }
                        Text {
                            text: "Widgets"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: ccWindow.currentTab === 2 ? Font.Bold : Font.Normal
                            color: ccWindow.currentTab === 2 ? Theme.palette.colOnSurface : Theme.palette.colOnSurfaceVariant
                        }
                    }
                }

                // Close Button
                IconButton {
                    icon: "󰅖"
                    implicitWidth: 32
                    implicitHeight: 32
                    iconSize: 15
                    onClicked: ShellService.toggleControlCenter()
                }
            }

            // ══════════════════════════════════════════════════════════════
            // TAB 0: CONTROLS & AUDIO MIXER
            // ══════════════════════════════════════════════════════════════
            ColumnLayout {
                visible: ccWindow.currentTab === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // Quick Toggles Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 8
                    columnSpacing: 8

                    // Wi-Fi
                    GlassCard {
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusMedium
                        interactive: true
                        elevation: 2
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text { text: "󰤨"; font.family: Theme.fontFamily; font.pixelSize: 18; color: Theme.palette.primary }
                            Column {
                                Text { text: "Wi-Fi"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.palette.colOnSurface }
                                Text { text: "Online"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.palette.colOnSurfaceVariant }
                            }
                        }
                    }

                    // Bluetooth
                    GlassCard {
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusMedium
                        interactive: true
                        elevation: 2
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text { text: "󰂯"; font.family: Theme.fontFamily; font.pixelSize: 18; color: Theme.palette.secondary }
                            Column {
                                Text { text: "Bluetooth"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.palette.colOnSurface }
                                Text { text: "Active"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.palette.colOnSurfaceVariant }
                            }
                        }
                    }

                    // Night Light Toggle
                    GlassCard {
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusMedium
                        interactive: true
                        elevation: 2
                        onClicked: NightLightService.toggle()
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text {
                                text: NightLightService.active ? "󰖔" : "󰖙"
                                font.family: Theme.fontFamily
                                font.pixelSize: 18
                                color: NightLightService.active ? Theme.palette.tertiary : Theme.palette.colOnSurfaceVariant
                            }
                            Column {
                                Text { text: "Night Light"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.palette.colOnSurface }
                                Text { text: NightLightService.active ? "Warm Filter" : "Off"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.palette.colOnSurfaceVariant }
                            }
                        }
                    }

                    // Do Not Disturb
                    GlassCard {
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusMedium
                        interactive: true
                        elevation: 2
                        onClicked: NotificationDaemon.toggleDnd()
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text {
                                text: NotificationDaemon.dnd ? "󰂛" : "󰂚"
                                font.family: Theme.fontFamily
                                font.pixelSize: 18
                                color: NotificationDaemon.dnd ? Theme.palette.error : Theme.palette.colOnSurfaceVariant
                            }
                            Column {
                                Text { text: "Do Not Disturb"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.palette.colOnSurface }
                                Text { text: NotificationDaemon.dnd ? "Muted" : "Alerts On"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.palette.colOnSurfaceVariant }
                            }
                        }
                    }

                    // Microphone Mute
                    GlassCard {
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusMedium
                        interactive: true
                        elevation: 2
                        onClicked: AudioService.toggleMicMute()
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text {
                                text: AudioService.micMuted ? "󰍭" : "󰍬"
                                font.family: Theme.fontFamily
                                font.pixelSize: 18
                                color: AudioService.micMuted ? Theme.palette.error : Theme.palette.primary
                            }
                            Column {
                                Text { text: "Microphone"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.palette.colOnSurface }
                                Text { text: AudioService.micMuted ? "Muted" : "Active"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.palette.colOnSurfaceVariant }
                            }
                        }
                    }

                    // Screen Snip
                    GlassCard {
                        Layout.fillWidth: true
                        height: 48
                        radius: Theme.radiusMedium
                        interactive: true
                        elevation: 2
                        onClicked: ShellService.toggleRegionSnip()
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text { text: "󰹑"; font.family: Theme.fontFamily; font.pixelSize: 18; color: Theme.palette.primary }
                            Column {
                                Text { text: "Screen Snip"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.palette.colOnSurface }
                                Text { text: "Copy Region"; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.palette.colOnSurfaceVariant }
                            }
                        }
                    }
                }

                // Master Sliders Card
                GlassCard {
                    Layout.fillWidth: true
                    radius: Theme.radiusMedium
                    elevation: 2
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // Volume Slider
                        Slider {
                            Layout.fillWidth: true
                            icon: AudioService.muted ? "󰝟" : "󰕾"
                            value: AudioService.volume
                            from: 0.0
                            to: 1.0
                            onValueModified: val => AudioService.setVolume(val)
                        }

                        // Display Brightness Slider
                        Slider {
                            Layout.fillWidth: true
                            icon: "󰃠"
                            value: BrightnessService.brightnessRatio
                            from: 0.05
                            to: 1.0
                            onValueModified: val => BrightnessService.setBrightnessRatio(val)
                        }
                    }
                }

                // PipeWire Application Audio Mixer
                Text {
                    visible: AudioService.appStreams.length > 0
                    text: "Application Mixer"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: Theme.palette.colOnSurfaceVariant
                }

                ListView {
                    visible: AudioService.appStreams.length > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(100, contentHeight)
                    clip: true
                    spacing: 6
                    model: AudioService.appStreams
                    delegate: GlassCard {
                        width: ListView.view ? ListView.view.width : 300
                        height: 38
                        radius: Theme.radiusSmall
                        elevation: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8

                            Text {
                                text: AudioService.getAppDisplayName(modelData)
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: Theme.palette.colOnSurface
                                Layout.preferredWidth: 90
                                elide: Text.ElideRight
                            }

                            Slider {
                                Layout.fillWidth: true
                                implicitHeight: 22
                                showValueText: false
                                value: modelData.audio?.volume ?? 0.5
                                from: 0.0
                                to: 1.0
                                onValueModified: v => AudioService.setAppVolume(modelData, v)
                            }

                            IconButton {
                                icon: (modelData.audio?.muted ?? false) ? "󰝟" : "󰕾"
                                iconSize: 12
                                implicitWidth: 22
                                implicitHeight: 22
                                onClicked: AudioService.toggleAppMute(modelData)
                            }
                        }
                    }
                }

                // Media Player Card
                GlassCard {
                    visible: MediaService.hasMedia
                    Layout.fillWidth: true
                    height: 86
                    radius: Theme.radiusMedium
                    elevation: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // Album Art
                        Rectangle {
                            width: 60
                            height: 60
                            radius: Theme.radiusSmall
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
                                font.pixelSize: 24
                                color: Theme.palette.colOnSurfaceVariant
                            }
                        }

                        // Info & Controls
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: MediaService.title
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: Theme.palette.colOnSurface
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: MediaService.artist
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.palette.colOnSurfaceVariant
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Row {
                                spacing: 8
                                IconButton {
                                    icon: "󰒮"
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    iconSize: 13
                                    onClicked: MediaService.previous()
                                }
                                IconButton {
                                    icon: MediaService.isPlaying ? "󰏤" : "󰐊"
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    iconSize: 13
                                    onClicked: MediaService.togglePlayPause()
                                }
                                IconButton {
                                    icon: "󰒭"
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    iconSize: 13
                                    onClicked: MediaService.next()
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }

            // ══════════════════════════════════════════════════════════════
            // TAB 1: NOTIFICATION HISTORY & MANAGEMENT
            // ══════════════════════════════════════════════════════════════
            ColumnLayout {
                visible: ccWindow.currentTab === 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Notification History"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBody
                        font.weight: Font.Bold
                        color: Theme.palette.colOnSurface
                    }
                    Item { Layout.fillWidth: true }
                    GlassCard {
                        height: 28
                        radius: 14
                        interactive: true
                        elevation: 1
                        onClicked: NotificationDaemon.clearHistory()
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 4
                            Text { text: "󰃢"; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.palette.primary }
                            Text { text: "Clear All"; font.family: Theme.fontFamily; font.pixelSize: 11; color: Theme.palette.colOnSurface }
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: NotificationDaemon.history

                    delegate: GlassCard {
                        width: ListView.view ? ListView.view.width : 300
                        height: 64
                        radius: Theme.radiusMedium
                        elevation: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Text {
                                text: "󰂚"
                                font.family: Theme.fontFamily
                                font.pixelSize: 18
                                color: Theme.palette.primary
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.appName || "Notification"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: Theme.palette.colOnSurface
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: modelData.timestamp ? new Date(modelData.timestamp).toLocaleTimeString(Qt.locale(), "hh:mm") : ""
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 9
                                        color: Theme.palette.colOnSurfaceVariant
                                    }
                                }

                                Text {
                                    text: modelData.summary || modelData.body || ""
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: Theme.palette.colOnSurfaceVariant
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                }
                            }
                        }
                    }

                    // Empty State
                    Item {
                        anchors.centerIn: parent
                        visible: NotificationDaemon.history.length === 0
                        width: 200
                        height: 120

                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "󰂛"
                                font.family: Theme.fontFamily
                                font.pixelSize: 36
                                color: Theme.palette.colOnSurfaceVariant
                                opacity: 0.4
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "No notifications"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody
                                color: Theme.palette.colOnSurfaceVariant
                            }
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // TAB 2: WIDGETS & FOCUS (WEATHER, POMODORO, TODO)
            // ══════════════════════════════════════════════════════════════
            ColumnLayout {
                visible: ccWindow.currentTab === 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // Live Weather Card
                GlassCard {
                    Layout.fillWidth: true
                    height: 90
                    radius: Theme.radiusMedium
                    elevation: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: WeatherService.icon
                            font.family: Theme.fontFamily
                            font.pixelSize: 38
                            color: Theme.palette.primary
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: `${WeatherService.temperature}  •  ${WeatherService.condition}`
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: Theme.palette.colOnSurface
                            }
                            Text {
                                text: `Humidity: ${WeatherService.humidity}  •  Wind: ${WeatherService.wind}`
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: Theme.palette.colOnSurfaceVariant
                            }
                            Text {
                                text: `Location: ${WeatherService.city}`
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.palette.outline
                            }
                        }
                    }
                }

                // Pomodoro Focus Timer Card
                GlassCard {
                    Layout.fillWidth: true
                    radius: Theme.radiusMedium
                    elevation: 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: PomodoroService.isBreak ? "󰔄 Short Break" : "󰅐 Focus Session"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: PomodoroService.isBreak ? Theme.palette.secondary : Theme.palette.primary
                            }
                            Item { Layout.fillWidth: true }
                            Badge {
                                text: PomodoroService.isRunning ? "RUNNING" : "PAUSED"
                                variant: PomodoroService.isRunning ? "primary" : "secondary"
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: PomodoroService.timeLeftFormatted
                            font.family: Theme.fontFamily
                            font.pixelSize: 34
                            font.weight: Font.Bold
                            color: Theme.palette.colOnSurface
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 12

                            Rectangle {
                                width: 80
                                height: 30
                                radius: 15
                                color: Theme.palette.primary
                                Text {
                                    anchors.centerIn: parent
                                    text: PomodoroService.isRunning ? "Pause" : "Start"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    color: Theme.palette.colOnPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: PomodoroService.toggle()
                                }
                            }

                            GlassCard {
                                width: 80
                                height: 30
                                radius: 15
                                interactive: true
                                elevation: 1
                                onClicked: PomodoroService.reset()
                                Text {
                                    anchors.centerIn: parent
                                    text: "Reset"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: Theme.palette.colOnSurface
                                }
                            }
                        }
                    }
                }

                // Todo & Checklist Card
                GlassCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusMedium
                    elevation: 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Tasks & Todos"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: Theme.palette.colOnSurface
                            }
                            Item { Layout.fillWidth: true }
                            IconButton {
                                icon: "󰃢"
                                implicitWidth: 24
                                implicitHeight: 24
                                iconSize: 12
                                onClicked: TodoService.clearCompleted()
                            }
                        }

                        // Add Task Input
                        GlassCard {
                            Layout.fillWidth: true
                            height: 32
                            radius: Theme.radiusSmall
                            elevation: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                TextInput {
                                    id: todoInput
                                    Layout.fillWidth: true
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: Theme.palette.colOnSurface
                                    clip: true
                                    onAccepted: {
                                        TodoService.addTask(text);
                                        text = "";
                                    }

                                    Text {
                                        visible: !todoInput.text
                                        text: "Add new task... (Press Enter)"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        color: Theme.palette.colOnSurfaceVariant
                                        opacity: 0.6
                                    }
                                }

                                IconButton {
                                    icon: "󰐕"
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    iconSize: 12
                                    onClicked: {
                                        TodoService.addTask(todoInput.text);
                                        todoInput.text = "";
                                    }
                                }
                            }
                        }

                        // Task List
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: TodoService.tasks

                            delegate: RowLayout {
                                width: ListView.view ? ListView.view.width : 300
                                spacing: 8

                                IconButton {
                                    icon: modelData.done ? "󰄲" : "󰄱"
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    iconSize: 14
                                    color: modelData.done ? Theme.palette.primary : Theme.palette.colOnSurfaceVariant
                                    onClicked: TodoService.toggleTask(modelData.id)
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.strikeout: modelData.done
                                    color: modelData.done ? Theme.palette.colOnSurfaceVariant : Theme.palette.colOnSurface
                                    elide: Text.ElideRight
                                }

                                IconButton {
                                    icon: "󰅖"
                                    implicitWidth: 18
                                    implicitHeight: 18
                                    iconSize: 10
                                    onClicked: TodoService.removeTask(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
