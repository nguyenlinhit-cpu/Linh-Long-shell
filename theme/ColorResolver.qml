pragma Singleton
import QtQuick

QtObject {
    id: root

    // Current active wallpaper path
    property string activeWallpaper: ""

    // Vibrancy metric: 0.0 (muted/dark) to 1.0 (vibrant/bright)
    property real wallpaperVibrancy: 0.5

    // Adaptive transparency formula:
    // Quadratic mapping from vibrancy to optimal glass translucency
    readonly property real calculatedBackgroundTransparency: {
        let x = wallpaperVibrancy;
        let y = 0.5768 * (x * x) - 0.759 * x + 0.2896;
        return Math.max(0.12, Math.min(0.35, y));
    }

    // Blend two colors by ratio
    function mix(color1, color2, ratio) {
        let r = color1.r * (1 - ratio) + color2.r * ratio;
        let g = color1.g * (1 - ratio) + color2.g * ratio;
        let b = color1.b * (1 - ratio) + color2.b * ratio;
        let a = color1.a * (1 - ratio) + color2.a * ratio;
        return Qt.rgba(r, g, b, a);
    }

    // Apply alpha opacity to a color
    function transparentize(col, alphaVal) {
        return Qt.rgba(col.r, col.g, col.b, alphaVal);
    }

    // Solve composite color against base layer
    function solveOverlay(base, overlay, opacity) {
        let r = base.r * (1 - opacity) + overlay.r * opacity;
        let g = base.g * (1 - opacity) + overlay.g * opacity;
        let b = base.b * (1 - opacity) + overlay.b * opacity;
        return Qt.rgba(r, g, b, 1.0);
    }
}
