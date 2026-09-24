import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../common"

PanelWindow {
    id: calendarWindow

    property bool isOpen: ShellService.calendarOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "linh-long-calendar"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: isOpen

    function toggle() {
        ShellService.toggleCalendar();
    }

    onIsOpenChanged: {
        if (isOpen) {
            viewDate = new Date();
        }
    }

    property date currentDate: new Date()
    property date viewDate: new Date()

    // Dismiss on outside click
    MouseArea {
        anchors.fill: parent
        onClicked: ShellService.calendarOpen = false
    }

    GlassCard {
        id: calCard
        anchors.top: parent.top
        anchors.topMargin: ConfigService.barHeight + 16
        anchors.horizontalCenter: parent.horizontalCenter
        width: 360
        height: calendarCol.implicitHeight + 36
        radius: Theme.radiusLarge
        elevation: 4

        // Prevent click bubbling
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: calendarCol
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            // ══════════════════════════════════════════════════════════════
            // DIGITAL CLOCK & DATE HEADER
            // ══════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true
                height: 72
                radius: Theme.radiusMedium
                color: Theme.palette.layer2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: Qt.formatTime(calendarWindow.currentDate, "hh:mm:ss")
                            font.family: Theme.fontMono
                            font.pixelSize: 26
                            font.weight: Font.Bold
                            color: Theme.palette.primary
                        }

                        Text {
                            text: Qt.formatDate(calendarWindow.currentDate, "dddd, MMMM d, yyyy")
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeCaption
                            color: Theme.palette.colOnSurfaceVariant
                        }
                    }

                    IconButton {
                        icon: "󰅖"
                        implicitWidth: 28
                        implicitHeight: 28
                        iconSize: 14
                        onClicked: ShellService.calendarOpen = false
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // MONTH NAVIGATION BAR
            // ══════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true

                IconButton {
                    icon: "󰅁"
                    implicitWidth: 32
                    implicitHeight: 32
                    tooltip: "Previous Month"
                    onClicked: {
                        let d = new Date(calendarWindow.viewDate);
                        d.setMonth(d.getMonth() - 1);
                        calendarWindow.viewDate = d;
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDate(calendarWindow.viewDate, "MMMM yyyy")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle
                    font.weight: Font.Bold
                    color: Theme.palette.colOnSurface
                }

                IconButton {
                    icon: "󰅂"
                    implicitWidth: 32
                    implicitHeight: 32
                    tooltip: "Next Month"
                    onClicked: {
                        let d = new Date(calendarWindow.viewDate);
                        d.setMonth(d.getMonth() + 1);
                        calendarWindow.viewDate = d;
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // DAY OF WEEK LABELS
            // ══════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    delegate: Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeCaption
                        font.weight: Font.Bold
                        color: Theme.palette.outline
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════
            // CALENDAR DAYS MATRIX (6 WEEKS x 7 DAYS)
            // ══════════════════════════════════════════════════════════════
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 6
                columnSpacing: 4

                Repeater {
                    model: calendarWindow.generateMonthDays(calendarWindow.viewDate)
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 34
                        radius: 17
                        color: {
                            if (modelData.isToday) return Theme.palette.primaryContainer;
                            if (dayMouse.containsMouse) return Theme.palette.layer3;
                            return "transparent";
                        }
                        border.width: modelData.isToday ? 1 : 0
                        border.color: Theme.palette.primary

                        Text {
                            anchors.centerIn: parent
                            text: modelData.day
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBody
                            font.weight: modelData.isToday ? Font.Bold : Font.Normal
                            color: {
                                if (modelData.isToday) return Theme.palette.colOnPrimaryContainer;
                                if (!modelData.currentMonth) return Theme.palette.outline;
                                return Theme.palette.colOnSurface;
                            }
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }

            // Jump to Today Button
            IconButton {
                Layout.alignment: Qt.AlignHCenter
                icon: "󰃮"
                text: "Today"
                onClicked: {
                    calendarWindow.viewDate = new Date();
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: calendarWindow.isOpen
        repeat: true
        onTriggered: calendarWindow.currentDate = new Date()
    }

    function generateMonthDays(date) {
        let year = date.getFullYear();
        let month = date.getMonth();
        let now = new Date();

        let firstDay = new Date(year, month, 1);
        let startingDay = (firstDay.getDay() + 6) % 7; // Monday = 0
        let daysInMonth = new Date(year, month + 1, 0).getDate();
        let daysInPrevMonth = new Date(year, month, 0).getDate();

        let days = [];

        // Previous month padding
        for (let i = startingDay - 1; i >= 0; i--) {
            days.push({
                day: daysInPrevMonth - i,
                currentMonth: false,
                isToday: false
            });
        }

        // Current month
        for (let i = 1; i <= daysInMonth; i++) {
            let isToday = (i === now.getDate() && month === now.getMonth() && year === now.getFullYear());
            days.push({
                day: i,
                currentMonth: true,
                isToday: isToday
            });
        }

        // Next month padding to fill 42 cells (6 rows)
        let totalCells = 42;
        let remaining = totalCells - days.length;
        for (let i = 1; i <= remaining; i++) {
            days.push({
                day: i,
                currentMonth: false,
                isToday: false
            });
        }

        return days;
    }
}
