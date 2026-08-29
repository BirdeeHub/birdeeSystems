import Quickshell
import QtQuick
import "../config.js" as Config

Item {
    required property var statusInfo
    required property var overrideText
    Text {
        visible: overrideText !== null
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        leftPadding: Config.bar.stats.leftPadding
        rightPadding: Config.bar.stats.rightPadding
        color: Config.colors.lightest
        font.pixelSize: Config.bar.fontSize
        text: overrideText
    }
    Row {
        visible: overrideText === null
        anchors.centerIn: parent
        Repeater {
            model: statusInfo
            Text {
                required property var modelData
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                leftPadding: Config.bar.stats.leftPadding
                rightPadding: Config.bar.stats.rightPadding

                color: modelData.color ?? Config.colors.lightest
                font.pixelSize: Config.bar.fontSize
                text: modelData.full_text
            }
        }
    }
}
