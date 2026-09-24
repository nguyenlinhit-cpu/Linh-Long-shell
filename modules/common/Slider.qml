import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
    id: root

    property real value: 0.5
    property real from: 0.0
    property real to: 1.0
    property string icon: ""
    property bool showValueText: true

    implicitWidth: 240
    implicitHeight: 36

    signal valueModified(real newValue)

    RowLayout {
        anchors.fill: parent
        spacing: 10

        // Left Icon
        Text {
            visible: root.icon.length > 0
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: 16
            color: Theme.palette.colOnSurfaceVariant
        }

        // Track & Progress
        Rectangle {
            id: track
            Layout.fillWidth: true
            height: 12
            radius: height / 2
            color: Theme.palette.layer2

            // Active Progress Fill
            Rectangle {
                id: progressFill
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.max(height, Math.min(parent.width, parent.width * ((root.value - root.from) / (root.to - root.from))))
                radius: height / 2
                color: Theme.palette.primary

                Behavior on width {
                    enabled: !dragArea.drag.active
                    NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutCubic }
                }
            }

            // Interactive Drag Area
            MouseArea {
                id: dragArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updateVal(mouseX) {
                    let clamped = Math.max(0, Math.min(track.width, mouseX));
                    let ratio = clamped / track.width;
                    let newVal = root.from + ratio * (root.to - root.from);
                    root.value = newVal;
                    root.valueModified(newVal);
                }

                onPressed: mouse => updateVal(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed) updateVal(mouse.x);
                }
            }
        }

        // Right Percentage / Value Label
        Text {
            visible: root.showValueText
            text: Math.round(((root.value - root.from) / (root.to - root.from)) * 100) + "%"
            font.family: Theme.fontMono
            font.pixelSize: 12
            color: Theme.palette.colOnSurfaceVariant
            Layout.preferredWidth: 36
            horizontalAlignment: Text.AlignRight
        }
    }
}
