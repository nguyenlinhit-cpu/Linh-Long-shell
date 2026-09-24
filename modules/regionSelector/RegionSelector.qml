import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: regionWindow

    property bool isOpen: false

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-region-selector"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    property real startX: 0
    property real startY: 0
    property real currentX: 0
    property real currentY: 0
    property bool isDragging: false

    function toggle() {
        isOpen = !isOpen;
        if (isOpen) {
            isDragging = false;
        }
    }

    // Semi-transparent overlay with crosshair cursor
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)

        focus: regionWindow.isOpen
        Keys.onEscapePressed: {
            regionWindow.isOpen = false;
            regionWindow.isDragging = false;
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            cursorShape: Qt.CrossCursor
            hoverEnabled: true

            onPressed: mouse => {
                regionWindow.startX = mouse.x;
                regionWindow.startY = mouse.y;
                regionWindow.currentX = mouse.x;
                regionWindow.currentY = mouse.y;
                regionWindow.isDragging = true;
            }

            onPositionChanged: mouse => {
                regionWindow.currentX = mouse.x;
                regionWindow.currentY = mouse.y;
            }

            onReleased: mouse => {
                if (regionWindow.isDragging) {
                    let rx = Math.min(regionWindow.startX, regionWindow.currentX);
                    let ry = Math.min(regionWindow.startY, regionWindow.currentY);
                    let rw = Math.abs(regionWindow.currentX - regionWindow.startX);
                    let rh = Math.abs(regionWindow.currentY - regionWindow.startY);

                    regionWindow.isOpen = false;
                    regionWindow.isDragging = false;

                    if (rw > 10 && rh > 10) {
                        regionWindow.captureArea(Math.round(rx), Math.round(ry), Math.round(rw), Math.round(rh));
                    }
                }
            }
        }

        // Selection Box Rectangle
        Rectangle {
            visible: regionWindow.isDragging
            x: Math.min(regionWindow.startX, regionWindow.currentX)
            y: Math.min(regionWindow.startY, regionWindow.currentY)
            width: Math.abs(regionWindow.currentX - regionWindow.startX)
            height: Math.abs(regionWindow.currentY - regionWindow.startY)
            color: Qt.rgba(Theme.palette.primary.r, Theme.palette.primary.g, Theme.palette.primary.b, 0.15)
            border.width: 2
            border.color: Theme.palette.primary

            // Coordinate Dimensions Badge
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 6
                anchors.horizontalCenter: parent.horizontalCenter
                width: badgeText.implicitWidth + 12
                height: 22
                radius: 4
                color: Theme.palette.inverseSurface

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: `${Math.round(parent.parent.width)} × ${Math.round(parent.parent.height)}`
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: Theme.palette.colOnInverseSurface
                }
            }
        }

        // Instructions header banner
        Rectangle {
            visible: !regionWindow.isDragging
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            width: hintText.implicitWidth + 28
            height: 36
            radius: Theme.radiusMedium
            color: Theme.palette.inverseSurface

            Text {
                id: hintText
                anchors.centerIn: parent
                text: "Drag a box to snip screenshot • Press [Esc] to cancel"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBody
                font.weight: Font.Medium
                color: Theme.palette.colOnInverseSurface
            }
        }
    }

    function captureArea(x, y, w, h) {
        let geom = `${x},${y} ${w}x${h}`;
        // Execute grim Wayland screenshot tool
        Quickshell.execDetached([
            "sh", "-c",
            `grim -g "${geom}" - | wl-copy && notify-send "Screenshot Captured" "Saved to clipboard (${geom})" -i accessories-screenshot`
        ]);
    }
}
