pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property list<var> history: []
    property int maxEntries: 100
    property string lastPastedText: ""

    // Monitor Quickshell clipboard property
    Connections {
        target: Quickshell
        function onClipboardTextChanged() {
            let text = Quickshell.clipboardText;
            if (text && text.trim().length > 0) {
                root.addEntry(text);
            }
        }
    }

    // Process to pull wl-paste text whenever refreshed
    Process {
        id: pasteProc
        command: ["bash", "-c", "wl-paste --no-newline 2>/dev/null || true"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim().length > 0) {
                    root.addEntry(data.trim());
                }
            }
        }
    }

    function refresh() {
        pasteProc.running = true;
    }

    function addEntry(text) {
        if (!text || text.trim().length === 0) return;
        // Avoid consecutive duplicate
        if (root.history.length > 0 && root.history[0].text === text) return;

        let entry = {
            id: Date.now() + Math.floor(Math.random() * 1000),
            text: text,
            preview: text.length > 120 ? text.substring(0, 120) + "..." : text,
            lines: text.split("\n").length,
            chars: text.length,
            pinned: false,
            timestamp: new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
        };

        root.history = [entry, ...root.history.filter(e => e.text !== text).slice(0, root.maxEntries - 1)];
    }

    function copyToClipboard(text) {
        root.lastPastedText = text;
        Quickshell.clipboardText = text;
        Quickshell.execDetached(["bash", "-c", `printf '%s' "${text.replace(/"/g, '\\"')}" | wl-copy`]);
    }

    function togglePin(id) {
        root.history = root.history.map(item => {
            if (item.id === id) {
                return Object.assign({}, item, { pinned: !item.pinned });
            }
            return item;
        });
    }

    function deleteEntry(id) {
        root.history = root.history.filter(item => item.id !== id);
    }

    function clearAll() {
        root.history = root.history.filter(item => item.pinned);
    }
}

