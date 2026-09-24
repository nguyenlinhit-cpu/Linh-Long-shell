pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Resource Usage Metrics
    property real cpuUsage: 0.0 // 0.0 to 1.0
    property real ramUsage: 0.0 // 0.0 to 1.0
    property real ramTotalGb: 16.0
    property real ramUsedGb: 0.0
    property real swapUsage: 0.0

    // History lists for sparkline / mini graph rendering
    readonly property int historyLength: 30
    property list<real> cpuHistory: []
    property list<real> ramHistory: []

    // Previous CPU state for differential delta calculation
    property var prevCpuStats: null

    // System Identity & Uptime
    readonly property string username: Quickshell.env("USER") || "user"
    readonly property string hostname: Quickshell.env("HOSTNAME") || "linux"
    property string uptimeFormatted: "0m"

    // Directly view kernel procfs entries without spawning any processes
    FileView { id: procStat; path: "/proc/stat" }
    FileView { id: procMeminfo; path: "/proc/meminfo" }
    FileView { id: procUptime; path: "/proc/uptime" }

    Timer {
        id: pollTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            root.sampleMeminfo();
            root.sampleCpuStat();
            root.sampleUptime();
        }
    }

    // Direct /proc/uptime Parser (Zero Fork)
    function sampleUptime() {
        procUptime.reload();
        let text = procUptime.text();
        if (!text) return;
        let secs = parseFloat(text.split(" ")[0]) || 0;
        let hrs = Math.floor(secs / 3600);
        let mins = Math.floor((secs % 3600) / 60);
        if (hrs > 0) root.uptimeFormatted = `${hrs}h ${mins}m`;
        else root.uptimeFormatted = `${mins}m`;
    }

    // Direct /proc/meminfo Parser (Zero Fork)
    function sampleMeminfo() {
        procMeminfo.reload();
        let text = procMeminfo.text();
        if (!text) return;

        let totalMatch = text.match(/MemTotal:\s+(\d+)\s+kB/);
        let availMatch = text.match(/MemAvailable:\s+(\d+)\s+kB/);
        let swapTotalMatch = text.match(/SwapTotal:\s+(\d+)\s+kB/);
        let swapFreeMatch = text.match(/SwapFree:\s+(\d+)\s+kB/);

        if (totalMatch && availMatch) {
            let totalKb = parseInt(totalMatch[1]);
            let availKb = parseInt(availMatch[1]);
            let usedKb = totalKb - availKb;

            root.ramTotalGb = totalKb / (1024 * 1024);
            root.ramUsedGb = usedKb / (1024 * 1024);
            root.ramUsage = Math.max(0.0, Math.min(1.0, usedKb / totalKb));

            // Append to RAM history
            let newHist = [...root.ramHistory, root.ramUsage];
            if (newHist.length > root.historyLength) newHist.shift();
            root.ramHistory = newHist;
        }

        if (swapTotalMatch && swapFreeMatch) {
            let sTotal = parseInt(swapTotalMatch[1]);
            let sFree = parseInt(swapFreeMatch[1]);
            root.swapUsage = sTotal > 0 ? (sTotal - sFree) / sTotal : 0.0;
        }
    }

    // Direct /proc/stat CPU Delta Parser (Zero Fork)
    function sampleCpuStat() {
        procStat.reload();
        let text = procStat.text();
        if (!text) return;

        let firstLine = text.split("\n")[0];
        let parts = firstLine.trim().split(/\s+/);
        if (parts.length < 5 || parts[0] !== "cpu") return;

        // user, nice, system, idle, iowait, irq, softirq, steal
        let user = parseInt(parts[1]) || 0;
        let nice = parseInt(parts[2]) || 0;
        let system = parseInt(parts[3]) || 0;
        let idle = parseInt(parts[4]) || 0;
        let iowait = parseInt(parts[5]) || 0;
        let irq = parseInt(parts[6]) || 0;
        let softirq = parseInt(parts[7]) || 0;
        let steal = parseInt(parts[8]) || 0;

        let total = user + nice + system + idle + iowait + irq + softirq + steal;
        let idleAll = idle + iowait;

        if (root.prevCpuStats) {
            let totalDelta = total - root.prevCpuStats.total;
            let idleDelta = idleAll - root.prevCpuStats.idle;

            if (totalDelta > 0) {
                let usage = 1.0 - (idleDelta / totalDelta);
                root.cpuUsage = Math.max(0.0, Math.min(1.0, usage));

                // Append to CPU history
                let newHist = [...root.cpuHistory, root.cpuUsage];
                if (newHist.length > root.historyLength) newHist.shift();
                root.cpuHistory = newHist;
            }
        }

        root.prevCpuStats = { total: total, idle: idleAll };
    }
}
