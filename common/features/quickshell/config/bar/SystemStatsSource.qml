import Quickshell
import Quickshell.Io
import QtQuick

Process {
    required property string i3status
    id: i3statusSource
    signal read(var data)
    command: [i3status]
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
