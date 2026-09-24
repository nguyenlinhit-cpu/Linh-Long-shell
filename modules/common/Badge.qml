import QtQuick
import "../../theme"

Rectangle {
    id: root

    property string text: ""
    property string variant: "primary" // "primary" | "secondary" | "error" | "surface"

    property color badgeColor: {
        if (variant === "secondary") return Theme.palette.secondaryContainer;
        if (variant === "error") return Theme.palette.errorContainer;
        if (variant === "surface") return Theme.palette.surfaceContainer;
        return Theme.palette.primaryContainer;
    }

    property color textColor: {
        if (variant === "secondary") return Theme.palette.colOnSecondaryContainer;
        if (variant === "error") return Theme.palette.colOnErrorContainer;
        if (variant === "surface") return Theme.palette.colOnSurface;
        return Theme.palette.colOnPrimaryContainer;
    }

    implicitWidth: label.implicitWidth + 14
    implicitHeight: 22
    radius: height / 2

    color: badgeColor

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeCaption
        font.weight: Font.DemiBold
        color: root.textColor
    }
}
