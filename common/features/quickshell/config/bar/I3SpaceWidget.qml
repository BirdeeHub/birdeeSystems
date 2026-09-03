import Quickshell
import QtQuick
import Quickshell.I3
import "../config.js" as Config

Row {
    required property var screen
    spacing: Config.bar.workspaces.spacing

    Repeater {
        model: I3.workspaces

        Rectangle {
            required property var modelData
            width: Config.bar.workspaces.width
            height: Config.bar.height * (Config.bar.workspaces.heightPercent / 100)

            visible: modelData.monitor === I3.monitorFor(screen)
            color: modelData.focused ? Config.colors.alert : modelData.active ? Config.colors.light : Config.colors.medium

            Text {
                anchors.centerIn: parent
                text: modelData.number
                // text: modelData.name
                color: modelData.focused ? Config.colors.dark : Config.colors.lightest
                font.pixelSize: Config.bar.fontSize
            }
            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
            }
            // workaround for when they don't appear on the new monitor when I unplug the old one even though they were moved.
            Component.onDestruction: I3.refreshWorkspaces()
        }
    }
}
