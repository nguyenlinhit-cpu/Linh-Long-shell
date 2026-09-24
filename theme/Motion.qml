pragma Singleton
import QtQuick

QtObject {
    id: root

    // Duration tokens (ms)
    readonly property int durationShort1: 50
    readonly property int durationShort2: 100
    readonly property int durationShort3: 150
    readonly property int durationShort4: 200
    readonly property int durationMedium1: 250
    readonly property int durationMedium2: 300
    readonly property int durationMedium3: 350
    readonly property int durationMedium4: 400
    readonly property int durationLong1: 450
    readonly property int durationLong2: 500
    readonly property int durationLong3: 550
    readonly property int durationLong4: 600

    // Standard Material Motion curves
    // Emphasized Easing (for entrances, expanding cards)
    readonly property list<real> emphasized: [0.2, 0.0, 0.0, 1.0]
    readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1.0]
    readonly property list<real> emphasizedAccel: [0.3, 0.0, 0.8, 0.15]

    // Standard Easing (for basic element moves)
    readonly property list<real> standard: [0.2, 0.0, 0.0, 1.0]
    readonly property list<real> standardDecel: [0.0, 0.0, 0.2, 1.0]
    readonly property list<real> standardAccel: [0.4, 0.0, 1.0, 1.0]

    // Fluid spring simulation tokens
    readonly property real springDamping: 0.75
    readonly property real springMass: 1.0
    readonly property real springStiffness: 160.0
}
