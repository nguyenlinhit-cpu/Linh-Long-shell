pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Active wallpaper image path
    property string activeWallpaper: ""
    property string previousWallpaper: ""
    property real transitionProgress: 1.0 // 0.0 to 1.0

    // Wallpaper configuration
    property string transitionType: "fade" // "fade" | "zoom" | "wipe"
    property int transitionDuration: 800
    property bool slideshowActive: false
    property int slideshowInterval: 1800

    // Available wallpapers in active collection
    property list<string> wallpaperList: []
    property int currentIndex: 0

    signal wallpaperChanged(string newPath)

    function setWallpaper(path) {
        if (path === root.activeWallpaper) return;
        root.previousWallpaper = root.activeWallpaper;
        root.activeWallpaper = path;
        root.transitionProgress = 0.0;
        anim.restart();
        root.wallpaperChanged(path);
    }

    NumberAnimation {
        id: anim
        target: root
        property: "transitionProgress"
        from: 0.0
        to: 1.0
        duration: root.transitionDuration
        easing.type: Easing.InOutCubic
    }

    function nextWallpaper() {
        if (root.wallpaperList.length === 0) return;
        root.currentIndex = (root.currentIndex + 1) % root.wallpaperList.length;
        root.setWallpaper(root.wallpaperList[root.currentIndex]);
    }

    Timer {
        id: slideshowTimer
        interval: root.slideshowInterval * 1000
        running: root.slideshowActive
        repeat: true
        onTriggered: root.nextWallpaper()
    }
}
