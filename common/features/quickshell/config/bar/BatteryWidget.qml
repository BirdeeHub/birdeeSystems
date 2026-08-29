import Quickshell
import Quickshell.Services.UPower
import QtQuick
import "../config.js" as Config

Rectangle {
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
    Rectangle {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        property real batRatio: UPower.displayDevice.energy / UPower.displayDevice.energyCapacity

        width: parent.width * batRatio
        height: parent.height

        color: batRatio > (Config.bar.battery.warnPercent / 100) ? Config.colors.good : batRatio > (Config.bar.battery.critPercent / 100) ? Config.colors.warn : Config.colors.alert
    }
    Text {
        anchors.centerIn: parent
        font.pixelSize: Config.bar.fontSize
        color: Config.colors.black
        text: {
            let time = UPower.displayDevice.timeToEmpty
            if (time > 0) return formatTime(time)
            let chargeTime = UPower.displayDevice.timeToFull
            if (chargeTime > 0) return "⚡" + formatTime(chargeTime)
            return "⚡"
        }
    }
}
