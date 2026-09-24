pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int brightnessPercent: 50
    property int maxBrightness: 200
    readonly property real brightnessRatio: brightnessPercent / 100.0

    signal brightnessChanged(int newPercent)

    // Direct zero-fork sysfs monitor
    FileView {
        id: curFile
        path: "/sys/class/backlight/nvidia_wmi_ec_backlight/brightness"
    }

    FileView {
        id: maxFile
        path: "/sys/class/backlight/nvidia_wmi_ec_backlight/max_brightness"
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.sampleSysfs()
    }

    function sampleSysfs() {
        maxFile.reload();
        let maxText = maxFile.text();
        if (maxText) {
            root.maxBrightness = parseInt(maxText.trim()) || 200;
        }

        curFile.reload();
        let curText = curFile.text();
        if (curText) {
            let cur = parseInt(curText.trim()) || 0;
            let pct = Math.round((cur / root.maxBrightness) * 100);
            if (pct !== root.brightnessPercent) {
                root.brightnessPercent = Math.max(0, Math.min(100, pct));
                root.brightnessChanged(root.brightnessPercent);
            }
        }
    }

    function setBrightness(percent) {
        let val = Math.max(5, Math.min(100, Math.round(percent)));
        root.brightnessPercent = val;
        Quickshell.execDetached(["brightnessctl", "set", `${val}%`]);
        root.brightnessChanged(val);
    }

    function setBrightnessRatio(ratio) {
        root.setBrightness(ratio * 100);
    }

    function incrementBrightness() {
        root.setBrightness(root.brightnessPercent + 5);
    }

    function decrementBrightness() {
        root.setBrightness(root.brightnessPercent - 5);
    }
}
