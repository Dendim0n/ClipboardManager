import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        MainApplication.shared.start()
        GlobalHotKey.shared.handler = { MainApplication.shared.openClipPopover() }
    }
}
