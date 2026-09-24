import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: desktopWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "linh-long-desktop-backdrop"

    property bool showContextMenu: false
    property real menuX: 100
    property real menuY: 100

    // Background Wallpaper
    Image {
        id: bgImage
        anchors.fill: parent
        source: WallpaperService.activeWallpaper ? `file://${WallpaperService.activeWallpaper}` : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true

        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
    }

    // Subtle dark gradient vignette
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#40000000" }
            GradientStop { position: 0.4; color: "#00000000" }
            GradientStop { position: 0.7; color: "#00000000" }
            GradientStop { position: 1.0; color: "#60000000" }
        }
    }

    // Right-Click Event Area for Desktop Menu
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                desktopWindow.menuX = Math.min(mouse.x, parent.width - 240);
                desktopWindow.menuY = Math.min(mouse.y, parent.height - 300);
                desktopWindow.showContextMenu = true;
            } else {
                desktopWindow.showContextMenu = false;
            }
        }
    }

    // Desktop Widgets Area (Clock & Hardware Monitor)
    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 60
        width: 380
        height: 180

        ColumnLayout {
            spacing: 8

            // Big Aesthetic Clock
            Text {
                text: {
                    let d = new Date();
                    let h = d.getHours().toString().padStart(2, "0");
                    let m = d.getMinutes().toString().padStart(2, "0");
                    return `${h}:${m}`;
                }
                font.family: Theme.fontFamily
                font.pixelSize: 64
                font.weight: Font.Bold
                color: "#FFFFFF"
                style: Text.Raised
                styleColor: "#40000000"
            }

            // Date
            Text {
                text: new Date().toLocaleDateString(Qt.locale(), "dddd, MMMM d")
                font.family: Theme.fontFamily
                font.pixelSize: 18
                font.weight: Font.DemiBold
                color: "#E0E0E0"
                style: Text.Raised
                styleColor: "#40000000"
            }

            // Quick Sysmon Badges
            RowLayout {
                spacing: 10
                Layout.topMargin: 4

                // CPU
                GlassCard {
                    height: 28
                    radius: 14
                    elevation: 1
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6
                        Text { text: "󰍛"; font.family: Theme.fontFamily; font.pixelSize: 14; color: Theme.palette.primary }
                        Text {
                            text: `CPU ${Math.round(HardwareService.cpuUsage * 100)}%`
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.palette.colOnSurface
                        }
                    }
                }

                // RAM
                GlassCard {
                    height: 28
                    radius: 14
                    elevation: 1
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6
                        Text { text: "󰘚"; font.family: Theme.fontFamily; font.pixelSize: 14; color: Theme.palette.secondary }
                        Text {
                            text: `RAM ${Math.round(HardwareService.ramUsage * 100)}%`
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.palette.colOnSurface
                        }
                    }
                }

                // Weather
                GlassCard {
                    visible: !!WeatherService.condition
                    height: 28
                    radius: 14
                    elevation: 1
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6
                        Text { text: WeatherService.icon; font.family: Theme.fontFamily; font.pixelSize: 14; color: Theme.palette.tertiary }
                        Text {
                            text: `${WeatherService.temp}°C`
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.palette.colOnSurface
                        }
                    }
                }
            }
        }
    }

    // Right-Click Context Menu Popup
    GlassCard {
        id: contextMenu
        visible: desktopWindow.showContextMenu
        x: desktopWindow.menuX
        y: desktopWindow.menuY
        width: 220
        radius: Theme.radiusMedium
        elevation: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2

            // Menu Items List
            Repeater {
                model: [
                    { icon: "󰸉", title: "Change Wallpaper", action: "wallpaper" },
                    { icon: "󰞷", title: "Open Terminal", action: "terminal" },
                    { icon: "󰍉", title: "App Launcher", action: "launcher" },
                    { icon: "󰕰", title: "Window Overview", action: "overview" },
                    { icon: "󰅍", title: "Clipboard History", action: "clipboard" },
                    { icon: "󰒓", title: "System Settings", action: "settings" },
                    { icon: "󰌾", title: "Lock Screen", action: "lock" },
                    { icon: "󰐥", title: "Power Menu", action: "power" }
                ]

                delegate: GlassCard {
                    Layout.fillWidth: true
                    height: 34
                    radius: Theme.radiusSmall
                    interactive: true
                    elevation: 0
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: modelData.icon
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                            color: Theme.palette.primary
                        }

                        Text {
                            text: modelData.title
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: Theme.palette.colOnSurface
                        }
                    }

                    onClicked: {
                        desktopWindow.showContextMenu = false;
                        if (modelData.action === "wallpaper") ShellService.toggleWallpaper();
                        else if (modelData.action === "terminal") Quickshell.execDetached(["bash", "-c", "kitty || foot || alacritty || xterm"]);
                        else if (modelData.action === "launcher") ShellService.toggleLauncher();
                        else if (modelData.action === "overview") ShellService.toggleOverview();
                        else if (modelData.action === "clipboard") ShellService.toggleClipboard();
                        else if (modelData.action === "settings") ShellService.toggleSettings();
                        else if (modelData.action === "lock") LockManager.lock();
                        else if (modelData.action === "power") ShellService.toggleSession();
                    }
                }
            }
        }
    }
}
