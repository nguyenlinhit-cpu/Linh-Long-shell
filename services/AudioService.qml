pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Native PipeWire connection state
    readonly property bool ready: Pipewire.defaultAudioSink?.ready ?? false

    // Master Output & Input Nodes
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // Master Volume Values (0.0 to 1.5)
    property real volume: sink?.audio?.volume ?? 0.0
    property bool muted: sink?.audio?.muted ?? false
    property real micVolume: source?.audio?.volume ?? 0.0
    property bool micMuted: source?.audio?.muted ?? false

    // Formatted Strings
    readonly property string sinkName: sink?.description || sink?.nickname || "Default Output"
    readonly property string sourceName: source?.description || source?.nickname || "Default Microphone"
    readonly property int volumePercent: Math.round(volume * 100)

    // Per-Application Stream Nodes (for granular mixer)
    readonly property list<var> appStreams: {
        if (!Pipewire.nodes?.values) return [];
        return Pipewire.nodes.values.filter(node => {
            return node.isSink && node.audio && node.isStream;
        });
    }

    // Available Output Hardware Devices
    readonly property list<var> outputDevices: {
        if (!Pipewire.nodes?.values) return [];
        return Pipewire.nodes.values.filter(node => {
            return node.isSink && node.audio && !node.isStream;
        });
    }

    // Direct Native Volume Control (Zero Bash Subprocesses)
    function setVolume(val) {
        if (!sink?.audio) return;
        sink.audio.volume = Math.max(0.0, Math.min(1.5, val));
    }

    function incrementVolume(step) {
        if (!sink?.audio) return;
        let s = (step !== undefined) ? step : 0.05;
        setVolume(sink.audio.volume + s);
    }

    function decrementVolume(step) {
        if (!sink?.audio) return;
        let s = (step !== undefined) ? step : 0.05;
        setVolume(sink.audio.volume - s);
    }

    function toggleMute() {
        if (!sink?.audio) return;
        sink.audio.muted = !sink.audio.muted;
    }

    function toggleMicMute() {
        if (!source?.audio) return;
        source.audio.muted = !source.audio.muted;
    }

    function setAppVolume(node, val) {
        if (!node?.audio) return;
        node.audio.volume = Math.max(0.0, Math.min(1.5, val));
    }

    function toggleAppMute(node) {
        if (!node?.audio) return;
        node.audio.muted = !node.audio.muted;
    }

    function getAppDisplayName(node) {
        if (!node) return "Application";
        return node.properties["application.name"] || node.description || node.name || "App Stream";
    }

    function getAppIcon(node) {
        if (!node) return "audio-volume-high";
        return node.properties["application.icon-name"] || "audio-x-generic";
    }
}
