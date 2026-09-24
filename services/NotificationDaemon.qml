pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // Notification Server State
    property bool dnd: false
    property list<var> activeToasts: []
    property list<var> history: []

    // Native Notification Server Handler
    NotificationServer {
        id: server

        onNotification: notification => {
            // Check DND mode
            if (root.dnd && notification.urgency !== NotificationUrgency.Critical) {
                root.addToHistory(notification);
                return;
            }

            // Add to active toast list
            let toastItem = {
                id: notification.id,
                appName: notification.appName || "System",
                summary: notification.summary || "",
                body: notification.body || "",
                appIcon: notification.appIcon || "dialog-information",
                urgency: notification.urgency,
                actions: notification.actions || [],
                timestamp: new Date(),
                raw: notification
            };

            root.activeToasts = [toastItem, ...root.activeToasts];
            root.addToHistory(notification);

            // Auto dismiss timer
            let timeout = notification.expireTimeout > 0 ? notification.expireTimeout : 5000;
            let timer = Qt.createQmlObject(`
                import QtQuick 2.15
                Timer {
                    interval: ${timeout}
                    running: true
                    repeat: false
                    onTriggered: {
                        NotificationDaemon.dismissToast(${notification.id});
                        destroy();
                    }
                }
            `, root);
        }
    }

    function dismissToast(id) {
        root.activeToasts = root.activeToasts.filter(t => t.id !== id);
    }

    function addToHistory(notif) {
        let historyItem = {
            id: notif.id,
            appName: notif.appName || "System",
            summary: notif.summary || "",
            body: notif.body || "",
            appIcon: notif.appIcon || "dialog-information",
            urgency: notif.urgency,
            timestamp: new Date()
        };
        root.history = [historyItem, ...root.history.slice(0, 49)];
    }

    function clearAllHistory() {
        root.history = [];
    }

    function toggleDnd() {
        root.dnd = !root.dnd;
    }
}
