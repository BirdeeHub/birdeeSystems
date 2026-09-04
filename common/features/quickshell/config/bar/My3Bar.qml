import Quickshell
import QtQuick
import "../config.js" as Config

Scope {
    id: root
    property var statusInfo: []
    SystemStats.StatsSource {
        onRead: data => root.statusInfo = data
    }
    property string i3Mode: "default"
    SystemStats.I3ModeSource {
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
                color: Config.colors.darker
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

                    SystemStats {
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
