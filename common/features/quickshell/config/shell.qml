//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import qs.bar
Scope {
    My3Bar {}
    NotifyDeez {}
    IpcHandler {
        target: "top"
        function quit(): void {
            Qt.quit()
        }
    }
}
