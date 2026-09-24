pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var tasks: [
        { id: 1, text: "Explore Linh-Long Desktop Shell", done: true },
        { id: 2, text: "Try Wallpaper Studio (Super + W)", done: false },
        { id: 3, text: "Test PipeWire App Stream Mixer", done: false }
    ]

    property string quickNote: "Welcome to Linh-Long Shell! Press Super + Space for Launcher, Super + C for Control Center."

    function addTask(text) {
        let trimmed = text.trim();
        if (!trimmed) return;
        let newTask = {
            id: Date.now(),
            text: trimmed,
            done: false
        };
        root.tasks = [...root.tasks, newTask];
    }

    function toggleTask(id) {
        root.tasks = root.tasks.map(t => {
            if (t.id === id) {
                return { id: t.id, text: t.text, done: !t.done };
            }
            return t;
        });
    }

    function removeTask(id) {
        root.tasks = root.tasks.filter(t => t.id !== id);
    }

    function clearCompleted() {
        root.tasks = root.tasks.filter(t => !t.done);
    }
}
