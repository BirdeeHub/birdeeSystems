import Quickshell
import QtQuick
import Quickshell.I3
import NixInfo

Row {
    required property var screen
    spacing: NixInfo.bar.workspaces.spacing

    Repeater {
        model: I3.workspaces

        Rectangle {
            required property var modelData
            width: NixInfo.bar.workspaces.width
            height: NixInfo.bar.height * (NixInfo.bar.workspaces.heightPercent / 100)

            visible: modelData.monitor === I3.monitorFor(screen)
            color: modelData.focused ? NixInfo.colors.alert : modelData.active ? NixInfo.colors.light : NixInfo.colors.medium

            Text {
                anchors.centerIn: parent
                text: modelData.number
                // text: modelData.name
                color: modelData.focused ? NixInfo.colors.dark : NixInfo.colors.lightest
                font.pixelSize: NixInfo.bar.fontSize
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
