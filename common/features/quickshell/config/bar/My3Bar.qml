import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import QtQuick
import Quickshell.I3
import "../config.js" as Config

Scope {
    required property string i3status
    required property bool isSway
    id: root

    property var statusInfo: []
    SystemStatsSource {
        i3status: root.i3status
        onRead: data => root.statusInfo = data
    }

    property string i3Mode: "default"
    I3ModeSource {
        isSway: root.isSway
        onRead: data => root.i3Mode = data
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: bar
                required property var modelData
                screen: modelData
                implicitHeight: Config.bar.height
                color: Config.colors.darkest
                anchors {
                    top: false
                    bottom: true
                    left: true
                    right: true
                }

                Item {
                    anchors.fill: parent

                    I3SpaceWidget {
                        screen: bar.screen
                        id: leftSection
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    SystemStatsDisplay {
                        anchors {
                            left: leftSection.right
                            right: rightSection.left
                            verticalCenter: parent.verticalCenter
                        }
                        overrideText: root.i3Mode !== "default" ? root.i3Mode : null
                        statusInfo: root.statusInfo
                    }

                    SystemTrayWidget {
                        id: rightSection
                        anchors {
                            right: batteryDisplay.left
                            verticalCenter: parent.verticalCenter
                            rightMargin: Config.bar.tray.rightMargin
                        }
                    }

                    BatteryWidget {
                        id: batteryDisplay
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                    }

                }
            }
        }
    }
}
