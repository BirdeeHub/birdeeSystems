import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Controls
import "../config.js" as Config

Rectangle {
    id: battery
    function formatTime(seconds) {
        if (seconds <= 0) return ""
        let minutes = Math.floor(seconds / 60)
        let hours = Math.floor(minutes / 60)
        minutes = minutes % 60
        if (hours > 0) return hours + "h " + minutes + "m"
        return minutes + "m"
    }
    width: Config.bar.battery.width
    height: Config.bar.height * (Config.bar.battery.heightPercent / 100)
    color: Config.colors.bright
    property real batRatio: UPower.displayDevice.energy / UPower.displayDevice.energyCapacity
    property int chargeEndThreshold: 0
    property int chargeStartThreshold: 0
    Rectangle {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        width: parent.width * parent.batRatio
        height: parent.height
        color: parent.batRatio > (Config.bar.battery.warnPercent / 100) ? Config.colors.good : parent.batRatio > (Config.bar.battery.critPercent / 100) ? Config.colors.warn : Config.colors.alert
    }
    Text {
        anchors.centerIn: parent
        font.pixelSize: Config.bar.fontSize
        color: Config.colors.darkest
        text: {
            let time = UPower.displayDevice.timeToEmpty
            if (time > 0) return formatTime(time)
            let chargeTime = UPower.displayDevice.timeToFull
            if (chargeTime > 0) return "⚡" + formatTime(chargeTime)
            return "⚡"
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            getThresholdStatus.running = true
            getChargeEndThreshold.running = true
            getChargeStartThreshold.running = true
            batteryPopup.visible = !batteryPopup.visible
        }
    }

    PopupWindow {
        id: batteryPopup
        visible: false

        implicitWidth: popupColumn.width + (popupColumn.anchors.margins * 2)
        implicitHeight: popupColumn.height + (popupColumn.anchors.margins * 2)

        anchor {
            item: battery
            edges: Edges.Top | Edges.Left
            gravity: Edges.Top | Edges.Left
        }

        Rectangle {
            anchors.fill: parent

            color: Config.colors.dark
            border.color: Config.colors.bright
            border.width: 2

            Column {
                id: popupColumn
                anchors {
                    left: parent.left
                    top: parent.top
                    margins: 16
                }
                spacing: 12

                Row {
                    spacing: 20
                    Text {
                        text: "Battery " +
                              Math.round(battery.batRatio * 100) + "%"

                        color: Config.colors.bright
                        font.bold: true
                    }

                    Rectangle {
                        width: 150
                        height: 36
                        color: Config.colors.dark
                        border.color: Config.colors.bright
                        border.width: 2
                        radius: 8

                        Text {
                            anchors.centerIn: parent
                            color: Config.colors.bright

                            text: {
                                switch (PowerProfiles.profile) {
                                case PowerProfile.PowerSaver:
                                    return "Power Saver"
                                case PowerProfile.Balanced:
                                    return "Balanced"
                                case PowerProfile.Performance:
                                    return "Performance"
                                default:
                                    return "Unknown"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                switch (PowerProfiles.profile) {
                                case PowerProfile.PowerSaver:
                                    PowerProfiles.profile = PowerProfile.Balanced
                                    break

                                case PowerProfile.Balanced:
                                    if (PowerProfiles.hasPerformanceProfile)
                                        PowerProfiles.profile = PowerProfile.Performance
                                    else
                                        PowerProfiles.profile = PowerProfile.PowerSaver
                                    break

                                case PowerProfile.Performance:
                                    PowerProfiles.profile = PowerProfile.PowerSaver
                                    break
                                }
                            }
                        }
                    }
                }

                Row {
                    spacing: 8
                    Text {
                        width: 220
                        wrapMode: Text.WordWrap
                        color: Config.colors.bright
                        text: "Enable charge threshold (Start: " + chargeStartThreshold + "%, End: " + chargeEndThreshold + "%)"
                    }
                    Switch {
                        id: thresholdSwitch
                        checked: false
                        onToggled: enableThreshold.running = true
                    }
                }
            }
        }

        Process {
            id: enableThreshold
            command: [
                "busctl",
                "call",
                "org.freedesktop.UPower",
                "/org/freedesktop/UPower/devices/battery_BAT0",
                "org.freedesktop.UPower.Device",
                "EnableChargeThreshold",
                "b",
                (thresholdSwitch.checked ? "true" : "false")
            ]
        }
        Process {
            id: getThresholdStatus
            command: [
                "busctl",
                "get-property",
                "org.freedesktop.UPower",
                "/org/freedesktop/UPower/devices/battery_BAT0",
                "org.freedesktop.UPower.Device",
                "ChargeThresholdEnabled"
            ]
            stdout: SplitParser {
                onRead: data => {
                    // busctl output should look something like:
                    // b true
                    thresholdSwitch.checked = data.trim().endsWith("true")
                }
            }
        }
        Process {
            id: getChargeEndThreshold
            command: [
                "busctl",
                "get-property",
                "org.freedesktop.UPower",
                "/org/freedesktop/UPower/devices/battery_BAT0",
                "org.freedesktop.UPower.Device",
                "ChargeEndThreshold"
            ]
            stdout: SplitParser {
                onRead: data => {
                    // Expected output: "u 80" (or similar)
                    battery.chargeEndThreshold =
                        parseInt(data.trim().split(" ")[1])
                }
            }
        }
        Process {
            id: getChargeStartThreshold
            command: [
                "busctl",
                "get-property",
                "org.freedesktop.UPower",
                "/org/freedesktop/UPower/devices/battery_BAT0",
                "org.freedesktop.UPower.Device",
                "ChargeStartThreshold"
            ]
            stdout: SplitParser {
                onRead: data => {
                    // Expected output: "u 75" (or similar)
                    battery.chargeStartThreshold =
                        parseInt(data.trim().split(" ")[1])
                }
            }
        }
    }
}
