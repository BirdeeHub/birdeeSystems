import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

import "config.js" as Config

Scope {
    id: root
    NotificationServer {
        id: server
        actionsSupported: true
        imageSupported: true
        bodyMarkupSupported: true
        onNotification: n => n.tracked = true
    }
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: notificationAnchor
                required property var modelData
                screen: modelData
                anchors.top: true
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                aboveWindows: false
                implicitHeight: 0

                Instantiator {
                    id: notificationFactory
                    model: server.trackedNotifications
                    onObjectAdded: (idx, obj) => obj.stackIndex = idx
                    onObjectRemoved: (idx, obj) => {
                        // Re-index the remaining popups
                        for (let i = 0; i < count; ++i) {
                            let popup = objectAt(i)
                            if (popup) popup.stackIndex = i
                        }
                    }
                    function dismissAll() {
                        for (let i = count - 1; i >= 0; --i) {
                            const popup = objectAt(i)
                            if (popup) popup.modelData.dismiss()
                        }
                    }
                    delegate: PopupWindow {
                        id: popup

                        required property var modelData
                        property int stackIndex: 0

                        anchor.window: notificationAnchor
                        anchor.rect.x: notificationAnchor.width - popup.width
                        anchor.rect.y: (popup.height + 4) * stackIndex

                        implicitWidth: 380
                        implicitHeight: Math.max(60, layout.implicitHeight + 20)
                        color: "transparent"
                        visible: true

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.MiddleButton) {
                                    notificationFactory.dismissAll()
                                } else {
                                    popup.modelData.dismiss()
                                }
                            }
                        }
                        Timer {
                            running: popup.modelData.urgency !== NotificationUrgency.Critical
                            interval: Config.notify.timeout
                            onTriggered: popup.modelData.dismiss()
                        }

                        Rectangle {
                            id: card
                            anchors.fill: parent
                            radius: 8
                            color: Config.colors.dark
                            border.width: 2
                            border.color: popup.modelData.urgency === NotificationUrgency.Critical ? Config.colors.alert : Config.colors.bright

                            RowLayout {
                                id: layout
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Image {
                                    Layout.preferredHeight: 36
                                    Layout.preferredWidth: 36
                                    Layout.alignment: Qt.AlignTop
                                    fillMode: Image.PreserveAspectFit
                                    visible: source.toString() !== ""
                                    source: popup.modelData.image ?? popup.modelData.appIcon ?? ""
                                }
                                ColumnLayout {
                                    id: content
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: popup.modelData.summary ?? ""
                                        color: Config.colors.bright
                                        font.pixelSize: Config.notify.fontSize
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        visible: text !== ""
                                        text: popup.modelData.body ?? ""
                                        color: Config.colors.bright
                                        font.pixelSize: Config.notify.fontSize - 1
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
