pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Centralized Visibility States for All Shell Windows
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool sessionOpen: false
    property bool wallpaperOpen: false
    property bool overviewOpen: false
    property bool calendarOpen: false
    property bool settingsOpen: false
    property bool cheatsheetOpen: false
    property bool aiOpen: false
    property bool regionSnipOpen: false
    property bool clipboardOpen: false
    property bool switcherOpen: false
    property bool mediaOpen: false
    property bool desktopWidgetsOpen: true

    function toggleLauncher() {
        root.launcherOpen = !root.launcherOpen;
        if (root.launcherOpen) {
            root.sessionOpen = false;
            root.overviewOpen = false;
            root.wallpaperOpen = false;
            root.clipboardOpen = false;
            root.switcherOpen = false;
        }
    }

    function toggleControlCenter() {
        root.controlCenterOpen = !root.controlCenterOpen;
    }

    function toggleSession() {
        root.sessionOpen = !root.sessionOpen;
        if (root.sessionOpen) {
            root.launcherOpen = false;
            root.overviewOpen = false;
            root.wallpaperOpen = false;
            root.clipboardOpen = false;
            root.switcherOpen = false;
        }
    }

    function toggleWallpaper() {
        root.wallpaperOpen = !root.wallpaperOpen;
    }

    function toggleOverview() {
        root.overviewOpen = !root.overviewOpen;
        if (root.overviewOpen) {
            root.launcherOpen = false;
            root.sessionOpen = false;
            root.clipboardOpen = false;
            root.switcherOpen = false;
        }
    }

    function toggleCalendar() {
        root.calendarOpen = !root.calendarOpen;
    }

    function toggleSettings() {
        root.settingsOpen = !root.settingsOpen;
    }

    function toggleCheatsheet() {
        root.cheatsheetOpen = !root.cheatsheetOpen;
    }

    function toggleAi() {
        root.aiOpen = !root.aiOpen;
    }

    function toggleRegionSnip() {
        root.regionSnipOpen = !root.regionSnipOpen;
    }

    function toggleClipboard() {
        root.clipboardOpen = !root.clipboardOpen;
        if (root.clipboardOpen) {
            root.launcherOpen = false;
            root.sessionOpen = false;
            root.overviewOpen = false;
            root.switcherOpen = false;
        }
    }

    function toggleSwitcher() {
        root.switcherOpen = !root.switcherOpen;
        if (root.switcherOpen) {
            root.launcherOpen = false;
            root.sessionOpen = false;
            root.overviewOpen = false;
            root.clipboardOpen = false;
        }
    }

    function toggleMedia() {
        root.mediaOpen = !root.mediaOpen;
    }

    function toggleDesktopWidgets() {
        root.desktopWidgetsOpen = !root.desktopWidgetsOpen;
    }

    function closeAllModals() {
        root.launcherOpen = false;
        root.controlCenterOpen = false;
        root.sessionOpen = false;
        root.wallpaperOpen = false;
        root.overviewOpen = false;
        root.calendarOpen = false;
        root.settingsOpen = false;
        root.cheatsheetOpen = false;
        root.aiOpen = false;
        root.regionSnipOpen = false;
        root.clipboardOpen = false;
        root.switcherOpen = false;
        root.mediaOpen = false;
    }
}
