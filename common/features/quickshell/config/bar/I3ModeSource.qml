import Quickshell
import Quickshell.Io

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

Process {
    required property bool isSway
    id: modeEvents
    command: [ isSway ? "swaymsg" : "i3-msg", "-t", "subscribe", "-m", "[\"mode\"]" ]
    running: true
    signal read(var data)
    stdout: SplitParser {
        onRead: data => {
            modeEvents.read(JSON.parse(data).change)
        }
    }
}
