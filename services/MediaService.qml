pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // Active player or first available
    readonly property MprisPlayer activePlayer: {
        let players = Mpris.players.values;
        if (!players || players.length === 0) return null;
        // Prioritize actively playing player
        let playing = players.find(p => p.playbackState === MprisPlaybackState.Playing);
        return playing ? playing : players[0];
    }

    readonly property bool hasMedia: activePlayer !== null
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property string title: activePlayer?.trackTitle || "No Media Playing"
    readonly property string artist: activePlayer?.trackArtist || "Unknown Artist"
    readonly property string album: activePlayer?.trackAlbum || ""
    readonly property string artUrl: activePlayer?.trackArtUrl || ""
    readonly property real position: activePlayer?.position || 0.0
    readonly property real length: activePlayer?.length || 1.0
    readonly property real progress: length > 0 ? (position / length) : 0.0

    // Direct Native MPRIS Controls (Zero Bash Subprocesses)
    function togglePlayPause() {
        if (!activePlayer) return;
        activePlayer.playPause();
    }

    function play() {
        if (!activePlayer) return;
        activePlayer.play();
    }

    function pause() {
        if (!activePlayer) return;
        activePlayer.pause();
    }

    function next() {
        if (!activePlayer) return;
        activePlayer.next();
    }

    function previous() {
        if (!activePlayer) return;
        activePlayer.previous();
    }

    function seekToProgress(ratio) {
        if (!activePlayer || activePlayer.length <= 0) return;
        activePlayer.position = ratio * activePlayer.length;
    }

    function formatTime(seconds) {
        let totalSec = Math.floor(seconds);
        let mins = Math.floor(totalSec / 60);
        let secs = totalSec % 60;
        return `${mins}:${secs < 10 ? "0" : ""}${secs}`;
    }
}
