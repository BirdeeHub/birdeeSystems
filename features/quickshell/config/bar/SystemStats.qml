import Quickshell
import Quickshell.Io
import QtQuick
import NixInfo

Item {
    component I3ModeSource: Process {
        id: modeEvents
        command: [ NixInfo.bar.stats.isSway ? "swaymsg" : "i3-msg", "-t", "subscribe", "-m", "[\"mode\"]" ]
        running: true
        signal read(var data)
        stdout: SplitParser {
            onRead: data => {
                modeEvents.read(JSON.parse(data).change)
            }
        }
    }
    component StatsSource: Process {
        id: i3statusSource
        signal read(var data)
        command: [NixInfo.bar.stats.i3status]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let res = null
                try {
                    res = JSON.parse(data.slice(1))
                } catch (e) {
                    res = []
                }
                i3statusSource.read(res)
            }
        }
    }
    required property var statusInfo
    required property var overrideText
    Text {
        visible: overrideText !== null
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        leftPadding: NixInfo.bar.stats.leftPadding
        rightPadding: NixInfo.bar.stats.rightPadding
        color: NixInfo.colors.lightest
        font.pixelSize: NixInfo.bar.fontSize
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
                leftPadding: NixInfo.bar.stats.leftPadding
                rightPadding: NixInfo.bar.stats.rightPadding

                color: modelData.color ?? NixInfo.colors.lightest
                font.pixelSize: NixInfo.bar.fontSize
                text: modelData.full_text
            }
        }
    }
}
