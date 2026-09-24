pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool enabled: false
    property int temperature: 4500 // 2500K (warm amber) to 6500K (cool neutral)

    function toggle() {
        root.enabled = !root.enabled;
        root.apply();
    }

    function setTemperature(temp) {
        root.temperature = Math.max(2500, Math.min(6500, temp));
        if (root.enabled) {
            root.apply();
        }
    }

    function apply() {
        if (root.enabled) {
            // Apply night light via hyprsunset or wlsunset
            if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")) {
                Quickshell.execDetached(["hyprsunset", "-t", `${root.temperature}`]);
            } else {
                Quickshell.execDetached(["wlsunset", "-t", `${root.temperature}`]);
            }
        } else {
            // Terminate sunset processes to restore standard gamma
            Quickshell.execDetached(["pkill", "-x", "hyprsunset"]);
            Quickshell.execDetached(["pkill", "-x", "wlsunset"]);
        }
    }
}
