import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"

Scope {
    id: root

    property bool enabled: true
    property int cornerSize: 4

    Timer {
        id: debounceTimer
        interval: 600
        repeat: false
    }

    // 1. Top-Left Corner: Overview Trigger
    PanelWindow {
        id: tlCorner
        anchors {
            top: true
            left: true
        }
        implicitWidth: root.cornerSize
        implicitHeight: root.cornerSize
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "linh-long-hotcorner-tl"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                if (!root.enabled || debounceTimer.running) return;
                debounceTimer.start();
                ShellService.toggleOverview();
            }
        }
    }

    // 2. Top-Right Corner: Control Center Trigger
    PanelWindow {
        id: trCorner
        anchors {
            top: true
            right: true
        }
        implicitWidth: root.cornerSize
        implicitHeight: root.cornerSize
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "linh-long-hotcorner-tr"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                if (!root.enabled || debounceTimer.running) return;
                debounceTimer.start();
                ShellService.toggleControlCenter();
            }
        }
    }

    // 3. Bottom-Left Corner: App Launcher Trigger
    PanelWindow {
        id: blCorner
        anchors {
            bottom: true
            left: true
        }
        implicitWidth: root.cornerSize
        implicitHeight: root.cornerSize
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "linh-long-hotcorner-bl"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                if (!root.enabled || debounceTimer.running) return;
                debounceTimer.start();
                ShellService.toggleLauncher();
            }
        }
    }
}
