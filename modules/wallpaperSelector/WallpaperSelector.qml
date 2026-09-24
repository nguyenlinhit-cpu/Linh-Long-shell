import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: wallpaperWindow

    property bool isOpen: ShellService.wallpaperOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-wallpaper-selector"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        ShellService.toggleWallpaper();
    }

    // Dismiss on background click
    Rectangle {
        anchors.fill: parent
        color: ColorResolver.transparentize(Theme.palette.layer0, 0.4)

        MouseArea {
            anchors.fill: parent
            onClicked: ShellService.wallpaperOpen = false
        }
    }

    // Wallpapers Collection
    readonly property var defaultWallpapers: [
        { name: "Cyberpunk Neon City", path: Qt.resolvedUrl("../../assets/wallpapers/cyberpunk_neon_city.jpg").toString().replace("file://", "") },
        { name: "Noctalia Dark Horizon", path: Qt.resolvedUrl("../../assets/wallpapers/noctalia_dark.png").toString().replace("file://", "") },
        { name: "Illogical Impulse Minimal", path: Qt.resolvedUrl("../../assets/wallpapers/illogical_impulse.png").toString().replace("file://", "") }
    ]

    property string searchQuery: ""

    // Modal Card
    GlassCard {
        anchors.centerIn: parent
        width: Math.min(880, parent.width - 48)
        height: Math.min(620, parent.height - 64)
        radius: Theme.radiusLarge
        elevation: 4

        // Prevent click bubbling
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // ══════════════════════════════════════════════════════════════
            // HEADER BAR
            // ══════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "󰸉"
                    font.family: Theme.fontFamily
                    font.pixelSize: 24
                    color: Theme.palette.primary
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Wallpaper & Theme Studio"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTitle
                        font.weight: Font.Bold
                        color: Theme.palette.colOnSurface
                    }
                    Text {
                        text: "Select a wallpaper to dynamically re-theme the entire desktop"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption
                        color: Theme.palette.colOnSurfaceVariant
                    }
                }

                // Random Wallpaper Button
                IconButton {
                    icon: "󰒝"
                    tooltip: "Pick Random Wallpaper"
                    onClicked: {
                        let randIdx = Math.floor(Math.random() * wallpaperWindow.defaultWallpapers.length);
                        let pick = wallpaperWindow.defaultWallpapers[randIdx];
                        wallpaperWindow.applyWallpaper(pick.path);
                    }
                }

                // Close Button
                IconButton {
                    icon: "󰅖"
                    tooltip: "Close"
                    onClicked: ShellService.wallpaperOpen = false
                }
            }

            // ══════════════════════════════════════════════════════════════
            // WALLPAPER GRID
            // ══════════════════════════════════════════════════════════════
            GridView {
                id: wallGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: width / 2
                cellHeight: 220
                clip: true

                model: wallpaperWindow.defaultWallpapers

                delegate: Item {
                    width: wallGrid.cellWidth
                    height: wallGrid.cellHeight

                    property bool isSelected: WallpaperService.activeWallpaper === modelData.path

                    GlassCard {
                        id: wallCard
                        anchors.fill: parent
                        anchors.margins: 8
                        radius: Theme.radiusMedium
                        elevation: hovered ? 3 : 1
                        interactive: true

                        border.width: isSelected ? 3 : (hovered ? 2 : 1)
                        border.color: isSelected ? Theme.palette.primary : (hovered ? Theme.palette.secondary : Theme.palette.glassBorder)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            // Thumbnail Image
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: Theme.radiusSmall
                                clip: true
                                color: Theme.palette.layer3

                                Image {
                                    anchors.fill: parent
                                    source: modelData.path ? ("file://" + modelData.path) : ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    scale: wallCard.hovered ? 1.05 : 1.0

                                    Behavior on scale {
                                        NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutCubic }
                                    }
                                }

                                // Active Selection Pill
                                Rectangle {
                                    visible: isSelected
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 8
                                    width: 28
                                    height: 28
                                    radius: 14
                                    color: Theme.palette.primary

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰄬"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: Theme.palette.colOnPrimary
                                    }
                                }
                            }

                            // Caption & Action
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 4
                                Layout.rightMargin: 4

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeBody
                                    font.weight: Font.DemiBold
                                    color: Theme.palette.colOnSurface
                                    elide: Text.ElideRight
                                }

                                Badge {
                                    text: isSelected ? "Active" : "Apply"
                                    badgeColor: isSelected ? Theme.palette.primaryContainer : Theme.palette.layer3
                                    textColor: isSelected ? Theme.palette.colOnPrimaryContainer : Theme.palette.colOnSurfaceVariant
                                }
                            }
                        }

                        onClicked: {
                            wallpaperWindow.applyWallpaper(modelData.path);
                        }
                    }
                }
            }
        }
    }

    function applyWallpaper(path) {
        WallpaperService.setWallpaper(path);
        // Trigger Hyprpaper / swww or direct Wayland background render
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")) {
            Quickshell.execDetached(["hyprctl", "hyprpaper", "preload", path]);
            Quickshell.execDetached(["hyprctl", "hyprpaper", "wallpaper", `,*` + path]);
        }
        ShellService.wallpaperOpen = false;
    }
}
