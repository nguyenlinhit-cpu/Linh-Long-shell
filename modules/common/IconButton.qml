import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property bool checked: false
    property bool checkable: false
    property string tooltip: ""
    property real iconSize: 18

    implicitWidth: 38
    implicitHeight: 38
    radius: Theme.radiusMedium

    color: {
        if (checked) return Theme.palette.primary;
        if (mouseArea.pressed) return Theme.palette.layer3;
        if (mouseArea.containsMouse) return Theme.palette.layer2;
        return "transparent";
    }

    border.width: checked ? 0 : 1
    border.color: mouseArea.containsMouse ? Theme.palette.glassBorder : "transparent"

    Behavior on color {
        ColorAnimation { duration: Motion.durationShort3; easing.type: Easing.OutCubic }
    }

    scale: mouseArea.pressed ? 0.94 : (mouseArea.containsMouse ? 1.04 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutCubic }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon.length > 0 ? root.icon : root.text
        font.family: Theme.fontFamily
        font.pixelSize: root.iconSize
        color: root.checked ? Theme.palette.colOnPrimary : Theme.palette.colOnSurface
    }

    signal clicked()

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.checkable) root.checked = !root.checked;
            root.clicked();
        }
    }
}
