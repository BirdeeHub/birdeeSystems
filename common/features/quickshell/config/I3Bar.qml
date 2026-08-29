import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import Quickshell.I3
import "config.js" as Config

Scope {
    required property var i3status
    required property bool isSway
    id: root

    property var statusInfo: []
    Process {
        id: statusCmd
        command: [i3status]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.statusInfo = JSON.parse(data.slice(1))
                } catch (e) {
                    root.statusInfo = []
                }
            }
        }
    }

    property string i3Mode: "default"
    Process {
        id: modeEvents
        command: [ isSway ? "swaymsg" : "i3-msg", "-t", "subscribe", "-m", "[\"mode\"]" ]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.i3Mode = JSON.parse(data).change
            }
        }
    }

    function formatTime(seconds) {
        if (seconds <= 0) return ""
        let minutes = Math.floor(seconds / 60)
        let hours = Math.floor(minutes / 60)
        minutes = minutes % 60
        if (hours > 0) return hours + "h " + minutes + "m"
        return minutes + "m"
    }

    // // NOTE: does not subscribe to mode events T.T
    // Connections {
    //     target: I3
    //     function onRawEvent(event) {
    //         console.log("RAW:", event.type, event.data)
    //         if (event.type !== "mode")
    //             return
    //         const data = JSON.parse(event.data)
    //         root.i3Mode = data.change
    //     }
    // }

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

                    // WORKSPACES
                    Row {
                        id: leftSection

                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: Config.bar.workspaces.spacing

                        Repeater {
                            model: I3.workspaces

                            Rectangle {
                                width: Config.bar.workspaces.width
                                height: Config.bar.height * (Config.bar.workspaces.heightPercent / 100)

                                visible: modelData.monitor === I3.monitorFor(screen)
                                color: modelData.focused ? Config.colors.alert : modelData.active ? Config.colors.light : Config.colors.medium

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.number
                                    // text: modelData.name
                                    color: modelData.focused ? Config.colors.dark : Config.colors.white
                                    font.pixelSize: Config.bar.fontSize
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: modelData.activate()
                                }
                            }
                        }
                    }

                    // STATS
                    Item {
                        id: status
                        anchors {
                            left: leftSection.right
                            right: rightSection.left
                            verticalCenter: parent.verticalCenter
                        }
                        Text {
                            visible: root.i3Mode !== "default"
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                            leftPadding: Config.bar.stats.leftPadding
                            rightPadding: Config.bar.stats.rightPadding
                            color: Config.colors.white
                            font.pixelSize: Config.bar.fontSize
                            text: root.i3Mode
                        }
                        Row {
                            visible: root.i3Mode === "default"
                            anchors.centerIn: parent
                            Repeater {
                                model: root.statusInfo
                                Text {
                                    required property var modelData
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideMiddle
                                    leftPadding: Config.bar.stats.leftPadding
                                    rightPadding: Config.bar.stats.rightPadding

                                    color: modelData.color ?? Config.colors.white
                                    font.pixelSize: Config.bar.fontSize
                                    text: modelData.full_text
                                }
                            }
                        }
                    }

                    // TRAY
                    Row {
                        id: rightSection

                        anchors {
                            right: batteryDisplay.left
                            verticalCenter: parent.verticalCenter
                            rightMargin: Config.bar.tray.rightMargin
                        }

                        spacing: Config.bar.tray.spacing

                        Repeater {
                            model: SystemTray.items

                            delegate: Item {
                                required property var modelData
                                width: Config.bar.height * (Config.bar.tray.iconPercentOfHeight / 100)
                                height: Config.bar.height * (Config.bar.tray.iconPercentOfHeight / 100)
                                Image {
                                    anchors.fill: parent
                                    source: modelData.icon
                                }
                                QsMenuAnchor {
                                    id: menuAnchor
                                    menu: modelData.menu
                                    anchor {
                                        window: bar
                                        item: parent
                                        gravity: Edges.Bottom
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                    onClicked: mouse => {
                                        // console.log("modelData", JSON.stringify(modelData))
                                        switch (mouse.button) {
                                        case Qt.LeftButton:
                                            if (modelData.hasMenu && modelData.onlyMenu) {
                                                menuAnchor.open()
                                            } else {
                                                modelData.activate()
                                            }
                                            break
                                        case Qt.RightButton:
                                            if (modelData.hasMenu) {
                                                menuAnchor.open()
                                            } else {
                                                modelData.secondaryActivate()
                                            }
                                            break
                                        case Qt.MiddleButton:
                                            if (modelData.hasMenu && modelData.onlyMenu) {
                                                menuAnchor.open()
                                            } else {
                                                modelData.secondaryActivate()
                                            }
                                            break
                                        }
                                    }
                                    onWheel: wheel => {
                                        if (wheel.angleDelta.y !== 0)
                                            modelData.scroll(-wheel.angleDelta.y, false)

                                        if (wheel.angleDelta.x !== 0)
                                            modelData.scroll(wheel.angleDelta.x, true)
                                    }
                                }
                            }
                        }
                    }

                    // BATTERY
                    Rectangle {
                        id: batteryDisplay
                        width: Config.bar.battery.width
                        height: Config.bar.height * (Config.bar.battery.heightPercent / 100)
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        color: Config.colors.bright
                        Rectangle {
                            id: batteryFill

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

                }
            }
        }
    }
}
