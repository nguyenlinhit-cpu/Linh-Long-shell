pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    // Detected Compositor Type: "hyprland" | "niri" | "sway" | "generic"
    readonly property string compositorType: {
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")) return "hyprland";
        if (Quickshell.env("NIRI_SOCKET")) return "niri";
        if (Quickshell.env("SWAYSOCK")) return "sway";
        return "generic";
    }

    // Workspaces Model (1 to 10 by default)
    property int activeWorkspaceId: 1
    property list<var> workspaces: [
        { id: 1, name: "1", active: true, hasWindows: true },
        { id: 2, name: "2", active: false, hasWindows: true },
        { id: 3, name: "3", active: false, hasWindows: false },
        { id: 4, name: "4", active: false, hasWindows: false },
        { id: 5, name: "5", active: false, hasWindows: false }
    ]

    // Active Window Details
    property string activeWindowTitle: "Desktop"
    property string activeWindowClass: ""

    // Running Toplevel Windows tracked via Wayland protocol
    readonly property list<var> openWindows: {
        return ToplevelManager.toplevels ? ToplevelManager.toplevels.values : [];
    }

    // Switch workspace safely
    function switchToWorkspace(id) {
        root.activeWorkspaceId = id;
        root.workspaces = root.workspaces.map(ws => {
            return {
                id: ws.id,
                name: ws.name,
                active: ws.id === id,
                hasWindows: ws.hasWindows
            };
        });

        if (root.compositorType === "hyprland") {
            // Dispatched via Hyprland IPC
        }
    }

    function focusWindow(window) {
        if (!window) return;
        window.activate();
    }

    function closeWindow(window) {
        if (!window) return;
        window.close();
    }
}
