import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import NixInfo

Row {
    spacing: NixInfo.bar.tray.spacing
    Repeater {
        model: SystemTray.items

        delegate: Item {
            required property var modelData
            width: NixInfo.bar.height * (NixInfo.bar.tray.iconPercentOfHeight / 100)
            height: NixInfo.bar.height * (NixInfo.bar.tray.iconPercentOfHeight / 100)
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
