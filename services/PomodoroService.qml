pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property int workDuration: 25 * 60 // 25 minutes
    property int breakDuration: 5 * 60  // 5 minutes
    property int remainingSeconds: 25 * 60
    property bool isRunning: false
    property bool isBreak: false

    readonly property string timeLeftFormatted: {
        let mins = Math.floor(root.remainingSeconds / 60);
        let secs = root.remainingSeconds % 60;
        let sMins = mins < 10 ? "0" + mins : `${mins}`;
        let sSecs = secs < 10 ? "0" + secs : `${secs}`;
        return `${sMins}:${sSecs}`;
    }

    Timer {
        id: timer
        interval: 1000
        running: root.isRunning
        repeat: true
        onTriggered: {
            if (root.remainingSeconds > 0) {
                root.remainingSeconds--;
            } else {
                root.isRunning = false;
                if (!root.isBreak) {
                    root.isBreak = true;
                    root.remainingSeconds = root.breakDuration;
                    Quickshell.execDetached(["notify-send", "Pomodoro Focus Complete!", "Time for a 5-minute break.", "-i", "alarm"]);
                } else {
                    root.isBreak = false;
                    root.remainingSeconds = root.workDuration;
                    Quickshell.execDetached(["notify-send", "Break Over!", "Ready to start another 25-minute focus session.", "-i", "alarm"]);
                }
            }
        }
    }

    function toggle() {
        root.isRunning = !root.isRunning;
    }

    function reset() {
        root.isRunning = false;
        root.isBreak = false;
        root.remainingSeconds = root.workDuration;
    }
}
