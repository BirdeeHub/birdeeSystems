import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import Quickshell.I3

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
                exclusionMode: ExclusionMode.Ignore
                screen: modelData
                implicitHeight: 15
                color: "#1a1b26"
                anchors {
                    top: false
                    bottom: true
                    left: true
                    right: true
                }

                Item {
                    anchors.fill: parent

                    // LEFT
                    Row {
                        id: leftSection

                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: 4

                        Repeater {
                            model: I3.workspaces

                            Rectangle {
                                width: 20
                                height: 14

                                visible: modelData.monitor === I3.monitorFor(screen)
                                color: modelData.focused ? "#BA02F2" : modelData.active ? "#047180" : "#3e4452"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.number
                                    // text: modelData.name
                                    color: modelData.focused ? "#292F34" : "white"
                                    font.pixelSize: 11
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: modelData.activate()
                                }
                            }
                        }
                    }

                    // MIDDLE
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
                            leftPadding: 8
                            rightPadding: 8
                            color: "white"
                            font.pixelSize: 11
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
                                    leftPadding: 8
                                    rightPadding: 8

                                    color: modelData.color ?? "white"
                                    font.pixelSize: 11
                                    text: modelData.full_text
                                }
                            }
                        }
                    }

                    // RIGHT
                    Row {
                        id: rightSection

                        anchors {
                            right: batteryDisplay.left
                            verticalCenter: parent.verticalCenter
                            rightMargin: 4
                        }

                        spacing: 8

                        Repeater {
                            model: SystemTray.items

                            delegate: Item {
                                required property var modelData
                                width: 14
                                height: 14
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
                        width: 50
                        height: 14
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        color: "#80a0ff"
                        Rectangle {
                            id: batteryFill

                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }

                            property real batRatio: UPower.displayDevice.energy / UPower.displayDevice.energyCapacity

                            width: parent.width * batRatio
                            height: parent.height

                            color: batRatio > 0.7 ? "#9ECE6A" : batRatio > 0.3 ? "#F2D674" : "#BA02F2"

                            Text {
                                anchors.centerIn: batteryDisplay
                                font.pixelSize: 11
                                color: "black"
                                text: {
                                    let time = UPower.displayDevice.timeToEmpty

                                    if (time > 0)
                                        return formatTime(time)

                                    let chargeTime = UPower.displayDevice.timeToFull

                                    if (chargeTime > 0)
                                        return "⚡" + formatTime(chargeTime)

                                    return "⚡"
                                }
                            }
                        }
                    }

                }
            }
        }
    }
}
