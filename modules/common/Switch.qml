import QtQuick
import "../../theme"

Rectangle {
    id: root

    property bool checked: false
    signal toggled(bool newState)

    implicitWidth: 48
    implicitHeight: 28
    radius: height / 2

    color: checked ? Theme.palette.primary : Theme.palette.layer2
    border.width: 1
    border.color: checked ? Theme.palette.primary : Theme.palette.outline

    Behavior on color {
        ColorAnimation { duration: Motion.durationShort3; easing.type: Easing.OutCubic }
    }

    // Moving circular thumb
    Rectangle {
        id: thumb
        width: root.height - 8
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? root.width - width - 4 : 4

        color: root.checked ? Theme.palette.colOnPrimary : Theme.palette.colOnSurfaceVariant

        Behavior on x {
            NumberAnimation { duration: Motion.durationShort4; easing.type: Easing.OutBack }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
