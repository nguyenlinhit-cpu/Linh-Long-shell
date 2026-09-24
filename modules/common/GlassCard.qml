import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root

    // Elevation Level: 0, 1, 2, 3, 4
    property int elevation: 1
    property bool interactive: false
    property bool hovered: interactive && mouseArea.containsMouse
    property bool pressed: interactive && mouseArea.pressed

    // Background selection based on elevation
    color: {
        let base = Theme.palette.layer1;
        if (elevation === 0) base = Theme.palette.layer0;
        else if (elevation === 1) base = Theme.palette.layer1;
        else if (elevation === 2) base = Theme.palette.layer2;
        else if (elevation === 3) base = Theme.palette.layer3;
        else if (elevation === 4) base = Theme.palette.layer4;

        if (hovered) base = Qt.lighter(base, 1.12);
        return ColorResolver.transparentize(base, Theme.cardAlpha);
    }

    radius: Theme.radiusMedium

    // Subtle glass border
    border.width: 1
    border.color: hovered ? Qt.lighter(Theme.palette.glassBorder, 1.3) : Theme.palette.glassBorder

    // Smooth hover transition
    Behavior on color {
        ColorAnimation { duration: Motion.durationShort4; easing.type: Easing.OutCubic }
    }
    Behavior on border.color {
        ColorAnimation { duration: Motion.durationShort4; easing.type: Easing.OutCubic }
    }

    // Inner top highlight line for glassmorphic depth
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: 1
        radius: root.radius
        color: Theme.palette.glassHighlight
    }

    signal clicked()

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
