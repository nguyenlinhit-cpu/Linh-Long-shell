import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"

Scope {
    id: root

    property int cornerRadius: 18

    // 1. Top-Left Corner
    PanelWindow {
        anchors { top: true; left: true }
        implicitWidth: root.cornerRadius
        implicitHeight: root.cornerRadius
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "linh-long-corner-tl"

        Canvas {
            anchors.fill: parent
            onPaint: {
                let ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "#000000";
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.arc(width, height, width, -Math.PI / 2, Math.PI, true);
                ctx.closePath();
                ctx.fill();
            }
        }
    }

    // 2. Top-Right Corner
    PanelWindow {
        anchors { top: true; right: true }
        implicitWidth: root.cornerRadius
        implicitHeight: root.cornerRadius
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "linh-long-corner-tr"

        Canvas {
            anchors.fill: parent
            onPaint: {
                let ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "#000000";
                ctx.beginPath();
                ctx.moveTo(width, 0);
                ctx.lineTo(0, 0);
                ctx.arc(0, height, width, -Math.PI / 2, 0, false);
                ctx.closePath();
                ctx.fill();
            }
        }
    }

    // 3. Bottom-Left Corner
    PanelWindow {
        anchors { bottom: true; left: true }
        implicitWidth: root.cornerRadius
        implicitHeight: root.cornerRadius
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "linh-long-corner-bl"

        Canvas {
            anchors.fill: parent
            onPaint: {
                let ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "#000000";
                ctx.beginPath();
                ctx.moveTo(0, height);
                ctx.lineTo(width, height);
                ctx.arc(width, 0, width, Math.PI / 2, Math.PI, false);
                ctx.closePath();
                ctx.fill();
            }
        }
    }

    // 4. Bottom-Right Corner
    PanelWindow {
        anchors { bottom: true; right: true }
        implicitWidth: root.cornerRadius
        implicitHeight: root.cornerRadius
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "linh-long-corner-br"

        Canvas {
            anchors.fill: parent
            onPaint: {
                let ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "#000000";
                ctx.beginPath();
                ctx.moveTo(width, height);
                ctx.lineTo(0, height);
                ctx.arc(0, 0, width, Math.PI / 2, 0, true);
                ctx.closePath();
                ctx.fill();
            }
        }
    }
}
