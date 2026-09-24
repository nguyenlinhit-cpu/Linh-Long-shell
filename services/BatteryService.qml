pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    // Native UPower Battery Device State
    readonly property bool hasBattery: UPower.displayDevice?.isBattery ?? false
    readonly property real percentage: UPower.displayDevice?.percentage ?? 100.0
    readonly property int percentageInt: Math.round(percentage)
    readonly property var chargeState: UPower.displayDevice?.state
    readonly property bool isCharging: chargeState === UPowerDeviceState.Charging
    readonly property bool isFullyCharged: chargeState === UPowerDeviceState.FullyCharged
    readonly property bool isCritical: hasBattery && percentage < 15.0 && !isCharging

    // Battery Icon Resolver based on percentage and charging state
    readonly property string iconName: {
        if (!hasBattery) return "battery-missing";
        if (isCharging) return "battery-charging";
        if (percentageInt >= 90) return "battery-100";
        if (percentageInt >= 70) return "battery-80";
        if (percentageInt >= 50) return "battery-60";
        if (percentageInt >= 30) return "battery-40";
        if (percentageInt >= 15) return "battery-20";
        return "battery-caution";
    }

    // Power Profile Management
    property string activePowerProfile: "balanced" // "performance" | "balanced" | "power-saver"

    function setPowerProfile(profile) {
        root.activePowerProfile = profile;
    }
}
